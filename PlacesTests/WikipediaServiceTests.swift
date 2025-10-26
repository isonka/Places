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
