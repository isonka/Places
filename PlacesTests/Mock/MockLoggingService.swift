import Foundation
import Combine
@testable import Places

final class MockLoggingService: LoggingServiceProtocol, @unchecked Sendable {
    
    struct LogEntry {
        let message: String
        let level: LogLevel
        let file: String
        let function: String
        let line: Int
        let timestamp: Date
    }
    
    private(set) var logs: [LogEntry] = []
    
    func log(
        _ message: String,
        level: LogLevel,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        logs.append(LogEntry(
            message: message,
            level: level,
            file: file,
            function: function,
            line: line,
            timestamp: Date()
        ))
    }
    
    func clear() {
        logs.removeAll()
    }
    
    func logs(for level: LogLevel) -> [LogEntry] {
        logs.filter { $0.level == level }
    }
}
