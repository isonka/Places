import Foundation
import Combine
import SwiftUI

@MainActor
class PlacesViewModel: ObservableObject {
    @Published var locations: [Location] = []
    @Published var isLoading: Bool = true
    @Published var customLatitude: String = ""
    @Published var customLongitude: String = ""
    @Published var errorMessage: String? = nil
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
        errorMessage = nil
        let result = await locationRepository.fetchLocations()
        switch result {
        case .success(let locs):
            locations = locs
            errorMessage = nil
        case .failureWithCache(let error, let cached):
            locations = cached
            errorMessage = "Network error: \(error.localizedDescription) Showing cached data."
        case .failure(let error):
            locations = []
            errorMessage = error.localizedDescription
        }
        isLoading = false
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
        latitudeError = LocationValidator.validateLatitude(value)
    }
    
    private func validateLongitude(_ value: String) {
        longitudeError = LocationValidator.validateLongitude(value)
    }
    
    func validateCustomLocation() {
        validateLatitude(customLatitude)
        validateLongitude(customLongitude)
    }
}
