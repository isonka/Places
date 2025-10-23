import Foundation
import Network

enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
}

protocol NetworkManagerProtocol {
    nonisolated func fetch<T: Decodable>(from urlString: String,
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
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                throw NetworkError.status(httpResponse.statusCode)
            }
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
