import Foundation
import Combine
import SwiftUI

@MainActor
class PlacesViewModel: ObservableObject {
    @Published var locations: [Location] = []
    @Published var isLoading: Bool = true
    @Published var customLatitude: String = ""
    @Published var customLongitude: String = ""
    @Published var userFacingError: UserFacingError? = nil
    @Published var isShowingCachedData: Bool = false
    @Published var lastSuccessfulFetch: Date? = nil
    @Published var latitudeError: String? = nil
    @Published var longitudeError: String? = nil
    
    private let locationRepository: LocationRepositoryProtocol
    private let logger = LoggingService.shared
    private var cancellables = Set<AnyCancellable>()
    
    var isCustomLocationValid: Bool {
        return latitudeError == nil && longitudeError == nil &&
        !customLatitude.isEmpty && !customLongitude.isEmpty
    }
    
    init(
        locationRepository: LocationRepositoryProtocol
    ) {
        self.locationRepository = locationRepository        
        setupValidation()
        logger.info("PlacesViewModel initialized")
    }
    
    func loadLocations() async {
        logger.info("Starting to load locations")
        isLoading = true
        userFacingError = nil
        isShowingCachedData = false
        
        let result = await locationRepository.fetchLocations()
        
        switch result {
        case .success(let locs):
            logger.info("Successfully loaded \(locs.count) locations")
            locations = locs
            lastSuccessfulFetch = Date()
            
        case .failureWithCache(let error, let cached):
            logger.warning("Network error, using \(cached.count) cached locations: \(error.localizedDescription)")
            locations = cached
            isShowingCachedData = true
            userFacingError = .usingCachedData(lastUpdated: lastSuccessfulFetch)
            
        case .failure(let error):
            logger.error("Failed to load locations, no cache available: \(error.localizedDescription)")
            locations = []
            isShowingCachedData = false
            userFacingError = .from(error) { [weak self] in
                Task { @MainActor in
                    await self?.loadLocations()
                }
            }
        }
        
        isLoading = false
        logger.debug("Loading complete. Is showing cached data: \(isShowingCachedData)")
    }
    
    private func setupValidation() {
        Publishers.Merge(
            $customLatitude.debounce(for: .milliseconds(300), scheduler: RunLoop.main),
            $customLongitude.debounce(for: .milliseconds(300), scheduler: RunLoop.main)
        )
        .sink { [weak self] _ in
            self?.validateCustomLocation()
        }
        .store(in: &cancellables)
    }
    
    func submitCustomLocation() -> (lat: Double, lon: Double)? {
        logger.debug("Custom location submit...")
        
        guard isCustomLocationValid else {
            logger.warning("Validation failed")
            return nil
        }
        
        let lat = Double(customLatitude)!
        let lon = Double(customLongitude)!
        
        logger.info("Validated: (\(lat), \(lon))")
        return (lat, lon)
    }
    
    func validateCustomLocation() {
        latitudeError = LocationValidator.validateLatitude(customLatitude)
        longitudeError = LocationValidator.validateLongitude(customLongitude)
        
        if isCustomLocationValid {
            logger.debug("Custom location validated: (\(customLatitude), \(customLongitude))")
        }
    }
}
