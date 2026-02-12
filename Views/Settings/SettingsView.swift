import SwiftUI

struct SettingsView: View {
    @State private var settings = SettingsManager.shared

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
                    HStack {
                        Text("Version")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SettingsView()
}
