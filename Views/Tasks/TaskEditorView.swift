import SwiftUI

enum TaskEditorMode {
    case add
    case edit(Task)
}

struct TaskEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let mode: TaskEditorMode
    let onSave: (String, TaskType, Double, Double?, String?, String?, Bool, String?) -> Void

    @State private var name: String = ""
    @State private var selectedType: TaskType = .boolean
    @State private var minimumValue: String = "1"
    @State private var goalValue: String = ""
    @State private var hasGoal: Bool = false
    @State private var selectedUnit: String = "None"
    @State private var customUnit: String = ""
    @State private var showCustomUnit: Bool = false
    @State private var selectedWorkoutType: String = "None"
    @State private var useHealthKit: Bool = false
    @State private var usePushFitPro: Bool = false
    @State private var selectedIcon: String? = nil
    @State private var showingIconPicker = false

    private let predefinedUnits = ["None", "Pages", "Cups", "Steps", "Custom"]
    private let healthKitManager = HealthKitManager.shared

    init(mode: TaskEditorMode, onSave: @escaping (String, TaskType, Double, Double?, String?, String?, Bool, String?) -> Void) {
        self.mode = mode
        self.onSave = onSave

        if case .edit(let task) = mode {
            _name = State(initialValue: task.name)
            _selectedType = State(initialValue: task.taskType)
            _minimumValue = State(initialValue: String(Int(task.minimumValue)))
            _hasGoal = State(initialValue: task.goalValue != nil)
            _goalValue = State(initialValue: task.goalValue != nil ? String(Int(task.goalValue!)) : "")
            _selectedIcon = State(initialValue: task.icon)

            // Set unit
            if let unit = task.unit {
                if predefinedUnits.contains(unit) {
                    _selectedUnit = State(initialValue: unit)
                } else {
                    _selectedUnit = State(initialValue: "Custom")
                    _customUnit = State(initialValue: unit)
                    _showCustomUnit = State(initialValue: true)
                }
            }

            // Set HealthKit workout type
            if let workoutType = task.healthKitWorkoutType {
                _selectedWorkoutType = State(initialValue: workoutType)
                _useHealthKit = State(initialValue: true)
            }

            // Set PushFit Pro integration
            _usePushFitPro = State(initialValue: task.pushFitProEnabled)
        }
    }

    var title: String {
        switch mode {
        case .add: return "New Task"
        case .edit: return "Edit Task"
        }
    }

    var isValid: Bool {
        !name.isEmpty &&
        Double(minimumValue) != nil &&
        (!hasGoal || Double(goalValue) != nil)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Task Details") {
                    TextField("Task Name", text: $name)
                        .textInputAutocapitalization(.words)

                    // Icon picker
                    Button {
                        showingIconPicker = true
                    } label: {
                        HStack {
                            Text("Icon")
                                .foregroundColor(.primary)
                            Spacer()
                            if let icon = selectedIcon {
                                Image(systemName: icon)
                                    .foregroundColor(.blue)
                            } else {
                                Text("None")
                                    .foregroundColor(.secondary)
                            }
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Picker("Type", selection: $selectedType) {
                        ForEach(TaskType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // Unit section (only for count tasks)
                if selectedType == .count {
                    Section("Unit") {
                        Picker("Unit", selection: $selectedUnit) {
                            ForEach(predefinedUnits, id: \.self) { unit in
                                Text(unit).tag(unit)
                            }
                        }
                        .onChange(of: selectedUnit) { oldValue, newValue in
                            showCustomUnit = (newValue == "Custom")
                            if newValue != "Custom" {
                                customUnit = ""
                            }
                        }

                        if showCustomUnit {
                            TextField("Enter custom unit", text: $customUnit)
                                .textInputAutocapitalization(.never)
                        }
                    }
                }

                // Targets section (hide for boolean tasks)
                if selectedType != .boolean {
                    Section {
                        HStack {
                            Text("Minimum")
                            Spacer()
                            TextField("0", text: $minimumValue)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                            Text(unitText)
                                .foregroundColor(.secondary)
                        }

                        Toggle("Set Goal", isOn: $hasGoal)

                        if hasGoal {
                            HStack {
                                Text("Goal")
                                Spacer()
                                TextField("0", text: $goalValue)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 100)
                                Text(unitText)
                                    .foregroundColor(.secondary)
                            }
                        }
                    } header: {
                        Text("Targets")
                    } footer: {
                        Text(footerText)
                    }
                }

                // App Integration section
                if selectedType == .time || selectedType == .count {
                    Section {
                        // HealthKit for time tasks
                        if selectedType == .time && healthKitManager.isHealthKitAvailable {
                            Toggle("Fitness (HealthKit)", isOn: $useHealthKit)

                            if useHealthKit {
                                Picker("Workout Type", selection: $selectedWorkoutType) {
                                    Text("All Workouts").tag("None")
                                    ForEach(healthKitManager.availableWorkoutTypes, id: \.name) { workout in
                                        Text(workout.name).tag(workout.name)
                                    }
                                }
                            }
                        }

                        // PushFit Pro for count tasks
                        if selectedType == .count {
                            Toggle("PushFit Pro", isOn: $usePushFitPro)
                        }

                    } header: {
                        Text("App Integration")
                    } footer: {
                        if selectedType == .time {
                            Text("Automatically sync workout data from other fitness apps. You'll be asked for permission on first use.")
                        } else {
                            Text("Sync rep counts from PushFit Pro. Make sure to enable data sharing in PushFit Pro settings.")
                        }
                    }
                }

                Section {
                    Text(exampleText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } header: {
                    Text("Example")
                }
            }
            .navigationTitle(title)
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
            .sheet(isPresented: $showingIconPicker) {
                IconPicker(selectedIcon: $selectedIcon)
            }
        }
    }

    private var unitText: String {
        switch selectedType {
        case .boolean:
            return ""
        case .count:
            if showCustomUnit && !customUnit.isEmpty {
                return customUnit
            } else if selectedUnit != "None" && selectedUnit != "Custom" {
                return selectedUnit.lowercased()
            }
            return ""
        case .time:
            return "min"
        }
    }

    private var footerText: String {
        switch selectedType {
        case .boolean:
            return "A day counts as Non-Zero if you mark it as done."
        case .count:
            return "A day counts as Non-Zero if you reach the minimum count."
        case .time:
            return "A day counts as Non-Zero if you reach the minimum time (in minutes). You can manually add time or use the built-in timer."
        }
    }

    private var exampleText: String {
        switch selectedType {
        case .boolean:
            return "Example: 'Meditation' with minimum 1 means any meditation session counts as a Non-Zero day."
        case .count:
            return "Example: 'Pushups' with minimum 5 means doing at least 5 pushups makes it a Non-Zero day. Goal of 20 gives you a target to aim for."
        case .time:
            return "Example: 'Reading' with minimum 10 minutes and goal 30 minutes. You can add time manually (+5m, +15m, +30m buttons) or use the timer for continuous tracking."
        }
    }

    private func save() {
        guard let minimum = Double(minimumValue) else { return }
        let goal = hasGoal ? Double(goalValue) : nil

        // Determine the unit to save
        var unitToSave: String? = nil
        if selectedType == .count {
            if showCustomUnit && !customUnit.isEmpty {
                unitToSave = customUnit
            } else if selectedUnit != "None" && selectedUnit != "Custom" {
                unitToSave = selectedUnit
            }
        }

        // Determine the HealthKit workout type to save
        var workoutTypeToSave: String? = nil
        if selectedType == .time && useHealthKit {
            workoutTypeToSave = selectedWorkoutType != "None" ? selectedWorkoutType : "All"
        }

        // Determine PushFit Pro integration
        let pushFitProToSave = selectedType == .count && usePushFitPro

        onSave(name, selectedType, minimum, goal, unitToSave, workoutTypeToSave, pushFitProToSave, selectedIcon)
        dismiss()
    }
}

#Preview {
    TaskEditorView(mode: .add) { name, type, min, goal, unit, workout, pushFit, icon in
        print("Saved: \(name), \(type), \(min), \(goal ?? 0), unit: \(unit ?? "none"), workout: \(workout ?? "none"), pushFit: \(pushFit), icon: \(icon ?? "none")")
    }
}
