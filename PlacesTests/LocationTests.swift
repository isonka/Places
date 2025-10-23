import Foundation
import XCTest
@testable import Places

final class LocationTests: XCTestCase {
    var mockManager: MockNetworkManager!
    var service: LocationService!
    var connectivityService: MockConnectivityService!

    override func setUp() {
        super.setUp()
        connectivityService = MockConnectivityService(isConnected: true)
        mockManager = MockNetworkManager(connectivityService: connectivityService)
        service = LocationService(networkManager: mockManager)
    }

    func testLocationServiceSuccess() async throws {
        mockManager.mockData = """
        {"locations": [{"name": "Test Place", "lat": 41.2, "long": 29.0}]}
        """.data(using: .utf8)!
        let locations = try await service.fetchLocations()
        XCTAssertEqual(locations.count, 1)
        XCTAssertEqual(locations.first?.name, "Test Place")
    }
    
    func testLocationServiceOptionalNameSuccess() async throws {
        mockManager.mockData = """
        {"locations": [{"name": "Test Place", "lat": 41.2, "long": 29.0}, {"lat": 41.2, "long": 29.0}]}
        """.data(using: .utf8)!
        let locations = try await service.fetchLocations()
        XCTAssertEqual(locations.count, 2)
        XCTAssertEqual(locations.first?.name, "Test Place")
        XCTAssertNil(locations.last?.name)
    }

    func testNetworkErrorThrow() async throws {
        connectivityService.isConnected = false
        mockManager.mockData = Data()
        do {
            _ = try await service.fetchLocations()
            XCTFail("Should throw NetworkError.noConnection")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .noConnection)
        } catch {
            XCTFail("Unexpected error type")
        }
    }
    
    func testLocationServiceDecodingFailure() async throws {
        mockManager.mockData = "{invalid}".data(using: .utf8)!
        do {
            _ = try await service.fetchLocations()
            XCTFail("Should throw NetworkError.decodingFailed")
        } catch let error as NetworkError {
            if case .decodingFailed = error {
                // success
            } else {
                XCTFail("Should throw decodingFailed error")
            }
        } catch {
            XCTFail("Unexpected error type")
        }
    }

    func testLocationServiceEmptyData() async throws {
        mockManager.mockData = Data()
        do {
            _ = try await service.fetchLocations()
            XCTFail("Should throw NetworkError.decodingFailed")
        } catch let error as NetworkError {
            if case .decodingFailed = error {
                // success
            } else {
                XCTFail("Should throw decodingFailed error for empty data")
            }
        } catch {
            XCTFail("Unexpected error type")
        }
    }

    func testLocationServiceRequestFailure() async throws {
        mockManager.mockData = """
        {"locations": [{"name": "Test Place", "lat": 41.2, "long": 29.0}]}
        """.data(using: .utf8)!
        mockManager.shouldFail = true
        do {
            _ = try await service.fetchLocations()
            XCTFail("Should throw NetworkError.requestFailed")
        } catch let error as NetworkError {
            if case .requestFailed = error {
                // success
            } else {
                XCTFail("Should throw requestFailed error")
            }
        } catch {
            XCTFail("Unexpected error type")
        }
    }

    func testLocationServiceStatusError() async throws {
        mockManager.mockData = """
        {"locations": [{"name": "Test Place", "lat": 41.2, "long": 29.0}]}
        """.data(using: .utf8)!
        mockManager.statusCode = 404
        do {
            _ = try await service.fetchLocations()
            XCTFail("Should throw NetworkError.status error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .status(404))
        } catch {
            XCTFail("Unexpected error type")
        }
    }
}
