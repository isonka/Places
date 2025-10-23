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
    
    func testLatitudeWithLeadingWhitespaceReturnsError() {
        XCTAssertEqual(LocationValidator.validateLatitude(" 45.0"), "Latitude cannot contain whitespace.")
    }
    
    func testLatitudeWithTrailingWhitespaceReturnsError() {
        XCTAssertEqual(LocationValidator.validateLatitude("45.0 "), "Latitude cannot contain whitespace.")
    }
    
    func testLongitudeWithWhitespaceReturnsError() {
        XCTAssertEqual(LocationValidator.validateLongitude(" 120.0 "), "Longitude cannot contain whitespace.")
    }
    
    func testLatitudeWithMultipleDecimalPointsReturnsError() {
        XCTAssertEqual(LocationValidator.validateLatitude("45.0.5"), "Latitude cannot have multiple decimal points.")
    }
    
    func testLongitudeWithMultipleDecimalPointsReturnsError() {
        XCTAssertEqual(LocationValidator.validateLongitude("120.5.7"), "Longitude cannot have multiple decimal points.")
    }
    
    func testLatitudeInfinityReturnsError() {
        XCTAssertEqual(LocationValidator.validateLatitude("inf"), "Latitude cannot be infinity.")
        XCTAssertEqual(LocationValidator.validateLatitude("infinity"), "Latitude cannot be infinity.")
    }
    
    func testLongitudeInfinityReturnsError() {
        XCTAssertEqual(LocationValidator.validateLongitude("inf"), "Longitude cannot be infinity.")
    }
    
    func testLatitudeNaNReturnsError() {
        XCTAssertEqual(LocationValidator.validateLatitude("nan"), "Latitude cannot be NaN.")
    }
    
    func testLongitudeNaNReturnsError() {
        XCTAssertEqual(LocationValidator.validateLongitude("nan"), "Longitude cannot be NaN.")
    }
    
    func testLatitudeScientificNotationValid() {
        XCTAssertNil(LocationValidator.validateLatitude("1e1"))
        XCTAssertEqual(LocationValidator.validateLatitude("1e3"), "Latitude must be between -90 and 90.")
    }
    
    func testLongitudeScientificNotationValid() {
        XCTAssertNil(LocationValidator.validateLongitude("1.5e2"))
        XCTAssertEqual(LocationValidator.validateLongitude("1e5"), "Longitude must be between -180 and 180.")
    }
    
    func testNegativeZeroIsValid() {
        XCTAssertNil(LocationValidator.validateLatitude("-0"))
        XCTAssertNil(LocationValidator.validateLongitude("-0.0"))
    }
    
    func testVerySmallDecimalNumbersAreValid() {
        XCTAssertNil(LocationValidator.validateLatitude("0.0000001"))
        XCTAssertNil(LocationValidator.validateLongitude("-0.0000001"))
    }
    
    func testLatitudeJustOutsideBoundary() {
        XCTAssertEqual(LocationValidator.validateLatitude("90.0001"), "Latitude must be between -90 and 90.")
        XCTAssertEqual(LocationValidator.validateLatitude("-90.0001"), "Latitude must be between -90 and 90.")
    }
    
    func testLongitudeJustOutsideBoundary() {
        XCTAssertEqual(LocationValidator.validateLongitude("180.0001"), "Longitude must be between -180 and 180.")
        XCTAssertEqual(LocationValidator.validateLongitude("-180.0001"), "Longitude must be between -180 and 180.")
    }
    
    func testSpecialCharactersReturnError() {
        XCTAssertEqual(LocationValidator.validateLatitude("45°"), "Latitude must be a valid number.")
        XCTAssertEqual(LocationValidator.validateLongitude("120'"), "Longitude must be a valid number.")
    }
    
    func testEmptyStringAfterTrimIsNil() {
        XCTAssertNil(LocationValidator.validateLatitude(""))
        XCTAssertNil(LocationValidator.validateLongitude(""))
    }
}
