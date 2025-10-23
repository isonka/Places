import XCTest
@testable import Places

final class LocationValidatorTests: XCTestCase {
    func testLatitudeEmptyStringIsValid() {
        XCTAssertNil(LocationValidator.validateLatitude(""))
    }
    
    func testLatitudeValidValueIsValid() {
        XCTAssertNil(LocationValidator.validateLatitude("45.0"))
    }
    
    func testLongitudeValidValueIsValid() {
        XCTAssertNil(LocationValidator.validateLongitude("120.0"))
    }
    
    func testLatitudeOutOfRangeReturnsError() {
        XCTAssertEqual(LocationValidator.validateLatitude("100"), "Latitude must be between -90 and 90.")
        XCTAssertEqual(LocationValidator.validateLatitude("-91"), "Latitude must be between -90 and 90.")
    }
    
    func testLongitudeOutOfRangeReturnsError() {
        XCTAssertEqual(LocationValidator.validateLongitude("200"), "Longitude must be between -180 and 180.")
        XCTAssertEqual(LocationValidator.validateLongitude("-181"), "Longitude must be between -180 and 180.")
    }
    
    func testLatitudeNonNumericReturnsError() {
        XCTAssertEqual(LocationValidator.validateLatitude("abc"), "Latitude must be a valid number.")
    }
    
    func testLongitudeNonNumericReturnsError() {
        XCTAssertEqual(LocationValidator.validateLongitude("xyz"), "Longitude must be a valid number.")
    }
    
    func testLatitudeCommaDecimalReturnsError() {
        XCTAssertEqual(LocationValidator.validateLatitude("45,5"), "Decimals must use . instead of ,")
    }
    
    func testLongitudeCommaDecimalReturnsError() {
        XCTAssertEqual(LocationValidator.validateLongitude("120,5"), "Decimals must use . instead of ,")
    }
    
    func testLatitudeBoundaryValuesAreValid() {
        XCTAssertNil(LocationValidator.validateLatitude("-90"))
        XCTAssertNil(LocationValidator.validateLatitude("90"))
    }
    
    func testLongitudeBoundaryValuesAreValid() {
        XCTAssertNil(LocationValidator.validateLongitude("-180"))
        XCTAssertNil(LocationValidator.validateLongitude("180"))
    }
}
