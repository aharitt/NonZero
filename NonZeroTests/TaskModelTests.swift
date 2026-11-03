import XCTest
import SwiftData
@testable import NonZero

@MainActor
final class TaskModelTests: XCTestCase {

    var modelContainer: ModelContainer!
    var context: ModelContext!

    override func setUp() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: Task.self, Entry.self, configurations: config)
        context = modelContainer.mainContext
    }

    override func tearDown() async throws {
        context = nil
        modelContainer = nil
    }

    // MARK: - Helpers

    func makeTask(name: String = "Test", type: TaskType = .count, minimum: Double = 1.0) -> Task {
        let task = Task(name: name, taskType: type, minimumValue: minimum)
        context.insert(task)
        return task
    }

    func addEntry(to task: Task, daysAgo: Int, value: Double) {
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
        let entry = Entry(task: task, date: date, value: value)
        context.insert(entry)
    }

    // MARK: - meetsMinimum

    func testMeetsMinimumExactly() {
        let task = makeTask(minimum: 5.0)
        XCTAssertTrue(task.meetsMinimum(value: 5.0))
    }

    func testMeetsMinimumAbove() {
        let task = makeTask(minimum: 5.0)
        XCTAssertTrue(task.meetsMinimum(value: 10.0))
    }

    func testMeetsMinimumBelow() {
        let task = makeTask(minimum: 5.0)
        XCTAssertFalse(task.meetsMinimum(value: 4.9))
    }

    func testMeetsMinimumZeroMinimum() {
        let task = makeTask(minimum: 0.0)
        XCTAssertTrue(task.meetsMinimum(value: 0.0))
    }

    func testMeetsMinimumBooleanTask() {
        let task = makeTask(type: .boolean, minimum: 1.0)
        XCTAssertFalse(task.meetsMinimum(value: 0.0))
        XCTAssertTrue(task.meetsMinimum(value: 1.0))
    }

    // MARK: - currentStreak

    func testCurrentStreakEmpty() {
        let task = makeTask()
        XCTAssertEqual(task.currentStreak(), 0)
    }

    func testCurrentStreakTodayOnly() {
        let task = makeTask()
        addEntry(to: task, daysAgo: 0, value: 1.0)
        XCTAssertEqual(task.currentStreak(), 1)
    }

    func testCurrentStreakYesterdayNotToday() {
        let task = makeTask()
        addEntry(to: task, daysAgo: 1, value: 1.0)
        XCTAssertEqual(task.currentStreak(), 1)
    }

    func testCurrentStreakConsecutiveIncludingToday() {
        let task = makeTask()
        addEntry(to: task, daysAgo: 0, value: 1.0)
        addEntry(to: task, daysAgo: 1, value: 1.0)
        addEntry(to: task, daysAgo: 2, value: 1.0)
        XCTAssertEqual(task.currentStreak(), 3)
    }

    func testCurrentStreakConsecutiveNotIncludingToday() {
        let task = makeTask()
        addEntry(to: task, daysAgo: 1, value: 1.0)
        addEntry(to: task, daysAgo: 2, value: 1.0)
        addEntry(to: task, daysAgo: 3, value: 1.0)
        XCTAssertEqual(task.currentStreak(), 3)
    }

    func testCurrentStreakBrokenByGap() {
        let task = makeTask()
        addEntry(to: task, daysAgo: 0, value: 1.0)
        addEntry(to: task, daysAgo: 1, value: 1.0)
        // day 2 missing
        addEntry(to: task, daysAgo: 3, value: 1.0)
        XCTAssertEqual(task.currentStreak(), 2)
    }

    func testCurrentStreakBrokenByBelowMinimum() {
        let task = makeTask(minimum: 5.0)
        addEntry(to: task, daysAgo: 0, value: 10.0) // non-zero
        addEntry(to: task, daysAgo: 1, value: 2.0)  // below minimum = breaks streak
        addEntry(to: task, daysAgo: 2, value: 10.0) // non-zero
        XCTAssertEqual(task.currentStreak(), 1)
    }

    func testCurrentStreakTodayBelowMinimum() {
        let task = makeTask(minimum: 5.0)
        addEntry(to: task, daysAgo: 0, value: 2.0)  // today but below minimum
        addEntry(to: task, daysAgo: 1, value: 10.0) // yesterday non-zero
        // Today doesn't count, so streak starts from yesterday
        XCTAssertEqual(task.currentStreak(), 1)
    }

    // MARK: - longestStreak

    func testLongestStreakEmpty() {
        let task = makeTask()
        XCTAssertEqual(task.longestStreak(), 0)
    }

    func testLongestStreakSingleEntry() {
        let task = makeTask()
        addEntry(to: task, daysAgo: 10, value: 1.0)
        XCTAssertEqual(task.longestStreak(), 1)
    }

    func testLongestStreakAllConsecutive() {
        let task = makeTask()
        for i in 0..<7 {
            addEntry(to: task, daysAgo: i, value: 1.0)
        }
        XCTAssertEqual(task.longestStreak(), 7)
    }

    func testLongestStreakPicksBest() {
        let task = makeTask()
        // Streak of 3: days 10, 9, 8 ago
        addEntry(to: task, daysAgo: 10, value: 1.0)
        addEntry(to: task, daysAgo: 9, value: 1.0)
        addEntry(to: task, daysAgo: 8, value: 1.0)
        // Gap
        // Streak of 5: days 5, 4, 3, 2, 1 ago
        for i in 1...5 {
            addEntry(to: task, daysAgo: i, value: 1.0)
        }
        XCTAssertEqual(task.longestStreak(), 5)
    }

    func testLongestStreakWithNonNonZeroEntries() {
        let task = makeTask(minimum: 5.0)
        addEntry(to: task, daysAgo: 4, value: 1.0)  // below min, doesn't count
        addEntry(to: task, daysAgo: 3, value: 10.0) // non-zero
        addEntry(to: task, daysAgo: 2, value: 10.0) // non-zero
        addEntry(to: task, daysAgo: 1, value: 10.0) // non-zero
        XCTAssertEqual(task.longestStreak(), 3)
    }

    // MARK: - Statistics

    func testTotalValueEmpty() {
        let task = makeTask()
        XCTAssertEqual(task.totalValue(), 0.0)
    }

    func testTotalValueSummed() {
        let task = makeTask()
        addEntry(to: task, daysAgo: 2, value: 10.0)
        addEntry(to: task, daysAgo: 1, value: 20.0)
        addEntry(to: task, daysAgo: 0, value: 30.0)
        XCTAssertEqual(task.totalValue(), 60.0)
    }

    func testTotalNonZeroDays() {
        let task = makeTask(minimum: 5.0)
        addEntry(to: task, daysAgo: 3, value: 10.0) // non-zero
        addEntry(to: task, daysAgo: 2, value: 3.0)  // below minimum
        addEntry(to: task, daysAgo: 1, value: 5.0)  // exactly minimum = non-zero
        addEntry(to: task, daysAgo: 0, value: 0.0)  // zero
        XCTAssertEqual(task.totalNonZeroDays(), 2)
    }

    func testTotalLoggedDays() {
        let task = makeTask()
        addEntry(to: task, daysAgo: 2, value: 0.0)
        addEntry(to: task, daysAgo: 1, value: 0.0)
        XCTAssertEqual(task.totalLoggedDays(), 2)
    }

    func testTotalNonZeroDaysEmpty() {
        let task = makeTask()
        XCTAssertEqual(task.totalNonZeroDays(), 0)
    }

    // MARK: - comebackCount

    func testComebackCountEmpty() {
        let task = makeTask()
        XCTAssertEqual(task.comebackCount(), 0)
    }

    func testComebackCountNoComeback() {
        let task = makeTask()
        addEntry(to: task, daysAgo: 2, value: 1.0)
        addEntry(to: task, daysAgo: 1, value: 1.0)
        addEntry(to: task, daysAgo: 0, value: 1.0)
        XCTAssertEqual(task.comebackCount(), 0)
    }

    func testComebackCountAfterGap() {
        let task = makeTask()
        addEntry(to: task, daysAgo: 5, value: 1.0) // non-zero
        // Days 4–1: no entries (gap)
        addEntry(to: task, daysAgo: 0, value: 1.0) // comeback
        XCTAssertEqual(task.comebackCount(), 1)
    }

    func testComebackCountAfterZeroEntry() {
        // A zero entry followed by a non-zero entry = one comeback (not two)
        let task = makeTask(minimum: 5.0)
        addEntry(to: task, daysAgo: 2, value: 10.0) // non-zero
        addEntry(to: task, daysAgo: 1, value: 0.0)  // zero (below minimum)
        addEntry(to: task, daysAgo: 0, value: 10.0) // comeback
        XCTAssertEqual(task.comebackCount(), 1)
    }

    func testComebackCountMultipleGaps() {
        let task = makeTask()
        addEntry(to: task, daysAgo: 10, value: 1.0)
        // Gap
        addEntry(to: task, daysAgo: 7, value: 1.0)  // comeback 1
        addEntry(to: task, daysAgo: 6, value: 1.0)
        // Gap
        addEntry(to: task, daysAgo: 3, value: 1.0)  // comeback 2
        XCTAssertEqual(task.comebackCount(), 2)
    }

    // MARK: - isCompleted(on:)

    func testIsCompletedWhenNonZero() {
        let task = makeTask(minimum: 1.0)
        addEntry(to: task, daysAgo: 0, value: 5.0)
        XCTAssertTrue(task.isCompleted(on: Date()))
    }

    func testIsCompletedWhenBelowMinimum() {
        let task = makeTask(minimum: 10.0)
        addEntry(to: task, daysAgo: 0, value: 3.0)
        XCTAssertFalse(task.isCompleted(on: Date()))
    }

    func testIsCompletedWhenNoEntry() {
        let task = makeTask()
        XCTAssertFalse(task.isCompleted(on: Date()))
    }
}
