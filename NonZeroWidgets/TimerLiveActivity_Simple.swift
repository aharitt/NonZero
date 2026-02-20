import ActivityKit
import WidgetKit
import SwiftUI

struct TimerLiveActivitySimple: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerActivityAttributes.self) { context in
            // Lock screen UI
            HStack(spacing: 8) {
                Image(systemName: "timer")
                    .foregroundColor(.green)
                Text(context.attributes.taskName)
                    .font(.headline)
                    .lineLimit(1)
                    .layoutPriority(1)
                Spacer(minLength: 4)
                Text(timerInterval: context.state.startTime...Date.distantFuture, countsDown: false)
                    .font(.system(.body, design: .monospaced))
                    .monospacedDigit()
                    .multilineTextAlignment(.trailing)
            }
            .padding()
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Image(systemName: "timer")
                            .foregroundColor(.green)
                        Text(context.attributes.taskName)
                            .font(.headline)
                            .lineLimit(1)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: context.state.startTime...Date.distantFuture, countsDown: false)
                        .font(.system(.body, design: .monospaced))
                        .monospacedDigit()
                        .multilineTextAlignment(.trailing)
                }
            } compactLeading: {
                Text(context.attributes.taskName)
                    .font(.caption)
                    .lineLimit(1)
            } compactTrailing: {
                Text(timerInterval: context.state.startTime...Date.distantFuture, countsDown: false)
                    .font(.caption2)
                    .monospacedDigit()
                    .multilineTextAlignment(.trailing)
            } minimal: {
                Image(systemName: "timer")
            }
        }
    }
}
