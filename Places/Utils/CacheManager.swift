import Foundation

protocol CacheManagerProtocol {
    func save<T: Codable & Sendable>(_ object: T, forKey key: String) async
    func load<T: Codable & Sendable>(_ type: T.Type, forKey key: String) async -> T?
}

struct CacheManager: CacheManagerProtocol {
    private let queue: DispatchQueue
    
    init(qos: DispatchQoS = .userInteractive) {
        self.queue = DispatchQueue(label: "com.places.cacheManager", qos: qos)
    }
    
    func save<T: Codable & Sendable>(_ object: T, forKey key: String) async {
        await withCheckedContinuation { continuation in
            queue.async {
                let url = self.cacheFileURL(for: key)
                do {
                    let data = try JSONEncoder().encode(object)
                    try data.write(to: url)
                } catch {
                    print("Failed to cache object for key \(key): \(error)")
                }
                continuation.resume()
            }
        }
    }
    
    func load<T: Codable & Sendable>(_ type: T.Type, forKey key: String) async -> T? {
        await withCheckedContinuation { continuation in
            queue.async {
                let url = self.cacheFileURL(for: key)
                guard let data = try? Data(contentsOf: url) else {
                    continuation.resume(returning: nil)
                    return
                }
                let decoded = try? JSONDecoder().decode(type, from: data)
                continuation.resume(returning: decoded)
            }
        }
    }
    
    private func cacheFileURL(for key: String) -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("\(key).json")
    }
}
