import SwiftUI

struct ReorderTasksView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var tasks: [Task]
    let onSave: ([Task]) -> Void

    init(tasks: [Task], onSave: @escaping ([Task]) -> Void) {
        _tasks = State(initialValue: tasks)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(tasks) { task in
                    HStack(spacing: 12) {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(.secondary)

                        TaskTypeIcon(taskType: task.taskType, size: 18)

                        Text(task.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
                .onMove { source, destination in
                    tasks.move(fromOffsets: source, toOffset: destination)
                }
            }
            .navigationTitle("Reorder Tasks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onSave(tasks)
                        dismiss()
                    }
                }
            }
            .environment(\.editMode, .constant(.active))
        }
    }
}
