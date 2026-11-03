import XCTest
import SwiftData
@testable import NonZero

@MainActor
final class EntryTests: XCTestCase {

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

    func makeTask(type: TaskType, minimum: Double, unit: String? = nil) -> Task {
        let task = Task(name: "Test", taskType: type, minimumValue: minimum, unit: unit)
        context.insert(task)
        return task
    }

    func makeEntry(task: Task, value: Double) -> Entry {
        let entry = Entry(task: task, date: Date(), value: value)
        context.insert(entry)
        return entry
    }

    // MARK: - isNonZero

    func testIsNonZeroAboveMinimum() {
        let task = makeTask(type: .count, minimum: 5.0)
        let entry = makeEntry(task: task, value: 10.0)
        XCTAssertTrue(entry.isNonZero)
    }

    func testIsNonZeroExactlyMinimum() {
        let task = makeTask(type: .count, minimum: 5.0)
        let entry = makeEntry(task: task, value: 5.0)
        XCTAssertTrue(entry.isNonZero)
    }

    func testIsNonZeroBelowMinimum() {
        let task = makeTask(type: .count, minimum: 5.0)
        let entry = makeEntry(task: task, value: 4.9)
        XCTAssertFalse(entry.isNonZero)
    }

    func testIsNonZeroBooleanDone() {
        let task = makeTask(type: .boolean, minimum: 1.0)
        let entry = makeEntry(task: task, value: 1.0)
        XCTAssertTrue(entry.isNonZero)
    }

    func testIsNonZeroBooleanNotDone() {
        let task = makeTask(type: .boolean, minimum: 1.0)
        let entry = makeEntry(task: task, value: 0.0)
        XCTAssertFalse(entry.isNonZero)
    }

    // MARK: - displayValue for boolean

    func testDisplayValueBooleanYes() {
        let task = makeTask(type: .boolean, minimum: 1.0)
        let entry = makeEntry(task: task, value: 1.0)
        XCTAssertEqual(entry.displayValue, "Yes")
    }

    func testDisplayValueBooleanNo() {
        let task = makeTask(type: .boolean, minimum: 1.0)
        let entry = makeEntry(task: task, value: 0.0)
        XCTAssertEqual(entry.displayValue, "No")
    }

    // MARK: - displayValue for count

    func testDisplayValueCountNoUnit() {
        let task = makeTask(type: .count, minimum: 1.0)
        let entry = makeEntry(task: task, value: 42.0)
        XCTAssertEqual(entry.displayValue, "42")
    }

    func testDisplayValueCountWithUnit() {
        let task = makeTask(type: .count, minimum: 1.0, unit: "pages")
        let entry = makeEntry(task: task, value: 20.0)
        XCTAssertEqual(entry.displayValue, "20 pages")
    }

    func testDisplayValueCountZero() {
        let task = makeTask(type: .count, minimum: 1.0)
        let entry = makeEntry(task: task, value: 0.0)
        XCTAssertEqual(entry.displayValue, "0")
    }

    // MARK: - displayValue for time

    func testDisplayValueTimeUnderHour() {
        let task = makeTask(type: .time, minimum: 1.0)
        let entry = makeEntry(task: task, value: 45.0)
        XCTAssertEqual(entry.displayValue, "45m")
    }

    func testDisplayValueTimeExactHour() {
        let task = makeTask(type: .time, minimum: 1.0)
        let entry = makeEntry(task: task, value: 60.0)
        XCTAssertEqual(entry.displayValue, "1h")
    }

    func testDisplayValueTimeHoursAndMinutes() {
        let task = makeTask(type: .time, minimum: 1.0)
        let entry = makeEntry(task: task, value: 90.0)
        XCTAssertEqual(entry.displayValue, "1h 30m")
    }

    // MARK: - date normalization

    func testEntryDateIsNormalizedToStartOfDay() {
        let task = makeTask(type: .count, minimum: 1.0)
        let now = Date()
        let entry = Entry(task: task, date: now, value: 1.0)
        context.insert(entry)
        let expected = Calendar.current.startOfDay(for: now)
        XCTAssertEqual(entry.date, expected)
    }

    func testEntryForDate() {
        let task = makeTask(type: .count, minimum: 1.0)
        let today = Calendar.current.startOfDay(for: Date())
        let entry = Entry(task: task, date: today, value: 5.0)
        context.insert(entry)
        let found = task.entry(for: today)
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.value, 5.0)
    }

    func testEntryForDateNotFound() {
        let task = makeTask(type: .count, minimum: 1.0)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let entry = Entry(task: task, date: yesterday, value: 5.0)
        context.insert(entry)
        // Entry exists for yesterday, not today
        XCTAssertNil(task.entry(for: Date()))
    }
}
