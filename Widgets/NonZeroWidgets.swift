import WidgetKit
import SwiftUI

@main
struct NonZeroWidgets: WidgetBundle {
    var body: some Widget {
        TimerLiveActivitySimple()  // Using simplified version to avoid memory issues
    }
}
