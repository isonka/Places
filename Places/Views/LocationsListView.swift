import SwiftUI

struct LocationsListView: View {
    let locations: [Location]
    let onLocationTap: (Location) -> Void
    
    var body: some View {
        Section(header: Text("Places")) {
            ForEach(locations) { location in
                LocationRow(location: location, onTap: onLocationTap)
            }
        }
    }
}

struct LocationRow: View {
    let location: Location
    let onTap: (Location) -> Void
    
    var body: some View {
        Button(action: { onTap(location) }) {
            VStack(alignment: .leading, spacing: 4) {
                if let name = location.name {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                Text("Latitude: \(location.lat), Longitude: \(location.long)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(location.name ?? "Unknown Location")
        .accessibilityHint("Opens Wikipedia for this location")
    }
}

// MARK: - Preview

#Preview("With Locations") {
    List {
        LocationsListView(locations: [
            Location(name: "Amsterdam", lat: 52.3676, long: 4.9041),
            Location(name: "Rotterdam", lat: 51.9225, long: 4.47917),
            Location(name: nil, lat: 41.0082, long: 28.9784)
        ]) { location in
            print("Tapped: \(location.name ?? "Unknown")")
        }
    }
}

#Preview("Empty List") {
    List {
        LocationsListView(locations: []) { _ in }
    }
}

