import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self)!
    }

    func daysBetween(_ otherDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self.startOfDay, to: otherDate.startOfDay)
        return abs(components.day ?? 0)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: self)
    }

    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: self)
    }

    var mediumDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
}

extension Calendar {
    func generateDates(
        from startDate: Date,
        to endDate: Date,
        matching component: DateComponents
    ) -> [Date] {
        var dates: [Date] = []
        enumerateDates(
            startingAfter: startDate,
            matching: component,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            if let date = date {
                if date <= endDate {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }
        return dates
    }

    func datesInRange(from start: Date, to end: Date) -> [Date] {
        var dates: [Date] = []
        var currentDate = startOfDay(for: start)
        let endDate = startOfDay(for: end)

        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = date(byAdding: .day, value: 1, to: currentDate)!
        }

        return dates
    }
}
