import SwiftUI

struct TasksListView: View {
    @State private var viewModel = TasksViewModel()
    @State private var taskToDelete: Task?
    @State private var currentPage = 0
    @State private var tasksPerPage = 8
    @State private var selectedTaskId: UUID?
    private let estimatedRowHeight: CGFloat = 75

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
        let reserved: CGFloat = 64
        let available = height - reserved
        let count = max(1, Int(available / estimatedRowHeight))
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
                        "No Tasks",
                        systemImage: "checklist",
                        description: Text("Add your first task to get started")
                    )
                } else {
                    GeometryReader { geo in
                        VStack(spacing: 0) {
                            // Title row with Reorder, pagination, and Add
                            HStack(alignment: .firstTextBaseline) {
                                Text("Tasks")
                                    .font(.title2)
                                    .fontWeight(.bold)

                                Spacer()

                                Button {
                                    viewModel.showingReorder = true
                                } label: {
                                    Text("Reorder")
                                        .font(.subheadline)
                                }
                                .disabled(viewModel.tasks.isEmpty)

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
                                    viewModel.showingAddTask = true
                                } label: {
                                    Image(systemName: "plus")
                                        .fontWeight(.semibold)
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
                                                TaskRow(
                                                    task: task,
                                                    isSelected: selectedTaskId == task.id,
                                                    onEdit: {
                                                        selectedTaskId = nil
                                                        viewModel.editingTask = task
                                                    },
                                                    onDelete: {
                                                        selectedTaskId = nil
                                                        taskToDelete = task
                                                    },
                                                    onLongPress: {
                                                        withAnimation(.easeOut(duration: 0.2)) {
                                                            selectedTaskId = selectedTaskId == task.id ? nil : task.id
                                                        }
                                                    },
                                                    onTap: {
                                                        if selectedTaskId != nil {
                                                            withAnimation(.easeOut(duration: 0.2)) {
                                                                selectedTaskId = nil
                                                            }
                                                        }
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
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showingAddTask = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .toolbar(viewModel.tasks.isEmpty ? .visible : .hidden, for: .navigationBar)
            .onAppear {
                if viewModel.tasks.isEmpty {
                    viewModel.loadTasks()
                }
            }
            .onChange(of: viewModel.tasks.count) {
                if currentPage >= totalPages {
                    currentPage = max(0, totalPages - 1)
                }
            }
            .sheet(isPresented: $viewModel.showingAddTask) {
                TaskEditorView(mode: .add) { name, type, minimum, goal, unit, workout, pushFit, icon in
                    viewModel.addTask(name: name, type: type, minimum: minimum, goal: goal, unit: unit, healthKitWorkout: workout, pushFitPro: pushFit, icon: icon)
                }
            }
            .sheet(item: $viewModel.editingTask) { task in
                TaskEditorView(
                    mode: .edit(task),
                    onSave: { name, type, minimum, goal, unit, workout, pushFit, icon in
                        viewModel.updateTask(task, name: name, type: type, minimum: minimum, goal: goal, unit: unit, healthKitWorkout: workout, pushFitPro: pushFit, icon: icon)
                    }
                )
            }
            .sheet(isPresented: $viewModel.showingReorder) {
                ReorderTasksView(tasks: viewModel.tasks) { reorderedTasks in
                    viewModel.reorderTasks(reorderedTasks)
                }
            }
            .alert("Delete Task", isPresented: Binding(
                get: { taskToDelete != nil },
                set: { if !$0 { taskToDelete = nil } }
            )) {
                Button("Cancel", role: .cancel) {
                    taskToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let task = taskToDelete {
                        viewModel.deleteTask(task)
                        taskToDelete = nil
                    }
                }
            } message: {
                if let task = taskToDelete {
                    Text("Are you sure you want to delete '\(task.name)'? This will also delete all associated entries.")
                }
            }
        }
    }
}

struct TaskRow: View {
    let task: Task
    let isSelected: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onLongPress: () -> Void
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            // Card content — shifts left when selected
            HStack(spacing: 12) {
                TaskTypeIcon(taskType: task.taskType, size: 20)

                VStack(alignment: .leading, spacing: 4) {
                    Text(task.name)
                        .font(.body)
                        .fontWeight(.semibold)

                    HStack(spacing: 6) {
                        Text("Min: \(Formatting.formatValue(task.minimumValue, for: task.taskType, unit: task.unit))")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        if let goal = task.goalValue {
                            Text("·")
                                .foregroundColor(.secondary)
                            Text("Goal: \(Formatting.formatValue(goal, for: task.taskType, unit: task.unit))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer()

                StreakBadge(streak: task.currentStreak())
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemGroupedBackground))
            )

            // Action buttons — slide in from right
            if isSelected {
                HStack(spacing: 0) {
                    Button {
                        onEdit()
                    } label: {
                        Image(systemName: "pencil")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 56)
                            .background(Color.blue)
                    }
                    .buttonStyle(.plain)

                    Button {
                        onDelete()
                    } label: {
                        Image(systemName: "trash")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 56)
                            .background(Color.red)
                    }
                    .buttonStyle(.plain)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.leading, 8)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            onLongPress()
        }
    }
}

#Preview {
    TasksListView()
}
