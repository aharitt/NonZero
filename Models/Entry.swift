import Foundation
import SwiftData

@Model
final class Entry {
    var id: UUID
    var date: Date // Normalized to start of day
    var value: Double // Bool stored as 0/1, count as number, time in minutes
    var note: String?
    var createdAt: Date

    // Relationship
    var task: Task?

    init(
        id: UUID = UUID(),
        task: Task,
        date: Date,
        value: Double,
        note: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.task = task
        // Normalize date to start of day
        self.date = Calendar.current.startOfDay(for: date)
        self.value = value
        self.note = note
        self.createdAt = createdAt
    }

    // Check if this entry counts as "non-zero"
    var isNonZero: Bool {
        guard let task = task else { return false }
        return task.meetsMinimum(value: value)
    }

    // Display value based on task type
    var displayValue: String {
        guard let task = task else { return "\(value)" }

        switch task.taskType {
        case .boolean:
            return value >= 1.0 ? "Yes" : "No"
        case .count:
            let countStr = "\(Int(value))"
            if let unit = task.unit {
                return "\(countStr) \(unit.lowercased())"
            }
            return countStr
        case .time:
            let minutes = Int(value)
            if minutes < 60 {
                return "\(minutes)m"
            } else {
                let hours = minutes / 60
                let remainingMinutes = minutes % 60
                return remainingMinutes > 0 ? "\(hours)h \(remainingMinutes)m" : "\(hours)h"
            }
        }
    }
}
