//
//  ContentView.swift
//  Places
//
//  Created by Onur Karsli on 22/10/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: PlacesViewModel
    @EnvironmentObject var wikipediaCoordinator: WikipediaCoordinator
    
    init(viewModel: PlacesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading locations...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                } else {
                    List {
                        Section(header: Text("Places")) {
                            ForEach(viewModel.locations) { location in
                                Button(action: {
                                    wikipediaCoordinator.openWikipedia(latitude: location.lat, longitude: location.long)
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
                        }
                        Section(header: Text("Custom Location")) {
                            VStack {
                                TextField("Latitude", text: $viewModel.customLatitude)
                                    .keyboardType(.decimalPad)
                                    .accessibilityLabel("Custom latitude input")
                                    .padding()
                                if let latitudeError = viewModel.latitudeError {
                                    Text(latitudeError)
                                        .foregroundColor(.red)
                                        .font(.caption)
                                }
                                TextField("Longitude", text: $viewModel.customLongitude)
                                    .keyboardType(.decimalPad)
                                    .accessibilityLabel("Custom longitude input")
                                    .padding()
                                if let longitudeError = viewModel.longitudeError {
                                    Text(longitudeError)
                                        .foregroundColor(.red)
                                        .font(.caption)
                                }
                                Button("Open Wikipedia for Custom Location") {
                                    if viewModel.isCustomLocationValid {
                                        wikipediaCoordinator.openWikipedia(
                                            latitude: Double(viewModel.customLatitude) ?? 0.0,
                                            longitude: Double(viewModel.customLongitude) ?? 0.0
                                        )
                                    }
                                }
                                .disabled(!viewModel.isCustomLocationValid)
                                .padding()
                                .background(viewModel.isCustomLocationValid ? Color.blue : Color.gray)
                                .cornerRadius(12)
                                .accessibilityLabel("Open Wikipedia for custom location")
                            }
                        }
                    }
                }
            }
            .alert(isPresented: $wikipediaCoordinator.showWikipediaAlert) {
                Alert(title: Text("Wikipedia app not found"), message: Text("Please install the Wikipedia app to view locations."), dismissButton: .default(Text("OK")))
            }
            .navigationTitle("Places")
        }.onAppear() {
            Task {
                await viewModel.loadLocations()
            }
        }
    }
}

#Preview {
    ContentView(viewModel: PlacesViewModel(locationRepository: LocationRepository(locationService: LocationService(networkManager: NetworkManager(connectivityService: ConnectivityService.shared))))) 
}
