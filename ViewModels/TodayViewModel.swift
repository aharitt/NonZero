import Foundation
import SwiftData

@MainActor
@Observable
class TodayViewModel {
    var tasks: [Task] = []
    var todayEntries: [UUID: Entry] = [:]
    var selectedTask: Task?
    var showingEntryEditor = false

    private let dataStore = DataStore.shared
    private let timerManager = TimerManager.shared
    var today: Date {
        Calendar.current.startOfDay(for: Date())
    }

    init() {
        loadData()
        setupNotificationObserver()
    }

    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            forName: .refreshBadge,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.loadData()
            }
        }
    }

    func loadData() {
        tasks = dataStore.fetchTasks(includeArchived: false)
        loadTodayEntries()
        updateBadge()
        updateAppIcon()
    }

    private func updateBadge() {
        AppBadgeManager.shared.updateBadge(tasks: tasks, todayEntries: todayEntries)
    }

    private func updateAppIcon() {
        let completionPercentage = AppIconManager.shared.calculateTodayCompletion(tasks: tasks)
        AppIconManager.shared.updateIcon(completionPercentage: completionPercentage)
    }

    private func loadTodayEntries() {
        todayEntries.removeAll()

        for task in tasks {
            if let entry = task.entry(for: today) {
                todayEntries[task.id] = entry
            }
        }
    }

    func getEntry(for task: Task) -> Entry? {
        return todayEntries[task.id]
    }

    func quickLog(task: Task, value: Double) {
        let wasNonZero = getEntry(for: task)?.isNonZero ?? false

        if let existingEntry = getEntry(for: task) {
            // Update existing entry
            dataStore.updateEntry(existingEntry, value: value, note: existingEntry.note)
        } else {
            // Create new entry
            let entry = Entry(task: task, date: today, value: value)
            dataStore.addEntry(entry)
        }

        // Play sound if task became non-zero
        let isNowNonZero = value >= task.minimumValue
        if !wasNonZero && isNowNonZero {
            SoundManager.shared.playSuccessSound()
        } else {
            SoundManager.shared.playTapSound()
        }

        loadData()
    }

    func toggleBoolean(task: Task) {
        let currentValue = getEntry(for: task)?.value ?? 0.0
        let newValue = currentValue >= 1.0 ? 0.0 : 1.0
        quickLog(task: task, value: newValue)
    }

    func incrementCount(task: Task, by amount: Double = 1.0) {
        let currentValue = getEntry(for: task)?.value ?? 0.0
        quickLog(task: task, value: currentValue + amount)
    }

    func addTime(task: Task, minutes: Double) {
        let currentValue = getEntry(for: task)?.value ?? 0.0
        quickLog(task: task, value: currentValue + minutes)
    }

    // Timer-specific methods
    func isTimerRunning(for task: Task) -> Bool {
        return timerManager.isRunning(taskId: task.id)
    }

    func getTimerElapsedTime(for task: Task) -> String {
        guard timerManager.isRunning(taskId: task.id) else { return "0:00" }
        // Access lastUpdate to ensure view tracks timer changes
        _ = timerManager.lastUpdate
        return timerManager.formattedElapsedTime
    }

    func startTimer(for task: Task) {
        timerManager.startTimer(for: task.id)
    }

    func stopTimer(for task: Task) {
        let elapsedMinutes = timerManager.stopTimer(for: task.id)

        // Add the elapsed time to today's entry
        if elapsedMinutes > 0 {
            addTime(task: task, minutes: elapsedMinutes)
        }
    }

    func openEntryEditor(for task: Task) {
        selectedTask = task
        showingEntryEditor = true
    }

    func saveEntry(task: Task, value: Double, note: String?) {
        let wasNonZero = getEntry(for: task)?.isNonZero ?? false

        if let existingEntry = getEntry(for: task) {
            dataStore.updateEntry(existingEntry, value: value, note: note)
        } else {
            let entry = Entry(task: task, date: today, value: value, note: note)
            dataStore.addEntry(entry)
        }

        // Play sound if task became non-zero
        let isNowNonZero = value >= task.minimumValue
        if !wasNonZero && isNowNonZero {
            SoundManager.shared.playSuccessSound()
        } else if value > 0 {
            SoundManager.shared.playTapSound()
        }

        loadData()
    }

    func getSuggestion(for task: Task) -> String? {
        // Get yesterday's entry
        let calendar = Calendar.current
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
              let yesterdayEntry = task.entry(for: yesterday) else {
            return nil
        }

        switch task.taskType {
        case .boolean:
            return yesterdayEntry.value >= 1.0 ? "Keep the streak going!" : nil
        case .count:
            let suggested = Int(yesterdayEntry.value) + 1
            return "Yesterday: \(Int(yesterdayEntry.value)). Try \(suggested) today?"
        case .time:
            let minutes = Int(yesterdayEntry.value)
            let suggested = minutes + 5
            return "Yesterday: \(minutes)m. Try \(suggested)m today?"
        }
    }

    // Sync HealthKit data for tasks that have HealthKit integration
    func syncHealthKitData() async {
        let healthKitManager = HealthKitManager.shared

        // Request authorization if not already authorized
        if !healthKitManager.isAuthorized {
            do {
                try await healthKitManager.requestAuthorization()
            } catch {
                print("HealthKit authorization failed: \(error)")
                return
            }
        }

        // Sync data for tasks with HealthKit integration (only time tasks support HealthKit)
        for task in tasks where task.taskType == .time && task.healthKitWorkoutType != nil {
            do {
                let workoutType = healthKitManager.workoutType(from: task.healthKitWorkoutType)
                let minutes = try await healthKitManager.fetchWorkoutMinutes(for: today, workoutType: workoutType)

                if minutes > 0 {
                    // Update or create entry with HealthKit data
                    if let existingEntry = getEntry(for: task) {
                        // Only update if HealthKit has more time
                        if minutes > existingEntry.value {
                            dataStore.updateEntry(existingEntry, value: minutes, note: "Synced from Fitness app")
                        }
                    } else {
                        let entry = Entry(task: task, date: today, value: minutes, note: "Synced from Fitness app")
                        dataStore.addEntry(entry)
                    }
                }
            } catch {
                print("Failed to sync HealthKit data for \(task.name): \(error)")
            }
        }

        loadData()
    }
}
