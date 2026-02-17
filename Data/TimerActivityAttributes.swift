import Foundation
import ActivityKit

/// Attributes for the timer Live Activity
struct TimerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        /// The elapsed time in seconds when the activity was last updated
        var elapsedSeconds: TimeInterval
        /// The timestamp when the timer started
        var startTime: Date
    }

    /// Static data that doesn't change during the activity
    var taskName: String
    var taskId: UUID
}
