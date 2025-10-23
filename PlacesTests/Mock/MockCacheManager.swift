//
//  MockCacheManager.swift
//  PlacesTests
//
//  Created by Onur Karsli on 23/10/2025.
//

import Foundation
@testable import Places

final class MockCacheManager: CacheManagerProtocol {
    var saveCalled = false
    var loadCalled = false
    var clearCacheCalled = false
    
    var savedKey: String?
    var loadedKey: String?
    var savedLocations: [Location]?
    var cachedLocations: [Location]?
    
    var shouldReturnCachedData = true
    private var storage: [String: Any] = [:]
    
    func save<T: Codable & Sendable>(_ object: T, forKey key: String) async {
        saveCalled = true
        savedKey = key
        storage[key] = object
        
        if let locations = object as? [Location] {
            savedLocations = locations
        }
    }
    
    func load<T: Codable & Sendable>(_ type: T.Type, forKey key: String) async -> T? {
        loadCalled = true
        loadedKey = key
        
        guard shouldReturnCachedData else {
            return nil
        }
        
        if let stored = storage[key] as? T {
            return stored
        }
        
        if type == [Location].self {
            return cachedLocations as? T
        }
        
        return nil
    }
    
    func clearCache() async {
        clearCacheCalled = true
        storage.removeAll()
        cachedLocations = nil
        savedLocations = nil
        reset()
    }
    
    func reset() {
        saveCalled = false
        loadCalled = false
        clearCacheCalled = false
        savedKey = nil
        loadedKey = nil
    }
    
    func setCachedData<T: Codable & Sendable>(_ data: T, forKey key: String) {
        storage[key] = data
    }
}
