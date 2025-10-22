//
//  NetworkTests.swift
//  PlacesTests
//
//  Created by Onur Karsli on 22/10/2025.
//

import Testing
import Foundation
@testable import Places

class MockConnectivityService: ConnectivityServiceProtocol {
    var isConnected: Bool
    init(isConnected: Bool) {
        self.isConnected = isConnected
    }
}

struct MockNetworkManager: NetworkManagerProtocol {
    var mockData: Data?
    var shouldFail: Bool = false
    var connectivityService: ConnectivityServiceProtocol = MockConnectivityService(isConnected: true)
    func fetch<T: Decodable>(from urlString: String, method: HTTPMethod = .GET, headers: [String: String]? = nil, body: Data? = nil) async throws -> T {
        if !connectivityService.isConnected {
            throw NetworkError.noConnection
        }
        if shouldFail {
            throw NetworkError.requestFailed(URLError(.badServerResponse))
        }
        guard let data = mockData else {
            throw NetworkError.badURL
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
}

struct NetworkTests {
    
    @Test func testNetworkManagerNoConnection() async throws {
        let mockManager = MockNetworkManager(mockData: nil, connectivityService: MockConnectivityService(isConnected: false))
        do {
            
            let _: LocationsResponse = try await mockManager.fetch(from: "http://test", method: .GET, headers: nil, body: nil)
            #expect(Bool(false), "Should throw NetworkError.noConnection")
        } catch let error as NetworkError {
            #expect(error == .noConnection)
        } catch {
            #expect(Bool(false), "Unexpected error type")
        }
    }

    @Test func testNetworkManagerSuccess() async throws {
        let json = """
        {"locations": [{"name": "Test Place", "lat": 41.2, "long": 29.0}]}
        """.data(using: .utf8)!
        let mockManager = MockNetworkManager(mockData: json, connectivityService: MockConnectivityService(isConnected: true))
        let response: LocationsResponse = try await mockManager.fetch(from: "http://test", method: .GET, headers: nil, body: nil)
        let locations = response.locations
        #expect(locations.count == 1)
        #expect(locations.first?.name == "Test Place")
    }

    @Test func testNetworkManagerDecodingFailure() async throws {
        let invalidJson = "{invalid}".data(using: .utf8)!
        let mockManager = MockNetworkManager(mockData: invalidJson, connectivityService: MockConnectivityService(isConnected: true))
        do {
            let _: LocationsResponse = try await mockManager.fetch(from: "http://test", method: .GET, headers: nil, body: nil)
            #expect(Bool(false), "Should throw NetworkError.decodingFailed")
        } catch let error as NetworkError {
            // Only compare the case, not the associated value
            #expect({
                if case .decodingFailed = error { return true }
                return false
            }(), "Should throw decodingFailed error")
        } catch {
            #expect(Bool(false), "Unexpected error type")
        }
    }

    @Test func testNetworkManagerBadURL() async throws {
        let mockManager = MockNetworkManager(mockData: nil, connectivityService: MockConnectivityService(isConnected: true))
        do {
            let _: LocationsResponse = try await mockManager.fetch(from: "not a url", method: .GET, headers: nil, body: nil)
            #expect(Bool(false), "Should throw NetworkError.badURL")
        } catch let error as NetworkError {
            #expect(error == .badURL)
        } catch {
            #expect(Bool(false), "Unexpected error type")
        }
    }

    @Test func testConnectivityServiceStatus() {
        let connected = MockConnectivityService(isConnected: true)
        let disconnected = MockConnectivityService(isConnected: false)
        #expect(connected.isConnected)
        #expect(!disconnected.isConnected)
    }
}
