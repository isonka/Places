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
    let wikipediaService = WikipediaService()
    let connectivityService = ConnectivityService()
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                viewModel: PlacesViewModel(
                    locationRepository: LocationRepository(
                        locationService: LocationService(
                            networkManager: NetworkManager(
                                connectivityService: connectivityService
                            )
                        )
                    )
                )
            )
            .environmentObject(wikipediaService)
        }
    }
}
