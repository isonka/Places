//
//  NetworkTests.swift
//  PlacesTests
//
//  Created by Onur Karsli on 22/10/2025.
//

import XCTest
@testable import Places

final class NetworkTests: XCTestCase {
    var mockManager: MockNetworkManager!
    var connectivityService: MockConnectivityService!
    
    override func setUp() async throws {
        try await super.setUp()
        connectivityService = MockConnectivityService(isConnected: true)
        mockManager = MockNetworkManager(connectivityService: connectivityService)
    }
    
    func testNetworkManagerNoConnection() async throws {
        connectivityService.isConnected = false
        do {
            let _: LocationsResponse = try await mockManager.fetch(from: "http://test", method: .GET, headers: nil, body: nil)
            XCTFail("Should throw NetworkError.noConnection")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .noConnection)
        } catch {
            XCTFail("Unexpected error type")
        }
    }

    func testNetworkManagerSuccess() async throws {
        mockManager.mockData = """
        {"locations": [{"name": "Test Place", "lat": 41.2, "long": 29.0}]}
        """.data(using: .utf8)!
        let response: LocationsResponse = try await mockManager.fetch(from: "http://test", method: .GET, headers: nil, body: nil)
        let locations = response.locations
        XCTAssertEqual(locations.count, 1)
        XCTAssertEqual(locations.first?.name, "Test Place")
    }

    func testNetworkManagerDecodingFailure() async throws {
        mockManager.mockData = "{invalid}".data(using: .utf8)!
        do {
            let _: LocationsResponse = try await mockManager.fetch(from: "http://test", method: .GET, headers: nil, body: nil)
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

    func testNetworkManagerBadURL() async throws {
        mockManager.mockData = nil
        do {
            let _: LocationsResponse = try await mockManager.fetch(from: "not a url", method: .GET, headers: nil, body: nil)
            XCTFail("Should throw NetworkError.badURL")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .badURL)
        } catch {
            XCTFail("Unexpected error type")
        }
    }

    func testNetworkManagerStatusError() async throws {
        mockManager.statusCode = 404
        do {
            let _: LocationsResponse = try await mockManager.fetch(from: "http://test", method: .GET, headers: nil, body: nil)
            XCTFail("Should throw NetworkError.status error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .status(404))
        } catch {
            XCTFail("Unexpected error type")
        }
    }

    func testConnectivityServiceStatus() {
        XCTAssertTrue(connectivityService.isConnected)
        connectivityService.isConnected = false
        XCTAssertFalse(connectivityService.isConnected)
    }
    
    func testGenericServiceSuccess() async throws {
        let dummyJson = """
        {"value": "Hello"}
        """.data(using: .utf8)!
        mockManager.mockData = dummyJson
        let result: Dummy = try await mockManager.fetch(from: "http://test")
        XCTAssertEqual(result, Dummy(value: "Hello"))
    }
}
