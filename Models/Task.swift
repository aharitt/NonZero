import Foundation
import SwiftData

enum TaskType: String, Codable, CaseIterable {
    case boolean = "Yes/No"
    case count = "Count"
    case duration = "Duration"
    case timer = "Timer"

    var displayName: String {
        return self.rawValue
    }
}

@Model
final class Task {
    var id: UUID
    var name: String
    var taskType: TaskType
    var minimumValue: Double
    var goalValue: Double?
    var unit: String? // Unit for count tasks (e.g., "pages", "cups", "steps")
    var healthKitWorkoutType: String? // HealthKit workout type for duration tasks
    var icon: String? // SF Symbol name for task icon
    var createdAt: Date
    var isArchived: Bool
    var sortOrder: Int // Order for manual sorting

    // Relationship
    @Relationship(deleteRule: .cascade, inverse: \Entry.task)
    var entries: [Entry] = []

    init(
        id: UUID = UUID(),
        name: String,
        taskType: TaskType,
        minimumValue: Double,
        goalValue: Double? = nil,
        unit: String? = nil,
        healthKitWorkoutType: String? = nil,
        icon: String? = nil,
        createdAt: Date = Date(),
        isArchived: Bool = false,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.taskType = taskType
        self.minimumValue = minimumValue
        self.goalValue = goalValue
        self.unit = unit
        self.healthKitWorkoutType = healthKitWorkoutType
        self.icon = icon
        self.createdAt = createdAt
        self.isArchived = isArchived
        self.sortOrder = sortOrder
    }

    // Helper to check if value meets minimum
    func meetsMinimum(value: Double) -> Bool {
        return value >= minimumValue
    }

    // Get entry for a specific date
    func entry(for date: Date) -> Entry? {
        let calendar = Calendar.current
        return entries.first { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }
    }

    // Check if task was completed on a specific date
    func isCompleted(on date: Date) -> Bool {
        guard let entry = entry(for: date) else { return false }
        return entry.isNonZero
    }

    // Get current streak
    func currentStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())

        while let entry = entry(for: currentDate), entry.isNonZero {
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }

        return streak
    }
}
