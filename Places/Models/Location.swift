import Foundation

nonisolated struct LocationsResponse: Codable, Sendable {
    let locations: [Location]
}

nonisolated struct Location: Codable, Identifiable, Sendable {
    let name: String?
    let lat: Double
    let long: Double
    
    var id: Int {
        var hasher = Hasher()
        hasher.combine(name ?? "")
        hasher.combine(lat)
        hasher.combine(long)
        return hasher.finalize()
    }
}
