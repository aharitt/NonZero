import XCTest
@testable import NonZero

final class FormattingTests: XCTestCase {

    // MARK: - formatPercentage

    func testFormatPercentageZero() {
        XCTAssertEqual(Formatting.formatPercentage(0.0), "0%")
    }

    func testFormatPercentageHalf() {
        XCTAssertEqual(Formatting.formatPercentage(0.5), "50%")
    }

    func testFormatPercentageFull() {
        XCTAssertEqual(Formatting.formatPercentage(1.0), "100%")
    }

    func testFormatPercentageRoundsDown() {
        XCTAssertEqual(Formatting.formatPercentage(0.333), "33%")
    }

    func testFormatPercentageRoundsUp() {
        XCTAssertEqual(Formatting.formatPercentage(0.999), "100%")
    }

    // MARK: - formatDecimal

    func testFormatDecimalDefault() {
        XCTAssertEqual(Formatting.formatDecimal(3.14159), "3.1")
    }

    func testFormatDecimalTwoPlaces() {
        XCTAssertEqual(Formatting.formatDecimal(3.14159, decimals: 2), "3.14")
    }

    func testFormatDecimalZeroPlaces() {
        XCTAssertEqual(Formatting.formatDecimal(3.7, decimals: 0), "4")
    }

    // MARK: - formatTime

    func testFormatTimeZeroMinutes() {
        XCTAssertEqual(Formatting.formatTime(minutes: 0), "0m")
    }

    func testFormatTimeUnderAnHour() {
        XCTAssertEqual(Formatting.formatTime(minutes: 30), "30m")
        XCTAssertEqual(Formatting.formatTime(minutes: 59), "59m")
    }

    func testFormatTimeExactHour() {
        XCTAssertEqual(Formatting.formatTime(minutes: 60), "1h")
        XCTAssertEqual(Formatting.formatTime(minutes: 120), "2h")
    }

    func testFormatTimeHoursAndMinutes() {
        XCTAssertEqual(Formatting.formatTime(minutes: 90), "1h 30m")
        XCTAssertEqual(Formatting.formatTime(minutes: 125), "2h 5m")
    }

    // MARK: - formatValue

    func testFormatValueBooleanTrue() {
        XCTAssertEqual(Formatting.formatValue(1.0, for: .boolean), "Yes")
        XCTAssertEqual(Formatting.formatValue(2.0, for: .boolean), "Yes")
    }

    func testFormatValueBooleanFalse() {
        XCTAssertEqual(Formatting.formatValue(0.0, for: .boolean), "No")
        XCTAssertEqual(Formatting.formatValue(0.9, for: .boolean), "No")
    }

    func testFormatValueCount() {
        XCTAssertEqual(Formatting.formatValue(0.0, for: .count), "0")
        XCTAssertEqual(Formatting.formatValue(5.0, for: .count), "5")
        XCTAssertEqual(Formatting.formatValue(100.0, for: .count), "100")
    }

    func testFormatValueTime() {
        XCTAssertEqual(Formatting.formatValue(30.0, for: .time), "30m")
        XCTAssertEqual(Formatting.formatValue(60.0, for: .time), "1h")
        XCTAssertEqual(Formatting.formatValue(90.0, for: .time), "1h 30m")
    }

    // MARK: - relativeDate

    func testRelativeDateToday() {
        XCTAssertEqual(Formatting.relativeDate(Date()), "Today")
    }

    func testRelativeDateYesterday() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        XCTAssertEqual(Formatting.relativeDate(yesterday), "Yesterday")
    }

    func testRelativeDateTomorrow() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        XCTAssertEqual(Formatting.relativeDate(tomorrow), "Tomorrow")
    }

    func testRelativeDatePast() {
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        let result = Formatting.relativeDate(twoDaysAgo)
        XCTAssertFalse(result == "Today")
        XCTAssertFalse(result == "Yesterday")
        XCTAssertFalse(result == "Tomorrow")
        XCTAssertFalse(result.isEmpty)
    }
}
