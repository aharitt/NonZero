import SwiftUI
import Charts

struct StatsView: View {
    @State private var viewModel = StatsViewModel()
    @State private var currentPage = 0
    @State private var tasksPerPage = 6
    private let estimatedCardHeight: CGFloat = 120

    var totalPages: Int {
        max(1, (viewModel.tasks.count + tasksPerPage - 1) / tasksPerPage)
    }

    func tasksForPage(_ page: Int) -> [Task] {
        let start = page * tasksPerPage
        let end = min(start + tasksPerPage, viewModel.tasks.count)
        guard start < viewModel.tasks.count else { return [] }
        return Array(viewModel.tasks[start..<end])
    }

    private func calculateTasksPerPage(height: CGFloat) {
        // GeometryReader height already excludes nav bar and tab bar
        // Reserve space for: title row (~48) + padding (~16)
        let reserved: CGFloat = 64
        let available = height - reserved
        let count = max(1, Int(available / estimatedCardHeight))
        if count != tasksPerPage {
            tasksPerPage = count
            currentPage = min(currentPage, max(0, totalPages - 1))
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.tasks.isEmpty {
                    ContentUnavailableView(
                        "No Stats Yet",
                        systemImage: "chart.bar",
                        description: Text("Add tasks and log entries to see your progress")
                    )
                } else {
                    GeometryReader { geo in
                        VStack(spacing: 0) {
                            // Title row with pagination arrows
                            HStack(alignment: .firstTextBaseline) {
                                Text("Stats")
                                    .font(.title2)
                                    .fontWeight(.bold)

                                Spacer()

                                if totalPages > 1 {
                                    Button {
                                        withAnimation { currentPage -= 1 }
                                    } label: {
                                        Image(systemName: "chevron.left")
                                            .fontWeight(.semibold)
                                    }
                                    .disabled(currentPage == 0)

                                    Text("\(currentPage + 1)/\(totalPages)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .monospacedDigit()

                                    Button {
                                        withAnimation { currentPage += 1 }
                                    } label: {
                                        Image(systemName: "chevron.right")
                                            .fontWeight(.semibold)
                                    }
                                    .disabled(currentPage >= totalPages - 1)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                            .padding(.bottom, 4)

                            TabView(selection: $currentPage) {
                                ForEach(0..<totalPages, id: \.self) { page in
                                    ScrollView {
                                        LazyVStack(spacing: 10) {
                                            if page == 0 {
                                                NavigationLink {
                                                    DayScoreDetailView(viewModel: viewModel)
                                                } label: {
                                                    DayScoreCard(viewModel: viewModel)
                                                }
                                                .buttonStyle(.plain)
                                            }

                                            ForEach(tasksForPage(page)) { task in
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
                                    .tag(page)
                                }
                            }
                            .tabViewStyle(.page(indexDisplayMode: .never))
                        }
                        .onAppear { calculateTasksPerPage(height: geo.size.height) }
                        .onChange(of: geo.size.height) { _, newHeight in
                            calculateTasksPerPage(height: newHeight)
                        }
                    }
                    .background(Color(.systemGroupedBackground))
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .onAppear {
            viewModel.loadTasks()
        }
    }
}

struct StatsTaskCard: View {
    let viewModel: StatsViewModel
    let task: Task

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                TaskTypeIcon(taskType: task.taskType, size: 18)

                Text(task.name)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            HStack(spacing: 8) {
                QuickStatItem(
                    icon: "arrow.up.circle.fill",
                    value: "\(task.comebackCount())",
                    label: "Comeback",
                    color: .green
                )

                QuickStatItem(
                    icon: "percent",
                    value: viewModel.getResilienceIndex(for: task).map { Formatting.formatPercentage($0) } ?? "—",
                    label: "Resilience",
                    color: .blue
                )

                QuickStatItem(
                    icon: "flame.fill",
                    value: "\(task.currentStreak())",
                    label: "Streak",
                    color: .orange
                )
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

struct DayScoreCard: View {
    let viewModel: StatsViewModel

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.yellow)

                Text("Day Score")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            HStack(spacing: 8) {
                QuickStatItem(
                    icon: "arrow.up.circle.fill",
                    value: "\(viewModel.dayScoreComebackCount())",
                    label: "Comeback",
                    color: .green
                )

                QuickStatItem(
                    icon: "percent",
                    value: viewModel.dayScoreResilienceIndex().map { Formatting.formatPercentage($0) } ?? "—",
                    label: "Resilience",
                    color: .blue
                )

                QuickStatItem(
                    icon: "flame.fill",
                    value: "\(viewModel.dayScoreCurrentStreak())",
                    label: "Streak",
                    color: .orange
                )
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemGroupedBackground))
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
                    .font(.callout)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundColor(.primary)

                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
        .padding(.horizontal, 6)
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(8)
    }
}

struct StatsCardsView: View {
    let viewModel: StatsViewModel
    let task: Task

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatCard(
                    title: "Current Streak",
                    value: "\(task.currentStreak())",
                    subtitle: "days",
                    color: .orange,
                    icon: "flame.fill"
                )

                StatCard(
                    title: "Longest Streak",
                    value: "\(task.longestStreak())",
                    subtitle: "days",
                    color: .purple,
                    icon: "star.fill"
                )

                StatCard(
                    title: "Comebacks",
                    value: "\(task.comebackCount())",
                    subtitle: "times",
                    color: .green,
                    icon: "arrow.up.circle.fill"
                )
            }

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
                .fontDesign(.rounded)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
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
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
}

#Preview {
    StatsView()
}
