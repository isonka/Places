import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: PlacesViewModel
    @EnvironmentObject var wikipediaService: WikipediaService
    private let logger = LoggingService.shared
    
    init(viewModel: PlacesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if let error = viewModel.userFacingError {
                    ErrorBannerView(error: error)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                contentBody
            }
            .animation(.easeInOut, value: viewModel.userFacingError?.id)
            .navigationTitle("Places")
            .sheet(item: $wikipediaService.wikipediaError) { error in
                WikipediaErrorSheet(error: error)
                    .presentationDetents([.medium])
            }
        }
        .onAppear {
            Task {
                await viewModel.loadLocations()
            }
        }
    }
    
    @ViewBuilder
    private var contentBody: some View {
        List {
            locationsSection
            customLocationSection
        }
        .refreshable {
            await viewModel.loadLocations()
        }
    }
    
    private var locationsSection: some View {
        LocationsListView(
            locations: viewModel.locations,
            isLoading: viewModel.isLoading,
            onLocationTap: handleLocationTap
        )
    }
    
    private var customLocationSection: some View {
        CustomLocationView(
            latitude: $viewModel.customLatitude,
            longitude: $viewModel.customLongitude,
            latitudeError: viewModel.latitudeError,
            longitudeError: viewModel.longitudeError,
            isValid: viewModel.isCustomLocationValid,
            onSubmit: handleCustomLocationSubmit
        )
    }
    
    private func handleLocationTap(_ location: Location) {
        wikipediaService.openWikipedia(
            latitude: location.lat,
            longitude: location.long
        )
    }
    
    private func handleCustomLocationSubmit() {
        logger.debug("Custom location submit - Valid: \(viewModel.isCustomLocationValid), Lat: '\(viewModel.customLatitude)', Long: '\(viewModel.customLongitude)'")
        
        guard viewModel.isCustomLocationValid,
              let latitude = Double(viewModel.customLatitude),
              let longitude = Double(viewModel.customLongitude) else {
            logger.warning("Custom location validation failed or couldn't convert to Double")
            return
        }
        
        logger.info("Opening Wikipedia for custom location: (\(latitude), \(longitude))")
        wikipediaService.openWikipedia(
            latitude: latitude,
            longitude: longitude
        )
    }
}

// MARK: - Preview

#Preview {
    ContentView(
        viewModel: PlacesViewModel(
            locationRepository: LocationRepository(
                locationService: LocationService(
                    networkManager: NetworkManager(
                        connectivityService: ConnectivityService()
                    )
                )
            )
        )
    )
    .environmentObject(WikipediaService())
}
