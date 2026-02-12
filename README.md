# NonZero - iOS Habit Tracker

A simple, powerful iOS app to help you maintain a "Non-Zero Day" lifestyle. Track tasks, build streaks, and visualize your progress.

## Features (MVP - Phase 1)

✅ **Task Management**
- Create/edit/delete tasks with three types:
  - **Boolean**: Yes/No (e.g., "Meditated today")
  - **Count**: Numeric tracking (e.g., "Pushups")
  - **Time**: Duration tracking (e.g., "Reading minutes")
- Set minimum thresholds and optional goals
- Track streaks automatically

✅ **Daily Check-in**
- Quick-action buttons for rapid logging
- Smart suggestions based on yesterday's performance
- "Yesterday you did 3 pushups. Want to do 4 today?"
- Optional notes per entry

✅ **Stats & Visualization**
- Current streak and longest streak
- 7-day completion rate
- Week-by-week bar charts
- Calendar heatmap (30/60 days)
- Detailed per-task analytics

## Tech Stack

- **SwiftUI** - Modern declarative UI
- **SwiftData** - iOS 17+ local persistence
- **MVVM Architecture** - Clean separation of concerns
- **Charts Framework** - Native iOS charting
- **iOS 17+** - Target platform

## Project Structure

```
NonZero/
├── App/
│   └── NonZeroApp.swift           # Main app entry point & TabView
├── Models/
│   ├── Task.swift                 # Task model with types & logic
│   └── Entry.swift                # Daily entry model
├── Data/
│   ├── DataStore.swift            # SwiftData wrapper & CRUD operations
│   └── SeedData.swift             # Optional sample data generator
├── ViewModels/
│   ├── TasksViewModel.swift       # Task management logic
│   ├── TodayViewModel.swift       # Daily logging logic with suggestions
│   └── StatsViewModel.swift       # Statistics & analytics logic
├── Views/
│   ├── Tasks/
│   │   ├── TasksListView.swift    # Task list with swipe actions
│   │   └── TaskEditorView.swift   # Create/edit task modal
│   ├── Today/
│   │   ├── TodayView.swift        # Daily check-in screen
│   │   └── EntryEditorSheet.swift # Detailed entry editor
│   ├── Stats/
│   │   ├── StatsView.swift        # Stats overview with charts
│   │   └── TaskDetailView.swift   # Per-task detailed analytics
│   └── Components/
│       ├── NonZeroBadge.swift     # Reusable badges & icons
│       └── CalendarHeatmapView.swift # GitHub-style heatmap
└── Utilities/
    ├── DateHelpers.swift          # Date manipulation extensions
    └── Formatting.swift           # Display formatters

```

## Getting Started

### 1. Create New Xcode Project

