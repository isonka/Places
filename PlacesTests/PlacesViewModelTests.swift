import XCTest
import Foundation
@testable import Places

@MainActor
final class PlacesViewModelTests: XCTestCase {
    var mockService: MockLocationService!
    var mockRepository: MockLocationRepository!
    var viewModel: PlacesViewModel!
    
    override func setUp() {
        super.setUp()
        mockService = MockLocationService()
        mockRepository = MockLocationRepository()
        viewModel = PlacesViewModel(locationRepository: mockRepository)
    }
    
    func testInitialState() {
        XCTAssertTrue(viewModel.locations.isEmpty)
        XCTAssertTrue(viewModel.isLoading)
        XCTAssertNil(viewModel.userFacingError)
        XCTAssertFalse(viewModel.isShowingCachedData)
        XCTAssertEqual(viewModel.customLatitude, "")
        XCTAssertEqual(viewModel.customLongitude, "")
    }
    
    func testLoadLocationsSuccess() async throws {
        let location = Location(name: "Test Place", lat: 41.2, long: 29.0)
        mockRepository.mockResult = .success([location])
        await viewModel.loadLocations()
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.locations.isEmpty)
        XCTAssertEqual(viewModel.locations.first?.name, "Test Place")
        XCTAssertNil(viewModel.userFacingError)
        XCTAssertFalse(viewModel.isShowingCachedData)
        XCTAssertNotNil(viewModel.lastSuccessfulFetch)
    }
    
    func testLoadLocationsNetworkError() async throws {
        let cachedLocation = Location(name: "Cached Place", lat: 41.2, long: 29.0)
        mockRepository.mockResult = .failureWithCache(error: NetworkError.noConnection, cached: [cachedLocation])
        await viewModel.loadLocations()
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.locations.isEmpty)
        XCTAssertNotNil(viewModel.userFacingError)
        XCTAssertTrue(viewModel.isShowingCachedData)
        XCTAssertEqual(viewModel.userFacingError?.title, "Showing Saved Locations")
        XCTAssertEqual(viewModel.userFacingError?.severity, .warning)
    }
    
    func testLoadLocationsOtherError() async throws {
        let cachedLocation = Location(name: "Cached", lat: 41.2, long: 29.0)
        mockRepository.mockResult = .failureWithCache(error: NetworkError.badURL, cached: [cachedLocation])
        await viewModel.loadLocations()
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.locations.isEmpty)
        XCTAssertNotNil(viewModel.userFacingError)
        XCTAssertTrue(viewModel.isShowingCachedData)
    }
    
    func testCustomLocationValidation() {
        viewModel.customLatitude = "abc"
        viewModel.customLongitude = "120.0"
        viewModel.validateCustomLocation()
        XCTAssertEqual(viewModel.latitudeError, "Latitude must be a valid number.")
        XCTAssertNil(viewModel.longitudeError)
        viewModel.customLatitude = "45.0"
        viewModel.customLongitude = "200"
        viewModel.validateCustomLocation()
        XCTAssertNil(viewModel.latitudeError)
        XCTAssertEqual(viewModel.longitudeError, "Longitude must be between -180 and 180.")
    }
    
    func testIsCustomLocationValid() {
        viewModel.customLatitude = "45.0"
        viewModel.customLongitude = "120.0"
        viewModel.validateCustomLocation()
        XCTAssertTrue(viewModel.isCustomLocationValid)
        viewModel.customLatitude = "abc"
        viewModel.validateCustomLocation()
        XCTAssertFalse(viewModel.isCustomLocationValid)
    }
    
    func testLoadLocationsWithEmptyList() async throws {
        mockRepository.mockResult = .success([])
        await viewModel.loadLocations()
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.locations.isEmpty)
        XCTAssertNil(viewModel.userFacingError)
    }
    
    func testLoadLocationsWithNilNames() async throws {
        let locations = [
            Location(name: nil, lat: 41.2, long: 29.0),
            Location(name: "Valid Name", lat: 42.0, long: 30.0)
        ]
        mockRepository.mockResult = .success(locations)
        await viewModel.loadLocations()
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.locations.count, 2)
        XCTAssertNil(viewModel.locations[0].name)
        XCTAssertEqual(viewModel.locations[1].name, "Valid Name")
        XCTAssertNil(viewModel.userFacingError)
    }
    
    func testLoadLocationsWithDuplicates() async throws {
        let locations = [
            Location(name: "Amsterdam", lat: 52.3676, long: 4.9041),
            Location(name: "Amsterdam", lat: 52.3676, long: 4.9041),
            Location(name: "Rotterdam", lat: 51.9225, long: 4.47917)
        ]
        mockRepository.mockResult = .success(locations)
        await viewModel.loadLocations()
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.locations.count, 3)
    }
    
    func testLoadLocationsWithIdenticalCoordinatesDifferentNames() async throws {
        let locations = [
            Location(name: "Location A", lat: 52.3676, long: 4.9041),
            Location(name: "Location B", lat: 52.3676, long: 4.9041)
        ]
        mockRepository.mockResult = .success(locations)
        await viewModel.loadLocations()
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.locations.count, 2)
    }
    
    func testMultipleConcurrentLoadCalls() async throws {
        let locations = [Location(name: "Test", lat: 41.2, long: 29.0)]
        mockRepository.mockResult = .success(locations)
        async let load1: () = viewModel.loadLocations()
        async let load2: () = viewModel.loadLocations()
        async let load3: () = viewModel.loadLocations()
        await load1
        await load2
        await load3
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.locations.count, 1)
    }
    
    func testLoadLocationsAfterPreviousError() async throws {
        mockRepository.mockResult = .failure(error: NetworkError.noConnection)
        await viewModel.loadLocations()
        XCTAssertNotNil(viewModel.userFacingError)
        mockRepository.mockResult = .success([Location(name: "Success", lat: 41.2, long: 29.0)])
        await viewModel.loadLocations()
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.userFacingError)
        XCTAssertEqual(viewModel.locations.count, 1)
    }
    
    func testLoadLocationsVeryLargeList() async throws {
        let largeList = (0..<1000).map { i in
            Location(name: "Location \(i)", lat: Double(i % 180 - 90), long: Double(i % 360 - 180))
        }
        mockRepository.mockResult = .success(largeList)
        await viewModel.loadLocations()
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.locations.count, 1000)
        XCTAssertNil(viewModel.userFacingError)
    }
    
    func testCustomLocationValidationWithEmptyLatitude() {
        viewModel.customLatitude = ""
        viewModel.customLongitude = "120.0"
        viewModel.validateCustomLocation()
        XCTAssertFalse(viewModel.isCustomLocationValid)
    }
    
    func testCustomLocationValidationWithEmptyLongitude() {
        viewModel.customLatitude = "45.0"
        viewModel.customLongitude = ""
        viewModel.validateCustomLocation()
        XCTAssertFalse(viewModel.isCustomLocationValid)
    }
    
    func testCustomLocationValidationWithBothEmpty() {
        viewModel.customLatitude = ""
        viewModel.customLongitude = ""
        viewModel.validateCustomLocation()
        XCTAssertFalse(viewModel.isCustomLocationValid)
    }
    
    func testCustomLocationValidationBoundaryValues() {
        viewModel.customLatitude = "90"
        viewModel.customLongitude = "180"
        viewModel.validateCustomLocation()
        XCTAssertTrue(viewModel.isCustomLocationValid)
        viewModel.customLatitude = "-90"
        viewModel.customLongitude = "-180"
        viewModel.validateCustomLocation()
        XCTAssertTrue(viewModel.isCustomLocationValid)
    }
    
    func testCustomLocationValidationWithWhitespace() {
        viewModel.customLatitude = " 45.0 "
        viewModel.customLongitude = "120.0"
        viewModel.validateCustomLocation()
        XCTAssertTrue(viewModel.isCustomLocationValid)
        XCTAssertNil(viewModel.latitudeError)
    }
    
    func testLocationWithExtremelySmallCoordinates() async throws {
        let locations = [Location(name: "Tiny", lat: 0.0000001, long: -0.0000001)]
        mockRepository.mockResult = .success(locations)
        await viewModel.loadLocations()
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.locations.count, 1)
        XCTAssertEqual(viewModel.locations[0].lat, 0.0000001, accuracy: 0.0000001)
    }
    
    func testLocationWithZeroCoordinates() async throws {
        let locations = [Location(name: "Null Island", lat: 0.0, long: 0.0)]
        mockRepository.mockResult = .success(locations)
        await viewModel.loadLocations()
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.locations.count, 1)
        XCTAssertEqual(viewModel.locations[0].lat, 0.0)
        XCTAssertEqual(viewModel.locations[0].long, 0.0)
    }
    
    func testErrorMessageClearedOnSuccessfulLoad() async throws {
        mockRepository.mockResult = .failure(error: NetworkError.noConnection)
        await viewModel.loadLocations()
        XCTAssertNotNil(viewModel.userFacingError)
        mockRepository.mockResult = .success([Location(name: "Test", lat: 41.2, long: 29.0)])
        await viewModel.loadLocations()
        XCTAssertNil(viewModel.userFacingError)
    }
    
    func testIsLoadingStateTransitions() async throws {
        mockRepository.mockResult = .success([Location(name: "Test", lat: 41.2, long: 29.0)])
        XCTAssertTrue(viewModel.isLoading)
        await viewModel.loadLocations()
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testLocationWithSpecialCharactersInName() async throws {
        let locations = [
            Location(name: "São Paulo", lat: -23.5505, long: -46.6333),
            Location(name: "Zürich", lat: 47.3769, long: 8.5417),
            Location(name: "東京 (Tokyo)", lat: 35.6762, long: 139.6503),
            Location(name: "Москва", lat: 55.7558, long: 37.6173)
        ]
        mockRepository.mockResult = .success(locations)
        await viewModel.loadLocations()
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.locations.count, 4)
        XCTAssertEqual(viewModel.locations[0].name, "São Paulo")
        XCTAssertEqual(viewModel.locations[1].name, "Zürich")
    }
    
    func testLocationWithVeryLongName() async throws {
        let longName = String(repeating: "A", count: 1000)
        let locations = [Location(name: longName, lat: 41.2, long: 29.0)]
        mockRepository.mockResult = .success(locations)
        await viewModel.loadLocations()
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.locations.count, 1)
        XCTAssertEqual(viewModel.locations[0].name?.count, 1000)
    }
    
    func testCustomLocationValidationChangingFromValidToInvalid() {
        viewModel.customLatitude = "45.0"
        viewModel.customLongitude = "120.0"
        viewModel.validateCustomLocation()
        XCTAssertTrue(viewModel.isCustomLocationValid)
        viewModel.customLatitude = "invalid"
        viewModel.validateCustomLocation()
        XCTAssertFalse(viewModel.isCustomLocationValid)
        XCTAssertNotNil(viewModel.latitudeError)
    }
}
