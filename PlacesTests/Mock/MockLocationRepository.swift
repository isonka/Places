import Foundation
@testable import Places

class MockLocationRepository: LocationRepositoryProtocol {
    var fetchLocationsResult: FetchLocationsResult = .success([])
    var fetchLocationsCalled = false
    var fetchLocationsCallCount = 0
    
    func fetchLocations() async -> FetchLocationsResult {
        fetchLocationsCalled = true
        fetchLocationsCallCount += 1
        return fetchLocationsResult
    }
}

