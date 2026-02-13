import SwiftUI

struct DeviceHelper {
    /// Calculate the optimal number of tasks to display per page based on available height
    /// - Parameters:
    ///   - availableHeight: The available height for displaying tasks
    ///   - estimatedRowHeight: The estimated height of each task row/card
    /// - Returns: The number of tasks that can fit comfortably on one page
    static func calculateTasksPerPage(availableHeight: CGFloat, estimatedRowHeight: CGFloat) -> Int {
        // Add some buffer space for padding and comfortable scrolling
        let bufferSpace: CGFloat = 40
        let usableHeight = availableHeight - bufferSpace

        // Calculate how many rows can fit
        let tasksPerPage = Int(usableHeight / estimatedRowHeight)

        // Ensure at least 3 tasks per page, max 15 for very large screens
        return max(3, min(15, tasksPerPage))
    }

    /// Get screen height
    static var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }

    /// Get screen width
    static var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }

    /// Check if device is an iPad
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
}
