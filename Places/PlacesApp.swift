//
//  PlacesApp.swift
//  Places
//
//  Created by Onur Karsli on 22/10/2025.
//

import SwiftUI
import Combine

@main
struct PlacesApp: App {
    let wikipediaCoordinator = WikipediaCoordinator()
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: PlacesViewModel(locationService: LocationService(networkManager: NetworkManager(connectivityService: ConnectivityService.shared))))
                .environmentObject(wikipediaCoordinator)
        }
    }
}
