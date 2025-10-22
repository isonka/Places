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
                                TextField("Longitude", text: $viewModel.customLongitude)
                                    .keyboardType(.decimalPad)
                                    .accessibilityLabel("Custom longitude input")
                                    .padding()
                                Button("Open Wikipedia for Custom Location") {
                                    wikipediaCoordinator.openCustomLocation(latitude: viewModel.customLatitude, longitude: viewModel.customLongitude)
                                }
                                .padding()
                                .background(Color.blue)
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
    ContentView(viewModel: PlacesViewModel(locationService: LocationService(networkManager: NetworkManager( connectivityService: ConnectivityService.shared))))
        .environmentObject(WikipediaCoordinator())
}
