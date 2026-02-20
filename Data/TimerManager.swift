import Foundation
import ActivityKit

@MainActor
@Observable
class TimerManager {
    static let shared = TimerManager()

    // Current running timer state
    var runningTaskId: UUID?
    var startTime: Date?
    var accumulatedSeconds: TimeInterval = 0

    // Live Activity for lock screen display
    private var currentActivity: Activity<TimerActivityAttributes>?

    // Computed elapsed time for current session
    var currentElapsedSeconds: TimeInterval {
        guard let start = startTime else { return 0 }
        return Date().timeIntervalSince(start)
    }

    // Total elapsed time (accumulated + current session)
    var totalElapsedSeconds: TimeInterval {
        return accumulatedSeconds + currentElapsedSeconds
    }

    private init() {
        loadState()
    }

    // Check if a specific task is running
    func isRunning(taskId: UUID) -> Bool {
        return runningTaskId == taskId
    }

    // Start timer for a task
    func startTimer(for taskId: UUID, taskName: String) {
        // If another timer is running, stop it first
        if let currentTaskId = runningTaskId, currentTaskId != taskId {
            _ = stopTimer(for: currentTaskId)
        }

        runningTaskId = taskId
        let now = Date()
        startTime = now
        accumulatedSeconds = 0
        saveState()

        // Start Live Activity for lock screen display
        startLiveActivity(taskId: taskId, taskName: taskName, startTime: now)
    }

    // Stop timer for a task and return total minutes
    func stopTimer(for taskId: UUID) -> Double {
        guard runningTaskId == taskId else { return 0 }

        let totalSeconds = totalElapsedSeconds
        let minutes = totalSeconds / 60.0

        // Reset state first so UI updates immediately
        runningTaskId = nil
        startTime = nil
        accumulatedSeconds = 0
        saveState()

        // Stop Live Activity in background (non-blocking)
        stopLiveActivity()

        return minutes
    }

    // Pause timer (accumulate time but stop counting)
    func pauseTimer(for taskId: UUID) {
        guard runningTaskId == taskId, let start = startTime else { return }

        accumulatedSeconds += Date().timeIntervalSince(start)
        startTime = Date() // Reset start time for next resume
        saveState()
    }

    // Get elapsed minutes for a running timer
    func getElapsedMinutes(for taskId: UUID) -> Double {
        guard runningTaskId == taskId else { return 0 }
        return totalElapsedSeconds / 60.0
    }

    // Persistence
    private func saveState() {
        UserDefaults.standard.set(runningTaskId?.uuidString, forKey: "TimerManager.runningTaskId")
        UserDefaults.standard.set(startTime, forKey: "TimerManager.startTime")
        UserDefaults.standard.set(accumulatedSeconds, forKey: "TimerManager.accumulatedSeconds")
    }

    private func loadState() {
        if let taskIdString = UserDefaults.standard.string(forKey: "TimerManager.runningTaskId"),
           let taskId = UUID(uuidString: taskIdString) {
            runningTaskId = taskId
            startTime = UserDefaults.standard.object(forKey: "TimerManager.startTime") as? Date
            accumulatedSeconds = UserDefaults.standard.double(forKey: "TimerManager.accumulatedSeconds")

            // Timer state restored — views will use Text(timerInterval:) for display
        }
    }

    // MARK: - Live Activity

    private func startLiveActivity(taskId: UUID, taskName: String, startTime: Date) {
        // Check if Live Activities are supported (iOS 16.1+)
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            return
        }

        // End any existing tracked activity
        if let activity = currentActivity {
            _Concurrency.Task { await activity.end(nil, dismissalPolicy: .immediate) }
            currentActivity = nil
        }

        let attributes = TimerActivityAttributes(taskName: taskName, taskId: taskId)
        let contentState = TimerActivityAttributes.ContentState(
            elapsedSeconds: 0,
            startTime: startTime
        )

        do {
            currentActivity = try Activity<TimerActivityAttributes>.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: nil),
                pushType: nil
            )
        } catch {
            // Live Activity failed to start - silently continue
        }
    }

    private func stopLiveActivity() {
        let activityToEnd = currentActivity
        currentActivity = nil

        // End activity and clean up orphans in async task (inherits main actor)
        // Using Task allows UI to update first before this runs
        _Concurrency.Task {
            if let activity = activityToEnd {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
            for activity in Activity<TimerActivityAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }
}
