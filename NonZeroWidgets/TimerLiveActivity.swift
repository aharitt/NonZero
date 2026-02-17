import ActivityKit
import WidgetKit
import SwiftUI

struct TimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerActivityAttributes.self) { context in
            // Lock screen and banner UI
            LockScreenTimerView(context: context)
        } dynamicIsland: { context in
            // Dynamic Island UI
            DynamicIsland {
                // Expanded view
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                            .foregroundColor(.green)
                        Text(context.attributes.taskName)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerText(from: context.state.startTime))
                        .font(.system(.title3, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .monospacedDigit()
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Image(systemName: "hourglass")
                            .foregroundColor(.secondary)
                            .font(.caption2)
                        Text("Tap to open app and stop timer")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                }
            } compactLeading: {
                // Compact leading (left side of notch)
                Image(systemName: "timer")
                    .foregroundColor(.green)
            } compactTrailing: {
                // Compact trailing (right side of notch)
                Text(timerText(from: context.state.startTime))
                    .font(.system(.caption2, design: .monospaced))
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                    .monospacedDigit()
            } minimal: {
                // Minimal view (when multiple activities)
                Image(systemName: "timer")
                    .foregroundColor(.green)
            }
        }
    }

    // Calculate elapsed time from start time
    private func timerText(from startTime: Date) -> String {
        let elapsed = Date().timeIntervalSince(startTime)
        let hours = Int(elapsed) / 3600
        let minutes = (Int(elapsed) % 3600) / 60
        let seconds = Int(elapsed) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

// Lock Screen View
struct LockScreenTimerView: View {
    let context: ActivityViewContext<TimerActivityAttributes>

    var elapsedTime: String {
        let elapsed = Date().timeIntervalSince(context.state.startTime)
        let hours = Int(elapsed) / 3600
        let minutes = (Int(elapsed) % 3600) / 60
        let seconds = Int(elapsed) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Timer icon
            Image(systemName: "timer")
                .font(.system(size: 32))
                .foregroundColor(.green)

            VStack(alignment: .leading, spacing: 4) {
                // Task name
                Text(context.attributes.taskName)
                    .font(.headline)
                    .fontWeight(.semibold)

                // Elapsed time
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(elapsedTime)
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.medium)
                        .monospacedDigit()
                }
            }

            Spacer()

            // Visual indicator
            VStack {
                Image(systemName: "stop.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.red)
                Text("Tap to stop")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.1))
        )
    }
}

#Preview("Notification", as: .content, using: TimerActivityAttributes(taskName: "Reading", taskId: UUID())) {
   TimerLiveActivity()
} contentStates: {
    TimerActivityAttributes.ContentState(elapsedSeconds: 125, startTime: Date().addingTimeInterval(-125))
}
