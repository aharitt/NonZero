import SwiftUI
import SwiftData

@main
struct NonZeroApp: App {
    let modelContainer: ModelContainer

    init() {
        // Initialize language manager early so all Text() calls use correct language
        _ = LanguageManager.shared

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
    @State private var contentID = UUID()

    var body: some View {
        Group {
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
        .id(contentID)
        .onAppear {
            if !hasInitialized {
                initializeDataStore()
                hasInitialized = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .appLanguageChanged)) { _ in
            contentID = UUID()
        }
    }

    @ViewBuilder
    private var mainTabView: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label(loc("Today"), systemImage: "calendar")
                }

            TasksListView()
                .tabItem {
                    Label(loc("Tasks"), systemImage: "checklist")
                }

            StatsView()
                .tabItem {
                    Label(loc("Stats"), systemImage: "chart.bar.fill")
                }

            SettingsView()
                .tabItem {
                    Label(loc("Settings"), systemImage: "gear")
                }
        }
        .onAppear {
            // Notify all ViewModels to reload now that DataStore is ready
            NotificationCenter.default.post(name: .refreshBadge, object: nil)
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
