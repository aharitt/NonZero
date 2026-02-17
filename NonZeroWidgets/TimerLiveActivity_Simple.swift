import ActivityKit
import WidgetKit
import SwiftUI

struct TimerLiveActivitySimple: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerActivityAttributes.self) { context in
            // Lock screen UI
            HStack {
                Image(systemName: "timer")
                    .foregroundColor(.green)
                Text(context.attributes.taskName)
                    .font(.headline)
                Spacer()
                Text(timerInterval: context.state.startTime...Date.distantFuture, countsDown: false)
                    .font(.system(.body, design: .monospaced))
                    .monospacedDigit()
            }
            .padding()
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.taskName)
                }
            } compactLeading: {
                Image(systemName: "timer")
            } compactTrailing: {
                Text(timerInterval: context.state.startTime...Date.distantFuture, countsDown: false)
                    .monospacedDigit()
            } minimal: {
                Image(systemName: "timer")
            }
        }
    }
}
