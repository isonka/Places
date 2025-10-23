import SwiftUI

struct CoordinateTextField: View {
    let icon: String
    let title: String
    let placeholder: String
    @Binding var text: String
    let error: String?
    let hint: String
    let identifier: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.secondary)
            
            inputField
            
            if let error = error {
                errorView(error)
            }
        }
    }
    
    private var inputField: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(error != nil ? .red : .blue)
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .keyboardType(.decimalPad)
                .font(.body)
                .accessibilityLabel(title)
                .accessibilityHint(hint)
                .accessibilityValue(text.isEmpty ? "Empty" : text)
                .accessibilityIdentifier(identifier)
            
            if !text.isEmpty {
                clearButton
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(error != nil ? Color.red : Color.clear, lineWidth: 1.5)
        )
    }
    
    private var clearButton: some View {
        Button(action: { text = "" }) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.secondary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Clear \(title)")
    }
    
    private func errorView(_ message: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.caption)
            Text(message)
                .font(.caption)
        }
        .foregroundColor(.red)
        .accessibilityAddTraits(.isStaticText)
        .accessibilityLabel("\(title) error: \(message)")
    }
}

// MARK: - Preview

#Preview("Empty") {
    CoordinateTextField(
        icon: "arrow.up.and.down",
        title: "Latitude",
        placeholder: "e.g., 52.3676",
        text: .constant(""),
        error: nil,
        hint: "Enter a latitude value between -90 and 90",
        identifier: "latitudeTextField"
    )
    .padding()
}

#Preview("With Value") {
    CoordinateTextField(
        icon: "arrow.up.and.down",
        title: "Latitude",
        placeholder: "e.g., 52.3676",
        text: .constant("52.3676"),
        error: nil,
        hint: "Enter a latitude value between -90 and 90",
        identifier: "latitudeTextField"
    )
    .padding()
}

#Preview("With Error") {
    CoordinateTextField(
        icon: "arrow.up.and.down",
        title: "Latitude",
        placeholder: "e.g., 52.3676",
        text: .constant("abc"),
        error: "Latitude must be a valid number.",
        hint: "Enter a latitude value between -90 and 90",
        identifier: "latitudeTextField"
    )
    .padding()
}

