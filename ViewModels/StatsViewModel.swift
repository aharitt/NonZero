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

    // Get recovery ratio - percentage of times user returned the next day after a zero day
    func getRecoveryRatio(for task: Task) -> Double {
        let calendar = Calendar.current
        let sortedEntries = task.entries.sorted { $0.date < $1.date }
        guard !sortedEntries.isEmpty else { return 0.0 }

        var zeroDays = 0
        var nextDayReturns = 0
        var previousDate: Date?
        var previousWasZero = false

        for entry in sortedEntries {
            if let prevDate = previousDate {
                let daysDiff = calendar.dateComponents([.day], from: prevDate, to: entry.date).day ?? 0

                // Check if previous day was a zero day (either no entry or didn't meet minimum)
                if previousWasZero && daysDiff == 1 && entry.isNonZero {
                    // User returned the next day after a zero day
                    nextDayReturns += 1
                }
            }

            // Track if current day is a zero day
            if !entry.isNonZero {
                previousWasZero = true
                zeroDays += 1
            } else {
                previousWasZero = false
            }

            previousDate = entry.date
        }

        // Check for gaps (days with no entries) as zero days
        if let firstEntry = sortedEntries.first, let lastEntry = sortedEntries.last {
            let totalDays = calendar.dateComponents([.day], from: firstEntry.date, to: lastEntry.date).day ?? 0
            let loggedDays = sortedEntries.count
            let gapDays = totalDays - loggedDays + 1
            if gapDays > 0 {
                zeroDays += gapDays
            }
        }

        guard zeroDays > 0 else { return 0.0 }
        return Double(nextDayReturns) / Double(zeroDays)
    }

    // Get days returned after miss - total non-zero days that came after a zero day
    func getDaysReturnedAfterMiss(for task: Task) -> Int {
        let calendar = Calendar.current
        let sortedEntries = task.entries.sorted { $0.date < $1.date }
        guard !sortedEntries.isEmpty else { return 0 }

        var daysAfterMiss = 0
        var previousDate: Date?
        var hadMiss = false

        for entry in sortedEntries {
            if let prevDate = previousDate {
                let daysDiff = calendar.dateComponents([.day], from: prevDate, to: entry.date).day ?? 0

                // Check if there was a gap or a zero entry
                if daysDiff > 1 {
                    hadMiss = true
                }
            }

            // If current entry is non-zero and we had a miss before, count it
            if entry.isNonZero && hadMiss {
                daysAfterMiss += 1
                hadMiss = false // Reset after counting
            } else if !entry.isNonZero {
                hadMiss = true // Mark as having a miss
            }

            previousDate = entry.date
        }

        return daysAfterMiss
    }
}
