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
    
    private let locationService: LocationServiceProtocol
    
    init(locationService: LocationServiceProtocol) {
        self.locationService = locationService
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
}
