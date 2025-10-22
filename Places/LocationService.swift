import Foundation

struct LocationsResponse: Codable {
    let locations: [Location]
}

class LocationService {
    static let shared = LocationService()
    private let urlString = "https://raw.githubusercontent.com/abnamrocoesd/assignment-ios/main/locations.json"

    func fetchLocations() async throws -> [Location] {
        do {
            let data = try await NetworkManager.shared.fetchData(from: urlString)
            let response = try JSONDecoder().decode(LocationsResponse.self, from: data)
            return response.locations
        } catch {
            throw error
        }
    }
}
