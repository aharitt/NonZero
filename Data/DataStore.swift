import Foundation
import SwiftData

@MainActor
class DataStore {
    static let shared = DataStore()

    var container: ModelContainer?
    var context: ModelContext?

    private init() {
        // Container and context will be set from the app initialization
    }

    // MARK: - Task Operations

    func fetchTasks(includeArchived: Bool = false) -> [Task] {
        guard let context = context else { return [] }

        let descriptor = FetchDescriptor<Task>(
            predicate: includeArchived ? nil : #Predicate { !$0.isArchived },
            sortBy: [SortDescriptor(\.sortOrder), SortDescriptor(\.createdAt)]
        )

        do {
            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch tasks: \(error)")
            return []
        }
    }

    func addTask(_ task: Task) {
        guard let context = context else { return }
        context.insert(task)
        saveContext()
    }

    func deleteTask(_ task: Task) {
        guard let context = context else { return }
        context.delete(task)
        saveContext()
    }

    // MARK: - Entry Operations

    func addEntry(_ entry: Entry) {
        guard let context = context else { return }
        context.insert(entry)
        saveContext()
    }

    func updateEntry(_ entry: Entry, value: Double, note: String?) {
        entry.value = value
        entry.note = note
        saveContext()
    }

    func deleteEntry(_ entry: Entry) {
        guard let context = context else { return }
        context.delete(entry)
        saveContext()
    }

    func fetchEntries(for task: Task, from startDate: Date, to endDate: Date) -> [Entry] {
        guard let context = context else { return [] }

        let descriptor = FetchDescriptor<Entry>(
            sortBy: [SortDescriptor(\.date)]
        )

        do {
            let allEntries = try context.fetch(descriptor)
            return allEntries.filter { entry in
                entry.task?.id == task.id &&
                entry.date >= startDate &&
                entry.date <= endDate
            }
        } catch {
            print("Failed to fetch entries: \(error)")
            return []
        }
    }

    func deleteAllData() {
        guard let context = context else { return }

        // Delete all tasks — entries are cascade-deleted automatically
        let descriptor = FetchDescriptor<Task>()
        do {
            let allTasks = try context.fetch(descriptor)
            for task in allTasks {
                context.delete(task)
            }
            saveContext()
        } catch {
            print("Failed to delete all data: \(error)")
        }
    }

    func deleteAllEntries() {
        guard let context = context else { return }

        let descriptor = FetchDescriptor<Entry>()

        do {
            let allEntries = try context.fetch(descriptor)
            for entry in allEntries {
                context.delete(entry)
            }
            saveContext()
        } catch {
            print("Failed to delete all entries: \(error)")
        }
    }

    // MARK: - Helper Methods

    func isNonZeroDay(date: Date) -> Bool {
        guard let context = context else { return false }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let descriptor = FetchDescriptor<Entry>(
            predicate: #Predicate<Entry> { entry in
                entry.date >= startOfDay && entry.date < endOfDay
            }
        )

        do {
            let entries = try context.fetch(descriptor)
            return entries.contains { $0.isNonZero }
        } catch {
            return false
        }
    }

    private func saveContext() {
        guard let context = context else { return }

        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
