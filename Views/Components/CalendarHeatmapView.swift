import SwiftUI
import SwiftData

struct IdentifiableDate: Identifiable {
    let date: Date
    var id: TimeInterval { date.timeIntervalSince1970 }
}

struct CalendarHeatmapView: View {
    let task: Task
    let startDate: Date
    let endDate: Date

    @State private var selectedDate: IdentifiableDate?

    private let columns = 7
    private let spacing: CGFloat = 4
    private let dataStore = DataStore.shared

    init(task: Task, days: Int = 30) {
        self.task = task
        let calendar = Calendar.current
        self.endDate = calendar.startOfDay(for: Date())
        self.startDate = calendar.date(byAdding: .day, value: -days + 1, to: endDate)!
    }

    var dates: [Date] {
        Calendar.current.datesInRange(from: startDate, to: endDate)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Last \(dates.count) days - Press to edit")
                .font(.subheadline)
                .foregroundColor(.secondary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns), spacing: spacing) {
                ForEach(dates, id: \.self) { date in
                    DayCell(task: task, date: date)
                        .onLongPressGesture(minimumDuration: 0.5) {
                            selectedDate = IdentifiableDate(date: date)
                        }
                }
            }

            HStack {
                Text(startDate.shortDate)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text(endDate.shortDate)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .sheet(item: $selectedDate) { identifiableDate in
            PastEntryEditorSheet(
                task: task,
                date: identifiableDate.date,
                entry: task.entry(for: identifiableDate.date),
                onSave: { value, note in
                    saveEntry(date: identifiableDate.date, value: value, note: note)
                }
            )
        }
    }

    private func saveEntry(date: Date, value: Double, note: String?) {
        if let existingEntry = task.entry(for: date) {
            dataStore.updateEntry(existingEntry, value: value, note: note)
        } else {
            let entry = Entry(task: task, date: date, value: value, note: note)
            dataStore.addEntry(entry)
        }
    }
}

struct DayCell: View {
    let task: Task
    let date: Date

    var entry: Entry? {
        task.entry(for: date)
    }

    var isNonZero: Bool {
        entry?.isNonZero ?? false
    }

    var intensity: Double {
        guard let entry = entry else { return 0 }
        if task.taskType == .boolean {
            return isNonZero ? 1.0 : 0.0
        }

        if let goal = task.goalValue, goal > 0 {
            return min(entry.value / goal, 1.0)
        } else {
            return isNonZero ? 0.7 : 0.0
        }
    }

    var color: Color {
        if intensity == 0 {
            return Color.gray.opacity(0.1)
        } else if intensity < 0.3 {
            return Color.green.opacity(0.3)
        } else if intensity < 0.7 {
            return Color.green.opacity(0.6)
        } else {
            return Color.green
        }
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(color)
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(4)

            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(intensity > 0.5 ? .white : .secondary)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(date.isToday ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    @Previewable @State var task = Task(name: "Pushups", taskType: .count, minimumValue: 5, goalValue: 20)

    CalendarHeatmapView(task: task, days: 30)
        .padding()
        .modelContainer(for: [Task.self, Entry.self])
}
