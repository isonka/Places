import Foundation
import Network

enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
}

enum NetworkError: Error, LocalizedError, Equatable {
    case badURL
    case requestFailed(Error)
    case decodingFailed(Error)
    case unknown
    case noConnection
    
    
    
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
        }
    }
    
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.badURL, .badURL): return true
        case (.noConnection, .noConnection): return true
        case (.unknown, .unknown): return true
        case (.requestFailed, .requestFailed): return true
        case (.decodingFailed, .decodingFailed): return true
        default: return false
        }
    }
}

protocol NetworkManagerProtocol {
    func fetch<T: Decodable>(from urlString: String,
                            method: HTTPMethod,
                            headers: [String: String]?,
                            body: Data?) async throws -> T
}

final class NetworkManager: NetworkManagerProtocol {
    private let connectivityService: ConnectivityService
    
    init(connectivityService: ConnectivityService) {
        self.connectivityService = connectivityService
    }
    
    func fetch<T: Decodable>(from urlString: String,
                            method: HTTPMethod = .GET,
                            headers: [String: String]? = nil,
                            body: Data? = nil) async throws -> T {
        guard connectivityService.isConnected else {
            throw NetworkError.noConnection
        }
        guard let url = URL(string: urlString) else {
            throw NetworkError.badURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        request.httpBody = body
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                return decoded
            } catch {
                throw NetworkError.decodingFailed(error)
            }
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
}
