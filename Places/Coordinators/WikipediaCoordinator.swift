import UIKit
import SwiftUI
import Combine

class WikipediaCoordinator: ObservableObject {
    @Published var showWikipediaAlert: Bool = false
    
    func openWikipedia(latitude: Double, longitude: Double) {
        let urlString = "wikipedia://places?location=\(latitude),\(longitude)"
        guard let url = URL(string: urlString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            showWikipediaAlert = true
        }
    }
    
    func openCustomLocation(latitude: String, longitude: String) {
        guard let lat = Double(latitude), let lon = Double(longitude),
              (-90...90).contains(lat), (-180...180).contains(lon) else { return }
        openWikipedia(latitude: lat, longitude: lon)
    }
}
