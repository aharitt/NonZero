import XCTest
@testable import NonZero

final class DateHelperTests: XCTestCase {

    // MARK: - Date.isToday

    func testIsTodayTrue() {
        XCTAssertTrue(Date().isToday)
    }

    func testIsTodayFalseYesterday() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        XCTAssertFalse(yesterday.isToday)
    }

    func testIsTodayFalseTomorrow() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        XCTAssertFalse(tomorrow.isToday)
    }

    // MARK: - Date.isYesterday

    func testIsYesterdayTrue() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        XCTAssertTrue(yesterday.isYesterday)
    }

    func testIsYesterdayFalseToday() {
        XCTAssertFalse(Date().isYesterday)
    }

    func testIsYesterdayFalseTwoDaysAgo() {
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        XCTAssertFalse(twoDaysAgo.isYesterday)
    }

    // MARK: - Date.startOfDay

    func testStartOfDayIsAtMidnight() {
        let now = Date()
        let start = now.startOfDay
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: start)
        XCTAssertEqual(components.hour, 0)
        XCTAssertEqual(components.minute, 0)
        XCTAssertEqual(components.second, 0)
    }

    func testStartOfDayMatchesCalendar() {
        let now = Date()
        XCTAssertEqual(now.startOfDay, Calendar.current.startOfDay(for: now))
    }

    // MARK: - Date.adding(days:)

    func testAddingPositiveDays() {
        let today = Calendar.current.startOfDay(for: Date())
        let result = today.adding(days: 3)
        let expected = Calendar.current.date(byAdding: .day, value: 3, to: today)!
        XCTAssertEqual(result, expected)
    }

    func testAddingNegativeDays() {
        let today = Calendar.current.startOfDay(for: Date())
        let result = today.adding(days: -5)
        let expected = Calendar.current.date(byAdding: .day, value: -5, to: today)!
        XCTAssertEqual(result, expected)
    }

    func testAddingZeroDays() {
        let today = Calendar.current.startOfDay(for: Date())
        XCTAssertEqual(today.adding(days: 0), today)
    }

    // MARK: - Date.daysBetween(_:)

    func testDaysBetweenSameDay() {
        let today = Date().startOfDay
        XCTAssertEqual(today.daysBetween(today), 0)
    }

    func testDaysBetweenOneDayApart() {
        let today = Date().startOfDay
        let yesterday = today.adding(days: -1)
        XCTAssertEqual(today.daysBetween(yesterday), 1)
        XCTAssertEqual(yesterday.daysBetween(today), 1) // symmetric
    }

    func testDaysBetweenSevenDaysApart() {
        let today = Date().startOfDay
        let weekAgo = today.adding(days: -7)
        XCTAssertEqual(today.daysBetween(weekAgo), 7)
    }

    // MARK: - Calendar.datesInRange(from:to:)

    func testDatesInRangeSingleDay() {
        let today = Calendar.current.startOfDay(for: Date())
        let dates = Calendar.current.datesInRange(from: today, to: today)
        XCTAssertEqual(dates.count, 1)
        XCTAssertEqual(dates.first, today)
    }

    func testDatesInRangeMultipleDays() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let threeDaysAgo = today.adding(days: -3)
        let dates = calendar.datesInRange(from: threeDaysAgo, to: today)
        XCTAssertEqual(dates.count, 4)
        XCTAssertEqual(dates.first, threeDaysAgo)
        XCTAssertEqual(dates.last, today)
    }

    func testDatesInRangeAreConsecutive() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let start = today.adding(days: -6)
        let dates = calendar.datesInRange(from: start, to: today)
        XCTAssertEqual(dates.count, 7)
        for i in 1..<dates.count {
            let diff = calendar.dateComponents([.day], from: dates[i - 1], to: dates[i]).day!
            XCTAssertEqual(diff, 1)
        }
    }

    func testDatesInRangeAllAtStartOfDay() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let start = today.adding(days: -3)
        let dates = calendar.datesInRange(from: start, to: today)
        for date in dates {
            let components = calendar.dateComponents([.hour, .minute, .second], from: date)
            XCTAssertEqual(components.hour, 0)
            XCTAssertEqual(components.minute, 0)
        }
    }
}
