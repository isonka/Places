import Foundation
import Combine
import SwiftUI

@MainActor
class PlacesViewModel: ObservableObject {
    @Published var locations: [Location] = []
    @Published var isLoading: Bool = true
    @Published var showError: Bool = false
    @Published var customLatitude: String = ""
    @Published var customLongitude: String = ""
    @Published var showWikipediaAlert: Bool = false
    @Published var errorMessage: String? = nil
    
    private let locationService: LocationServiceProtocol
    
    init(locationService: LocationServiceProtocol) {
        self.locationService = locationService
    }
    
    func loadLocations() async {
        isLoading = true
        showError = false
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
            showError = true
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            isLoading = false
        }
    }
    
    func openWikipedia(latitude: Double, longitude: Double) {
        let urlString = "wikipedia://places?location=\(latitude),\(longitude)"
        guard let url = URL(string: urlString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            showWikipediaAlert = true
        }
    }
    
    func openCustomLocation() {
        guard let lat = Double(customLatitude), let lon = Double(customLongitude),
              (-90...90).contains(lat), (-180...180).contains(lon) else { return }
        openWikipedia(latitude: lat, longitude: lon)
    }
}
