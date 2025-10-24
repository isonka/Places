import Foundation
@testable import Places

final class MockLocationService: LocationServiceProtocol {
    var result: [Location] = []
    var errorToThrow: Error?
    
    func fetchLocations() async throws -> [Location] {
        if let error = errorToThrow {
            throw error
        }
        return result
    }
}
