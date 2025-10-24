import SwiftUI

extension UserFacingError.Severity {
    var backgroundColor: Color {
        switch self {
        case .info:
            return Color.blue.opacity(0.1)
        case .warning:
            return Color.orange.opacity(0.1)
        case .error:
            return Color.red.opacity(0.1)
        }
    }
    
    var primaryColor: Color {
        switch self {
        case .info:
            return .blue
        case .warning:
            return .orange
        case .error:
            return .red
        }
    }
    
    var buttonColor: Color {
        primaryColor
    }
    
    var buttonTextColor: Color {
        .white
    }
}

