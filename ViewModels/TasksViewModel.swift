import Foundation
import SwiftData

@MainActor
@Observable
class TasksViewModel {
    var tasks: [Task] = []
    var showingAddTask = false
    var editingTask: Task?
    var showingReorder = false

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

    func loadTasks() {
        tasks = dataStore.fetchTasks(includeArchived: false)
    }

    func addTask(name: String, type: TaskType, minimum: Double, goal: Double?, unit: String?, healthKitWorkout: String?, pushFitPro: Bool, icon: String?) {
        // Calculate next sort order
        let maxSortOrder = tasks.map(\.sortOrder).max() ?? 0

        let task = Task(
            name: name,
            taskType: type,
            minimumValue: minimum,
            goalValue: goal,
            unit: unit,
            healthKitWorkoutType: healthKitWorkout,
            pushFitProEnabled: pushFitPro,
            icon: icon,
            sortOrder: maxSortOrder + 1
        )
        dataStore.addTask(task)
        loadTasks()
    }

    func updateTask(_ task: Task, name: String, type: TaskType, minimum: Double, goal: Double?, unit: String?, healthKitWorkout: String?, pushFitPro: Bool, icon: String?) {
        task.name = name
        task.taskType = type
        task.minimumValue = minimum
        task.goalValue = goal
        task.unit = unit
        task.healthKitWorkoutType = healthKitWorkout
        task.pushFitProEnabled = pushFitPro
        task.icon = icon

        if let context = dataStore.context {
            try? context.save()
        }
        loadTasks()
    }

    func deleteTask(_ task: Task) {
        dataStore.deleteTask(task)
        loadTasks()
    }

    func archiveTask(_ task: Task) {
        task.isArchived = true
        if let context = dataStore.context {
            try? context.save()
        }
        loadTasks()
    }

    func reorderTasks(_ reorderedTasks: [Task]) {
        // Update sort order for all tasks
        for (index, task) in reorderedTasks.enumerated() {
            task.sortOrder = index
        }

        if let context = dataStore.context {
            try? context.save()
        }
        loadTasks()
    }
}
