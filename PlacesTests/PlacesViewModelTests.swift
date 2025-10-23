import XCTest
import Foundation
@testable import Places

@MainActor
final class PlacesViewModelTests: XCTestCase {
    var mockService: MockLocationService!
    var viewModel: PlacesViewModel!
    
    override func setUp() {
        super.setUp()
        mockService = MockLocationService()
        viewModel = PlacesViewModel(locationRepository: LocationRepository(locationService: mockService))
    }
    
    func testInitialState() {
        XCTAssertTrue(viewModel.locations.isEmpty)
        XCTAssertTrue(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.customLatitude, "")
        XCTAssertEqual(viewModel.customLongitude, "")
    }
    
    func testLoadLocationsSuccess() async throws {
        let location = Location(name: "Test Place", lat: 41.2, long: 29.0)
        mockService.result = [location]
        await viewModel.loadLocations()
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.locations.isEmpty)
        XCTAssertEqual(viewModel.locations.first?.name, "Test Place")
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testLoadLocationsNetworkError() async throws {
        mockService.errorToThrow = NetworkError.noConnection
        await viewModel.loadLocations()
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.locations.isEmpty)
        XCTAssertEqual(viewModel.errorMessage!, "Network error: \(NetworkError.noConnection.localizedDescription) Showing cached data.")
    }
    
    func testLoadLocationsOtherError() async throws {
        mockService.errorToThrow = NetworkError.badURL
        await viewModel.loadLocations()
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.locations.isEmpty)
        XCTAssertEqual(viewModel.errorMessage!, "Network error: \(NetworkError.badURL.localizedDescription) Showing cached data.")
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
}
