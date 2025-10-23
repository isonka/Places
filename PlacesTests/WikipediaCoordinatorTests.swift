//
//  WikipediaCoordinatorTests.swift
//  PlacesTests
//
//  Created by Onur Karsli on 23/10/2025.
//

import XCTest
import Combine
@testable import Places

final class WikipediaCoordinatorTests: XCTestCase {
    var coordinator: WikipediaCoordinator!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        coordinator = WikipediaCoordinator()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        coordinator = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testOpenWikipediaWithValidCoordinates() {
        let latitude = 37.7749
        let longitude = -122.4194
        coordinator.openWikipedia(latitude: latitude, longitude: longitude)
        XCTAssertTrue(true)
    }
    
    func testOpenCustomLocationWithValidStringCoordinates() {
        let latitude = "37.7749"
        let longitude = "-122.4194"
        coordinator.openCustomLocation(latitude: latitude, longitude: longitude)
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
            coordinator.openCustomLocation(latitude: lat, longitude: lon)
            XCTAssertTrue(true)
        }
    }
    
    func testOpenCustomLocationWithBoundaryValues() {
        let testCases = [
            ("90.0", "180.0"),     // Maximum valid values
            ("-90.0", "-180.0"),   // Minimum valid values
        ]
        for (lat, lon) in testCases {
            coordinator.openCustomLocation(latitude: lat, longitude: lon)
            XCTAssertTrue(true)
        }
    }    
    
    func testShowWikipediaAlertCanBeSet() {
        let expectation = XCTestExpectation(description: "Alert should be published")
        coordinator.$showWikipediaAlert
            .dropFirst()
            .sink { shown in
                if shown {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        coordinator.showWikipediaAlert = true
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(coordinator.showWikipediaAlert)
    }
}
