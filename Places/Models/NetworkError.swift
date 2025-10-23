import Foundation

enum NetworkError: Error, LocalizedError, Equatable {
    case badURL
    case requestFailed(Error)
    case decodingFailed(Error)
    case unknown
    case noConnection
    case status(Int)
    
    var errorDescription: String? {
        switch self {
        case .badURL:
            return "The URL provided was invalid."
        case .requestFailed(let error):
            return "Network request failed: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .noConnection:
            return "No internet connection."
        case .unknown:
            return "An unknown error occurred."
        case .status(let code):
            return "Unexpected HTTP status code: \(code)"
        }
    }
    
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.badURL, .badURL): return true
        case (.noConnection, .noConnection): return true
        case (.unknown, .unknown): return true
        case (.requestFailed, .requestFailed): return true
        case (.decodingFailed, .decodingFailed): return true
        case (.status, .status): return true
        default: return false
        }
    }
}
