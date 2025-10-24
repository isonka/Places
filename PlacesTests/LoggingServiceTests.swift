import XCTest
@testable import Places

final class LoggingServiceTests: XCTestCase {    
    func testRealLoggerDoesNotCrash() {
        let logger = LoggingService.shared
        logger.debug("Test")
        logger.info("Test")
        logger.warning("Test")
        logger.error("Test")
        XCTAssertTrue(true)
    }
}

