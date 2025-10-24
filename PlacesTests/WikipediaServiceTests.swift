import XCTest
import Combine
@testable import Places

final class WikipediaServiceTests: XCTestCase {
    var service: WikipediaService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        service = WikipediaService()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        service = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testOpenCustomLocationWithInvalidCoordinatesDoesNotSetError() {
        service.openCustomLocation(latitude: "invalid", longitude: "151.2093")
        XCTAssertNil(service.wikipediaError, "Invalid input should fail validation silently")
    }
    
    func testOpenCustomLocationWithInvalidLongitude() {
        service.openCustomLocation(latitude: "37.7749", longitude: "invalid")
        XCTAssertNil(service.wikipediaError, "Invalid longitude should fail validation silently")
    }
    
    func testOpenCustomLocationWithOutOfRangeLatitude() {
        service.openCustomLocation(latitude: "95.0", longitude: "0")
        XCTAssertNil(service.wikipediaError, "Out of range latitude should fail validation silently")
    }
    
    func testOpenCustomLocationWithOutOfRangeLongitude() {
        service.openCustomLocation(latitude: "0", longitude: "185.0")
        XCTAssertNil(service.wikipediaError, "Out of range longitude should fail validation silently")
    }
    
    func testOpenCustomLocationWithEmptyStrings() {
        service.openCustomLocation(latitude: "", longitude: "")
        XCTAssertNil(service.wikipediaError, "Empty strings should fail validation silently")
    }
    
    func testWikipediaErrorCanBeSet() {
        let expectation = XCTestExpectation(description: "Error should be published")
        
        service.$wikipediaError
            .dropFirst()
            .sink { error in
                if error != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        service.wikipediaError = .wikipediaNotInstalled { }
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(service.wikipediaError)
        XCTAssertEqual(service.wikipediaError?.title, "Wikipedia App Required")
    }
    
    func testWikipediaErrorCanBeCleared() {
        service.wikipediaError = .wikipediaNotInstalled { }
        XCTAssertNotNil(service.wikipediaError)
        
        service.wikipediaError = nil
        XCTAssertNil(service.wikipediaError)
    }
}
