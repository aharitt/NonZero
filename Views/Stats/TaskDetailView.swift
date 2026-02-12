import SwiftUI
import SwiftUI
import Charts

struct TaskDetailView: View {
    let task: Task
    @State private var viewModel = StatsViewModel()

    var totalValue: Double {
        viewModel.getTotalValue(for: task)
    }

    var averageValue: Double {
        viewModel.getAverageValue(for: task, days: 7)
    }

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
                // Task Info
                TaskInfoCard(task: task)

                // Key Stats
                VStack(alignment: .leading, spacing: 16) {
                    Text("Statistics")
                        .font(.headline)
                        .padding(.horizontal)

                    HStack(spacing: 12) {
                        DetailStatCard(
                            title: "Total",
                            value: Formatting.formatValue(totalValue, for: task.taskType),
                            icon: "sum"
                        )

                        DetailStatCard(
                            title: "7-Day Avg",
                            value: Formatting.formatValue(averageValue, for: task.taskType),
                            icon: "chart.bar"
                        )
                    }
                    .padding(.horizontal)

                    HStack(spacing: 12) {
                        DetailStatCard(
                            title: "Current Streak",
                            value: "\(viewModel.getCurrentStreak(for: task))",
                            subtitle: "days",
                            icon: "flame.fill",
                            color: .orange
                        )

                        DetailStatCard(
                            title: "Best Streak",
                            value: "\(viewModel.getLongestStreak(for: task))",
                            subtitle: "days",
                            icon: "star.fill",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)

                    HStack(spacing: 12) {
                        DetailStatCard(
                            title: "Comebacks",
                            value: "\(viewModel.getComebackCount(for: task))",
                            subtitle: "times",
                            icon: "arrow.up.circle.fill",
                            color: .green
                        )

                        DetailStatCard(
                            title: "Non-Zero Days",
                            value: "\(viewModel.getTotalNonZeroDays(for: task))",
                            subtitle: "total",
                            icon: "checkmark.seal.fill",
                            color: .blue
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

                // Calendar Heatmap
                CalendarHeatmapView(task: task, days: 60)
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
        .navigationTitle(task.name)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.loadTasks()
        }
    }
}

struct TaskInfoCard: View {
    let task: Task

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                TaskTypeIcon(taskType: task.taskType, size: 24)
                Text(task.taskType.displayName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                StreakBadge(streak: task.currentStreak())
            }

            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Minimum")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(Formatting.formatValue(task.minimumValue, for: task.taskType))
                        .font(.title3)
                        .fontWeight(.semibold)
                }

                Spacer()

                if let goal = task.goalValue {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Goal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(Formatting.formatValue(goal, for: task.taskType))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
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
