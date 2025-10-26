import UIKit
import SwiftUI
import Combine

protocol WikipediaServiceProtocol: ObservableObject {
    var wikipediaError: UserFacingError? { get set }
    func openWikipedia(latitude: Double, longitude: Double)
}

class WikipediaService: WikipediaServiceProtocol {
    @Published var wikipediaError: UserFacingError? = nil
    private let logger: LoggingServiceProtocol = LoggingService.shared
    
    init() {        
        logger.debug("WikipediaService initialized")
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
        } else {
            logger.error("Invalid App Store URL: \(appStoreURL)")
        }
    }
}
