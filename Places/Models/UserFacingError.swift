import Foundation

struct UserFacingError: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    let severity: Severity
    
    enum Severity {
        case info
        case warning
        case error
        
        var icon: String {
            switch self {
            case .info: return "info.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.circle.fill"
            }
        }
    }
}

extension UserFacingError {    
    private enum RetryableErrorType {
        case noConnection
        case serverError
        case dataError
        case unknown
        
        var title: String {
            switch self {
            case .noConnection: return "No Internet Connection"
            case .serverError: return "Server Error"
            case .dataError: return "Data Error"
            case .unknown: return "Something Went Wrong"
            }
        }
        
        var message: String {
            switch self {
            case .noConnection:
                return "Please check your connection and try again."
            case .serverError:
                return "We're having trouble reaching our servers. This usually resolves quickly."
            case .dataError:
                return "We received unexpected data. Our team has been notified."
            case .unknown:
                return "An unexpected error occurred. Please try again."
            }
        }
    }
        
    private static func retryableError(_ type: RetryableErrorType, retryAction: @escaping () -> Void) -> UserFacingError {
        UserFacingError(
            title: type.title,
            message: type.message,
            actionTitle: "Retry",
            action: retryAction,
            severity: .error
        )
    }
            
    static func noConnection(retryAction: @escaping () -> Void) -> UserFacingError {
        retryableError(.noConnection, retryAction: retryAction)
    }
    
    static func serverError(retryAction: @escaping () -> Void) -> UserFacingError {
        retryableError(.serverError, retryAction: retryAction)
    }
    
    static func dataError(retryAction: @escaping () -> Void) -> UserFacingError {
        retryableError(.dataError, retryAction: retryAction)
    }
    
    static func unknown(retryAction: @escaping () -> Void) -> UserFacingError {
        retryableError(.unknown, retryAction: retryAction)
    }
    
    static func usingCachedData(lastUpdated: Date?) -> UserFacingError {
        let timeString = lastUpdated.map { "Last updated \($0.timeAgoString)" } ?? "Offline mode"
        
        return UserFacingError(
            title: "Showing Saved Locations",
            message: "\(timeString). We'll refresh when you're back online.",
            actionTitle: nil,
            action: nil,
            severity: .warning
        )
    }
    
    static func wikipediaNotInstalled(installAction: @escaping () -> Void) -> UserFacingError {
        UserFacingError(
            title: "Wikipedia App Required",
            message: "Install the Wikipedia app to explore locations with rich content and offline access.",
            actionTitle: "Get Wikipedia",
            action: installAction,
            severity: .info
        )
    }
}

extension UserFacingError {    
    static func from(_ error: Error, retryAction: @escaping () -> Void) -> UserFacingError {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .noConnection:
                return .noConnection(retryAction: retryAction)
            case .badURL:
                return .dataError(retryAction: retryAction)
            case .requestFailed:
                return .serverError(retryAction: retryAction)
            case .decodingFailed:
                return .dataError(retryAction: retryAction)
            case .status(let code) where (500...599).contains(code):
                return .serverError(retryAction: retryAction)
            case .status:
                return .serverError(retryAction: retryAction)
            case .unknown:
                return .unknown(retryAction: retryAction)
            }
        }
        return .unknown(retryAction: retryAction)
    }
}

