import SwiftUI

struct SettingsView: View {
    @State private var settings = SettingsManager.shared
    @State private var showingResetConfirmation = false

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
        }
    }

    private func resetAllRecords() {
        dataStore.deleteAllEntries()

        // Refresh badge after resetting records
        NotificationCenter.default.post(name: .refreshBadge, object: nil)
    }
}

#Preview {
    SettingsView()
}
