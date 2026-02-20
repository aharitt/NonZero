import Foundation
import SwiftData

@MainActor
@Observable
class StatsViewModel {
    var tasks: [Task] = []
    var selectedTask: Task?

    private let dataStore = DataStore.shared

    init() {
        loadTasks()
        setupNotificationObserver()
    }

    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            forName: .refreshBadge,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.loadTasks()
            }
        }
    }

    // Cached set of dates that are Non-Zero days
    var dayScoreNonZeroDates: Set<Date> = []

    func loadTasks() {
        tasks = dataStore.fetchTasks(includeArchived: false)
        if selectedTask == nil, let firstTask = tasks.first {
            selectedTask = firstTask
        }
        computeDayScoreData()
    }

    // MARK: - Day Score

    private func computeDayScoreData() {
        let calendar = Calendar.current
        guard !tasks.isEmpty else {
            dayScoreNonZeroDates = []
            return
        }

        let criteria = SettingsManager.shared.dayScoreCriteria
        let taskCount = tasks.count

        // Build a map: date -> count of completed tasks
        var dateCompletionCount: [Date: Int] = [:]
        for task in tasks {
            for entry in task.entries where entry.isNonZero {
                let date = calendar.startOfDay(for: entry.date)
                dateCompletionCount[date, default: 0] += 1
            }
        }

        var result: Set<Date> = []
        for (date, count) in dateCompletionCount {
            let percentage = Int(Double(count) / Double(taskCount) * 100)
            if percentage >= criteria {
                result.insert(date)
            }
        }

        dayScoreNonZeroDates = result
    }

    private var earliestTaskDate: Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: tasks.map(\.createdAt).min() ?? Date())
    }

    func dayScoreCurrentStreak() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0

        let todayIsNonZero = dayScoreNonZeroDates.contains(today)
        var currentDate = todayIsNonZero ? today : calendar.date(byAdding: .day, value: -1, to: today)!

        for _ in 0..<365 {
            if dayScoreNonZeroDates.contains(currentDate) {
                streak += 1
                guard let prev = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
                currentDate = prev
            } else {
                break
            }
        }

        return streak
    }

    func dayScoreLongestStreak() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startDate = earliestTaskDate

        var longest = 0
        var current = 0
        var date = startDate

        while date <= today {
            if dayScoreNonZeroDates.contains(date) {
                current += 1
                longest = max(longest, current)
            } else {
                current = 0
            }
            guard let next = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = next
        }

        return longest
    }

    func dayScoreTotalNonZeroDays() -> Int {
        dayScoreNonZeroDates.count
    }

    func dayScoreComebackCount() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startDate = earliestTaskDate

        var comebacks = 0
        var previousWasZero = false
        var date = startDate

        while date <= today {
            let isNonZero = dayScoreNonZeroDates.contains(date)
            if isNonZero && previousWasZero {
                comebacks += 1
            }
            previousWasZero = !isNonZero
            guard let next = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = next
        }

        return comebacks
    }

    func dayScoreResilienceIndex() -> Double? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startDate = earliestTaskDate
        let halfLife: Double = 30.0

        var weightedScoreSum: Double = 0
        var weightSum: Double = 0
        var consecutiveMissed = 0
        var previousWasZero = false
        var date = startDate

        while date <= today {
            let isNonZero = dayScoreNonZeroDates.contains(date)

            if isNonZero && previousWasZero {
                // Comeback event detected
                let comebackScore = 1.0 / (1.0 + Double(consecutiveMissed - 1) * 0.5)
                let ageDays = Double(calendar.dateComponents([.day], from: date, to: today).day ?? 0)
                let weight = pow(0.5, ageDays / halfLife)
                weightedScoreSum += comebackScore * weight
                weightSum += weight
                consecutiveMissed = 0
            }

            if !isNonZero {
                consecutiveMissed += 1
            } else {
                consecutiveMissed = 0
            }

            previousWasZero = !isNonZero
            guard let next = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = next
        }

        guard weightSum > 0 else { return nil }
        return weightedScoreSum / weightSum
    }

    func dayScoreDaysReturnedAfterMiss() -> Int {
        // Same as comebackCount for day score (every calendar day is tracked, no gaps)
        dayScoreComebackCount()
    }

    func dayScoreCompletionRate(days: Int) -> Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var completed = 0

        for i in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            if dayScoreNonZeroDates.contains(date) {
                completed += 1
            }
        }

        return Double(completed) / Double(days)
    }

    func getCompletionRate(for task: Task, days: Int = 7) -> Double {
        let calendar = Calendar.current
        let endDate = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -days + 1, to: endDate) else {
            return 0.0
        }

        var completedDays = 0
        var currentDate = startDate

        while currentDate <= endDate {
            if task.isCompleted(on: currentDate) {
                completedDays += 1
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return Double(completedDays) / Double(days)
    }

    func getWeekData(for task: Task) -> [(date: Date, value: Double, isNonZero: Bool)] {
        let calendar = Calendar.current
        let endDate = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -6, to: endDate) else {
            return []
        }

        var data: [(date: Date, value: Double, isNonZero: Bool)] = []
        var currentDate = startDate

        while currentDate <= endDate {
            if let entry = task.entry(for: currentDate) {
                data.append((date: currentDate, value: entry.value, isNonZero: entry.isNonZero))
            } else {
                data.append((date: currentDate, value: 0.0, isNonZero: false))
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return data
    }

    func getAverageValue(for task: Task, days: Int = 7) -> Double {
        let calendar = Calendar.current
        let endDate = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -days + 1, to: endDate) else {
            return 0.0
        }

        let entries = dataStore.fetchEntries(for: task, from: startDate, to: endDate)
        guard !entries.isEmpty else { return 0.0 }

        let total = entries.reduce(0.0) { $0 + $1.value }
        return total / Double(days)
    }

    // Resilience Index: recency-weighted comeback score
    // Returns nil if no comeback events exist
    func getResilienceIndex(for task: Task) -> Double? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let taskCreated = calendar.startOfDay(for: task.createdAt)
        let halfLife: Double = 30.0

        var weightedScoreSum: Double = 0
        var weightSum: Double = 0
        var consecutiveMissed = 0
        var previousWasZero = false
        var date = taskCreated

        while date <= today {
            let isNonZero = task.isCompleted(on: date)

            if isNonZero && previousWasZero {
                let comebackScore = 1.0 / (1.0 + Double(consecutiveMissed - 1) * 0.5)
                let ageDays = Double(calendar.dateComponents([.day], from: date, to: today).day ?? 0)
                let weight = pow(0.5, ageDays / halfLife)
                weightedScoreSum += comebackScore * weight
                weightSum += weight
                consecutiveMissed = 0
            }

            if !isNonZero {
                consecutiveMissed += 1
            } else {
                consecutiveMissed = 0
            }

            previousWasZero = !isNonZero
            guard let next = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = next
        }

        guard weightSum > 0 else { return nil }
        return weightedScoreSum / weightSum
    }

    // Get days returned after miss - total non-zero days that came after a zero day or gap
    func getDaysReturnedAfterMiss(for task: Task) -> Int {
        let calendar = Calendar.current
        let sortedEntries = task.entries.sorted { $0.date < $1.date }
        guard !sortedEntries.isEmpty else { return 0 }

        var daysAfterMiss = 0
        var previousWasZero = false
        var previousDate: Date?

        for entry in sortedEntries {
            // Check for gap
            if let prevDate = previousDate {
                let daysDiff = calendar.dateComponents([.day], from: prevDate, to: entry.date).day ?? 0
                if daysDiff > 1 {
                    // Gap before this entry
                    if entry.isNonZero {
                        daysAfterMiss += 1
                    }
                    previousWasZero = !entry.isNonZero
                    previousDate = entry.date
                    continue
                }
            }

            // Check for zero-to-non-zero transition
            if entry.isNonZero && previousWasZero {
                daysAfterMiss += 1
            }

            previousWasZero = !entry.isNonZero
            previousDate = entry.date
        }

        return daysAfterMiss
    }
}
