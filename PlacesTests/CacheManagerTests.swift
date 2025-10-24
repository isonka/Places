import XCTest
@testable import Places

final class CacheManagerTests: XCTestCase {
    var cacheManager: CacheManagerProtocol!
    let testKey = "test_locations"

    override func setUp() async throws {
        try await super.setUp()
        cacheManager = MockCacheManager()
        await cacheManager.clearCache()
    }
    
    override func tearDown() async throws {
        await cacheManager.clearCache()
        try await super.tearDown()
    }

    func testSaveAndLoadLocationsResponse() async {
        let locations = [Location(name: "A", lat: 1.0, long: 2.0)]
        let response = LocationsResponse(locations: locations)
        
        await cacheManager.save(response, forKey: testKey)
        let loaded = await cacheManager.load(LocationsResponse.self, forKey: testKey)
        
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.locations.count, 1)
        XCTAssertEqual(loaded?.locations.first?.name, "A")
    }

    func testLoadReturnsNilForMissingFile() async {
        let loaded = await cacheManager.load(LocationsResponse.self, forKey: "nonexistent_key")
        XCTAssertNil(loaded)
    }
    
    func testSaveAndLoadMultipleEntries() async {
        let keys = ["key1", "key2", "key3"]
        
        for (index, key) in keys.enumerated() {
            let locations = [Location(name: "Location \(index)", lat: Double(index), long: Double(index))]
            let response = LocationsResponse(locations: locations)
            await cacheManager.save(response, forKey: key)
        }
        
        for (index, key) in keys.enumerated() {
            let loaded = await cacheManager.load(LocationsResponse.self, forKey: key)
            XCTAssertNotNil(loaded)
            XCTAssertEqual(loaded?.locations.first?.name, "Location \(index)")
        }
    }
    
    func testSaveOverwritesExistingData() async {
        let locations1 = [Location(name: "First", lat: 1.0, long: 2.0)]
        let response1 = LocationsResponse(locations: locations1)
        await cacheManager.save(response1, forKey: testKey)
        
        let locations2 = [Location(name: "Second", lat: 3.0, long: 4.0)]
        let response2 = LocationsResponse(locations: locations2)
        await cacheManager.save(response2, forKey: testKey)
        
        let loaded = await cacheManager.load(LocationsResponse.self, forKey: testKey)
        XCTAssertEqual(loaded?.locations.first?.name, "Second")
    }
    
    func testClearCache() async {
        for i in 0..<3 {
            let locations = [Location(name: "Location \(i)", lat: Double(i), long: Double(i))]
            let response = LocationsResponse(locations: locations)
            await cacheManager.save(response, forKey: "key\(i)")
        }
        
        let loaded1 = await cacheManager.load(LocationsResponse.self, forKey: "key0")
        XCTAssertNotNil(loaded1)
        
        await cacheManager.clearCache()
        
        for i in 0..<3 {
            let loaded = await cacheManager.load(LocationsResponse.self, forKey: "key\(i)")
            XCTAssertNil(loaded, "Cache should be cleared")
        }
    }

    func testThreadSafety() async {
        let locations = [Location(name: "B", lat: 3.0, long: 4.0)]
        let response = LocationsResponse(locations: locations)
                
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<10 {
                group.addTask { [cacheManager, testKey] in
                    await cacheManager?.save(response, forKey: testKey)
                    let loaded = await cacheManager?.load(LocationsResponse.self, forKey: testKey)
                    XCTAssertNotNil(loaded)
                }
            }
        }
        
        let loaded = await cacheManager.load(LocationsResponse.self, forKey: testKey)
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.locations.first?.name, "B")
    }
    
    func testConcurrentSavesAndLoads() async {
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<5 {
                group.addTask { [cacheManager] in
                    let locations = [Location(name: "Location \(i)", lat: Double(i), long: Double(i))]
                    let response = LocationsResponse(locations: locations)
                    await cacheManager?.save(response, forKey: "concurrent_key\(i)")
                }
            }
            
            for i in 0..<5 {
                group.addTask { [cacheManager] in
                    _ = await cacheManager?.load(LocationsResponse.self, forKey: "concurrent_key\(i)")
                }
            }
        }
        
        for i in 0..<5 {
            let loaded = await cacheManager.load(LocationsResponse.self, forKey: "concurrent_key\(i)")
            XCTAssertNotNil(loaded, "Concurrent save should succeed")
        }
    }
    
    func testCorruptedCacheIsHandledGracefully() async {
        // This test requires the real CacheManager to test file corruption
        let realCacheManager = await CacheManager(qos: .utility)
        let corruptedKey = "corrupted_test_key"
                
        let locations = [Location(name: "Test", lat: 1.0, long: 2.0)]
        let response = LocationsResponse(locations: locations)
        await realCacheManager.save(response, forKey: corruptedKey)
                
        let cacheDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let cacheURL = cacheDir.appendingPathComponent("\(corruptedKey).json")
        try? "corrupted data".write(to: cacheURL, atomically: true, encoding: .utf8)
        
        let loaded = await realCacheManager.load(LocationsResponse.self, forKey: corruptedKey)
        XCTAssertNil(loaded, "Corrupted cache should return nil")
                
        await realCacheManager.clearCache()
    }
    
    func testEmptyArrayCanBeCached() async {
        let response = LocationsResponse(locations: [])
        await cacheManager.save(response, forKey: testKey)
        
        let loaded = await cacheManager.load(LocationsResponse.self, forKey: testKey)
        XCTAssertNotNil(loaded)
        XCTAssertTrue(loaded?.locations.isEmpty ?? false)
    }
}
