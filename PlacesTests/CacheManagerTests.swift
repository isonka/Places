import XCTest
@testable import Places

final class CacheManagerTests: XCTestCase {
    var cacheManager: CacheManager!
    let testKey = "test_locations"

    override func setUp() {
        super.setUp()
        // Use .utility QoS for tests to avoid priority inversion warnings
        cacheManager = CacheManager(qos: .utility)
        // Clean up before each test
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(testKey).json")
        try? FileManager.default.removeItem(at: url)
    }

    func testSaveAndLoadLocationsResponse() async {
        let locations = [Location(name: "A", lat: 1.0, long: 2.0)]
        let response = LocationsResponse(locations: locations)
        await cacheManager.save(response, forKey: testKey)
        let loaded =  await cacheManager.load(LocationsResponse.self, forKey: testKey)
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.locations.count, 1)
        XCTAssertEqual(loaded?.locations.first?.name, "A")
    }

    func testLoadReturnsNilForMissingFile() async {
        let loaded = await cacheManager.load(LocationsResponse.self, forKey: "nonexistent_key")
        XCTAssertNil(loaded)
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
}