1. Open Xcode
2. **File → New → Project**
3. Choose **iOS → App**
4. Set:
   - Product Name: `NonZero`
   - Interface: `SwiftUI`
   - Storage: `None` (we're using SwiftData manually)
   - Language: `Swift`
   - Minimum Deployment: `iOS 17.0`

### 2. Add the Code

1. **Delete** the default `ContentView.swift` file
2. **Copy** all files from the `NonZero/` folder into your Xcode project
3. **Maintain the folder structure** in Xcode (create groups matching the folders)

### 3. Run the App

1. Select a simulator (iPhone 15 Pro recommended)
2. Press **Cmd+R** to build and run
3. The app will launch with an empty state

### 4. Optional: Add Sample Data

Uncomment this line in [NonZeroApp.swift](NonZero/App/NonZeroApp.swift):

```swift
// SeedData.createSampleData(in: modelContext)
```

This will populate the app with sample tasks and entries for testing.

## How It Works

### Data Model

**Task**
- Defines what you're tracking (name, type, minimum, goal)
- Calculates streaks automatically
- Links to entries via SwiftData relationship

**Entry**
- One per task per day
- Stores value (Bool/Int/Double) and optional note
- Automatically checks if it meets the "Non-Zero" threshold

### Core Logic

A day is **Non-Zero** if:
- Any task's entry value ≥ its minimum threshold

Example:
- Task: "Pushups", minimum: 5
- Entry: 7 pushups → ✅ Non-Zero
- Entry: 3 pushups → ❌ Zero (below minimum)

### The "Magical" Feature

**Smart Suggestions** (already implemented!)
- Looks at yesterday's performance
- Suggests incremental improvement
- "Yesterday: 10 pushups. Try 11 today?"
- One-tap acceptance via quick actions

## Usage Guide

### Creating a Task

1. Go to **Tasks** tab
2. Tap **+ button**
3. Enter:
   - Name (e.g., "Morning Pushups")
   - Type (Boolean/Count/Time)
   - Minimum (threshold for Non-Zero)
   - Goal (optional target)

### Logging Daily Progress

**Quick Actions** (Today tab):
- **Boolean**: Single toggle button
- **Count**: +1, +5, +10 buttons
- **Time**: +5m, +15m, +30m buttons

**Detailed Entry**:
- Tap pencil icon
- Enter exact value
- Add optional note
- Save

### Viewing Stats

1. **Stats** tab shows overview
2. Select task from segmented picker
3. View:
   - Current & best streak
   - 7-day completion rate
   - Weekly bar chart
   - 30-day heatmap
4. Tap "View Detailed Stats" for full history

## Customization

### Change Colors

Edit [NonZeroBadge.swift](NonZero/Views/Components/NonZeroBadge.swift):
```swift
.fill(isNonZero ? Color.green : Color.gray.opacity(0.3))
```

### Adjust Quick Action Values

Edit [TodayView.swift](NonZero/Views/Today/TodayView.swift):
```swift
ForEach([1.0, 5.0, 10.0], id: \.self) // Change these values
```

### Change Heatmap Days

Edit [CalendarHeatmapView.swift](NonZero/Views/Components/CalendarHeatmapView.swift):
```swift
init(task: Task, days: Int = 30) // Change default days
```

## Next Steps (Phase 2 & 3)

### Phase 2 - Enhanced Analytics
- [ ] 30/60/90-day views
- [ ] Export data (CSV/JSON)
- [ ] Better time-based task UI (hour picker)

### Phase 3 - Engagement
- [ ] Local notifications/reminders
- [ ] Task templates ("Workout", "Reading", etc.)
- [ ] iCloud sync via CloudKit
- [ ] Widgets (iOS 17 Interactive Widgets)

## Architecture Highlights

### Why MVVM?
- **Models**: Pure data (Task, Entry)
- **Views**: SwiftUI declarative UI
- **ViewModels**: Business logic, observable state
- Clean testing boundaries

### Why SwiftData?
- Modern (iOS 17+)
- Type-safe Swift macros
- Automatic change tracking
- Simpler than Core Data

### Why Local-First?
- Works offline always
- Fast & responsive
- No backend costs
- Privacy-focused
- Easy to add iCloud sync later

## Performance Notes

- SwiftData lazy-loads relationships
- Queries use predicate macros (compile-time safety)
- Charts automatically optimize rendering
- Heatmap limits to visible range

## Troubleshooting

### Build Errors
- Ensure iOS 17.0+ deployment target
- Check all files are added to target
- Clean build folder (Cmd+Shift+K)

### Data Not Persisting
- Check simulator isn't being reset
- Verify modelContainer is in WindowGroup
- DataStore initialization must happen onAppear

### Preview Crashes
- Some previews use in-memory storage
- Restart Xcode if Canvas misbehaves
- Some previews may not work in earlier iOS versions

## File References

Key files to understand the app:

- [NonZeroApp.swift](NonZero/App/NonZeroApp.swift) - Start here
- [Task.swift](NonZero/Models/Task.swift) - Core model logic
- [TodayViewModel.swift](NonZero/ViewModels/TodayViewModel.swift) - Smart suggestions
- [TodayView.swift](NonZero/Views/Today/TodayView.swift) - Main user interface

## License

Feel free to use this code for personal or commercial projects!

---

Built with ❤️ for the Non-Zero Day philosophy
