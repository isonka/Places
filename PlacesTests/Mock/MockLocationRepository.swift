import Foundation
@testable import Places

final class MockLocationRepository: LocationRepositoryProtocol, @unchecked Sendable {
    var mockResult: FetchLocationsResult = .success([])
    
    func fetchLocations() async -> FetchLocationsResult {
        return mockResult
    }
    
    func reset() {        
        mockResult = .success([])
    }
}

