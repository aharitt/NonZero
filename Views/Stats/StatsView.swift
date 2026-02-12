import SwiftUI
import Charts

struct StatsView: View {
    @State private var viewModel = StatsViewModel()
    @State private var currentPage = 0

    // Split tasks into pages of 6
    var taskPages: [[Task]] {
        let tasksPerPage = 6
        return stride(from: 0, to: viewModel.tasks.count, by: tasksPerPage).map {
            Array(viewModel.tasks[$0..<min($0 + tasksPerPage, viewModel.tasks.count)])
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.tasks.isEmpty {
                    ContentUnavailableView(
                        "No Stats Yet",
                        systemImage: "chart.bar",
                        description: Text("Add tasks and log entries to see your progress")
                    )
                    .padding()
                } else {
                    // Paginated task stats view
                    TabView(selection: $currentPage) {
                        ForEach(Array(taskPages.enumerated()), id: \.offset) { pageIndex, pageTasks in
                            ScrollView {
                                VStack(spacing: 6) {
                                    ForEach(pageTasks) { task in
                                        NavigationLink {
                                            TaskDetailView(task: task)
                                        } label: {
                                            StatsTaskCard(viewModel: viewModel, task: task)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                            }
                            .tag(pageIndex)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: taskPages.count > 1 ? .always : .never))
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                }
            }
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            viewModel.loadTasks()
        }
    }
}

// New card component for paginated stats
struct StatsTaskCard: View {
    let viewModel: StatsViewModel
    let task: Task

    var body: some View {
        VStack(spacing: 8) {
            // Header with task name and icon
            HStack(spacing: 8) {
                TaskTypeIcon(taskType: task.taskType, size: 16)

                Text(task.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            // Quick stats
            HStack(spacing: 8) {
                QuickStatItem(
                    icon: "flame.fill",
                    value: "\(viewModel.getCurrentStreak(for: task))",
                    label: "Streak",
                    color: .orange
                )

                QuickStatItem(
                    icon: "star.fill",
                    value: "\(viewModel.getLongestStreak(for: task))",
                    label: "Best",
                    color: .purple
                )

                QuickStatItem(
                    icon: "chart.bar.fill",
                    value: Formatting.formatPercentage(viewModel.getCompletionRate(for: task, days: 7)),
                    label: "7-Day",
                    color: .blue
                )
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
        )
    }
}

struct QuickStatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
        .padding(.horizontal, 6)
        .background(color.opacity(0.1))
        .cornerRadius(6)
    }
}

struct StatsCardsView: View {
    let viewModel: StatsViewModel
    let task: Task

    var body: some View {
        VStack(spacing: 12) {
            // First row: Streaks
            HStack(spacing: 12) {
                StatCard(
                    title: "Current Streak",
                    value: "\(viewModel.getCurrentStreak(for: task))",
                    subtitle: "days",
                    color: .orange,
                    icon: "flame.fill"
                )

                StatCard(
                    title: "Longest Streak",
                    value: "\(viewModel.getLongestStreak(for: task))",
                    subtitle: "days",
                    color: .purple,
                    icon: "star.fill"
                )

                StatCard(
                    title: "Comebacks",
                    value: "\(viewModel.getComebackCount(for: task))",
                    subtitle: "times",
                    color: .green,
                    icon: "arrow.up.circle.fill"
                )
            }

            // Second row: Completion Rates
            HStack(spacing: 12) {
                StatCard(
                    title: "7-Day Rate",
                    value: Formatting.formatPercentage(viewModel.getCompletionRate(for: task, days: 7)),
                    subtitle: "complete",
                    color: .blue,
                    icon: "chart.line.uptrend.xyaxis"
                )

                StatCard(
                    title: "30-Day Rate",
                    value: Formatting.formatPercentage(viewModel.getCompletionRate(for: task, days: 30)),
                    subtitle: "complete",
                    color: .cyan,
                    icon: "chart.bar.fill"
                )

                StatCard(
                    title: "90-Day Rate",
                    value: Formatting.formatPercentage(viewModel.getCompletionRate(for: task, days: 90)),
                    subtitle: "complete",
                    color: .indigo,
                    icon: "chart.xyaxis.line"
                )
            }
        }
        .padding(.horizontal)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct WeekChartView: View {
    let viewModel: StatsViewModel
    let task: Task

    var weekData: [(date: Date, value: Double, isNonZero: Bool)] {
        viewModel.getWeekData(for: task)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last 7 Days")
                .font(.headline)
                .padding(.horizontal)

            Chart {
                ForEach(weekData, id: \.date) { data in
                    BarMark(
                        x: .value("Day", data.date, unit: .day),
                        y: .value("Value", data.value)
                    )
                    .foregroundStyle(data.isNonZero ? Color.green : Color.gray.opacity(0.3))
                    .cornerRadius(4)
                }

                if let goal = task.goalValue {
                    RuleMark(y: .value("Goal", goal))
                        .foregroundStyle(Color.blue.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                }

                RuleMark(y: .value("Minimum", task.minimumValue))
                    .foregroundStyle(Color.orange.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.weekday(.narrow))
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
}

#Preview {
    StatsView()
}
