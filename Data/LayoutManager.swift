import Foundation

/// Shared layout state so all three main tabs show the same number of tasks per page.
/// TodayView is the authority: it measures its available height and writes here.
/// TasksListView and StatsView read tasksPerPage from here.
@Observable
final class LayoutManager {
    static let shared = LayoutManager()

    /// Height of one card, shared across all three main tabs.
    static let cardHeight: CGFloat = 96
    /// Vertical gap between cards in LazyVStack.
    static let cardSpacing: CGFloat = 10

    var tasksPerPage: Int = 6

    private init() {}

    /// Call from TodayView's GeometryReader. Reserved = title row + top/bottom padding.
    func update(availableHeight: CGFloat, reserved: CGFloat = 64) {
        let slotHeight = Self.cardHeight + Self.cardSpacing
        let count = max(1, Int((availableHeight - reserved) / slotHeight))
        if count != tasksPerPage {
            tasksPerPage = count
        }
    }
}
