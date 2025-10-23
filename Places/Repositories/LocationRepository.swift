import Foundation

enum FetchLocationsResult {
    case success([Location])
    case failureWithCache(error: Error, cached: [Location])
    case failure(error: Error)
}

protocol LocationRepositoryProtocol {
    func fetchLocations() async -> FetchLocationsResult
}

final class LocationRepository: LocationRepositoryProtocol {
    private let locationService: LocationServiceProtocol
    private let cacheManager: CacheManagerProtocol
    
    init(locationService: LocationServiceProtocol, cacheManager: CacheManagerProtocol = CacheManager()) {
        self.locationService = locationService
        self.cacheManager = cacheManager
    }
    
    func fetchLocations() async -> FetchLocationsResult {
        do {
            let locations: [Location] = try await locationService.fetchLocations()
            // Save cache in background
            await cacheManager.save(locations, forKey: "Locations")
            return .success(locations)
        } catch {
            // Load from cache on error
            if let cached: [Location] = await cacheManager.load([Location].self, forKey: "Locations") {
                return .failureWithCache(error: error, cached: cached)
            } else {
                return .failure(error: error)
            }
        }
    }
}
