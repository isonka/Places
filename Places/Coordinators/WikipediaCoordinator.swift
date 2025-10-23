import UIKit
import SwiftUI
import Combine

class WikipediaCoordinator: ObservableObject {
    @Published var wikipediaError: UserFacingError? = nil
    
    func openWikipedia(latitude: Double, longitude: Double) {
        let urlString = "wikipedia://places?location=\(latitude),\(longitude)"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid Wikipedia URL: \(urlString)")
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url) { success in
                if !success {
                    print("❌ Failed to open Wikipedia app")
                }
            }
        } else {
            wikipediaError = .wikipediaNotInstalled { [weak self] in
                self?.openAppStore()
            }
        }
    }
    
    private func openAppStore() {
        let appStoreURL = "https://apps.apple.com/app/wikipedia/id324715238"
        if let url = URL(string: appStoreURL) {
            UIApplication.shared.open(url)
        }
    }
    
    func openCustomLocation(latitude: String, longitude: String) {
        guard let lat = Double(latitude), let lon = Double(longitude),
              (-90...90).contains(lat), (-180...180).contains(lon) else { return }
        openWikipedia(latitude: lat, longitude: lon)
    }
}
