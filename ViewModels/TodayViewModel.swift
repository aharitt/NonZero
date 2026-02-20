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
    private let settingsManager = SettingsManager.shared
    var today: Date {
        Calendar.current.startOfDay(for: Date())
    }

    // Stored properties updated by loadData() to avoid SwiftData relationship
    // traversal in computed properties, which can cause observation loops
    var dayScorePercentage: Int = 0
    var isNonZeroDay: Bool = false

    private func updateDayScore() {
        guard !tasks.isEmpty else {
            dayScorePercentage = 0
            isNonZeroDay = false
            return
        }
        let completedCount = tasks.filter { task in
            guard let entry = todayEntries[task.id] else { return false }
            return task.meetsMinimum(value: entry.value)
        }.count
        dayScorePercentage = Int(Double(completedCount) / Double(tasks.count) * 100)
        isNonZeroDay = dayScorePercentage >= settingsManager.dayScoreCriteria
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
        updateDayScore()
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

    func startTimer(for task: Task) {
        timerManager.startTimer(for: task.id, taskName: task.name)
    }

    func stopTimer(for task: Task) {
        let elapsedMinutes = timerManager.stopTimer(for: task.id)

        // Defer data save to next run loop so UI updates immediately
        _Concurrency.Task { @MainActor in
            if elapsedMinutes > 0 {
                addTime(task: task, minutes: elapsedMinutes)
            }
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
        // Don't show suggestion if task is already completed today
        if let todayEntry = getEntry(for: task), todayEntry.isNonZero {
            return nil
        }

        let calendar = Calendar.current

        // Check yesterday
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else {
            return nil
        }

        let yesterdayEntry = task.entry(for: yesterday)
        let didYesterday = yesterdayEntry?.isNonZero ?? false

        // Don't show motivational speech if they did it yesterday
        if didYesterday {
            return nil
        }

        // Focus on comeback! Check how many days they've missed
        let missedDays = countConsecutiveMissedDays(for: task, endingOn: yesterday)

        // Don't show message for brand new tasks (0 missed days)
        if missedDays == 0 {
            return nil
        }

        switch task.taskType {
        case .boolean:
            if missedDays >= 6 {
                return "You don't need perfect. Just one non-zero today."
            } else if missedDays >= 3 {
                let daysWord = missedDays == 3 ? "Three" : missedDays == 4 ? "Four" : "Five"
                return "\(daysWord) days paused. No worries. Just start small."
            } else if missedDays == 2 {
                return "Two quiet days. Let's move again."
            } else {
                return "Yesterday was zero. Today doesn't have to be."
            }

        case .count:
            if missedDays >= 6 {
                return "You don't need perfect. Just one non-zero today."
            } else if missedDays >= 3 {
                let daysWord = missedDays == 3 ? "Three" : missedDays == 4 ? "Four" : "Five"
                return "\(daysWord) days paused. No worries. Just start small."
            } else if missedDays == 2 {
                return "Two quiet days. Let's move again."
            } else if missedDays == 1 {
                if let lastValue = yesterdayEntry?.value, lastValue > 0 {
                    // They logged but didn't reach minimum
                    let suggested = Int(task.minimumValue)
                    return "Almost there yesterday! Try \(suggested) today?"
                } else {
                    return "Yesterday was zero. Today doesn't have to be."
                }
            } else {
                return nil
            }

        case .time:
            if missedDays >= 6 {
                return "You don't need perfect. Just one non-zero today."
            } else if missedDays >= 3 {
                let daysWord = missedDays == 3 ? "Three" : missedDays == 4 ? "Four" : "Five"
                return "\(daysWord) days paused. No worries. Just start small."
            } else if missedDays == 2 {
                return "Two quiet days. Let's move again."
            } else if missedDays == 1 {
                if let lastValue = yesterdayEntry?.value, lastValue > 0 {
                    // They logged but didn't reach minimum
                    let suggested = Int(task.minimumValue)
                    return "Almost there! Try \(suggested)m today?"
                } else {
                    return "Yesterday was zero. Today doesn't have to be."
                }
            } else {
                return nil
            }
        }
    }

    private func countConsecutiveMissedDays(for task: Task, endingOn endDate: Date) -> Int {
        let calendar = Calendar.current
        var count = 0
        var currentDate = endDate

        // Get the task's creation date (start of day)
        let taskCreatedDate = calendar.startOfDay(for: task.createdAt)

        // Count backwards up to 30 days or until task creation date
        for _ in 0..<30 {
            // Stop if we've gone before the task was created
            if currentDate < taskCreatedDate {
                break
            }

            if let entry = task.entry(for: currentDate), entry.isNonZero {
                // Found a completed day, stop counting
                break
            }

            count += 1

            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                break
            }
            currentDate = previousDay
        }

        return count
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
                let healthKitType = task.healthKitWorkoutType!
                print("📊 Syncing HealthKit for task: \(task.name), type: \(healthKitType)")

                let minutes = try await healthKitManager.fetchMinutes(for: today, healthKitType: healthKitType)
                print("📊 Found \(minutes) minutes from HealthKit")

                if minutes > 0 {
                    // Update or create entry with HealthKit data
                    if let existingEntry = getEntry(for: task) {
                        // Only update if HealthKit has more time
                        if minutes > existingEntry.value {
                            print("📊 Updating existing entry from \(existingEntry.value) to \(minutes) minutes")
                            dataStore.updateEntry(existingEntry, value: minutes, note: "Synced from Fitness app")
                        } else {
                            print("📊 Existing entry (\(existingEntry.value) min) already >= HealthKit (\(minutes) min)")
                        }
                    } else {
                        print("📊 Creating new entry with \(minutes) minutes")
                        let entry = Entry(task: task, date: today, value: minutes, note: "Synced from Fitness app")
                        dataStore.addEntry(entry)
                    }
                } else {
                    print("📊 No workout data found for today")
                }
            } catch {
                print("❌ Failed to sync HealthKit data for \(task.name): \(error)")
            }
        }

        loadData()
    }
}
