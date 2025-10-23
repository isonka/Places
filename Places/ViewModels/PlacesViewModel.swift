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
    
    private let locationService: LocationServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    var isCustomLocationValid: Bool {
        return latitudeError == nil && longitudeError == nil &&
            !customLatitude.isEmpty && !customLongitude.isEmpty
    }
    
    init(locationService: LocationServiceProtocol) {
        self.locationService = locationService
        setupValidation()
    }
    
    func loadLocations() async {
        isLoading = true
        errorMessage = nil
        do {
            locations = try await locationService.fetchLocations()
            isLoading = false
        } catch let error as NetworkError {
            switch error {
            case .noConnection:
                errorMessage = error.errorDescription
            default:
                errorMessage = error.localizedDescription
            }
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
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
