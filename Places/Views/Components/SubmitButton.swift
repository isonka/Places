import SwiftUI

struct SubmitButton: View {
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            if isEnabled {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
            action()
        }) {
            buttonContent
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .scaleEffect(isEnabled ? 1.0 : 0.98)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
        .accessibilityLabel("Open Wikipedia for custom location")
        .accessibilityHint(isEnabled ? "Double tap to open Wikipedia" : "Enter valid coordinates first")
        .accessibilityIdentifier("openWikipediaButton")
    }
    
    private var buttonContent: some View {
        HStack(spacing: 8) {
            Image(systemName: "arrow.up.right.circle.fill")
                .font(.title3)
            
            Text("Open in Wikipedia")
                .font(.headline)
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(backgroundGradient)
        .cornerRadius(14)
        .shadow(
            color: isEnabled ? Color.blue.opacity(0.3) : Color.clear,
            radius: 8,
            x: 0,
            y: 4
        )
    }
    
    private var backgroundGradient: some View {
        Group {
            if isEnabled {
                LinearGradient(
                    colors: [Color.blue, Color.blue.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            } else {
                LinearGradient(
                    colors: [Color.gray, Color.gray.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
        }
    }
}

// MARK: - Preview

#Preview("Enabled") {
    SubmitButton(isEnabled: true) {
        // Preview action
    }
    .padding()
}

#Preview("Disabled") {
    SubmitButton(isEnabled: false) {
        // Preview action
    }
    .padding()
}

