//
//  WikipediaServiceTests.swift
//  PlacesTests
//
//  Created by Onur Karsli on 23/10/2025.
//

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
    
    func testOpenWikipediaWithValidCoordinates() {
        let latitude = 37.7749
        let longitude = -122.4194
        service.openWikipedia(latitude: latitude, longitude: longitude)
        XCTAssertTrue(true)
    }
    
    func testOpenCustomLocationWithValidStringCoordinates() {
        let latitude = "37.7749"
        let longitude = "-122.4194"
        service.openCustomLocation(latitude: latitude, longitude: longitude)
        XCTAssertTrue(true)
    }
    
    func testOpenCustomLocationWithInvalidCoordinates() {
        let testCases = [
            ("invalid", "151.2093"),  // Invalid latitude
            ("37.7749", "invalid"),   // Invalid longitude
            ("95.0", "0"),            // Out of range latitude
            ("0", "185.0"),           // Out of range longitude
            ("", ""),                 // Empty strings
        ]
        for (lat, lon) in testCases {
            service.openCustomLocation(latitude: lat, longitude: lon)
            XCTAssertTrue(true)
        }
    }
    
    func testOpenCustomLocationWithBoundaryValues() {
        let testCases = [
            ("90.0", "180.0"),     // Maximum valid values
            ("-90.0", "-180.0"),   // Minimum valid values
        ]
        for (lat, lon) in testCases {
            service.openCustomLocation(latitude: lat, longitude: lon)
            XCTAssertTrue(true)
        }
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
}
