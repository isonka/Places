import Foundation

extension Date {
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

