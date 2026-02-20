import SwiftUI
import SwiftData

@main
struct NonZeroApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            // Use migration plan for schema versioning
            let modelConfiguration = ModelConfiguration(isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(
                for: Task.self, Entry.self,
                migrationPlan: TaskMigrationPlan.self,
                configurations: modelConfiguration
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var hasInitialized = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        if !hasSeenOnboarding {
            OnboardingView {
                withAnimation {
                    hasSeenOnboarding = true
                }
            }
        } else {
            mainTabView
        }
    }

    @ViewBuilder
    private var mainTabView: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "calendar")
                }

            TasksListView()
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
                }

            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .onAppear {
            if !hasInitialized {
                initializeDataStore()
                // Optionally seed data for testing
                // SeedData.createSampleData(in: modelContext)
                hasInitialized = true

                // Notify all ViewModels to reload now that DataStore is ready
                // (child onAppear fires before parent, so initial loads got nil context)
                NotificationCenter.default.post(name: .refreshBadge, object: nil)
            }
        }
        .task {
            // Request badge authorization
            await AppBadgeManager.shared.requestAuthorization()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                // Refresh badge count when app becomes active
                // This ensures the badge updates if the day changed
                NotificationCenter.default.post(name: .refreshBadge, object: nil)
            }
        }
    }

    @MainActor
    private func initializeDataStore() {
        DataStore.shared.context = modelContext
        DataStore.shared.container = modelContext.container
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Task.self, Entry.self], inMemory: true)
}
