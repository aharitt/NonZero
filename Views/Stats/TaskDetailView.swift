import SwiftUI
import SwiftUI
import Charts

struct TaskDetailView: View {
    let task: Task
    @State private var viewModel = StatsViewModel()
    @State private var refreshID = UUID()

    var recentEntries: [Entry] {
        task.entries
            .filter { $0.value > 0 }
            .sorted { $0.date > $1.date }
            .prefix(10)
            .map { $0 }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Key Stats
                VStack(alignment: .leading, spacing: 16) {
                    Text("Statistics")
                        .font(.headline)
                        .padding(.horizontal)

                    HStack(spacing: 12) {
                        DetailStatCard(
                            title: "Current Streak",
                            value: "\(task.currentStreak())",
                            subtitle: "days",
                            icon: "flame.fill",
                            color: .orange
                        )

                        DetailStatCard(
                            title: "Comeback",
                            value: "\(task.comebackCount())",
                            subtitle: "times",
                            icon: "arrow.up.circle.fill",
                            color: .green
                        )
                    }
                    .padding(.horizontal)

                    HStack(spacing: 12) {
                        DetailStatCard(
                            title: "Recovery Ratio",
                            value: Formatting.formatPercentage(viewModel.getRecoveryRatio(for: task)),
                            icon: "percent",
                            color: .blue
                        )

                        DetailStatCard(
                            title: "Days Returned After Miss",
                            value: "\(viewModel.getDaysReturnedAfterMiss(for: task))",
                            subtitle: "days",
                            icon: "arrow.uturn.up.circle.fill",
                            color: .cyan
                        )
                    }
                    .padding(.horizontal)

                    HStack(spacing: 12) {
                        DetailStatCard(
                            title: "Non-Zero Days",
                            value: "\(task.totalNonZeroDays())",
                            subtitle: "total",
                            icon: "checkmark.seal.fill",
                            color: .mint
                        )

                        DetailStatCard(
                            title: "Best Streak",
                            value: "\(task.longestStreak())",
                            subtitle: "days",
                            icon: "star.fill",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)

                    // Completion Rates
                    Text("Completion Rates")
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.top, 8)

                    HStack(spacing: 12) {
                        DetailStatCard(
                            title: "7 Days",
                            value: Formatting.formatPercentage(viewModel.getCompletionRate(for: task, days: 7)),
                            icon: "calendar",
                            color: .blue
                        )

                        DetailStatCard(
                            title: "30 Days",
                            value: Formatting.formatPercentage(viewModel.getCompletionRate(for: task, days: 30)),
                            icon: "calendar",
                            color: .cyan
                        )

                        DetailStatCard(
                            title: "90 Days",
                            value: Formatting.formatPercentage(viewModel.getCompletionRate(for: task, days: 90)),
                            icon: "calendar",
                            color: .indigo
                        )
                    }
                    .padding(.horizontal)
                }
                .id(refreshID)

                // Calendar Heatmap
                CalendarHeatmapView(task: task, days: 60, onEntryChanged: {
                    refreshID = UUID()
                })
                    .padding(.horizontal)

                // Recent Entries
                if !recentEntries.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Entries")
                            .font(.headline)
                            .padding(.horizontal)

                        VStack(spacing: 8) {
                            ForEach(recentEntries) { entry in
                                EntryRowView(entry: entry, task: task)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    TaskTypeIcon(taskType: task.taskType, size: 20)
                    Text(task.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            viewModel.loadTasks()
        }
    }
}

struct DetailStatCard: View {
    let title: String
    let value: String
    var subtitle: String = ""
    let icon: String
    var color: Color = .blue

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)

                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct EntryRowView: View {
    let entry: Entry
    let task: Task

    var body: some View {
        HStack {
            NonZeroBadge(isNonZero: entry.isNonZero, size: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(Formatting.relativeDate(entry.date))
                    .font(.subheadline)
                    .fontWeight(.medium)

                if let note = entry.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            Text(entry.displayValue)
                .font(.headline)
                .foregroundColor(entry.isNonZero ? .green : .secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

#Preview {
    let task = Task(name: "Pushups", taskType: .count, minimumValue: 5, goalValue: 20)
    NavigationStack {
        TaskDetailView(task: task)
    }
}
