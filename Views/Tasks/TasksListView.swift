import SwiftUI

struct TasksListView: View {
    @State private var viewModel = TasksViewModel()
    @State private var currentPage = 0
    @State private var taskToDelete: Task?

    var body: some View {
        NavigationStack {
            TasksListContentView(
                viewModel: viewModel,
                currentPage: $currentPage,
                taskToDelete: $taskToDelete
            )
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.showingReorder = true
                    } label: {
                        Text("Reorder")
                    }
                    .disabled(viewModel.tasks.isEmpty)
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.showingAddTask = true
                    } label: {
                        Image(systemName: "plus")
                    }
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

// Extracted content view to avoid compiler complexity issues
struct TasksListContentView: View {
    @Bindable var viewModel: TasksViewModel
    @Binding var currentPage: Int
    @Binding var taskToDelete: Task?
    @State private var tasksPerPage: Int = 6
    @State private var availableHeight: CGFloat = 0

    var taskPages: [[Task]] {
        let count = viewModel.tasks.count
        var pages: [[Task]] = []

        for startIndex in stride(from: 0, to: count, by: tasksPerPage) {
            let endIndex = min(startIndex + tasksPerPage, count)
            let page = Array(viewModel.tasks[startIndex..<endIndex])
            pages.append(page)
        }

        return pages
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                if viewModel.tasks.isEmpty {
                    ContentUnavailableView(
                        "No Tasks",
                        systemImage: "checklist",
                        description: Text("Add your first task to get started")
                    )
                } else {
                    TabView(selection: $currentPage) {
                        ForEach(Array(taskPages.enumerated()), id: \.offset) { pageIndex, pageTasks in
                            taskListPage(pageTasks: pageTasks, pageIndex: pageIndex)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: taskPages.count > 1 ? .always : .never))
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                }
            }
            .onAppear {
                // Load data once when view appears
                if viewModel.tasks.isEmpty {
                    viewModel.loadTasks()
                }
            }
            .onChange(of: geometry.size) { oldSize, newSize in
                // Recalculate when geometry changes
                updateTasksPerPage(height: newSize.height)
            }
            .task {
                // Initial calculation
                updateTasksPerPage(height: geometry.size.height)
            }
        }
    }

    private func taskListPage(pageTasks: [Task], pageIndex: Int) -> some View {
        List {
            ForEach(pageTasks) { task in
                TaskRow(
                    task: task,
                    isSelected: viewModel.selectedTaskId == task.id,
                    onTap: {
                        withAnimation {
                            if viewModel.selectedTaskId == task.id {
                                viewModel.selectedTaskId = nil
                            } else {
                                viewModel.selectedTaskId = task.id
                            }
                        }
                    },
                    onEdit: {
                        viewModel.editingTask = task
                        viewModel.selectedTaskId = nil
                    },
                    onDelete: {
                        taskToDelete = task
                        viewModel.selectedTaskId = nil
                    }
                )
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 3, leading: 16, bottom: 3, trailing: 16))
            }
        }
        .listStyle(.plain)
        .tag(pageIndex)
    }

    private func updateTasksPerPage(height: CGFloat) {
        // Only recalculate if height has changed significantly (avoid flickering)
        guard abs(height - availableHeight) > 10 else { return }
        availableHeight = height

        // TaskRow: ~72 points (row) + ~6 points (list row spacing) = ~78 points total
        // Account for list spacing and page indicator
        let estimatedRowHeight: CGFloat = 78
        let pageIndicatorSpace: CGFloat = 30
        let usableHeight = height - pageIndicatorSpace
        let calculated = Int(usableHeight / estimatedRowHeight)
        let newTasksPerPage = max(5, min(15, calculated))

        // Only update if it actually changed
        if tasksPerPage != newTasksPerPage {
            tasksPerPage = newTasksPerPage
        }
    }
}

struct TaskRow: View {
    let task: Task
    let isSelected: Bool
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Edit and Delete buttons (shown when selected)
            if isSelected {
                HStack(spacing: 8) {
                    Button {
                        onEdit()
                    } label: {
                        Image(systemName: "pencil")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                            .frame(width: 32, height: 32)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)

                    Button {
                        onDelete()
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 16))
                            .foregroundColor(.red)
                            .frame(width: 32, height: 32)
                            .background(Color.red.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
                .transition(.move(edge: .leading).combined(with: .opacity))
            }

            TaskTypeIcon(taskType: task.taskType, size: 18)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                HStack(spacing: 6) {
                    Text("Min: \(Formatting.formatValue(task.minimumValue, for: task.taskType, unit: task.unit))")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    if let goal = task.goalValue {
                        Text("·")
                            .foregroundColor(.secondary)
                        Text("Goal: \(Formatting.formatValue(goal, for: task.taskType, unit: task.unit))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            StreakBadge(streak: task.currentStreak())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
        )
        .contentShape(Rectangle())
        .onTapGesture {
            // Quick tap only works to deselect when already selected
            if isSelected {
                onTap()
            }
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            // Long press to select/toggle
            onTap()
        }
    }
}

#Preview {
    TasksListView()
}
