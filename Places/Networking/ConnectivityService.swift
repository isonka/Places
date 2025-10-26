import Foundation
import Combine
import Network

protocol ConnectivityServiceProtocol {    
    func checkConnection() async -> Bool
}

final class ConnectivityService: ConnectivityServiceProtocol {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "ConnectivityMonitor")
    private actor ConnectionState {
        var isConnected: Bool = true
        
        func update(_ connected: Bool) {
            isConnected = connected
        }
    }

    private let connectionState = ConnectionState()
        
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task {
                await self?.connectionState.update(path.status == .satisfied)
            }
        }
        monitor.start(queue: queue)
    }
    
    func checkConnection() async -> Bool {
        await connectionState.isConnected
    }
    
    deinit {
        monitor.cancel()
    }
}
