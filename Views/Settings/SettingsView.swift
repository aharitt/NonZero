import SwiftUI
import UniformTypeIdentifiers

enum ImportMode {
    case tasks
    case fullBackup
}

struct ShareableFile: Identifiable {
    let id = UUID()
    let url: URL
}

struct SettingsView: View {
    @State private var settings = SettingsManager.shared
    @State private var showingResetConfirmation = false
    @State private var shareFile: ShareableFile?
    @State private var showingImportPicker = false
    @State private var importMode: ImportMode = .tasks
    @State private var showingImportAlert = false
    @State private var importMessage = ""
    @State private var showingBackupRestoreConfirmation = false
    @State private var pendingBackupURL: URL?

    private let dataStore = DataStore.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Text("Settings")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 4)

                List {
                Section {
                    Button {
                        UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
                        NotificationCenter.default.post(name: .refreshBadge, object: nil)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "hand.wave.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            Text("Welcome Screen")
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                    }

                    NavigationLink {
                        NonZeroPrincipleView()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "sparkles")
                                .foregroundColor(.green)
                                .frame(width: 24)
                            Text("The NonZero Principle")
                                .font(.body)
                        }
                    }

                    NavigationLink {
                        ResilienceIndexView()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.uturn.up.circle.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            Text("Resilience Index")
                                .font(.body)
                        }
                    }
                }

                Section {
                    Toggle(isOn: $settings.showBadge) {
                        HStack(spacing: 12) {
                            Image(systemName: "app.badge")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            Text("Show Badge")
                                .font(.body)
                        }
                    }

                    Toggle(isOn: $settings.playSounds) {
                        HStack(spacing: 12) {
                            Image(systemName: "speaker.wave.2")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            Text("Sounds")
                                .font(.body)
                        }
                    }

                    HStack(spacing: 12) {
                        Image(systemName: "chart.pie")
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        Text("Day Score Criteria")
                            .font(.body)
                        Spacer()
                        Text("\(settings.dayScoreCriteria)%")
                            .font(.body)
                            .fontDesign(.rounded)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }

                    Slider(
                        value: Binding(
                            get: { Double(settings.dayScoreCriteria) },
                            set: { settings.dayScoreCriteria = Int($0) }
                        ),
                        in: 0...100,
                        step: 5
                    )
                    .tint(.orange)
                }

                Section {
                    NavigationLink {
                        FeedbackView()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.orange)
                                .frame(width: 24)
                            Text("Send Feedback")
                                .font(.body)
                        }
                    }
                }

                Section {
                    Button {
                        exportTasks()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            Text("Export Tasks")
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                    }

                    Button {
                        importMode = .tasks
                        showingImportPicker = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "square.and.arrow.down")
                                .foregroundColor(.green)
                                .frame(width: 24)
                            Text("Import Tasks")
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                    }

                    Button {
                        exportFullBackup()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.up.doc")
                                .foregroundColor(.indigo)
                                .frame(width: 24)
                            Text("Export Backup")
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                    }

                    Button {
                        importMode = .fullBackup
                        showingImportPicker = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.down.doc")
                                .foregroundColor(.indigo)
                                .frame(width: 24)
                            Text("Restore Backup")
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                    }

                    Button(role: .destructive) {
                        showingResetConfirmation = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            Text("Reset All Records")
                                .font(.body)
                        }
                    }
                }

            }
            }
            .background(Color(.systemGroupedBackground))
            .toolbar(.hidden, for: .navigationBar)
            .alert("Reset All Records?", isPresented: $showingResetConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    resetAllRecords()
                }
            } message: {
                Text("This will permanently delete all your logged entries (streaks, progress, history) but keep your task definitions. This action cannot be undone.")
            }
            .alert("Restore Backup?", isPresented: $showingBackupRestoreConfirmation) {
                Button("Cancel", role: .cancel) {
                    pendingBackupURL = nil
                }
                Button("Replace All Data", role: .destructive) {
                    if let url = pendingBackupURL {
                        performBackupRestore(url: url)
                        pendingBackupURL = nil
                    }
                }
            } message: {
                Text("This will delete all existing tasks and entries, then restore from the backup file. This action cannot be undone.")
            }
            .sheet(item: $shareFile) { file in
                ShareSheet(items: [file.url])
            }
            .fileImporter(
                isPresented: $showingImportPicker,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                switch importMode {
                case .tasks:
                    handleImport(result: result)
                case .fullBackup:
                    handleBackupImport(result: result)
                }
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

    // MARK: - Task Export/Import

    private func exportTasks() {
        let tasks = dataStore.fetchTasks(includeArchived: true)

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

            let tempDir = FileManager.default.temporaryDirectory
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd_HHmmss"
            let timestamp = dateFormatter.string(from: Date())
            let fileName = "NonZero_Tasks_\(timestamp).json"
            let fileURL = tempDir.appendingPathComponent(fileName)

            try jsonData.write(to: fileURL)

            shareFile = ShareableFile(url: fileURL)
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
                guard url.startAccessingSecurityScopedResource() else {
                    importMessage = "Cannot access file"
                    showingImportAlert = true
                    return
                }
                defer { url.stopAccessingSecurityScopedResource() }

                let jsonData = try Data(contentsOf: url)
                let tasks = try JSONDecoder().decode([ExportableTask].self, from: jsonData)

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

    // MARK: - Full Backup Export/Import

    private func exportFullBackup() {
        let tasks = dataStore.fetchTasks(includeArchived: true)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let backupTasks = tasks.map { task in
            BackupTask(
                name: task.name,
                taskType: task.taskType.rawValue,
                minimumValue: task.minimumValue,
                goalValue: task.goalValue,
                unit: task.unit,
                healthKitWorkoutType: task.healthKitWorkoutType,
                pushFitProEnabled: task.pushFitProEnabled,
                icon: task.icon,
                createdAt: task.createdAt,
                sortOrder: task.sortOrder,
                isArchived: task.isArchived,
                entries: task.entries.map { entry in
                    BackupEntry(
                        date: entry.date,
                        value: entry.value,
                        note: entry.note,
                        createdAt: entry.createdAt
                    )
                }
            )
        }

        let backup = FullBackup(
            version: 2,
            exportDate: Date(),
            tasks: backupTasks,
            settings: BackupSettings(dayScoreCriteria: settings.dayScoreCriteria)
        )

        do {
            let jsonData = try encoder.encode(backup)

            let tempDir = FileManager.default.temporaryDirectory
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd_HHmmss"
            let timestamp = dateFormatter.string(from: Date())
            let fileName = "NonZero_Backup_\(timestamp).json"
            let fileURL = tempDir.appendingPathComponent(fileName)

            try jsonData.write(to: fileURL)

            shareFile = ShareableFile(url: fileURL)
        } catch {
            importMessage = "Backup export failed: \(error.localizedDescription)"
            showingImportAlert = true
        }
    }

    private func handleBackupImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }

            guard url.startAccessingSecurityScopedResource() else {
                importMessage = "Cannot access file"
                showingImportAlert = true
                return
            }

            // Store URL for confirmation, keep security scope open
            pendingBackupURL = url
            showingBackupRestoreConfirmation = true

        case .failure(let error):
            importMessage = "Backup import failed: \(error.localizedDescription)"
            showingImportAlert = true
        }
    }

    private func performBackupRestore(url: URL) {
        defer { url.stopAccessingSecurityScopedResource() }

        do {
            let jsonData = try Data(contentsOf: url)

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let backup = try decoder.decode(FullBackup.self, from: jsonData)

            // Delete all existing data
            dataStore.deleteAllData()

            // Restore tasks and entries
            var restoredTasks = 0
            var restoredEntries = 0

            for backupTask in backup.tasks {
                guard let taskType = TaskType(rawValue: backupTask.taskType) else { continue }

                let task = Task(
                    name: backupTask.name,
                    taskType: taskType,
                    minimumValue: backupTask.minimumValue,
                    goalValue: backupTask.goalValue,
                    unit: backupTask.unit,
                    healthKitWorkoutType: backupTask.healthKitWorkoutType,
                    pushFitProEnabled: backupTask.pushFitProEnabled,
                    icon: backupTask.icon,
                    createdAt: backupTask.createdAt,
                    isArchived: backupTask.isArchived,
                    sortOrder: backupTask.sortOrder
                )

                dataStore.addTask(task)
                restoredTasks += 1

                for backupEntry in backupTask.entries {
                    let entry = Entry(
                        task: task,
                        date: backupEntry.date,
                        value: backupEntry.value,
                        note: backupEntry.note,
                        createdAt: backupEntry.createdAt
                    )
                    dataStore.addEntry(entry)
                    restoredEntries += 1
                }
            }

            // Restore settings
            if let backupSettings = backup.settings {
                settings.dayScoreCriteria = backupSettings.dayScoreCriteria
            }

            NotificationCenter.default.post(name: .refreshBadge, object: nil)

            importMessage = "Restored \(restoredTasks) task(s) and \(restoredEntries) entry(ies)"
            showingImportAlert = true
        } catch {
            importMessage = "Backup restore failed: \(error.localizedDescription)"
            showingImportAlert = true
        }
    }
}

