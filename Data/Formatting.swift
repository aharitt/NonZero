import Foundation

enum Formatting {
    static func formatPercentage(_ value: Double) -> String {
        let percentage = value * 100
        return String(format: "%.0f%%", percentage)
    }
    
    static func formatDecimal(_ value: Double, decimals: Int = 1) -> String {
        return String(format: "%.\(decimals)f", value)
    }
    
    static func formatTime(minutes: Double) -> String {
        let totalMinutes = Int(minutes)
        if totalMinutes < 60 {
            return "\(totalMinutes)m"
        } else {
            let hours = totalMinutes / 60
            let remainingMinutes = totalMinutes % 60
            return remainingMinutes > 0 ? "\(hours)h \(remainingMinutes)m" : "\(hours)h"
        }
    }
    
    static func formatValue(_ value: Double, for taskType: TaskType) -> String {
        switch taskType {
        case .boolean:
            return value >= 1.0 ? "Yes" : "No"
        case .count:
            return "\(Int(value))"
        case .time:
            return formatTime(minutes: value)
        }
    }
    
    static func relativeDate(_ date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
}
