import Foundation

struct AppDependencies {
    let connectivityService: ConnectivityServiceProtocol
    let networkManager: NetworkManagerProtocol
    let locationService: LocationServiceProtocol
    let cacheManager: CacheManagerProtocol
    let locationRepository: LocationRepositoryProtocol
    let wikipediaService: WikipediaServiceProtocol
    let logger: LoggingServiceProtocol
    
    static func make() -> AppDependencies {
        let logger = LoggingService.shared
        let connectivityService = ConnectivityService()
        let networkManager = NetworkManager(
            connectivityService: connectivityService
        )
        let locationService = LocationService(
            networkManager: networkManager
        )
        let cacheManager = CacheManager()
        let locationRepository = LocationRepository(
            locationService: locationService,
            cacheManager: cacheManager
        )
        let wikipediaService = WikipediaService()
        
        return AppDependencies(
            connectivityService: connectivityService,
            networkManager: networkManager,
            locationService: locationService,
            cacheManager: cacheManager,
            locationRepository: locationRepository,
            wikipediaService: wikipediaService,
            logger: logger
        )
    }
}

