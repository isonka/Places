import SwiftUI

struct LocationsListView: View {
    let locations: [Location]
    let isLoading: Bool
    let onLocationTap: (Location) -> Void
    
    var body: some View {
        Section(header: Text("Places")) {
            if isLoading && locations.isEmpty {
                LocationsListSkeleton(count: 5)
            } else {
                ForEach(locations) { location in
                    LocationRow(location: location, onTap: onLocationTap)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("With Locations") {
    List {
        LocationsListView(
            locations: [
                Location(name: "Amsterdam", lat: 52.3676, long: 4.9041),
                Location(name: "Rotterdam", lat: 51.9225, long: 4.47917),
                Location(name: nil, lat: 41.0082, long: 28.9784)
            ],
            isLoading: false,
            onLocationTap: { location in
                print("Tapped: \(location.name ?? "Unknown")")
            }
        )
    }
}

#Preview("Loading State") {
    List {
        LocationsListView(
            locations: [],
            isLoading: true,
            onLocationTap: { _ in }
        )
    }
}

#Preview("Empty List") {
    List {
        LocationsListView(
            locations: [],
            isLoading: false,
            onLocationTap: { _ in }
        )
    }
}

