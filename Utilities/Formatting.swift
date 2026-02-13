import Foundation

struct Formatting {
    // Format time in minutes to readable string
    static func formatTime(minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes)m"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes > 0 {
                return "\(hours)h \(remainingMinutes)m"
            } else {
                return "\(hours)h"
            }
        }
    }

    // Format count
    static func formatCount(_ count: Int) -> String {
        return "\(count)"
    }

    // Format boolean
    static func formatBoolean(_ value: Bool) -> String {
        return value ? "Yes" : "No"
    }

    // Format percentage
    static func formatPercentage(_ value: Double) -> String {
        return String(format: "%.0f%%", value * 100)
    }

    // Format decimal
    static func formatDecimal(_ value: Double, places: Int = 1) -> String {
        return String(format: "%.\(places)f", value)
    }

    // Format streak
    static func formatStreak(_ days: Int) -> String {
        if days == 0 {
            return "No streak"
        } else if days == 1 {
            return "1 day"
        } else {
            return "\(days) days"
        }
    }

    // Format value based on task type
    static func formatValue(_ value: Double, for taskType: TaskType, unit: String? = nil) -> String {
        switch taskType {
        case .boolean:
            return formatBoolean(value >= 1.0)
        case .count:
            let countStr = formatCount(Int(value))
            if let unit = unit {
                return "\(countStr) \(unit.lowercased())"
            }
            return countStr
        case .time:
            return formatTime(minutes: Int(value))
        }
    }

    // Relative date formatting
    static func relativeDate(_ date: Date) -> String {
        if date.isToday {
            return "Today"
        } else if date.isYesterday {
            return "Yesterday"
        } else {
            let daysAgo = Date().daysBetween(date)
            if daysAgo <= 7 {
                return "\(daysAgo) days ago"
            } else {
                return date.shortDate
            }
        }
    }
}
