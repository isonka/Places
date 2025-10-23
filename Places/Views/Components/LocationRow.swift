import SwiftUI

struct LocationRow: View {
    let location: Location
    let onTap: (Location) -> Void
    
    var body: some View {
        Button(action: { onTap(location) }) {
            HStack(spacing: 16) {
                locationIcon
                locationDetails
                Spacer()
                chevronIndicator
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(location.name ?? "Unknown Location")
        .accessibilityHint("Opens Wikipedia for this location")
        .accessibilityValue("Latitude \(location.lat), Longitude \(location.long)")
    }
    
    // MARK: - Components
    
    private var locationIcon: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.8), Color.cyan.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 48, height: 48)
            
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 22))
                .foregroundColor(.white)
                .symbolRenderingMode(.hierarchical)
        }
        .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
    }
    
    private var locationDetails: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(location.name ?? "Unknown Location")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                coordinateLabel(
                    icon: "arrow.up.and.down",
                    value: formatCoordinate(location.lat, isLatitude: true)
                )
                
                coordinateLabel(
                    icon: "arrow.left.and.right",
                    value: formatCoordinate(location.long, isLatitude: false)
                )
            }
        }
    }
    
    private var chevronIndicator: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.secondary.opacity(0.5))
    }
    
    // MARK: - Helper Views
    
    @ViewBuilder
    private func coordinateLabel(icon: String, value: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
                .monospacedDigit()
        }
    }
    
    // MARK: - Helpers
    
    private func formatCoordinate(_ value: Double, isLatitude: Bool) -> String {
        let direction: String
        if isLatitude {
            direction = value >= 0 ? "N" : "S"
        } else {
            direction = value >= 0 ? "E" : "W"
        }
        return String(format: "%.4f°%@", abs(value), direction)
    }
}

// MARK: - Preview

#Preview("Location with Name") {
    List {
        LocationRow(
            location: Location(name: "Amsterdam", lat: 52.3676, long: 4.9041),
            onTap: { _ in }
        )
    }
}

#Preview("Location without Name") {
    List {
        LocationRow(
            location: Location(name: nil, lat: -33.8688, long: 151.2093),
            onTap: { _ in }
        )
    }
}

#Preview("Multiple Locations") {
    List {
        LocationRow(
            location: Location(name: "Amsterdam", lat: 52.3676, long: 4.9041),
            onTap: { _ in }
        )
        LocationRow(
            location: Location(name: "Sydney", lat: -33.8688, long: 151.2093),
            onTap: { _ in }
        )
        LocationRow(
            location: Location(name: "Tokyo", lat: 35.6762, long: 139.6503),
            onTap: { _ in }
        )
    }
}

