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
    private let cacheKey = "Locations"
    private let locationService: LocationServiceProtocol
    private let cacheManager: CacheManagerProtocol
    
    init(locationService: LocationServiceProtocol, cacheManager: CacheManagerProtocol = CacheManager()) {
        self.locationService = locationService
        self.cacheManager = cacheManager
    }
    
    func fetchLocations() async -> FetchLocationsResult {
        do {
            let locations = try await locationService.fetchLocations()
            await cacheManager.save(locations, forKey: cacheKey)
            return .success(locations)
        } catch {
            if let cached = await cacheManager.load([Location].self, forKey: cacheKey) {
                return .failureWithCache(error: error, cached: cached)
            } else {
                return .failure(error: error)
            }
        }
    }
}
