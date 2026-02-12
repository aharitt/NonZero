import SwiftUI

struct EntryEditorSheet: View {
    @Environment(\.dismiss) private var dismiss

    let task: Task
    let entry: Entry?
    let onSave: (Double, String?) -> Void

    @State private var value: String = ""
    @State private var note: String = ""
    @State private var boolValue: Bool = false

    init(task: Task, entry: Entry?, onSave: @escaping (Double, String?) -> Void) {
        self.task = task
        self.entry = entry
        self.onSave = onSave

        if let entry = entry {
            switch task.taskType {
            case .boolean:
                _boolValue = State(initialValue: entry.value >= 1.0)
            case .count, .duration, .timer:
                _value = State(initialValue: String(Int(entry.value)))
            }
            _note = State(initialValue: entry.note ?? "")
        } else {
            _value = State(initialValue: "")
            _note = State(initialValue: "")
            _boolValue = State(initialValue: false)
        }
    }

    var isValid: Bool {
        switch task.taskType {
        case .boolean:
            return true
        case .count, .duration, .timer:
            return Double(value) != nil
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Task") {
                    HStack {
                        TaskTypeIcon(taskType: task.taskType)
                        Text(task.name)
                            .font(.headline)
                    }
                }

                Section {
                    switch task.taskType {
                    case .boolean:
                        Toggle("Completed", isOn: $boolValue)

                    case .count:
                        HStack {
                            Text("Count")
                            Spacer()
                            TextField("0", text: $value)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                        }

                    case .duration, .timer:
                        HStack {
                            Text("Minutes")
                            Spacer()
                            TextField("0", text: $value)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Minimum:")
                                .foregroundColor(.secondary)
                            Text(Formatting.formatValue(task.minimumValue, for: task.taskType))
                                .fontWeight(.semibold)
                        }
                        .font(.caption)

                        if let goal = task.goalValue {
                            HStack {
                                Text("Goal:")
                                    .foregroundColor(.secondary)
                                Text(Formatting.formatValue(goal, for: task.taskType))
                                    .fontWeight(.semibold)
                            }
                            .font(.caption)
                        }
                    }
                } header: {
                    Text("Value")
                }

                Section {
                    TextField("Add a note (optional)", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Note")
                }

                if entry != nil {
                    Section {
                        Button(role: .destructive) {
                            // Delete entry (set value to 0)
                            onSave(0, nil)
                            dismiss()
                        } label: {
                            Text("Clear Entry")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
            }
            .navigationTitle("Log Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    private func save() {
        let finalValue: Double

        switch task.taskType {
        case .boolean:
            finalValue = boolValue ? 1.0 : 0.0
        case .count, .duration, .timer:
            finalValue = Double(value) ?? 0.0
        }

        onSave(finalValue, note.isEmpty ? nil : note)
        dismiss()
    }
}

#Preview {
    let task = Task(name: "Pushups", taskType: .count, minimumValue: 5, goalValue: 20)
    return EntryEditorSheet(task: task, entry: nil) { value, note in
        print("Saved: \(value), \(note ?? "no note")")
    }
}
