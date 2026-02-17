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
    }

    func loadTasks() {
        tasks = dataStore.fetchTasks(includeArchived: false)
        if selectedTask == nil, let firstTask = tasks.first {
            selectedTask = firstTask
        }
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

    // Get recovery ratio - percentage of times user returned after a zero/missed day
    func getRecoveryRatio(for task: Task) -> Double {
        let calendar = Calendar.current
        let sortedEntries = task.entries.sorted { $0.date < $1.date }
        guard !sortedEntries.isEmpty else { return 0.0 }

        var missedDays = 0
        var returns = 0
        var previousWasZero = false

        for entry in sortedEntries {
            if entry.isNonZero && previousWasZero {
                // Returned after a zero day
                returns += 1
                previousWasZero = false
            } else if !entry.isNonZero {
                // Zero day
                previousWasZero = true
                missedDays += 1
            } else {
                previousWasZero = false
            }
        }

        // Also count returns after gaps
        var previousDate: Date?
        for entry in sortedEntries where entry.isNonZero {
            if let prevDate = previousDate {
                let daysDiff = calendar.dateComponents([.day], from: prevDate, to: entry.date).day ?? 0
                if daysDiff > 1 {
                    // Gap = missed days, returning after gap counts
                    missedDays += (daysDiff - 1)
                    returns += 1
                }
            }
            previousDate = entry.date
        }

        guard missedDays > 0 else { return 0.0 }
        return Double(returns) / Double(missedDays)
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
