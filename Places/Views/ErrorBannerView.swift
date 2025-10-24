import SwiftUI

struct ErrorBannerView: View {
    let error: UserFacingError
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: error.severity.icon)
                    .font(.title3)
                    .foregroundColor(error.severity.primaryColor)
                    .frame(width: 24, alignment: .center)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(error.title)
                        .font(.headline)
                        .foregroundColor(error.severity.primaryColor)
                        .fixedSize(horizontal: false, vertical: false)
                    
                    Text(error.message)
                        .font(.subheadline)
                        .foregroundColor(error.severity.primaryColor.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: false)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if let actionTitle = error.actionTitle, let action = error.action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(error.severity.buttonTextColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(error.severity.buttonColor)
                        .cornerRadius(8)
                }
                .accessibilityLabel("\(actionTitle) to resolve error")
            }
        }
        .padding(16)
        .background(error.severity.backgroundColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(error.severity == .error ? "Error" : error.severity == .warning ? "Warning" : "Information"): \(error.title)")
        .accessibilityHint(error.message)
    }
}

// MARK: - Preview

#Preview("Error with Retry") {
    VStack {
        ErrorBannerView(
            error: .noConnection {
                // Preview action
            }
        )
        
        Spacer()
    }
}

#Preview("Warning with Cache") {
    VStack {
        ErrorBannerView(
            error: .usingCachedData(lastUpdated: Date().addingTimeInterval(-3600))
        )
        
        Spacer()
    }
}

#Preview("Info") {
    VStack {
        ErrorBannerView(
            error: .wikipediaNotInstalled {
                // Preview action
            }
        )
        
        Spacer()
    }
}

