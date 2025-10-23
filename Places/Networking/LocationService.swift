import Foundation

protocol LocationServiceProtocol: Sendable {
    func fetchLocations() async throws -> [Location]
}

struct LocationService: LocationServiceProtocol {
    private let urlString: String
    private let networkManager: NetworkManagerProtocol
    
    init(urlString: String = "https://raw.githubusercontent.com/abnamrocoesd/assignment-ios/main/locations.json", networkManager: NetworkManagerProtocol = NetworkManager(connectivityService: ConnectivityService())) {
        self.networkManager = networkManager
        self.urlString = urlString
    }
    
    func fetchLocations() async throws -> [Location] {
        do {
            let response: LocationsResponse = try await networkManager.fetch(from: urlString, method: .GET, headers: nil, body: nil)
            return response.locations
        } catch {
            throw error
        }
    }
}
