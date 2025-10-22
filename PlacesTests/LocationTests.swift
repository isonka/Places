//
//  PlacesTests.swift
//  PlacesTests
//
//  Created by Onur Karsli on 22/10/2025.
//

import Testing
import Foundation
@testable import Places

struct LocationTests {
    @Test func testLocationServiceSuccess() async throws {
        let json = """
        {"locations": [{"name": "Test Place", "lat": 41.2, "long": 29.0}]}
        """.data(using: .utf8)!
        let mockManager = MockNetworkManager(mockData: json)
        let service = LocationService(networkManager: mockManager)
        let locations = try await service.fetchLocations()
        #expect(locations.count == 1)
        #expect(locations.first?.name == "Test Place")
    }
    
    @Test func testLocationServiceOptionalNameSuccess() async throws {
        let json = """
        {"locations": [{"name": "Test Place", "lat": 41.2, "long": 29.0}, {"lat": 41.2, "long": 29.0}]}
        """.data(using: .utf8)!
        let mockManager = MockNetworkManager(mockData: json)
        let service = LocationService(networkManager: mockManager)
        let locations = try await service.fetchLocations()
        #expect(locations.count == 2)
        #expect(locations.first?.name == "Test Place")
        #expect(locations.last?.name == nil)
    }

    @Test func testNetworkErrorThrow() async throws {
        let mockManager = MockNetworkManager(mockData: nil, connectivityService: MockConnectivityService(isConnected: false))
        let service = LocationService(networkManager: mockManager)
        do {
            _ = try await service.fetchLocations()
            #expect(Bool(false), "Should throw NetworkError.noConnection")
        } catch let error as NetworkError {
            #expect(error == .noConnection)
        } catch {
            #expect(Bool(false), "Unexpected error type")
        }
    }
    
    @Test func testLocationServiceDecodingFailure() async throws {
        let invalidJson = "{invalid}".data(using: .utf8)!
        let mockManager = MockNetworkManager(mockData: invalidJson)
        let service = LocationService(networkManager: mockManager)
        do {
            _ = try await service.fetchLocations()
            #expect(Bool(false), "Should throw NetworkError.decodingFailed")
        } catch let error as NetworkError {
            #expect({
                if case .decodingFailed = error { return true }
                return false
            }(), "Should throw decodingFailed error")
        } catch {
            #expect(Bool(false), "Unexpected error type")
        }
    }

    @Test func testLocationServiceEmptyData() async throws {
        let mockManager = MockNetworkManager(mockData: Data())
        let service = LocationService(networkManager: mockManager)
        do {
            _ = try await service.fetchLocations()
            #expect(Bool(false), "Should throw NetworkError.decodingFailed")
        } catch let error as NetworkError {
            #expect({
                if case .decodingFailed = error { return true }
                return false
            }(), "Should throw decodingFailed error for empty data")
        } catch {
            #expect(Bool(false), "Unexpected error type")
        }
    }
}
