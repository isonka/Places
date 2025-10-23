import SwiftUI

struct CustomLocationView: View {
    @Binding var latitude: String
    @Binding var longitude: String
    let latitudeError: String?
    let longitudeError: String?
    let isValid: Bool
    let onSubmit: () -> Void
    
    var body: some View {
        Section {
            VStack(spacing: 20) {
                headerView
                coordinateInputs
                SubmitButton(isEnabled: isValid, action: onSubmit)
            }
            .padding(.vertical, 16)
        } header: {
            sectionHeader
        }
    }
    
    private var sectionHeader: some View {
        HStack {
            Image(systemName: "location.circle.fill")
                .foregroundColor(.blue)
            Text("Custom Location")
        }
        .font(.headline)
    }
    
    private var headerView: some View {
        VStack(spacing: 4) {
            Image(systemName: "map.fill")
                .font(.system(size: 32))
                .foregroundColor(.blue)
                .padding(12)
                .background(
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                )
            
            Text("Enter Coordinates")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var coordinateInputs: some View {
        VStack(spacing: 16) {
            CoordinateTextField(
                icon: "arrow.up.and.down",
                title: "Latitude",
                placeholder: "e.g., 52.3676",
                text: $latitude,
                error: latitudeError,
                hint: "Enter a latitude value between -90 and 90",
                identifier: "latitudeTextField"
            )
            
            CoordinateTextField(
                icon: "arrow.left.and.right",
                title: "Longitude",
                placeholder: "e.g., 4.9041",
                text: $longitude,
                error: longitudeError,
                hint: "Enter a longitude value between -180 and 180",
                identifier: "longitudeTextField"
            )
        }
    }
}

// MARK: - Preview

#Preview("Valid Input") {
    List {
        CustomLocationView(
            latitude: .constant("52.3676"),
            longitude: .constant("4.9041"),
            latitudeError: nil,
            longitudeError: nil,
            isValid: true
        ) {
            print("Submit tapped")
        }
    }
}

#Preview("With Errors") {
    List {
        CustomLocationView(
            latitude: .constant("abc"),
            longitude: .constant("200"),
            latitudeError: "Latitude must be a valid number.",
            longitudeError: "Longitude must be between -180 and 180.",
            isValid: false
        ) {
            print("Submit tapped")
        }
    }
}

#Preview("Empty Fields") {
    List {
        CustomLocationView(
            latitude: .constant(""),
            longitude: .constant(""),
            latitudeError: nil,
            longitudeError: nil,
            isValid: false
        ) {
            print("Submit tapped")
        }
    }
}
