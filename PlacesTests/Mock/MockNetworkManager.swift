import Foundation
import Combine
@testable import Places

final class MockConnectivityService: ConnectivityServiceProtocol {
    var isConnected: Bool
    private var subject = CurrentValueSubject<Bool, Never>(true)
    
    var isConnectedPublisher: AnyPublisher<Bool, Never> {
        subject.eraseToAnyPublisher()
    }
    
    init(isConnected: Bool = true) {
        self.isConnected = isConnected
        subject.send(isConnected)
    }
    
    func checkConnection() async -> Bool {
        return isConnected
    }
    
    func setConnected(_ connected: Bool) {
        isConnected = connected
        subject.send(connected)
    }
}

struct Dummy: Codable, Equatable {
    let value: String
}

class MockNetworkManager: NetworkManagerProtocol {
    init(mockData: Data? = nil, connectivityService: ConnectivityServiceProtocol = MockConnectivityService(isConnected: true), statusCode: Int? = nil, shouldFail: Bool = false) {
        self.mockData = mockData
        self.connectivityService = connectivityService
        self.statusCode = statusCode
        self.shouldFail = shouldFail
    }
    
    var mockData: Data?
    var shouldFail: Bool = false
    var connectivityService: ConnectivityServiceProtocol = MockConnectivityService(isConnected: true)
    var statusCode: Int? = nil // New property to simulate status error
    func fetch<T: Decodable>(from urlString: String, method: HTTPMethod = .GET, headers: [String: String]? = nil, body: Data? = nil) async throws -> T {
        if !(await connectivityService.checkConnection()) {
            throw NetworkError.noConnection
        }
        if let code = statusCode {
            throw NetworkError.status(code)
        }
        if shouldFail {
            throw NetworkError.requestFailed(URLError(.badServerResponse))
        }
        guard let data = mockData else {
            throw NetworkError.badURL
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
}
