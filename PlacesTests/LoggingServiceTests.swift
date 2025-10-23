import XCTest
@testable import Places

final class LoggingServiceTests: XCTestCase {
    
    var mockLogger: MockLoggingService!
    
    override func setUp() {
        super.setUp()
        mockLogger = MockLoggingService()
    }
    
    override func tearDown() {
        mockLogger = nil
        super.tearDown()
    }
    
    func testDebugLogging() {
        mockLogger.debug("Test debug message")
        
        XCTAssertEqual(mockLogger.logs.count, 1)
        XCTAssertEqual(mockLogger.logs.first?.level, .debug)
        XCTAssertEqual(mockLogger.logs.first?.message, "Test debug message")
    }
    
    func testInfoLogging() {
        mockLogger.info("Test info message")
        
        XCTAssertEqual(mockLogger.logs.count, 1)
        XCTAssertEqual(mockLogger.logs.first?.level, .info)
        XCTAssertEqual(mockLogger.logs.first?.message, "Test info message")
    }
    
    func testWarningLogging() {
        mockLogger.warning("Test warning message")
        
        XCTAssertEqual(mockLogger.logs.count, 1)
        XCTAssertEqual(mockLogger.logs.first?.level, .warning)
        XCTAssertEqual(mockLogger.logs.first?.message, "Test warning message")
    }
    
    func testErrorLogging() {
        mockLogger.error("Test error message")
        
        XCTAssertEqual(mockLogger.logs.count, 1)
        XCTAssertEqual(mockLogger.logs.first?.level, .error)
        XCTAssertEqual(mockLogger.logs.first?.message, "Test error message")
    }
    
    func testMultipleLogs() {
        mockLogger.debug("Debug message")
        mockLogger.info("Info message")
        mockLogger.warning("Warning message")
        mockLogger.error("Error message")
        
        XCTAssertEqual(mockLogger.logs.count, 4)
        
        XCTAssertEqual(mockLogger.logs[0].level, .debug)
        XCTAssertEqual(mockLogger.logs[1].level, .info)
        XCTAssertEqual(mockLogger.logs[2].level, .warning)
        XCTAssertEqual(mockLogger.logs[3].level, .error)
    }
    
    func testLogsForLevel() {
        mockLogger.debug("Debug 1")
        mockLogger.info("Info 1")
        mockLogger.debug("Debug 2")
        mockLogger.error("Error 1")
        mockLogger.debug("Debug 3")
        
        let debugLogs = mockLogger.logs(for: .debug)
        XCTAssertEqual(debugLogs.count, 3)
        XCTAssertEqual(debugLogs[0].message, "Debug 1")
        XCTAssertEqual(debugLogs[1].message, "Debug 2")
        XCTAssertEqual(debugLogs[2].message, "Debug 3")
        
        let infoLogs = mockLogger.logs(for: .info)
        XCTAssertEqual(infoLogs.count, 1)
        XCTAssertEqual(infoLogs[0].message, "Info 1")
    }
    
    func testClearLogs() {
        mockLogger.debug("Message 1")
        mockLogger.info("Message 2")
        mockLogger.error("Message 3")
        
        XCTAssertEqual(mockLogger.logs.count, 3)
        
        mockLogger.clear()
        
        XCTAssertEqual(mockLogger.logs.count, 0)
    }
    
    func testLogContainsFileAndLine() {
        let testFile = "TestFile.swift"
        let testFunction = "testFunction()"
        let testLine = 42
        
        mockLogger.log("Test message", level: .info, file: testFile, function: testFunction, line: testLine)
        
        XCTAssertEqual(mockLogger.logs.count, 1)
        let log = mockLogger.logs.first!
        
        XCTAssertTrue(log.file.contains(testFile))
        XCTAssertEqual(log.function, testFunction)
        XCTAssertEqual(log.line, testLine)
    }
        
    func testLoggerInViewModel() async {
        let mockLogger = MockLoggingService()
        let mockRepository = MockLocationRepository()
        let viewModel = await PlacesViewModel(locationRepository: mockRepository, logger: mockLogger)
                
        let initLogs = mockLogger.logs(for: .info).filter { $0.message.contains("initialized") }
        XCTAssertEqual(initLogs.count, 1)
        
        mockLogger.clear()
        
        // Should log when loading locations
        await viewModel.loadLocations()
        
        XCTAssertTrue(mockLogger.logs.count > 0)
        XCTAssertTrue(mockLogger.logs.contains { $0.message.contains("Starting to load locations") })
    }
}

