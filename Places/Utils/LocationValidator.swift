import Foundation

enum CoordinateType {
    case latitude
    case longitude
    
    var range: ClosedRange<Double> {
        switch self {
        case .latitude: return -90...90
        case .longitude: return -180...180
        }
    }
    
    var name: String {
        switch self {
        case .latitude: return "Latitude"
        case .longitude: return "Longitude"
        }
    }
    
    var rangeError: String {
        switch self {
        case .latitude: return "Latitude must be between -90 and 90."
        case .longitude: return "Longitude must be between -180 and 180."
        }
    }
}

struct LocationValidator {
    typealias ValidationRule = (String, CoordinateType) -> String?
    
    static let coordinateRules: [ValidationRule] = [
        { value, type in
            value.trimmingCharacters(in: .whitespaces) != value ? "\(type.name) cannot contain whitespace." : nil
        },
        { value, _ in value.contains(",") ? "Decimals must use . instead of ," : nil },
        { value, type in
            value.filter({ $0 == "." }).count > 1 ? "\(type.name) cannot have multiple decimal points." : nil
        },
        { value, type in Double(value) == nil ? "\(type.name) must be a valid number." : nil },
        { value, type in
            guard let number = Double(value) else { return nil }
            if number.isInfinite { return "\(type.name) cannot be infinity." }
            if number.isNaN { return "\(type.name) cannot be NaN." }
            return nil
        },
        { value, type in
            guard let number = Double(value) else { return nil }
            return type.range.contains(number) ? nil : type.rangeError
        }
    ]
    
    static func validate(value: String, type: CoordinateType) -> String? {
        guard !value.isEmpty else { return nil }
        for rule in coordinateRules {
            if let error = rule(value, type) {
                return error
            }
        }
        return nil
    }
    
    static func validateLatitude(_ value: String) -> String? {
        validate(value: value, type: .latitude)
    }
    
    static func validateLongitude(_ value: String) -> String? {
        validate(value: value, type: .longitude)
    }
}
