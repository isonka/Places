import Foundation

protocol CacheManagerProtocol: Sendable {
    func save<T: Codable & Sendable>(_ object: T, forKey key: String) async
    func load<T: Codable & Sendable>(_ type: T.Type, forKey key: String) async -> T?
    func clearCache() async
}

struct CacheManager: CacheManagerProtocol {
    private let queue: DispatchQueue
    private let logger: LoggingServiceProtocol = LoggingService.shared
    
    init(qos: DispatchQoS = .userInitiated) {
        self.queue = DispatchQueue(label: "com.places.cacheManager", qos: qos)        
        logger.debug("CacheManager initialized")
    }
    
    func save<T: Codable & Sendable>(_ object: T, forKey key: String) async {
        await withCheckedContinuation { continuation in
            queue.async {
                do {
                    let url = self.cacheFileURL(for: key)
                    let data = try JSONEncoder().encode(object)
                    try data.write(to: url, options: .atomic)
                    self.logger.debug("Successfully cached object for key: \(key)")
                } catch {
                    self.logger.error("Failed to cache object for key \(key): \(error.localizedDescription)")
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
                    self.logger.debug("No cached data found for key: \(key)")
                    continuation.resume(returning: nil)
                    return
                }
                
                do {
                    let decoded = try JSONDecoder().decode(type, from: data)
                    self.logger.info("Successfully loaded cached data for key: \(key)")
                    continuation.resume(returning: decoded)
                } catch {
                    self.logger.error("Failed to decode cache for key \(key): \(error.localizedDescription)")
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
                    
                    let removedCount = files.filter { $0.pathExtension == "json" }.count
                    
                    for file in files where file.pathExtension == "json" {
                        try? FileManager.default.removeItem(at: file)
                    }
                    
                    self.logger.info("Cache cleared: \(removedCount) file(s) removed")
                } catch {
                    self.logger.error("Failed to clear cache: \(error.localizedDescription)")
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
