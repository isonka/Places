import Foundation

extension Date {
    /// Returns a human-readable "time ago" string from this date to now
    /// Examples: "just now", "5 minutes ago", "2 hours ago", "3 days ago"
    var timeAgoString: String {
        let interval = Date().timeIntervalSince(self)
        
        switch interval {
        case 0..<60:
            return "just now"
        case 60..<3600:
            let minutes = Int(interval / 60)
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        case 3600..<86400:
            let hours = Int(interval / 3600)
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        default:
            let days = Int(interval / 86400)
            return "\(days) day\(days == 1 ? "" : "s") ago"
        }
    }
}

