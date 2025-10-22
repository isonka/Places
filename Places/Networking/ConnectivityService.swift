import Foundation
import Combine
import Network

protocol ConnectivityServiceProtocol {
    var isConnected: Bool { get }
}

final class ConnectivityService: ConnectivityServiceProtocol, ObservableObject {
    @Published private(set) var isConnected: Bool = true
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "ConnectivityMonitor")
    
    static let shared = ConnectivityService()
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        monitor.start(queue: queue)
    }
}