// MARK: - Export/Import Models

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

struct FullBackup: Codable {
    let version: Int
    let exportDate: Date
    let tasks: [BackupTask]
    let settings: BackupSettings?
}

struct BackupTask: Codable {
    let name: String
    let taskType: String
    let minimumValue: Double
    let goalValue: Double?
    let unit: String?
    let healthKitWorkoutType: String?
    let pushFitProEnabled: Bool
    let icon: String?
    let createdAt: Date
    let sortOrder: Int
    let isArchived: Bool
    let entries: [BackupEntry]
}

struct BackupEntry: Codable {
    let date: Date
    let value: Double
    let note: String?
    let createdAt: Date
}

struct BackupSettings: Codable {
    let dayScoreCriteria: Int
}

// Share sheet for iOS
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct NonZeroPrincipleView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("The rule is simple.")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Do not let a day become zero.")
                    .font(.title3)
                    .foregroundColor(.green)
                    .fontWeight(.semibold)

                Text("You don't have to be perfect.\nYou don't have to complete everything.")
                    .font(.body)
                    .fontWeight(.medium)

                Text("Just non-zero. \n1 page, 1 push-up, 1 min conversation...")
                    .font(.body)
                    .fontWeight(.medium)

                Text("You may have a zero-day. \nNo worries. Come back. Start small.")
                    .font(.body)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("The NonZero Principle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ResilienceIndexView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Resilience is not about never struggling.\nIt is about responding to struggle by returning.")
                    .font(.body)
                    .fontWeight(.bold)

                Text("In psychology, resilience is often described as the ability to bounce back from setbacks and adapt after difficulty. The Resilience Index reflects this idea in behavioral form. It measures how consistently you resume your efforts after missing days.")
                    .font(.body)

                Text("When you miss a day and return, that is resilience. When you miss several days and still return, that is resilience too — because resilience is not perfection, but persistence.")
                    .font(.body)

                VStack(alignment: .leading, spacing: 8) {
                    Text("The index considers two patterns:")
                        .font(.body)
                        .fontWeight(.medium)

                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                        Text("How reliably you return")
                    }
                    .font(.body)

                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                        Text("How quickly you resume")
                    }
                    .font(.body)
                }

                Text("Recent comebacks carry more weight than distant ones, because resilience is something practiced in the present. Long gaps do not erase your resilience. They simply make your return more meaningful.")
                    .font(.body)

                Text("This index is not a clinical assessment or a personality score. It is a reflection of your pattern of persistence over time. In that sense, it is closely related to what researchers call \"grit\" — the capacity to continue showing up for what matters.")
                    .font(.body)

                Text("As long as you refuse to drop and keep returning, your resilience remains active.")
                    .font(.body)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Resilience Index")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FeedbackView: View {
    @State private var feedbackText = ""
    @State private var showingMailError = false
    @State private var showingSentConfirmation = false

    private let feedbackEmail = "nonzeroprinciple@gmail.com"

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    private var deviceInfo: String {
        let device = UIDevice.current
        return "\(device.model), iOS \(device.systemVersion)"
    }

    var body: some View {
        Form {
            Section {
                TextEditor(text: $feedbackText)
                    .frame(minHeight: 150)
            } header: {
                Text("Your Feedback")
            } footer: {
                Text("Tell us what you like, what could be better, or report a bug.")
            }

            Section {
                Button {
                    sendFeedback()
                } label: {
                    HStack {
                        Spacer()
                        Label("Send via Email", systemImage: "paperplane.fill")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
                .disabled(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            Section {
                HStack {
                    Text("Email")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(feedbackEmail)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }

                HStack {
                    Text("App Version")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(appVersion)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }

                HStack {
                    Text("Device")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(deviceInfo)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            } header: {
                Text("Info")
            }
        }
        .navigationTitle("Send Feedback")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Cannot Send Email", isPresented: $showingMailError) {
            Button("Copy Email Address") {
                UIPasteboard.general.string = feedbackEmail
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your device is not configured to send email. You can copy the email address and send feedback manually to \(feedbackEmail).")
        }
        .alert("Thank You!", isPresented: $showingSentConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your feedback email has been prepared. Please send it from your email app.")
        }
    }

    private func sendFeedback() {
        let subject = "NonZero Feedback (v\(appVersion))"
        let body = "\(feedbackText)\n\n---\nApp: NonZero v\(appVersion)\nDevice: \(deviceInfo)"

        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        guard let url = URL(string: "mailto:\(feedbackEmail)?subject=\(encodedSubject)&body=\(encodedBody)") else {
            showingMailError = true
            return
        }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            showingSentConfirmation = true
        } else {
            showingMailError = true
        }
    }
}

#Preview {
    SettingsView()
}
