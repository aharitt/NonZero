# NonZero App - Functional Specification

**Version:** 1.4
**Last Updated:** February 18, 2026
**Platform:** iOS 17.0+
**Technology Stack:** SwiftUI, SwiftData, HealthKit, ActivityKit

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Product Overview](#product-overview)
3. [Core Concepts](#core-concepts)
4. [User Interface](#user-interface)
5. [Features](#features)
6. [Task Types](#task-types)
7. [Data Model](#data-model)
8. [Third-Party Integrations](#third-party-integrations)
9. [Technical Architecture](#technical-architecture)
10. [Future Enhancements](#future-enhancements)

---

## 1. Executive Summary

NonZero is an iOS habit tracking application designed around the "Non-Zero Days" philosophy - the principle that doing any amount of progress, no matter how small, creates momentum and builds lasting habits. The app helps users define trackable tasks, log daily progress, and visualize their consistency through streaks and analytics.

### Key Value Propositions

- **Flexible Tracking**: Support for Yes/No tasks, countable activities, and time-based tracking (manual + timer)
- **Day Score System**: Configurable threshold for what percentage of tasks constitutes a Non-Zero Day
- **Smart Suggestions**: Context-aware, task-type-specific recommendations based on previous performance
- **Visual Feedback**: Streak tracking, calendar heatmaps, and dynamic app icon for instant motivation
- **App Integration**: Seamless sync with HealthKit (Fitness app Exercise Ring + workouts) and PushFit Pro
- **Live Activities**: Running timer displayed on lock screen and Dynamic Island with task name
- **Data Portability**: Export/import task definitions, plus full backup and restore of all data
- **Onboarding**: First-launch welcome screen explaining the Non-Zero philosophy
- **Offline-First**: Full functionality without internet connection

---

## 2. Product Overview

### 2.1 Purpose

NonZero helps users:
- Build sustainable habits through daily tracking
- Maintain "Non-Zero Days" by completing a configurable percentage of daily targets
- Visualize progress through streaks and analytics
- Stay motivated with smart suggestions and visual feedback

### 2.2 Target Users

- Individuals seeking to build better habits
- People following the "Non-Zero Days" philosophy
- Fitness enthusiasts tracking workouts and reps
- Anyone wanting simple, flexible habit tracking

### 2.3 Core Philosophy

A "Non-Zero Day" is achieved when the user completes enough tasks to meet their **Day Score** threshold. By default, completing at least 10% of tasks qualifies as a Non-Zero Day, but this is configurable (0-100% in 5% increments). The app emphasizes **consistency over perfection** - even small progress counts.

At the individual task level, a task is "Non-Zero" when the logged value meets or exceeds the task's minimum value.

---

## 3. Core Concepts

### 3.1 Tasks

A **Task** represents a trackable habit or activity with the following attributes:

- **Name**: User-defined label (e.g., "Reading", "Pushups")
- **Type**: Boolean, Count, or Time (includes both manual duration entry and timer)
- **Minimum Value**: The threshold that qualifies as a Non-Zero day for this task
- **Goal Value** (Optional): Target to aim for beyond the minimum
- **Unit** (Optional): Measurement unit for count tasks (e.g., pages, cups, steps)
- **Icon** (Optional): SF Symbol for visual identification
- **Integrations**: HealthKit workout type / Exercise Ring or PushFit Pro connection

### 3.2 Entries

An **Entry** records daily progress for a task:

- **Date**: The day this entry belongs to
- **Value**: The recorded amount (1 for boolean, number for count/time)
- **Note** (Optional): User comments about the entry
- **Non-Zero Status**: Automatically calculated based on minimum value

### 3.3 Streaks

- **Current Streak**: Consecutive days with Non-Zero entries (ending today)
- **Longest Streak**: Historical best streak for motivation

### 3.4 Day Score

The **Day Score** is an aggregate measure of daily progress across all tasks:

- Calculated as: `(completed tasks / total tasks) * 100`
- A task is "completed" when its entry value meets or exceeds its minimum
- The **Day Score Criteria** (default 10%, configurable 0-100% in 5% steps) determines the threshold for a global Non-Zero Day
- When Day Score >= criteria, the Today tab header shows "Today is Non-Zero" in green
- Day Score has its own streak, comeback, and resilience statistics tracked over time

---

## 4. User Interface

The app consists of four main tabs:

### 4.1 Today Tab

**Purpose**: Daily task logging and quick entry creation

**Features**:
- Dynamic header: "Today is Non-Zero" (green) when Day Score criteria is met, or "Make Today Non-Zero" otherwise
- Adaptive pagination based on screen height (cards resize to fit device)
- List of all active tasks with task type icons
- Quick action buttons per task type:
  - Boolean: "Done" capsule button (green)
  - Count: +1, +5, +10 capsule buttons (blue)
  - Time: +5m, +15m, +30m capsule buttons (blue) + Start timer button (green play icon)
  - Time (timer running): Elapsed time display + Stop button (red)
- Edit button (pencil icon) on each card for detailed entry editing
- Smart suggestions displayed as hint text below task name
- Visual indicators for completed tasks (green checkmark + green border)
- Value display for all types when > 0 (even below minimum)
- HealthKit sync button (heart icon) in the title row
- Pull-to-refresh for HealthKit sync
- App badge showing incomplete tasks count
- Page navigation arrows when tasks exceed one page

**User Flow**:
1. User opens app to Today tab
2. Sees list of tasks with current day's status
3. Taps quick action to log progress
4. Smart suggestion appears if applicable
5. Badge and dynamic app icon update in real-time

### 4.2 Tasks Tab

**Purpose**: Task management and organization

**Features**:
- Adaptive paginated task list (based on screen height, starting at ~8 per page)
- Long-press to reveal Edit/Delete buttons
- Reorder tasks functionality
- Add new task button
- Streak badge display per task
- Task type icons

**User Flow - Creating a Task**:
1. Tap "+" button
2. Enter task name
3. Select task type (Boolean/Count/Time)
4. Choose icon (optional)
5. Set unit (for count tasks)
6. Define minimum and optional goal
7. Enable integrations (HealthKit/PushFit Pro)
8. Review example
9. Save task

**User Flow - Managing Tasks**:
1. Long-press task card
2. Edit/Delete buttons appear
3. Tap Edit to modify or Delete to remove
4. Confirmation dialog for deletion

### 4.3 Stats Tab

**Purpose**: Progress visualization and analytics

**Features**:
- **Day Score Card** (pinned at top): Shows overall Day Score with Comeback, Resilience Index, and Current Streak; navigates to Day Score detail view
- Task list with inline quick stats (Comeback, Resilience, Streak chips per card)
- Adaptive pagination based on screen height

**Day Score Detail View**:
- Trophy icon + "Day Score" in navigation bar
- Statistics section: Non-Zero Days, Comeback, Resilience Index, Days to Return, Current Streak, Best Streak
- Completion Rates: 7-day, 30-day, 90-day percentages
- Computed by walking every day from the earliest task creation date to today

**Per-Task Detail View**:
- Task type icon + name in navigation bar (inline style)
- Statistics section with 6 stat cards:
  - Current Streak (days)
  - Comeback count (times returned after missing)
  - Resilience Index (percentage)
  - Days to Return
  - Non-Zero Days (total)
  - Best Streak (days)
- Completion Rates: 7-day, 30-day, 90-day percentages
- Calendar heatmap (last 60 days, GitHub-style)
  - Each cell shows the day number (1-31)
  - Header label: "LAST N DAYS -- PRESS TO EDIT"
  - Long-press cells (0.5s) to edit past entries via sheet
- Recent entries list (last 10 entries with values > 0)
- Statistics refresh immediately when entries are edited

**Visualizations**:
- **Heatmap**: 60-day grid showing completion intensity with day numbers
- **Stats Cards**: Multiple statistics with icons and color coding
- **Completion Rates**: 7/30/90-day percentage cards

### 4.4 Settings Tab

**Purpose**: App configuration, data management, and preferences

**Features**:

**About Section** (first):
- Non-Zero Philosophy: Navigates to a dedicated page explaining the Non-Zero Days philosophy
- Show Welcome Screen: Resets onboarding flag so the welcome page shows again
- App version and build number display

**General Section**:
- Badge toggle: Show/hide count of incomplete tasks on app icon
- Sounds toggle: Play sound when marking tasks complete

**Day Score Section**:
- Day Score Criteria slider (0-100%, step 5%)
- Description: "Percentage of tasks needed for a Non-Zero day"
- Live percentage readout in orange bold text
- Persisted via SettingsManager (default: 10%)

**Data Section**:
- Export Tasks: Save task definitions to JSON file via share sheet
- Import Tasks: Load task definitions from JSON file via file picker
- Export Full Data: Save all tasks, entries, and settings to a full backup JSON file
- Restore Full Data: Import full backup file (replaces all existing data with confirmation dialog)
- Reset All Records: Delete all logged entries (keeps task definitions) with confirmation dialog
- Footer: "Full backup includes all tasks, history entries, and settings. Restoring will replace all existing data."

---

## 5. Features

### 5.1 Task Creation & Editing

**Inputs**:
- Task name (required)
- Task type (required): Boolean, Count, Time
- Icon selection (optional, SF Symbols via icon picker)
- Unit selection (count tasks only): None, Pages, Cups, Steps, Custom
- Minimum value (required for non-boolean)
- Goal value (optional toggle)
- App integrations:
  - HealthKit (time tasks): Exercise Minutes (Ring), All Workouts, or specific workout type
  - PushFit Pro (count tasks): Enable/disable toggle

**Validation**:
- Name cannot be empty
- Minimum value must be a valid number
- Goal value must be greater than minimum (if set)

**UI Adaptation**:
- Boolean tasks: No Targets section shown
- Count tasks: Unit selector + PushFit Pro option
- Time tasks: HealthKit integration option + Timer functionality

### 5.2 Daily Logging

**Quick Actions**:
- **Boolean**: Single "Done" capsule button; shows "Did It!" label when completed
- **Count**: Three capsule buttons: +1, +5, +10 (adds to current value)
- **Time** (idle): Three capsule buttons: +5m, +15m, +30m + green play button to start timer
- **Time** (timer running): Monospaced elapsed time display + red "Stop" button
- **All types**: Pencil button opens detailed entry editor sheet

**Smart Suggestions**:
- Only shown when task is NOT completed today and was NOT completed yesterday
- Counts consecutive missed days backwards (up to 30 days, stopping at task creation date)
- Brand-new tasks with 0 missed days get no suggestion
- Task-type-aware motivational messages:
  - 1 day missed: "Yesterday was zero. Today doesn't have to be."
  - 1 day missed (count/time with partial log below minimum): "Almost there yesterday! Try [minimum] today?" / "Almost there! Try [minimum]m today?"
  - 2 days missed: "Two quiet days. Let's move again."
  - 3-5 days missed: "[N] days paused. No worries. Just start small."
  - 6+ days missed: "You don't need perfect. Just one non-zero today."
- Displayed as caption text below task name

**Entry Management**:
- Create new entry
- Update existing entry
- Add optional note
- Edit past entries via Stats heatmap (long-press)

### 5.3 Streak Tracking

**Current Streak Calculation**:
```
1. Start from today
2. Check if today has Non-Zero entry
3. Move backwards day by day
4. Stop when encountering day without Non-Zero entry
5. Count = number of consecutive Non-Zero days
```

**Display**:
- Badge next to task showing current streak
- Displayed in Stats detail view statistics section
- Longest streak preserved for motivation

### 5.4 Analytics & Visualization

**Calendar Heatmap (60 days)**:
- Grid layout: 7 columns (days of week)
- Each cell shows the calendar day number (1-31)
- Color intensity: Based on entry value relative to goal
- Gray: No entry
- Light green: Meets minimum
- Dark green: Meets/exceeds goal
- Long-press (0.5s): Edit past entry via sheet
- Header: "LAST N DAYS -- PRESS TO EDIT"
- Date range labels at bottom

**Statistics Cards**:
- Current Streak: Days + flame icon (orange)
- Comeback: Times returned after missing + arrow icon (green)
- Resilience Index: Percentage + percent icon (blue)
- Days to Return: Days + arrow icon (cyan)
- Non-Zero Days: Total count + checkmark icon (mint)
- Best Streak: Days + star icon (purple)

**Completion Rates**:
- 7 Days: Percentage (blue)
- 30 Days: Percentage (cyan)
- 90 Days: Percentage (indigo)

### 5.5 App Badge

**Behavior**:
- Shows count of incomplete tasks for current day
- Updates when:
  - App becomes active
  - User completes/uncompletes a task
  - Day changes
- Can be disabled in Settings
- Requires user permission (requested on first launch)

### 5.6 Data Export/Import

#### 5.6.1 Task Export/Import

**Purpose**: Backup and restore task definitions during major updates

**Export**:
- Exports all task definitions (including archived tasks) to JSON
- File format: `NonZero_Tasks_YYYY-MM-dd_HHmmss.json`
- Preserves: name, type, min/goal, unit, integrations, icon, createdAt
- Uses iOS share sheet for saving/sharing

**Import**:
- File picker for selecting JSON files
- Creates new tasks with all original properties
- Shows success/error alert with imported count
- Validates task type before creation

#### 5.6.2 Full Backup & Restore

**Purpose**: Complete data backup including tasks, entries, and settings

**Export Full Data**:
- Exports all tasks, all entries, and settings to a single JSON file
- File format: `NonZero_Backup_YYYY-MM-dd_HHmmss.json`
- Backup format version: 2
- Includes `BackupSettings` (dayScoreCriteria)
- Uses iOS share sheet for saving/sharing

**Restore Full Data**:
- File picker for selecting backup JSON files
- Confirmation dialog: "This will delete all existing tasks and entries, then restore from the backup file. This action cannot be undone."
- Deletes all existing data via `DataStore.deleteAllData()`
- Restores tasks, entries, and settings from backup
- Shows success/error alert

**Location**: Settings → Data section

### 5.7 Live Activities (Timer)

**Purpose**: Display running timer on lock screen and Dynamic Island

**Features**:
- Shows task name and elapsed time on lock screen when timer is active
- Dynamic Island support:
  - **Compact leading**: Timer icon (green) + task name (caption)
  - **Compact trailing**: Auto-updating elapsed time (monospaced)
  - **Expanded**: Task name (leading), elapsed time (trailing), "Tap to open app and stop timer" hint (bottom)
  - **Minimal**: Timer icon (green)
- Auto-updating timer using `Text(timerInterval:)` — counts up every second
- Monospaced digit display for clean timer appearance
- Automatically starts when user starts a timer task
- Automatically ends when timer is stopped
- Orphan cleanup: When stopping a timer, the app also iterates all `Activity<TimerActivityAttributes>.activities` to end any orphaned Live Activities that may persist after an app restart or force-quit

**Requirements**:
- Paid Apple Developer account ($99/year) required for Widget Extension
- NSSupportsLiveActivities enabled in Info.plist
- ActivityKit framework

**Status**: Fully implemented. Requires paid Apple Developer account to install the Widget Extension on device.

### 5.8 Sound Effects & Haptics

**Behavior**:
- **Success sound** (system sound 1054 + success haptic): Plays when a task first becomes Non-Zero
- **Tap haptic** (light impact, no audio): Plays for incremental logging that doesn't yet reach minimum
- Can be disabled in Settings → General → Sounds

### 5.9 Dynamic App Icon

**Purpose**: Visual indicator of daily progress on the home screen

**Behavior**:
- App icon automatically changes based on today's task completion percentage
- Below 20% completion: Default app icon
- 20%+ completion: Alternate "AppIconNonZero" icon
- Updates in real-time as tasks are completed (triggered on every `loadData()` call)
- Uses `UIApplication.shared.setAlternateIconName(_:)`

### 5.10 Day Score

**Purpose**: Aggregate measure of daily progress across all tasks

**Calculation**:
- Day Score = (number of completed tasks / total active tasks) * 100
- A task is "completed" when its logged value >= its minimum value
- Global Non-Zero Day = Day Score >= Day Score Criteria setting

**Settings**:
- Day Score Criteria: Configurable from 0% to 100% in 5% increments
- Default: 10%
- Located in Settings → Day Score section

**Display**:
- Today tab header dynamically shows "Today is Non-Zero" (green) or "Make Today Non-Zero"
- Stats tab: Dedicated Day Score card with detail view
- Day Score detail view: Same 6 stat cards + 3 completion rates as per-task detail, but computed across all tasks

### 5.11 Onboarding (Welcome Screen)

**Purpose**: Introduce new users to the app on first launch

**Behavior**:
- Shown automatically on first app launch (before the main tab view)
- Single page with app name "NonZero", tagline "Make every day count"
- Four feature highlights: Track Your Way, Build Streaks, See Your Progress, Stay Connected
- "Get Started" button dismisses onboarding and shows the main tab view
- Flag persisted via `@AppStorage("hasSeenOnboarding")`
- Can be replayed from Settings → About → "Show Welcome Screen"

### 5.12 Non-Zero Philosophy Page

**Purpose**: Explain the Non-Zero Days philosophy to users

**Content**:
- "The rule is simple."
- "Do not let a day become zero."
- "You don't have to be perfect. You don't have to complete everything."
- "Just non-zero. 1 page, 1 push-up, 1 min conversation..."
- "You may have a zero-day. No worries. Come back and start small!"

**Access**: Settings → About → "Non-Zero Philosophy" (NavigationLink)

---

## 6. Task Types

### 6.1 Boolean (Yes/No)

**Use Case**: Binary completion tracking (e.g., "Meditated", "Called Mom")

**Properties**:
- Minimum: Always 1 (implicit)
- Goal: Not applicable
- Value: 0 (not done) or 1 (done)

**UI**:
- "Done" capsule button in Today view; shows "Did It!" label when completed
- No Targets section in editor
- No unit or integration options
- Does not display "No" when not completed

**Example**: "Meditation" - Did I meditate today? Yes or No.

### 6.2 Count

**Use Case**: Countable activities (e.g., "Pushups", "Pages Read", "Glasses of Water")

**Properties**:
- Minimum: User-defined number
- Goal: Optional user-defined number
- Value: Integer count
- Unit: None, Pages, Cups, Steps, or Custom

**UI**:
- Three quick-add capsule buttons: +1, +5, +10
- Unit selector in editor
- PushFit Pro integration option

**Integrations**:
- PushFit Pro: Sync rep counts automatically

**Example**: "Pushups" - Minimum: 5, Goal: 20 pushups

### 6.3 Time

**Use Case**: Time-based activities with manual entry or real-time timer (e.g., "Reading", "Focus Work", "Running")

**Properties**:
- Minimum: User-defined minutes
- Goal: Optional user-defined minutes
- Value: Minutes (manual entry or from timer)
- Unit: Always "minutes"

**UI**:
- Three quick-add capsule buttons: +5m, +15m, +30m
- Green play button to start timer
- When timer running: monospaced elapsed time display + red stop button
- Edit button opens sheet for manual numeric entry
- Live Activity on lock screen and Dynamic Island (when timer running)
- HealthKit integration option

**Integrations**:
- HealthKit: Sync Exercise Ring minutes or workout durations from Fitness app
- Filter by: Exercise Minutes (Ring), All Workouts, or specific workout type (Running, Cycling, etc.)

**Example**: "Reading" - Minimum: 10 minutes, Goal: 30 minutes (manual entry)
**Example**: "Focus Work" - Minimum: 25 minutes, Goal: 120 minutes (timer)

---

## 7. Data Model

### 7.1 Schema Version 2 (Current)

**Task Entity**:
```swift
- id: UUID
- name: String
- taskType: TaskType (.boolean, .count, .time)
- minimumValue: Double
- goalValue: Double? (optional)
- unit: String? (optional, for count tasks)
- healthKitWorkoutType: String? (optional, for time tasks)
- pushFitProEnabled: Bool (for count tasks)
- icon: String? (optional SF Symbol name)
- createdAt: Date
- isArchived: Bool
- sortOrder: Int
- entries: [Entry] (relationship)
```

**Entry Entity**:
```swift
- id: UUID
- date: Date
- value: Double
- note: String? (optional)
- createdAt: Date
- task: Task? (relationship)
```

### 7.2 Relationships

- **One-to-Many**: Task → Entries
- **Delete Rule**: Cascade (deleting task removes all entries)
- **Inverse**: Entry.task ← Task.entries

### 7.3 Computed Properties

**Task**:
- `meetsMinimum(value: Double) -> Bool`
- `entry(for date: Date) -> Entry?`
- `isCompleted(on date: Date) -> Bool`
- `currentStreak() -> Int`
- `longestStreak() -> Int`
- `totalValue() -> Double`
- `totalNonZeroDays() -> Int`
- `totalLoggedDays() -> Int`
- `comebackCount() -> Int`

**Entry**:
- `isNonZero -> Bool` (computed: value >= task.minimumValue)

### 7.4 Schema Migration

**Version History**:
- **V1**: Original schema (no PushFit Pro support)
- **V2**: Added `pushFitProEnabled` property

**Migration Strategy**:
- Lightweight migration from V1 → V2
- Automatic on app update
- Existing tasks get `pushFitProEnabled = false`

---

## 8. Third-Party Integrations

### 8.1 HealthKit (Fitness App)

**Purpose**: Sync workout and exercise data for time tasks

**Supported Task Types**: Time

**Features**:
- Read Exercise Ring minutes (Apple Exercise Time)
- Read workout durations from Fitness app
- Filter by specific workout type (Running, Cycling, Yoga, etc.)
- Options: Exercise Minutes (Ring) (default), All Workouts, or specific type
- Permission requested on first use
- Manual sync via title row button or pull-to-refresh
- Shows values even below minimum (when > 0)

**User Flow**:
1. Create/edit time task
2. Toggle "Fitness (HealthKit)" on
3. Select data source: Exercise Minutes (Ring), All Workouts, or specific type
4. Grant permission when prompted
5. Tap sync button or pull-to-refresh on Today tab
6. Data syncs to entries

**Technical**:
- Uses HealthKit framework
- Exercise Minutes: Queries `HKQuantityType.appleExerciseTime` using `HKStatisticsQuery` with `.cumulativeSum`
- Workouts: Queries `HKWorkout` objects for the current day
- Date range: startOfDay to endOfDay with inclusive overlap (no strict start date filtering)
- Filters by HKWorkoutActivityType when specified
- Converts duration (seconds) to minutes
- Only updates entry if HealthKit value exceeds existing value

### 8.2 PushFit Pro

**Purpose**: Sync rep counts for count tasks

**Supported Task Types**: Count

**Features**:
- Automatic sync of pushup/rep counts
- Enable per-task basis
- Data sharing must be enabled in PushFit Pro

**User Flow**:
1. Create/edit count task
2. Toggle "PushFit Pro" on
3. Enable data sharing in PushFit Pro settings
4. Rep counts sync automatically

**Technical**:
- Integration method: TBD (documentation pending)
- Potential approaches:
  - HealthKit quantity samples
  - URL scheme
  - Shared container

---

## 9. Technical Architecture

### 9.1 Architecture Pattern

**MVVM (Model-View-ViewModel)**:
- **Models**: Task, Entry (SwiftData)
- **Views**: SwiftUI views (TodayView, TasksListView, etc.)
- **ViewModels**: Observable classes (TasksViewModel, TodayViewModel, StatsViewModel)

### 9.2 Data Persistence

**Framework**: SwiftData (iOS 17+)

**Features**:
- Local-first persistence
- Automatic model observation
- Schema versioning with migration
- Offline support

**DataStore Pattern**:
- Singleton wrapper around ModelContext
- Centralized CRUD operations
- Shared across ViewModels
- `deleteAllData()` method for full backup restore

### 9.3 Key Technologies

| Technology | Purpose |
|------------|---------|
| SwiftUI | Declarative UI framework |
| SwiftData | Data persistence |
| Observation | State management (@Observable) |
| Charts | Native iOS charts for analytics |
| HealthKit | Fitness data integration |
| ActivityKit | Live Activities for lock screen timer |
| UserDefaults | Settings persistence |
| NotificationCenter | Badge refresh coordination |
| UniformTypeIdentifiers | File import/export |

### 9.4 Project Structure

```
NonZero/
├── App/
│   └── NonZeroApp.swift (Entry point, ModelContainer setup)
├── Models/
│   ├── Task.swift (Task entity)
│   ├── Entry.swift (Entry entity)
│   └── TaskSchema.swift (Schema versioning)
├── ViewModels/
│   ├── TasksViewModel.swift
│   ├── TodayViewModel.swift
│   └── StatsViewModel.swift
├── Views/
│   ├── Today/
│   │   ├── TodayView.swift (Daily logging + TodayTaskCard)
│   │   └── EntryEditorSheet.swift
│   ├── Tasks/
│   │   ├── TasksListView.swift (Task management)
│   │   ├── TaskEditorView.swift
│   │   └── ReorderTasksView.swift
│   ├── Stats/
│   │   ├── StatsView.swift (Analytics overview + Day Score card)
│   │   └── TaskDetailView.swift (Per-task + Day Score detail views)
│   ├── Onboarding/
│   │   └── OnboardingView.swift (First-launch welcome screen)
│   ├── Settings/
│   │   └── SettingsView.swift (Configuration + export/import + full backup + philosophy page)
│   └── Components/
│       ├── CalendarHeatmapView.swift (60-day heatmap with day numbers)
│       ├── NonZeroBadge.swift (Streak badges, task type icons)
│       ├── IconPicker.swift (SF Symbol picker)
│       └── PastEntryEditorSheet.swift (Edit past entries)
├── Data/
│   ├── DataStore.swift (Persistence wrapper + deleteAllData)
│   ├── SeedData.swift (Sample data generator)
│   ├── Extensions.swift (Date/Calendar extensions)
│   ├── Formatting.swift (Value formatters)
│   ├── HealthKitManager.swift (HealthKit queries + Exercise Ring)
│   ├── TimerManager.swift (Timer logic + Live Activity + orphan cleanup)
│   ├── TimerActivityAttributes.swift (Live Activity data model)
│   └── SettingsManager.swift (UserDefaults wrapper + dayScoreCriteria)
├── Utilities/
│   ├── AppBadgeManager.swift (App icon badge)
│   ├── AppIconManager.swift (Dynamic app icon switching)
│   ├── SoundManager.swift (Sound effects + haptics)
│   ├── DeviceHelper.swift (Device detection)
│   ├── DateHelpers.swift (Date utilities)
│   └── Formatting.swift (Additional formatters)
├── NonZeroWidgets/ (Widget Extension target — active)
│   ├── NonZeroWidgetsBundle.swift (Widget entry point)
│   ├── TimerLiveActivity_Simple.swift (Lock screen + Dynamic Island timer UI)
│   ├── NonZeroWidgetsLiveActivity.swift (Xcode-generated placeholder)
│   └── NonZeroWidgetsControl.swift (Control Widget stub — inactive)
└── Widgets/ (Reference/backup copies — not part of active target)
    ├── TimerLiveActivity.swift (Elaborate Live Activity variant)
    └── TimerLiveActivity_Simple.swift (Older copy)
```

### 9.5 State Management

**Approach**: SwiftUI + Observation framework

**Patterns**:
- `@Observable` for ViewModels (iOS 17+)
- `@State` for local view state
- `@Environment(\.modelContext)` for SwiftData access
- `@Binding` for parent-child communication

**Benefits**:
- Automatic UI updates
- No manual ObservableObject conformance
- Cleaner, more readable code

---

## 10. Future Enhancements

### 10.1 Phase 2 Features (Planned)

**Timer Enhancements**:
- Background tracking
- Timer notifications
- Pause/resume state persistence

**Customization**:
- Custom task colors
- Task templates ("Morning Routine", "Workout", etc.)
- Custom streak definitions

### 10.2 Phase 3 Features (Future)

**Notifications & Reminders**:
- Daily reminders per task
- Custom reminder times
- Smart notifications based on patterns

**Cloud Sync**:
- iCloud sync via CloudKit
- Multi-device support
- Conflict resolution

**Widgets**:
- Home Screen widgets (today's progress)
- Lock Screen widgets (streak counter)
- Interactive widget actions

**Apple Watch** (requires paid developer account):
- Companion watchOS app
- Quick logging from wrist
- Complication support
- Activity ring style visualization

**Social Features**:
- Share achievements
- Accountability partners
- Leaderboards (optional)

### 10.3 Technical Improvements

**Performance**:
- Optimize large data sets
- Lazy loading for historical entries
- Image caching for custom icons

**Accessibility**:
- VoiceOver optimization
- Dynamic Type support
- High contrast mode
- Reduce motion alternatives

**Internationalization**:
- Multi-language support
- Localized date/time formats
- RTL language support

**Testing**:
- Unit tests for ViewModels
- UI tests for critical flows
- SwiftData migration tests

---

## Appendix A: User Stories

### Epic: Task Management

**US-1**: As a user, I want to create a Yes/No task so I can track binary habits like "Meditated today."

**US-2**: As a user, I want to create a count task with a custom unit so I can track "pages read" or "glasses of water."

**US-3**: As a user, I want to set a minimum and optional goal so I can distinguish between "good enough" and "ideal."

**US-4**: As a user, I want to reorder my tasks so I can prioritize what matters most.

**US-5**: As a user, I want to delete a task with confirmation so I don't accidentally lose data.

### Epic: Daily Logging

**US-6**: As a user, I want quick action buttons so I can log progress in one tap.

**US-7**: As a user, I want smart suggestions based on my recent history so I'm encouraged to get back on track.

**US-8**: As a user, I want to see which tasks I've completed today so I know what's left.

**US-9**: As a user, I want a badge showing incomplete tasks so I'm reminded without opening the app.

### Epic: Progress Tracking

**US-10**: As a user, I want to see my current streak so I'm motivated to maintain it.

**US-11**: As a user, I want a calendar heatmap so I can visualize my consistency over time.

**US-12**: As a user, I want detailed statistics (comeback count, resilience index, completion rates) so I can understand my habits deeply.

**US-13**: As a user, I want to edit past entries so I can correct mistakes or add forgotten data.

**US-19**: As a user, I want to see an overall Day Score so I can track my aggregate daily consistency.

**US-20**: As a user, I want my app icon to change based on today's progress so I'm visually motivated from the home screen.

### Epic: Integrations

**US-14**: As a fitness enthusiast, I want to sync HealthKit Exercise Ring minutes or workouts so I don't double-log exercise.

**US-15**: As a PushFit Pro user, I want to sync rep counts so my pushup progress is automatic.

### Epic: Data Management

**US-16**: As a user, I want to export my task definitions so I can back them up before updates.

**US-17**: As a user, I want to import task definitions so I can restore them after reinstalling.

**US-18**: As a user, I want to see my running timer on the lock screen with the task name so I can track time without opening the app.

**US-21**: As a user, I want to create a full backup of all my data so I can restore everything if needed.

**US-22**: As a new user, I want to see a welcome screen on first launch so I understand what the app does.

**US-23**: As a user, I want to read about the Non-Zero philosophy so I can stay motivated and understand the app's core idea.

---

## Appendix B: Glossary

| Term | Definition |
|------|------------|
| **Non-Zero Day** | At the task level: a day where the entry value meets the task's minimum. At the app level: a day where the Day Score meets the Day Score Criteria |
| **Day Score** | Percentage of tasks completed (meeting minimum) on a given day |
| **Day Score Criteria** | Configurable threshold (default 10%) that determines what percentage of tasks must be completed for a global Non-Zero Day |
| **Streak** | Consecutive days with Non-Zero entries |
| **Minimum** | The threshold value that qualifies as a Non-Zero day for an individual task |
| **Goal** | Optional target value beyond the minimum |
| **Entry** | A daily log record for a task |
| **Quick Action** | One-tap button for logging progress in Today view |
| **Smart Suggestion** | Context-aware, task-type-specific recommendation based on recent missed days |
| **Heatmap** | Calendar grid visualization showing completion intensity with day numbers |
| **Comeback** | Returning to a Non-Zero day after a miss or gap |
| **Resilience Index** | Recency-weighted comeback score measuring how quickly users return after missed days (half-life: 30 days) |
| **Live Activity** | Real-time lock screen and Dynamic Island display using ActivityKit |
| **Dynamic App Icon** | App icon that changes based on daily completion percentage |
| **SwiftData** | Apple's modern persistence framework (iOS 17+) |
| **MVVM** | Model-View-ViewModel architectural pattern |

---

## Appendix C: Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-01-15 | Initial release |
| 1.1 | 2026-02-12 | - Added PushFit Pro integration<br>- Implemented schema versioning<br>- Hidden Targets for boolean tasks<br>- Improved app integrations UI |
| 1.2 | 2026-02-16 | - Added Export/Import task definitions<br>- Implemented Live Activities for timer (lock screen + Dynamic Island)<br>- Simplified Stats detail view (removed redundant info card)<br>- Added Sounds toggle in Settings<br>- Fixed HealthKit query predicate (inclusive date overlap)<br>- Merged Duration/Timer into single Time task type<br>- Extended calendar heatmap to 60 days<br>- Added comeback/recovery statistics<br>- Added 7/30/90-day completion rates<br>- Stats refresh immediately on entry edits |
| 1.3 | 2026-02-18 | - Added Day Score system with configurable criteria (Settings)<br>- Added Day Score card + detail view in Stats tab<br>- Added Dynamic App Icon (changes at 20% completion)<br>- Added Full Backup & Restore (all tasks, entries, settings)<br>- Added HealthKit Exercise Minutes (Ring) as default sync option<br>- Added task name to Dynamic Island compact view<br>- Fixed orphaned Live Activities persisting after app restart<br>- Updated quick action buttons (count: +1/+5/+10, time: +5m/+15m/+30m)<br>- Updated smart suggestions with task-type-aware messaging<br>- Added haptic feedback tiers (success sound vs light tap) |
| 1.4 | 2026-02-18 | - Added first-launch onboarding welcome screen<br>- Added Non-Zero Philosophy page (Settings → About)<br>- Added "Show Welcome Screen" replay option in Settings<br>- Moved About section to top of Settings tab |

---

**Document End**

*For questions or feedback about this specification, contact the development team.*
