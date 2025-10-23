import SwiftUI

struct WikipediaErrorSheet: View {
    let error: UserFacingError
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Icon
                Image(systemName: "app.badge")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .padding(.top, 32)
                                
                VStack(spacing: 12) {
                    Text(error.title)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(error.message)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 32)
                }
                .padding(.horizontal, 16)
                                
                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(icon: "globe", text: "Explore millions of articles")
                    FeatureRow(icon: "arrow.down.circle", text: "Read offline with saved articles")
                    FeatureRow(icon: "location.fill", text: "Discover places near you")
                }
                .padding(.horizontal, 32)
                .padding(.top, 8)
                
                Spacer()
                                
                VStack(spacing: 12) {
                    if let actionTitle = error.actionTitle, let action = error.action {
                        Button(action: {
                            action()
                            dismiss()
                        }) {
                            Text(actionTitle)
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                    }
                    
                    Button("Maybe Later") {
                        dismiss()
                    }
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    WikipediaErrorSheet(
        error: .wikipediaNotInstalled {
            print("Get Wikipedia tapped")
        }
    )
}

