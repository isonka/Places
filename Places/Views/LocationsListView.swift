import SwiftUI

struct LocationsListView: View {
    let locations: [Location]
    let isLoading: Bool
    let onLocationTap: (Location) -> Void
    var lastUpdated: Date? = nil
    
    var body: some View {
        Section {
            if isLoading && locations.isEmpty {
                LocationsListSkeleton(count: 5)
            } else if locations.isEmpty {
                emptyStateView
            } else {
                ForEach(locations) { location in
                    LocationRow(location: location, onTap: onLocationTap)
                }
            }
        } header: {
            Text("Places")
        } footer: {
            if let lastUpdated = lastUpdated, !locations.isEmpty {
                lastUpdatedFooter(date: lastUpdated)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "map.circle")
                .font(.system(size: 56))
                .foregroundColor(.secondary)
            
            VStack(spacing: 4) {
                Text("No Locations")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Pull down to refresh")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .listRowBackground(Color.clear)
    }
    
    @ViewBuilder
    private func lastUpdatedFooter(date: Date) -> some View {
        HStack {
            Image(systemName: "clock.arrow.circlepath")
                .font(.caption2)
            Text("Updated \(date.timeAgoString)")
                .font(.caption2)
        }
        .foregroundColor(.secondary)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 4)
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
            onLocationTap: { _ in
                // Preview action
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

