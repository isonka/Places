import Foundation

enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
}

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func fetchData(from urlString: String,
                   method: HTTPMethod = .GET,
                   headers: [String: String]? = nil,
                   body: Data? = nil) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        request.httpBody = body
        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    }
}
