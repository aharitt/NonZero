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
    @AppStorage("appLanguage") private var appLanguage: String = AppLanguage.english.rawValue

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Text(loc("Settings"))
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
                            Text(loc("Welcome Screen"))
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
                            Text(loc("The NonZero Principle"))
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
                            Text(loc("Resilience Index"))
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
                            Text(loc("Show Badge"))
                                .font(.body)
                        }
                    }

                    Toggle(isOn: $settings.playSounds) {
                        HStack(spacing: 12) {
                            Image(systemName: "speaker.wave.2")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            Text(loc("Sounds"))
                                .font(.body)
                        }
                    }

                    HStack(spacing: 12) {
                        Image(systemName: "chart.pie")
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        Text(loc("Day Score Criteria"))
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
                        HealthIntegrationView()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            Text(loc("Health Integration"))
                                .font(.body)
                        }
                    }
                }

                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "globe")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        Picker(loc("Language"), selection: Binding(
                            get: { AppLanguage(rawValue: appLanguage) ?? .english },
                            set: { language in
                                LanguageManager.shared.setLanguage(language)
                            }
                        )) {
                            ForEach(AppLanguage.allCases, id: \.self) { language in
                                Text(language.displayName).tag(language)
                            }
                        }
                    }
                }

                Section {
                    NavigationLink {
                        FeedbackView()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.orange)
                                .frame(width: 24)
                            Text(loc("Send Feedback"))
                                .font(.body)
                        }
                    }
                }

                Section {
                    NavigationLink {
                        ManageDataView()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "externaldrive")
                                .foregroundColor(.indigo)
                                .frame(width: 24)
                            Text(loc("Manage Data"))
                                .font(.body)
                        }
                    }
                }

            }
            }
            .listSectionSpacing(10)
            .background(Color(.systemGroupedBackground))
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

// MARK: - Manage Data View

