import Foundation
import SwiftData

enum TaskType: String, Codable, CaseIterable {
    case boolean = "Yes/No"
    case count = "Count"
    case time = "Time"

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
    var healthKitWorkoutType: String? // HealthKit workout type for time tasks
    var pushFitProEnabled: Bool // PushFit Pro integration for count tasks
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
        pushFitProEnabled: Bool = false,
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
        self.pushFitProEnabled = pushFitProEnabled
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
        let today = calendar.startOfDay(for: Date())
        var streak = 0

        // Check if today is completed
        let todayCompleted = isCompleted(on: today)

        // If today is completed, start from today; otherwise start from yesterday
        var currentDate = todayCompleted ? today : calendar.date(byAdding: .day, value: -1, to: today)!

        // Count consecutive completed days backwards
        while let entry = entry(for: currentDate), entry.isNonZero {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                break
            }
            currentDate = previousDay
        }

        return streak
    }

    // Get longest streak ever
    func longestStreak() -> Int {
        let calendar = Calendar.current
        var longestStreak = 0
        var currentStreak = 0

        // Sort entries by date
        let sortedEntries = entries.sorted { $0.date < $1.date }
        var previousDate: Date?

        for entry in sortedEntries where entry.isNonZero {
            if let prevDate = previousDate {
                let daysDiff = calendar.dateComponents([.day], from: prevDate, to: entry.date).day ?? 0
                if daysDiff == 1 {
                    currentStreak += 1
                } else {
                    longestStreak = max(longestStreak, currentStreak)
                    currentStreak = 1
                }
            } else {
                currentStreak = 1
            }
            previousDate = entry.date
        }

        longestStreak = max(longestStreak, currentStreak)
        return longestStreak
    }

    // MARK: - Statistics

    /// Total sum of all entry values
    func totalValue() -> Double {
        return entries.reduce(0) { $0 + $1.value }
    }

    /// Total number of non-zero days (days where minimum was met)
    func totalNonZeroDays() -> Int {
        return entries.filter { $0.isNonZero }.count
    }

    /// Total number of logged days (any entry, even if below minimum)
    func totalLoggedDays() -> Int {
        return entries.count
    }

    /// Number of times user came back after a zero day
    /// A comeback = any non-zero day that follows a zero day (or gap)
    func comebackCount() -> Int {
        let calendar = Calendar.current
        var comebacks = 0

        // Sort entries by date
        let sortedEntries = entries.sorted { $0.date < $1.date }
        guard !sortedEntries.isEmpty else { return 0 }

        var previousWasZero = false

        for entry in sortedEntries {
            if entry.isNonZero && previousWasZero {
                // Current day is non-zero and previous day was zero = comeback!
                comebacks += 1
                previousWasZero = false
            } else if !entry.isNonZero {
                // Current day is zero
                previousWasZero = true
            } else {
                // Current day is non-zero, previous was also non-zero
                previousWasZero = false
            }
        }

        // Also check for comebacks after gaps (missing days)
        var previousDate: Date?
        for entry in sortedEntries where entry.isNonZero {
            if let prevDate = previousDate {
                let daysDiff = calendar.dateComponents([.day], from: prevDate, to: entry.date).day ?? 0
                // If there's a gap of more than 1 day, count it as a comeback
                if daysDiff > 1 {
                    comebacks += 1
                }
            }
            previousDate = entry.date
        }

        return comebacks
    }
}
