import Foundation

protocol CacheManagerProtocol: Sendable {
    func save<T: Codable & Sendable>(_ object: T, forKey key: String) async
    func load<T: Codable & Sendable>(_ type: T.Type, forKey key: String) async -> T?
    func clearCache() async
}

struct CacheManager: CacheManagerProtocol {
    private let queue: DispatchQueue
    
    init(qos: DispatchQoS = .userInitiated) {
        self.queue = DispatchQueue(label: "com.places.cacheManager", qos: qos)
    }
    
    func save<T: Codable & Sendable>(_ object: T, forKey key: String) async {
        await withCheckedContinuation { continuation in
            queue.async {
                do {
                    let url = self.cacheFileURL(for: key)
                    let data = try JSONEncoder().encode(object)
                    try data.write(to: url, options: .atomic)
                } catch {
                    print("❌ Failed to cache object for key \(key): \(error)")
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
                
                do {
                    let decoded = try JSONDecoder().decode(type, from: data)
                    continuation.resume(returning: decoded)
                } catch {
                    print("❌ Failed to decode cache for key \(key): \(error)")
                    try? FileManager.default.removeItem(at: url)
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    func clearCache() async {
        await withCheckedContinuation { continuation in
            queue.async {
                do {
                    let cacheDir = self.cacheDirectory()
                    let files = try FileManager.default.contentsOfDirectory(
                        at: cacheDir,
                        includingPropertiesForKeys: nil
                    )
                    
                    for file in files where file.pathExtension == "json" {
                        try? FileManager.default.removeItem(at: file)
                    }
                } catch {
                    print("❌ Failed to clear cache: \(error)")
                }
                continuation.resume()
            }
        }
    }
    
    private func cacheDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func cacheFileURL(for key: String) -> URL {
        cacheDirectory().appendingPathComponent("\(key).json")
    }
}