struct ManageDataView: View {
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
        List {
            Section {
                Button {
                    exportTasks()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        Text(loc("Export Tasks"))
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
                        Text(loc("Import Tasks"))
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
                        Text(loc("Export Backup"))
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
                        Text(loc("Restore Backup"))
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                }
            }

            Section {
                Button {
                    if let context = dataStore.context {
                        SeedData.loadSampleData(in: context)
                        NotificationCenter.default.post(name: .refreshBadge, object: nil)
                        importMessage = loc("Sample data loaded successfully")
                        showingImportAlert = true
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.purple)
                            .frame(width: 24)
                        Text(loc("Load Sample Data"))
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
                        Text(loc("Reset All Records"))
                            .font(.body)
                    }
                }
            }
        }
        .navigationTitle(loc("Manage Data"))
        .navigationBarTitleDisplayMode(.inline)
        .alert(loc("Reset All Records?"), isPresented: $showingResetConfirmation) {
            Button(loc("Cancel"), role: .cancel) {}
            Button(loc("Reset"), role: .destructive) {
                dataStore.deleteAllEntries()
                NotificationCenter.default.post(name: .refreshBadge, object: nil)
            }
        } message: {
            Text(loc("This will permanently delete all your logged entries (streaks, progress, history) but keep your task definitions. This action cannot be undone."))
        }
        .alert(loc("Restore Backup?"), isPresented: $showingBackupRestoreConfirmation) {
            Button(loc("Cancel"), role: .cancel) {
                pendingBackupURL = nil
            }
            Button(loc("Replace All Data"), role: .destructive) {
                if let url = pendingBackupURL {
                    performBackupRestore(url: url)
                    pendingBackupURL = nil
                }
            }
        } message: {
            Text(loc("This will delete all existing tasks and entries, then restore from the backup file. This action cannot be undone."))
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
        .alert(loc("Import Result"), isPresented: $showingImportAlert) {
            Button(loc("OK"), role: .cancel) {}
        } message: {
            Text(importMessage)
        }
    }

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
            let fileURL = tempDir.appendingPathComponent("NonZero_Tasks_\(timestamp).json")
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
                    importMessage = loc("Cannot access file")
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
                    BackupEntry(date: entry.date, value: entry.value, note: entry.note, createdAt: entry.createdAt)
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
            let fileURL = tempDir.appendingPathComponent("NonZero_Backup_\(timestamp).json")
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
            dataStore.deleteAllData()
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
                Text(loc("The rule is simple."))
                    .font(.title2)
                    .fontWeight(.bold)

                Text(loc("Do not let a day become zero."))
                    .font(.title3)
                    .foregroundColor(.green)
                    .fontWeight(.semibold)

                Text(loc("You don't have to be perfect.\nYou don't have to complete everything."))
                    .font(.body)
                    .fontWeight(.medium)

                Text(loc("Just non-zero. \n1 page, 1 push-up, 1 min conversation..."))
                    .font(.body)
                    .fontWeight(.medium)

                Text(loc("You may have a zero-day. \nNo worries. Come back. Start small."))
                    .font(.body)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(loc("The NonZero Principle"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ResilienceIndexView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(loc("Resilience is not about never struggling.\nIt is about responding to struggle by returning."))
                    .font(.body)
                    .fontWeight(.bold)

                Text(loc("In psychology, resilience is often described as the ability to bounce back from setbacks and adapt after difficulty. The Resilience Index reflects this idea in behavioral form. It measures how consistently you resume your efforts after missing days."))
                    .font(.body)

                Text(loc("When you miss a day and return, that is resilience. When you miss several days and still return, that is resilience too — because resilience is not perfection, but persistence."))
                    .font(.body)

                VStack(alignment: .leading, spacing: 8) {
                    Text(loc("The index considers two patterns:"))
                        .font(.body)
                        .fontWeight(.medium)

                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                        Text(loc("How reliably you return"))
                    }
                    .font(.body)

                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                        Text(loc("How quickly you resume"))
                    }
                    .font(.body)
                }

                Text(loc("Recent comebacks carry more weight than distant ones, because resilience is something practiced in the present. Long gaps do not erase your resilience. They simply make your return more meaningful."))
                    .font(.body)

                Text(loc("This index is not a clinical assessment or a personality score. It is a reflection of your pattern of persistence over time. In that sense, it is closely related to what researchers call \"grit\" — the capacity to continue showing up for what matters."))
                    .font(.body)

                Text(loc("As long as you refuse to drop and keep returning, your resilience remains active."))
                    .font(.body)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(loc("Resilience Index"))
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
                Text(loc("Your Feedback"))
            } footer: {
                Text(loc("Tell us what you like, what could be better, or report a bug."))
            }

            Section {
                Button {
                    sendFeedback()
                } label: {
                    HStack {
                        Spacer()
                        Label(loc("Send via Email"), systemImage: "paperplane.fill")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
                .disabled(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            Section {
                HStack {
                    Text(loc("Email"))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(feedbackEmail)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }

                HStack {
                    Text(loc("App Version"))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(appVersion)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }

                HStack {
                    Text(loc("Device"))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(deviceInfo)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            } header: {
                Text(loc("Info"))
            }
        }
        .navigationTitle(loc("Send Feedback"))
        .navigationBarTitleDisplayMode(.inline)
        .alert(loc("Cannot Send Email"), isPresented: $showingMailError) {
            Button(loc("Copy Email Address")) {
                UIPasteboard.general.string = feedbackEmail
            }
            Button(loc("OK"), role: .cancel) {}
        } message: {
            Text(loc("Your device is not configured to send email. You can copy the email address and send feedback manually."))
        }
        .alert(loc("Thank You!"), isPresented: $showingSentConfirmation) {
            Button(loc("OK"), role: .cancel) {}
        } message: {
            Text(loc("Your feedback email has been prepared. Please send it from your email app."))
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

struct HealthIntegrationView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(loc("NonZero uses Apple HealthKit to help you track fitness-related tasks automatically."))
                    .font(.body)

                VStack(alignment: .leading, spacing: 12) {
                    Text(loc("What We Access"))
                        .font(.headline)

                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "figure.run")
                            .foregroundColor(.green)
                            .frame(width: 24)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(loc("Workout Data"))
                                .font(.body)
                                .fontWeight(.medium)
                            Text(loc("Duration and type of workouts recorded in the Health app or other fitness apps."))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(loc("Exercise Minutes"))
                                .font(.body)
                                .fontWeight(.medium)
                            Text(loc("Daily exercise minutes from your Activity rings to automatically log time-based tasks."))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text(loc("How It Works"))
                        .font(.headline)

                    Text(loc("When you create a time-based task and enable HealthKit integration, NonZero reads your workout data to automatically update your daily progress. This helps you track fitness habits without manual entry."))
                        .font(.body)

                    Text(loc("You can enable or disable HealthKit for each task individually in the task editor."))
                        .font(.body)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text(loc("Your Privacy"))
                        .font(.headline)

                    Text(loc("NonZero only reads health data — it never writes to or modifies your Health records. All data stays on your device and is never sent to any server."))
                        .font(.body)

                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label(loc("Manage Health Permissions"), systemImage: "gear")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(loc("Health Integration"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
}
