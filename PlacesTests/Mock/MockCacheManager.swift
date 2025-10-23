//
//  MockCacheManager.swift
//  PlacesTests
//
//  Created by Onur Karsli on 23/10/2025.
//

import Foundation
@testable import Places

class MockCacheManager: CacheManagerProtocol {
    var saveCalled = false
    var loadCalled = false
    var savedKey: String?
    var loadedKey: String?
    var savedLocations: [Location]?
    var cachedLocations: [Location]?
    
    func save<T: Codable & Sendable>(_ object: T, forKey key: String) async {
        saveCalled = true
        savedKey = key
        if let locations = object as? [Location] {
            savedLocations = locations
        }
    }
    
    func load<T: Codable & Sendable>(_ type: T.Type, forKey key: String) async -> T? {
        loadCalled = true
        loadedKey = key
        if type == [Location].self {
            return cachedLocations as? T
        }
        return nil
    }
}
