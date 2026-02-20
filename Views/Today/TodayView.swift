import SwiftUI

// Disambiguate between Swift concurrency Task and our Task model
typealias ConcurrencyTask = _Concurrency.Task

struct TodayView: View {
    @State private var viewModel = TodayViewModel()
    @State private var timerManager = TimerManager.shared
    @State private var currentPage = 0
    @State private var tasksPerPage = 6
    private let estimatedCardHeight: CGFloat = 100

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
                        "No Tasks Yet",
                        systemImage: "checklist",
                        description: Text("Add tasks in the Tasks tab to start tracking")
                    )
                } else {
                    GeometryReader { geo in
                        VStack(spacing: 0) {
                            // Title row with pagination arrows and sync
                            HStack(alignment: .firstTextBaseline) {
                                Text(viewModel.isNonZeroDay ? "Today is Non-Zero" : "Make Today Non-Zero")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(viewModel.isNonZeroDay ? .green : .primary)

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

                                Button {
                                    ConcurrencyTask {
                                        await viewModel.syncHealthKitData()
                                    }
                                } label: {
                                    Image(systemName: "arrow.clockwise.heart.fill")
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                            .padding(.bottom, 4)

                            TabView(selection: $currentPage) {
                                ForEach(0..<totalPages, id: \.self) { page in
                                    ScrollView {
                                        LazyVStack(spacing: 10) {
                                            ForEach(tasksForPage(page)) { task in
                                                TodayTaskCard(
                                                    task: task,
                                                    entry: viewModel.getEntry(for: task),
                                                    suggestion: viewModel.getSuggestion(for: task),
                                                    timerManager: timerManager,
                                                    onQuickAction: { value in
                                                        viewModel.quickLog(task: task, value: value)
                                                    },
                                                    onStartTimer: {
                                                        viewModel.startTimer(for: task)
                                                    },
                                                    onStopTimer: {
                                                        viewModel.stopTimer(for: task)
                                                    },
                                                    onEdit: {
                                                        viewModel.openEntryEditor(for: task)
                                                    }
                                                )
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
            .onAppear {
                viewModel.loadData()
            }
            .refreshable {
                await viewModel.syncHealthKitData()
            }
            .sheet(isPresented: $viewModel.showingEntryEditor) {
                if let task = viewModel.selectedTask {
                    EntryEditorSheet(
                        task: task,
                        entry: viewModel.getEntry(for: task),
                        onSave: { value, note in
                            viewModel.saveEntry(task: task, value: value, note: note)
                        }
                    )
                }
            }
        }
    }
}

struct TodayTaskCard: View {
    let task: Task
    let entry: Entry?
    let suggestion: String?
    let timerManager: TimerManager
    let onQuickAction: (Double) -> Void
    let onStartTimer: () -> Void
    let onStopTimer: () -> Void
    let onEdit: () -> Void

    var currentValue: Double {
        entry?.value ?? 0
    }

    var isNonZero: Bool {
        entry?.isNonZero ?? false
    }

    var isTimerRunning: Bool {
        timerManager.isRunning(taskId: task.id)
    }

    @ViewBuilder
    private var headerRow: some View {
        HStack(spacing: 8) {
            if isNonZero {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.green)
            } else {
                TaskTypeIcon(taskType: task.taskType, size: 20)
            }

            Text(task.name)
                .font(.body)
                .fontWeight(.semibold)
            Spacer()

            if let entry = entry, entry.value > 0 {
                Text(entry.displayValue)
                    .font(.body)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundColor(isNonZero ? .green : .secondary)
            }
        }
    }

    @ViewBuilder
    private var booleanActions: some View {
        if isNonZero {
            Label("Did It!", systemImage: "checkmark.circle.fill")
                .frame(maxWidth: .infinity)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.green)
                .padding(.vertical, 6)
        } else {
            Button {
                onQuickAction(1)
            } label: {
                Label("Done", systemImage: "checkmark.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .controlSize(.small)
            .buttonBorderShape(.capsule)
        }
    }

    @ViewBuilder
    private var countActions: some View {
        ForEach([1.0, 5.0, 10.0], id: \.self) { amount in
            Button {
                onQuickAction(currentValue + amount)
            } label: {
                Text("+\(Int(amount))")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.blue)
            .controlSize(.small)
            .buttonBorderShape(.capsule)
        }
    }

    @ViewBuilder
    private var timeActions: some View {
        if isTimerRunning, let start = timerManager.startTime {
            Text(timerInterval: start...Date.distantFuture, countsDown: false)
                .font(.system(.callout, design: .monospaced))
                .fontWeight(.semibold)
                .foregroundColor(.green)
                .frame(maxWidth: .infinity)

            Button {
                onStopTimer()
            } label: {
                Label("Stop", systemImage: "stop.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.red)
            .controlSize(.small)
            .buttonBorderShape(.capsule)
        } else {
            ForEach([5.0, 15.0, 30.0], id: \.self) { minutes in
                Button {
                    onQuickAction(currentValue + minutes)
                } label: {
                    Text("+\(Int(minutes))m")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.blue)
                .controlSize(.small)
                .buttonBorderShape(.capsule)
            }

            Button {
                onStartTimer()
            } label: {
                Image(systemName: "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .controlSize(.small)
            .buttonBorderShape(.capsule)
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            headerRow

            if let suggestion = suggestion {
                Text(suggestion)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: 6) {
                switch task.taskType {
                case .boolean: booleanActions
                case .count: countActions
                case .time: timeActions
                }

                Button {
                    onEdit()
                } label: {
                    Image(systemName: "pencil")
                }
                .buttonStyle(.bordered)
                .tint(.secondary)
                .controlSize(.small)
                .buttonBorderShape(.capsule)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(isNonZero ? Color.green.opacity(0.3) : Color.clear, lineWidth: 1.5)
        )
    }
}

#Preview {
    TodayView()
}
