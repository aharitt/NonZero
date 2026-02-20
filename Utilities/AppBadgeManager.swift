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

    private static let midnightNotificationID = "com.nonzero.midnightBadgeReset"

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

        let activeTasks = tasks.filter { !$0.isArchived }

        let incompleteCount = activeTasks.filter { task in
            // Check if task has a non-zero entry for today
            if let entry = todayEntries[task.id] {
                return !entry.isNonZero
            }

            // No entry means incomplete
            return true
        }.count

        // Set badge number
        UNUserNotificationCenter.current().setBadgeCount(incompleteCount)

        // Schedule midnight badge reset with total active task count
        scheduleMidnightBadgeReset(activeTaskCount: activeTasks.count)
    }

    // Clear badge
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
        cancelMidnightBadgeReset()
    }

    // Schedule a silent notification at midnight to reset badge to all tasks incomplete
    private func scheduleMidnightBadgeReset(activeTaskCount: Int) {
        guard SettingsManager.shared.showBadge, activeTaskCount > 0 else {
            cancelMidnightBadgeReset()
            return
        }

        let center = UNUserNotificationCenter.current()

        // Remove any existing midnight notification
        center.removePendingNotificationRequests(withIdentifiers: [Self.midnightNotificationID])

        // Create silent notification that just sets the badge at midnight
        let content = UNMutableNotificationContent()
        content.badge = NSNumber(value: activeTaskCount)
        // No title, body, or sound — this is a silent badge-only update
        content.interruptionLevel = .passive

        // Trigger at midnight
        var dateComponents = DateComponents()
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: Self.midnightNotificationID,
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    private func cancelMidnightBadgeReset() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [Self.midnightNotificationID])
    }
}
