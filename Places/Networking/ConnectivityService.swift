import Foundation
import Combine
import Network

protocol ConnectivityServiceProtocol: Sendable {
    var isConnectedPublisher: AnyPublisher<Bool, Never> { get }
    func checkConnection() async -> Bool
}

final class ConnectivityService: ConnectivityServiceProtocol {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "ConnectivityMonitor")
    private let subject = CurrentValueSubject<Bool, Never>(true)
    
    var isConnectedPublisher: AnyPublisher<Bool, Never> {
        subject.eraseToAnyPublisher()
    }
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.subject.send(path.status == .satisfied)
        }
        monitor.start(queue: queue)
    }
    
    func checkConnection() async -> Bool {
        await withCheckedContinuation { continuation in
            queue.async { [weak self] in
                continuation.resume(returning: self?.subject.value ?? false)
            }
        }
    }
    
    deinit {
        monitor.cancel()
    }
}
