import Foundation
import UserNotifications
import SwiftData

// Notification name for refreshing badge
extension Notification.Name {
    static let refreshBadge = Notification.Name("refreshBadge")
}

@MainActor
class AppBadgeManager {
    static let shared = AppBadgeManager()

    private init() {}

    // Request permission to show badges
    func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.badge])
            if granted {
                print("Badge permission granted")
            }
        } catch {
            print("Failed to request badge authorization: \(error)")
        }
    }

    // Update badge count based on incomplete tasks for today
    func updateBadge(tasks: [Task], todayEntries: [UUID: Entry]) {
        // Check if badge is enabled in settings
        guard SettingsManager.shared.showBadge else {
            clearBadge()
            return
        }

        let incompleteCount = tasks.filter { task in
            guard !task.isArchived else { return false }

            // Check if task has a non-zero entry for today
            if let entry = todayEntries[task.id] {
                return !entry.isNonZero
            }

            // No entry means incomplete
            return true
        }.count

        // Set badge number
        UNUserNotificationCenter.current().setBadgeCount(incompleteCount)
    }

    // Clear badge
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
}
