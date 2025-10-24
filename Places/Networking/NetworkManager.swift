import Foundation
import Network

enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
}

protocol NetworkManagerProtocol: Sendable {
    nonisolated func fetch<T: Decodable>(from urlString: String,
                                         method: HTTPMethod,
                                         headers: [String: String]?,
                                         body: Data?) async throws -> T
}

struct NetworkManager: NetworkManagerProtocol {
    private let connectivityService: ConnectivityServiceProtocol
    private let logger: LoggingServiceProtocol = LoggingService.shared
    
    init(
        connectivityService: ConnectivityServiceProtocol        
    ) {
        self.connectivityService = connectivityService        
    }
    
    func fetch<T: Decodable>(from urlString: String,
                             method: HTTPMethod = .GET,
                             headers: [String: String]? = nil,
                             body: Data? = nil) async throws -> T {
        logger.debug("Starting \(method.rawValue) request to: \(urlString)")
        
        guard await connectivityService.checkConnection() else {
            logger.warning("No network connection available")
            throw NetworkError.noConnection
        }
        
        guard let url = URL(string: urlString) else {
            logger.error("Invalid URL: \(urlString)")
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
            
            if let httpResponse = response as? HTTPURLResponse {
                logger.debug("Received HTTP \(httpResponse.statusCode) from \(urlString)")
                
                if !(200...299).contains(httpResponse.statusCode) {
                    logger.error("HTTP error \(httpResponse.statusCode) for \(urlString)")
                    throw NetworkError.status(httpResponse.statusCode)
                }
            }
            
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                logger.info("Successfully decoded response from \(urlString)")
                return decoded
            } catch {
                logger.error("Decoding failed for \(urlString): \(error.localizedDescription)")
                throw NetworkError.decodingFailed(error)
            }
        } catch {
            logger.error("Request failed for \(urlString): \(error.localizedDescription)")
            throw NetworkError.requestFailed(error)
        }
    }
}
