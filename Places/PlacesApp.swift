import SwiftUI
import Combine

@main
struct PlacesApp: App {
    let dependencies = AppDependencies.make()
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                viewModel: PlacesViewModel(
                    locationRepository: dependencies.locationRepository                    
                )
            )
            .environmentObject(dependencies.wikipediaService as! WikipediaService)
        }
    }
}
