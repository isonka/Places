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
    private var cancellables = Set<AnyCancellable>()
    
    var isCustomLocationValid: Bool {
        return latitudeError == nil && longitudeError == nil &&
            !customLatitude.isEmpty && !customLongitude.isEmpty
    }
    
    init(locationRepository: LocationRepositoryProtocol) {
        self.locationRepository = locationRepository
        setupValidation()
    }
    
    func loadLocations() async {
        isLoading = true
        userFacingError = nil
        isShowingCachedData = false
        
        let result = await locationRepository.fetchLocations()
        
        switch result {
        case .success(let locs):
            locations = locs
            userFacingError = nil
            isShowingCachedData = false
            lastSuccessfulFetch = Date()
            
        case .failureWithCache(let error, let cached):
            locations = cached
            isShowingCachedData = true
            userFacingError = .usingCachedData(lastUpdated: lastSuccessfulFetch)
                        
            print("⚠️ Network error (showing cache): \(error.localizedDescription)")
            
        case .failure(let error):
            locations = []
            isShowingCachedData = false
            userFacingError = .from(error) { [weak self] in
                Task { @MainActor in
                    await self?.loadLocations()
                }
            }
            
            print("❌ Network error (no cache): \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func retry() async {
        await loadLocations()
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
    
    private func validateLatitude(_ value: String) {
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        if trimmed != value && !value.isEmpty {
            customLatitude = trimmed
        }
        latitudeError = LocationValidator.validateLatitude(trimmed)
    }
    
    private func validateLongitude(_ value: String) {
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        if trimmed != value && !value.isEmpty {
            customLongitude = trimmed
        }
        longitudeError = LocationValidator.validateLongitude(trimmed)
    }
    
    func validateCustomLocation() {
        validateLatitude(customLatitude)
        validateLongitude(customLongitude)
    }
}
