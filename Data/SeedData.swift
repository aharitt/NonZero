import Foundation
import SwiftData

@MainActor
class SeedData {
    static func createSampleData(in context: ModelContext) {
        // Check if data already exists
        let descriptor = FetchDescriptor<Task>()
        if let count = try? context.fetchCount(descriptor), count > 0 {
            return // Data already exists
        }

        loadSampleData(in: context)
    }

    static func loadSampleData(in context: ModelContext) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Create sample tasks
        let pushups = Task(
            name: "Pushups",
            taskType: .count,
            minimumValue: 1,
            goalValue: 20
        )
        pushups.sortOrder = 0

        let reading = Task(
            name: "Reading",
            taskType: .time,
            minimumValue: 5,
            goalValue: 30
        )
        reading.sortOrder = 1

        let meditation = Task(
            name: "Meditation",
            taskType: .boolean,
            minimumValue: 1
        )
        meditation.sortOrder = 2

        let focusWork = Task(
            name: "Focus Work",
            taskType: .time,
            minimumValue: 25,
            goalValue: 120
        )
        focusWork.sortOrder = 3

        context.insert(pushups)
        context.insert(reading)
        context.insert(meditation)
        context.insert(focusWork)

        // Create 30 days of realistic data with streaks, gaps, and comebacks
        for daysAgo in 0...29 {
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { continue }

            // Pushups: mostly consistent with a gap around day 10-12
            if daysAgo < 10 || daysAgo > 12 {
                let value = Double([5, 8, 10, 12, 15, 7, 20, 6, 3, 18, 14, 9, 11, 16, 22, 4, 13][daysAgo % 17])
                let entry = Entry(task: pushups, date: date, value: value)
                context.insert(entry)
            }

            // Reading: regular with a gap around day 15-18
            if daysAgo < 15 || daysAgo > 18 {
                let value = Double([10, 25, 5, 35, 15, 20, 8, 30, 12, 45, 6, 22, 18, 28, 40][daysAgo % 15])
                let entry = Entry(task: reading, date: date, value: value)
                context.insert(entry)
            }

            // Meditation: very consistent, missed only days 5 and 20
            if daysAgo != 5 && daysAgo != 20 {
                let entry = Entry(task: meditation, date: date, value: 1.0)
                context.insert(entry)
            }

            // Focus work: about every other day
            if daysAgo % 2 == 0 || daysAgo == 1 || daysAgo == 7 {
                let value = Double([30, 45, 60, 90, 25, 50, 35, 75, 40, 55, 120, 28, 65, 80, 38][daysAgo % 15])
                let entry = Entry(task: focusWork, date: date, value: value)
                context.insert(entry)
            }
        }

        do {
            try context.save()
        } catch {
            print("Failed to save seed data: \(error)")
        }
    }
}
