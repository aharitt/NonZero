import SwiftUI

// Disambiguate between Swift concurrency Task and our Task model
typealias ConcurrencyTask = _Concurrency.Task

struct TodayView: View {
    @State private var viewModel = TodayViewModel()
    @State private var timerManager = TimerManager.shared
    @State private var currentPage = 0

    var todayDate: String {
        Date().formatted(date: .abbreviated, time: .omitted)
    }

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
                        "No Tasks Yet",
                        systemImage: "checklist",
                        description: Text("Add tasks in the Tasks tab to start tracking")
                    )
                    .padding()
                } else {
                    // Paginated task view
                    TabView(selection: $currentPage) {
                        ForEach(Array(taskPages.enumerated()), id: \.offset) { pageIndex, pageTasks in
                            ScrollView {
                                VStack(spacing: 8) {
                                    ForEach(pageTasks) { task in
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
                                .padding(.vertical)
                            }
                            .tag(pageIndex)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: taskPages.count > 1 ? .always : .never))
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                }
            }
            .navigationTitle("Today - \(todayDate)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        ConcurrencyTask {
                            await viewModel.syncHealthKitData()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise.heart.fill")
                    }
                }
            })
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

    var timerElapsedTime: String {
        guard isTimerRunning else { return "0:00" }
        // Access lastUpdate to ensure view tracks timer changes
        _ = timerManager.lastUpdate
        return timerManager.formattedElapsedTime
    }

    var body: some View {
        VStack(spacing: 6) {
            // Header with task name and current value
            HStack(spacing: 6) {
                TaskTypeIcon(taskType: task.taskType, size: 18)
                Text(task.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                if entry != nil {
                    Text(entry!.displayValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(isNonZero ? .green : .secondary)
                }
            }

            // Suggestion
            if let suggestion = suggestion {
                Text(suggestion)
                    .font(.caption2)
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Quick Actions
            HStack(spacing: 6) {
                switch task.taskType {
                case .boolean:
                    Button {
                        onQuickAction(isNonZero ? 0 : 1)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: isNonZero ? "xmark.circle" : "checkmark.circle")
                                .font(.caption)
                            Text(isNonZero ? "Undone" : "Done")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(isNonZero ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                        .foregroundColor(isNonZero ? .red : .green)
                        .cornerRadius(6)
                    }

                case .count:
                    ForEach([1.0, 5.0, 10.0], id: \.self) { amount in
                        Button {
                            onQuickAction(currentValue + amount)
                        } label: {
                            Text("+\(Int(amount))")
                                .font(.caption)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(6)
                        }
                    }

                case .duration:
                    ForEach([5.0, 15.0, 30.0], id: \.self) { minutes in
                        Button {
                            onQuickAction(currentValue + minutes)
                        } label: {
                            Text("+\(Int(minutes))m")
                                .font(.caption)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(6)
                        }
                    }

                case .timer:
                    if isTimerRunning {
                        // Show elapsed time and stop button
                        HStack(spacing: 6) {
                            Text(timerElapsedTime)
                                .font(.system(.body, design: .monospaced))
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(6)

                            Button {
                                onStopTimer()
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "stop.fill")
                                        .font(.caption)
                                    Text("Stop")
                                        .font(.caption)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.red.opacity(0.1))
                                .foregroundColor(.red)
                                .cornerRadius(6)
                            }
                        }
                    } else {
                        // Show start button
                        Button {
                            onStartTimer()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "play.fill")
                                    .font(.caption)
                                Text("Start")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.green.opacity(0.1))
                            .foregroundColor(.green)
                            .cornerRadius(6)
                        }
                    }
                }

                Button {
                    onEdit()
                } label: {
                    Image(systemName: "pencil")
                        .font(.caption)
                        .frame(width: 36)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .foregroundColor(.secondary)
                        .cornerRadius(6)
                }
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

#Preview {
    TodayView()
}

// You can test the timer display by uncommenting the seed data in your app initialization
