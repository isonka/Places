import XCTest
@testable import Places

final class LocationRepositoryTests: XCTestCase {
    var repository: LocationRepository!
    var mockLocationService: MockLocationService!
    var mockCacheManager: MockCacheManager!
    
    override func setUp() {
        super.setUp()
        mockLocationService = MockLocationService()
        mockCacheManager = MockCacheManager()
        repository = LocationRepository(locationService: mockLocationService, cacheManager: mockCacheManager)
    }
    
    override func tearDown() {
        repository = nil
        mockLocationService = nil
        mockCacheManager = nil
        super.tearDown()
    }
    
    func testFetchLocationsSuccess() async {
        let expectedLocations = [
            Location(name: "Amsterdam", lat: 52.3676, long: 4.9041),
            Location(name: "Rotterdam", lat: 51.9225, long: 4.47917)
        ]
        mockLocationService.result = expectedLocations
        let result = await repository.fetchLocations()
        switch result {
        case .success(let locations):
            XCTAssertEqual(locations.count, 2)
            XCTAssertEqual(locations[0].name, "Amsterdam")
            XCTAssertEqual(locations[1].name, "Rotterdam")
        case .failureWithCache, .failure:
            XCTFail("Expected success, got failure")
        }
    }
    
    func testFetchLocationsSuccessSavesToCache() async {
        let expectedLocations = [Location(name: "Test", lat: 1.0, long: 2.0)]
        mockLocationService.result = expectedLocations        
        _ = await repository.fetchLocations()
        XCTAssertTrue(mockCacheManager.saveCalled)
        XCTAssertEqual(mockCacheManager.savedKey, "Locations")
        XCTAssertEqual(mockCacheManager.savedLocations?.count, 1)
        XCTAssertEqual(mockCacheManager.savedLocations?.first?.name, "Test")
    }
    
    func testFetchLocationsFailureWithCache() async {
        let cachedLocations = [Location(name: "Cached Location", lat: 10.0, long: 20.0)]
        mockLocationService.errorToThrow = NetworkError.noConnection
        mockCacheManager.cachedLocations = cachedLocations
        let result = await repository.fetchLocations()
        switch result {
        case .failureWithCache(let error, let cached):
            XCTAssertEqual(cached.count, 1)
            XCTAssertEqual(cached.first?.name, "Cached Location")
            XCTAssertTrue(error is NetworkError)
            if let networkError = error as? NetworkError {
                XCTAssertEqual(networkError, .noConnection)
            }
        case .success, .failure:
            XCTFail("Expected failureWithCache, got different result")
        }
    }
    
    func testFetchLocationsFailureWithCacheLoadsFromCache() async {
        let cachedLocations = [Location(name: "Cached", lat: 5.0, long: 10.0)]
        mockLocationService.errorToThrow = NetworkError.requestFailed(NSError(domain: "test", code: 500))
        mockCacheManager.cachedLocations = cachedLocations
        _ = await repository.fetchLocations()
        XCTAssertTrue(mockCacheManager.loadCalled)
        XCTAssertEqual(mockCacheManager.loadedKey, "Locations")
    }
    
    func testFetchLocationsFailureWithoutCache() async {
        mockLocationService.errorToThrow = NetworkError.noConnection
        mockCacheManager.cachedLocations = nil
        let result = await repository.fetchLocations()
        switch result {
        case .failure(let error):
            XCTAssertTrue(error is NetworkError)
            if let networkError = error as? NetworkError {
                XCTAssertEqual(networkError, .noConnection)
            }
        case .success, .failureWithCache:
            XCTFail("Expected failure, got different result")
        }
    }
    
    func testFetchLocationsDecodingFailureWithoutCache() async {
        mockLocationService.errorToThrow = NetworkError.decodingFailed(NSError(domain: "test", code: 1))
        mockCacheManager.cachedLocations = nil
        let result = await repository.fetchLocations()
        switch result {
        case .failure(let error):
            XCTAssertTrue(error is NetworkError)
            if case .decodingFailed = error as? NetworkError {
                // Success - correct error type
            } else {
                XCTFail("Expected decodingFailed error")
            }
        case .success, .failureWithCache:
            XCTFail("Expected failure, got different result")
        }
    }
    
    func testFetchLocationsEmptyArraySuccess() async {
        mockLocationService.result = []
        let result = await repository.fetchLocations()
        switch result {
        case .success(let locations):
            XCTAssertTrue(locations.isEmpty)
        case .failureWithCache, .failure:
            XCTFail("Expected success with empty array")
        }
    }
    
    func testFetchLocationsEmptyCachedArray() async {
        mockLocationService.errorToThrow = NetworkError.noConnection
        mockCacheManager.cachedLocations = []
        let result = await repository.fetchLocations()
        switch result {
        case .failureWithCache(_, let cached):
            XCTAssertTrue(cached.isEmpty)
        case .success, .failure:
            XCTFail("Expected failureWithCache with empty cached array")
        }
    }
}
