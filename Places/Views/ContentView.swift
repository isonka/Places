//
//  ContentView.swift
//  Places
//
//  Created by Onur Karsli on 22/10/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: PlacesViewModel
    
    init(viewModel: PlacesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading locations...")
                } else if viewModel.showError {
                    Text("Failed to load locations.")
                        .foregroundColor(.red)
                } else {
                    List {
                        ForEach(viewModel.locations) { location in
                            Button(action: {
                                viewModel.openWikipedia(latitude: location.lat, longitude: location.long)
                            }) {
                                VStack(alignment: .leading) {
                                    if let name = location.name {
                                        Text(name)
                                            .font(.headline)
                                    }
                                    Text("Latitude: \(location.lat), Longitude: \(location.long)")
                                        .font(.subheadline)
                                }
                            }
                            .accessibilityLabel(location.name ?? "Unknown Location")
                            .accessibilityHint("Opens Wikipedia for this location")
                        }
                        Section(header: Text("Custom Location")) {
                            VStack {
                                TextField("Latitude", text: $viewModel.customLatitude)
                                    .keyboardType(.decimalPad)
                                    .accessibilityLabel("Custom latitude input")
                                TextField("Longitude", text: $viewModel.customLongitude)
                                    .keyboardType(.decimalPad)
                                    .accessibilityLabel("Custom longitude input")
                                Button("Open in Wikipedia") {
                                    viewModel.openCustomLocation()
                                }
                                .accessibilityLabel("Open custom location in Wikipedia")
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Places")
            .alert("Wikipedia app is not installed.", isPresented: $viewModel.showWikipediaAlert) {
                Button("OK", role: .cancel) {}
            }
        }.onAppear() {
            Task {
                await viewModel.loadLocations()
            }
        }
    }
}

#Preview {
    ContentView(viewModel: PlacesViewModel(locationService: LocationService(networkManager: NetworkManager( connectivityService: ConnectivityService.shared))))
}
