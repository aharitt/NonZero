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

    func getCurrentStreak(for task: Task) -> Int {
        return task.currentStreak()
    }

    func getLongestStreak(for task: Task) -> Int {
        let calendar = Calendar.current
        var longestStreak = 0
        var currentStreak = 0

        // Sort entries by date
        let sortedEntries = task.entries.sorted { $0.date < $1.date }
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

    func getTotalValue(for task: Task) -> Double {
        return task.entries.reduce(0) { $0 + $1.value }
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

    // Get comeback count - number of times user restarted after breaking a streak
    func getComebackCount(for task: Task) -> Int {
        let calendar = Calendar.current
        var comebacks = 0
        var wasInStreak = false
        var brokStreak = false

        // Sort entries by date
        let sortedEntries = task.entries.sorted { $0.date < $1.date }
        guard !sortedEntries.isEmpty else { return 0 }

        var previousDate: Date?

        for entry in sortedEntries {
            if let prevDate = previousDate {
                let daysDiff = calendar.dateComponents([.day], from: prevDate, to: entry.date).day ?? 0

                if entry.isNonZero {
                    if daysDiff > 1 && wasInStreak {
                        // Comeback after breaking a streak
                        brokStreak = true
                    }

                    if brokStreak {
                        comebacks += 1
                        brokStreak = false
                    }

                    wasInStreak = true
                } else {
                    // Entry exists but didn't meet minimum
                    if wasInStreak {
                        brokStreak = true
                        wasInStreak = false
                    }
                }
            } else {
                // First entry
                if entry.isNonZero {
                    wasInStreak = true
                }
            }

            previousDate = entry.date
        }

        return comebacks
    }

    // Get total non-zero days (days where minimum was met)
    func getTotalNonZeroDays(for task: Task) -> Int {
        return task.entries.filter { $0.isNonZero }.count
    }

    // Get total logged days (any entry, even if below minimum)
    func getTotalLoggedDays(for task: Task) -> Int {
        return task.entries.count
    }
}
