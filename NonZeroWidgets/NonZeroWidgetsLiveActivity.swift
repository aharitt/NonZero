//
//  NonZeroWidgetsLiveActivity.swift
//  NonZeroWidgets
//
//  Created by Lewis Lee on 2/13/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct NonZeroWidgetsAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct NonZeroWidgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NonZeroWidgetsAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension NonZeroWidgetsAttributes {
    fileprivate static var preview: NonZeroWidgetsAttributes {
        NonZeroWidgetsAttributes(name: "World")
    }
}

extension NonZeroWidgetsAttributes.ContentState {
    fileprivate static var smiley: NonZeroWidgetsAttributes.ContentState {
        NonZeroWidgetsAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: NonZeroWidgetsAttributes.ContentState {
         NonZeroWidgetsAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: NonZeroWidgetsAttributes.preview) {
   NonZeroWidgetsLiveActivity()
} contentStates: {
    NonZeroWidgetsAttributes.ContentState.smiley
    NonZeroWidgetsAttributes.ContentState.starEyes
}
