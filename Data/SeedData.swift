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

        // Create sample tasks
        let pushups = Task(
            name: "Pushups",
            taskType: .count,
            minimumValue: 1,
            goalValue: 20,
            icon: "dumbbell.fill"
        )

        let reading = Task(
            name: "Reading",
            taskType: .time,
            minimumValue: 5,
            goalValue: 30,
            icon: "book.fill"
        )

        let meditation = Task(
            name: "Meditation",
            taskType: .boolean,
            minimumValue: 1,
            icon: "moon.stars.fill"
        )

        let focusWork = Task(
            name: "Focus Work",
            taskType: .time,
            minimumValue: 25,
            goalValue: 120,
            icon: "flame.fill"
        )

        context.insert(pushups)
        context.insert(reading)
        context.insert(meditation)
        context.insert(focusWork)

        // Create some sample entries for the past week
        let calendar = Calendar.current
        for daysAgo in 0...6 {
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date())!

            // Add entries for pushups (increasing over time)
            let pushupEntry = Entry(
                task: pushups,
                date: date,
                value: Double(3 + daysAgo)
            )
            context.insert(pushupEntry)

            // Add entries for reading (varying times)
            if daysAgo % 2 == 0 {
                let readingEntry = Entry(
                    task: reading,
                    date: date,
                    value: Double(15 + daysAgo * 2)
                )
                context.insert(readingEntry)
            }

            // Add meditation entries (most days)
            if daysAgo != 3 {
                let meditationEntry = Entry(
                    task: meditation,
                    date: date,
                    value: 1.0
                )
                context.insert(meditationEntry)
            }

            // Add focus work entries (some days)
            if daysAgo % 3 == 0 {
                let focusEntry = Entry(
                    task: focusWork,
                    date: date,
                    value: Double(30 + daysAgo * 5)
                )
                context.insert(focusEntry)
            }
        }

        do {
            try context.save()
        } catch {
            print("Failed to save seed data: \(error)")
        }
    }
}
