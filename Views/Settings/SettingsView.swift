import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @State private var settings = SettingsManager.shared
    @State private var showingResetConfirmation = false
    @State private var showingExportSheet = false
    @State private var showingImportPicker = false
    @State private var exportFileURL: URL?
    @State private var showingImportAlert = false
    @State private var importMessage = ""

    private let dataStore = DataStore.shared

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        return "\(version).\(build)"
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle(isOn: $settings.showBadge) {
                        HStack(spacing: 12) {
                            Image(systemName: "app.badge")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Show Badge")
                                    .font(.body)
                                Text("Display count of zero tasks on app icon")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Toggle(isOn: $settings.playSounds) {
                        HStack(spacing: 12) {
                            Image(systemName: "speaker.wave.2")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Sounds")
                                    .font(.body)
                                Text("Play sound when marking tasks")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("General")
                }

                Section {
                    Button {
                        exportTasks()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Export Tasks")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                Text("Save task definitions to file")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Button {
                        showingImportPicker = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "square.and.arrow.down")
                                .foregroundColor(.green)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Import Tasks")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                Text("Load task definitions from file")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Button(role: .destructive) {
                        showingResetConfirmation = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Reset All Records")
                                    .font(.body)
                                Text("Delete all entries but keep task definitions")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Data")
                }

                Section {
                    HStack {
                        Text("Version")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Reset All Records?", isPresented: $showingResetConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    resetAllRecords()
                }
            } message: {
                Text("This will permanently delete all your logged entries (streaks, progress, history) but keep your task definitions. This action cannot be undone.")
            }
            .sheet(isPresented: $showingExportSheet) {
                if let url = exportFileURL {
                    ShareSheet(items: [url])
                }
            }
            .fileImporter(
                isPresented: $showingImportPicker,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                handleImport(result: result)
            }
            .alert("Import Result", isPresented: $showingImportAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(importMessage)
            }
        }
    }

    private func resetAllRecords() {
        dataStore.deleteAllEntries()

        // Refresh badge after resetting records
        NotificationCenter.default.post(name: .refreshBadge, object: nil)
    }

    private func exportTasks() {
        let tasks = dataStore.fetchTasks(includeArchived: true)

        // Convert tasks to exportable format
        let exportData = tasks.map { task in
            ExportableTask(
                name: task.name,
                taskType: task.taskType.rawValue,
                minimumValue: task.minimumValue,
                goalValue: task.goalValue,
                unit: task.unit,
                healthKitWorkoutType: task.healthKitWorkoutType,
                pushFitProEnabled: task.pushFitProEnabled,
                icon: task.icon,
                createdAt: task.createdAt
            )
        }

        do {
            let jsonData = try JSONEncoder().encode(exportData)

            // Create file URL in temporary directory
            let tempDir = FileManager.default.temporaryDirectory
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd_HHmmss"
            let timestamp = dateFormatter.string(from: Date())
            let fileName = "NonZero_Tasks_\(timestamp).json"
            let fileURL = tempDir.appendingPathComponent(fileName)

            // Write to file
            try jsonData.write(to: fileURL)

            // Show share sheet
            exportFileURL = fileURL
            showingExportSheet = true
        } catch {
            importMessage = "Export failed: \(error.localizedDescription)"
            showingImportAlert = true
        }
    }

    private func handleImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }

            do {
                // Read file
                guard url.startAccessingSecurityScopedResource() else {
                    importMessage = "Cannot access file"
                    showingImportAlert = true
                    return
                }
                defer { url.stopAccessingSecurityScopedResource() }

                let jsonData = try Data(contentsOf: url)
                let tasks = try JSONDecoder().decode([ExportableTask].self, from: jsonData)

                // Import tasks
                for taskData in tasks {
                    guard let taskType = TaskType(rawValue: taskData.taskType) else { continue }

                    let task = Task(
                        name: taskData.name,
                        taskType: taskType,
                        minimumValue: taskData.minimumValue,
                        goalValue: taskData.goalValue,
                        unit: taskData.unit,
                        healthKitWorkoutType: taskData.healthKitWorkoutType,
                        pushFitProEnabled: taskData.pushFitProEnabled,
                        icon: taskData.icon,
                        createdAt: taskData.createdAt
                    )

                    dataStore.addTask(task)
                }

                importMessage = "Successfully imported \(tasks.count) task(s)"
                showingImportAlert = true
            } catch {
                importMessage = "Import failed: \(error.localizedDescription)"
                showingImportAlert = true
            }

        case .failure(let error):
            importMessage = "Import failed: \(error.localizedDescription)"
            showingImportAlert = true
        }
    }
}

// Exportable task structure
struct ExportableTask: Codable {
    let name: String
    let taskType: String
    let minimumValue: Double
    let goalValue: Double?
    let unit: String?
    let healthKitWorkoutType: String?
    let pushFitProEnabled: Bool
    let icon: String?
    let createdAt: Date
}

// Share sheet for iOS
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SettingsView()
}
