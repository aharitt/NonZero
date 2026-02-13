import UIKit
import SwiftData

@Observable
class AppIconManager {
    static let shared = AppIconManager()

    private init() {}

    /// Update app icon based on daily task completion percentage
    /// - Parameter completionPercentage: Percentage of tasks completed (0.0 - 1.0)
    func updateIcon(completionPercentage: Double) {
        let threshold = 0.2 // 20%
        let shouldShowNonZero = completionPercentage >= threshold

        let targetIcon = shouldShowNonZero ? "AppIconNonZero" : nil // nil = default icon

        // Only change if different from current
        if UIApplication.shared.alternateIconName != targetIcon {
            changeIcon(to: targetIcon)
        }
    }

    /// Calculate completion percentage for today's tasks
    /// - Parameters:
    ///   - tasks: All active tasks
    ///   - context: SwiftData ModelContext
    /// - Returns: Completion percentage (0.0 - 1.0)
    func calculateTodayCompletion(tasks: [Task]) -> Double {
        guard !tasks.isEmpty else { return 0.0 }

        let today = Calendar.current.startOfDay(for: Date())
        var completedCount = 0

        for task in tasks {
            if task.isCompleted(on: today) {
                completedCount += 1
            }
        }

        return Double(completedCount) / Double(tasks.count)
    }

    /// Change the app icon
    /// - Parameter iconName: Name of the alternate icon, or nil for default
    private func changeIcon(to iconName: String?) {
        guard UIApplication.shared.supportsAlternateIcons else {
            print("Alternate icons not supported")
            return
        }

        UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error = error {
                print("Failed to change app icon: \(error.localizedDescription)")
            } else {
                print("App icon changed to: \(iconName ?? "default")")
            }
        }
    }

    /// Reset to default icon (for testing or manual reset)
    func resetToDefaultIcon() {
        changeIcon(to: nil)
    }
}
