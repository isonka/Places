import Foundation

enum FetchLocationsResult: Sendable {
    case success([Location])
    case failureWithCache(error: Error, cached: [Location])
    case failure(error: Error)
}

protocol LocationRepositoryProtocol: Sendable {
    func fetchLocations() async -> FetchLocationsResult
}

final class LocationRepository: LocationRepositoryProtocol, @unchecked Sendable {
    private let cacheKey = "Locations"
    private let locationService: LocationServiceProtocol
    private let cacheManager: CacheManagerProtocol
    private let logger: LoggingServiceProtocol = LoggingService.shared
    
    init(
        locationService: LocationServiceProtocol,
        cacheManager: CacheManagerProtocol = CacheManager(),
    ) {
        self.locationService = locationService
        self.cacheManager = cacheManager
        logger.debug("LocationRepository initialized")
    }
    
    func fetchLocations() async -> FetchLocationsResult {
        logger.info("Fetching locations from service")
        
        do {
            let locations = try await locationService.fetchLocations()
            logger.info("Successfully fetched \(locations.count) locations from service")
            
            await cacheManager.save(locations, forKey: cacheKey)
            logger.debug("Locations cached successfully")
            
            return .success(locations)
        } catch {
            logger.warning("Failed to fetch from service: \(error.localizedDescription)")
            
            if let cached = await cacheManager.load([Location].self, forKey: cacheKey) {
                logger.info("Returning \(cached.count) cached locations as fallback")
                return .failureWithCache(error: error, cached: cached)
            } else {
                logger.error("No cached data available, returning failure")
                return .failure(error: error)
            }
        }
    }
}
