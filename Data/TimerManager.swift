import Foundation
import Combine

@MainActor
@Observable
class TimerManager {
    static let shared = TimerManager()

    // Current running timer state
    var runningTaskId: UUID?
    var startTime: Date?
    var accumulatedSeconds: TimeInterval = 0

    // Force UI updates by changing this property every second
    var lastUpdate: Date = Date()

    // Timer to update UI every second
    private var displayTimer: Timer?

    // Computed elapsed time for current session
    var currentElapsedSeconds: TimeInterval {
        guard let start = startTime else { return 0 }
        return Date().timeIntervalSince(start)
    }

    // Total elapsed time (accumulated + current session)
    var totalElapsedSeconds: TimeInterval {
        return accumulatedSeconds + currentElapsedSeconds
    }

    // Format elapsed time as string
    var formattedElapsedTime: String {
        let total = totalElapsedSeconds
        let hours = Int(total) / 3600
        let minutes = (Int(total) % 3600) / 60
        let seconds = Int(total) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }

    private init() {
        loadState()
    }

    // Check if a specific task is running
    func isRunning(taskId: UUID) -> Bool {
        return runningTaskId == taskId
    }

    // Start timer for a task
    func startTimer(for taskId: UUID) {
        // If another timer is running, stop it first
        if let currentTaskId = runningTaskId, currentTaskId != taskId {
            _ = stopTimer(for: currentTaskId)
        }

        runningTaskId = taskId
        startTime = Date()
        accumulatedSeconds = 0
        saveState()

        // Start display timer to trigger UI updates
        startDisplayTimer()
    }

    // Stop timer for a task and return total minutes
    func stopTimer(for taskId: UUID) -> Double {
        guard runningTaskId == taskId else { return 0 }

        let totalSeconds = totalElapsedSeconds
        let minutes = totalSeconds / 60.0

        // Reset state
        runningTaskId = nil
        startTime = nil
        accumulatedSeconds = 0
        saveState()

        // Stop display timer
        stopDisplayTimer()

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

    // Start display timer for UI updates
    private func startDisplayTimer() {
        stopDisplayTimer() // Stop existing timer if any
        displayTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            // Update this property to trigger SwiftUI view updates
            MainActor.assumeIsolated {
                self?.lastUpdate = Date()
            }
        }
    }

    private func stopDisplayTimer() {
        displayTimer?.invalidate()
        displayTimer = nil
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

            // If there was a running timer, restart display timer
            if startTime != nil {
                startDisplayTimer()
            }
        }
    }
}
