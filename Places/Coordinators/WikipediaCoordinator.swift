import UIKit
import SwiftUI
import Combine

class WikipediaCoordinator: ObservableObject {
    @Published var wikipediaError: UserFacingError? = nil
    private let logger: LoggingServiceProtocol
    
    init(logger: LoggingServiceProtocol = LoggingService.shared) {
        self.logger = logger
        logger.debug("WikipediaCoordinator initialized")
    }
    
    func openWikipedia(latitude: Double, longitude: Double) {
        logger.info("Attempting to open Wikipedia for coordinates: (\(latitude), \(longitude))")
        
        let urlString = "wikipedia://places?location=\(latitude),\(longitude)"
        guard let url = URL(string: urlString) else {
            logger.error("Invalid Wikipedia URL: \(urlString)")
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            logger.debug("Wikipedia app is installed, opening URL")
            UIApplication.shared.open(url) { success in
                if success {
                    self.logger.info("Successfully opened Wikipedia app")
                } else {
                    self.logger.error("Failed to open Wikipedia app")
                }
            }
        } else {
            logger.warning("Wikipedia app not installed")
            wikipediaError = .wikipediaNotInstalled { [weak self] in
                self?.openAppStore()
            }
        }
    }
    
    private func openAppStore() {
        logger.info("Opening App Store for Wikipedia app")
        let appStoreURL = "https://apps.apple.com/app/wikipedia/id324715238"
        if let url = URL(string: appStoreURL) {
            UIApplication.shared.open(url)
        }
    }
    
    func openCustomLocation(latitude: String, longitude: String) {
        logger.debug("Validating custom location: (\(latitude), \(longitude))")
        
        guard let lat = Double(latitude), let lon = Double(longitude),
              (-90...90).contains(lat), (-180...180).contains(lon) else {
            logger.warning("Invalid custom location coordinates")
            return
        }
        
        logger.info("Custom location validated, opening Wikipedia")
        openWikipedia(latitude: lat, longitude: lon)
    }
}
