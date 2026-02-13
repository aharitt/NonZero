# NonZero App - Functional Specification

**Version:** 1.1
**Last Updated:** February 12, 2026
**Platform:** iOS 17.0+
**Technology Stack:** SwiftUI, SwiftData, HealthKit

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

- **Flexible Tracking**: Support for Yes/No tasks, countable activities, and time-based tracking
- **Smart Suggestions**: Context-aware recommendations based on previous performance
- **Visual Feedback**: Streak tracking and calendar heatmaps for instant motivation
- **App Integration**: Seamless sync with HealthKit (Fitness) and PushFit Pro
- **Offline-First**: Full functionality without internet connection

---

## 2. Product Overview

### 2.1 Purpose

NonZero helps users:
- Build sustainable habits through daily tracking
- Maintain "Non-Zero Days" by completing minimum daily targets
- Visualize progress through streaks and analytics
- Stay motivated with smart suggestions and visual feedback

### 2.2 Target Users

- Individuals seeking to build better habits
- People following the "Non-Zero Days" philosophy
- Fitness enthusiasts tracking workouts and reps
- Anyone wanting simple, flexible habit tracking

### 2.3 Core Philosophy

A "Non-Zero Day" is achieved when the user completes at least the minimum requirement for any task. The app emphasizes **consistency over perfection** - even small progress counts.

---

## 3. Core Concepts

### 3.1 Tasks

A **Task** represents a trackable habit or activity with the following attributes:

- **Name**: User-defined label (e.g., "Reading", "Pushups")
- **Type**: Boolean, Count, Duration, or Timer
- **Minimum Value**: The threshold that qualifies as a Non-Zero day
- **Goal Value** (Optional): Target to aim for beyond the minimum
- **Unit** (Optional): Measurement unit for count tasks (e.g., pages, cups, steps)
- **Icon** (Optional): SF Symbol for visual identification
- **Integrations**: HealthKit workout type or PushFit Pro connection

### 3.2 Entries

An **Entry** records daily progress for a task:

- **Date**: The day this entry belongs to
- **Value**: The recorded amount (1 for boolean, number for count/duration)
- **Note** (Optional): User comments about the entry
- **Non-Zero Status**: Automatically calculated based on minimum value

### 3.3 Streaks

- **Current Streak**: Consecutive days with Non-Zero entries (ending today)
- **Longest Streak**: Historical best streak for motivation

---

## 4. User Interface

The app consists of four main tabs:

### 4.1 Today Tab

**Purpose**: Daily task logging and quick entry creation

**Features**:
- List of all active tasks
- Quick action buttons per task type:
  - Boolean: "Done" button
  - Count: Stepper with custom increment
  - Duration: Time input field
  - Timer: Start/Stop timer
- Smart suggestions based on yesterday's performance
- Visual indicators for completed tasks
- App badge showing incomplete tasks count

**User Flow**:
1. User opens app to Today tab
2. Sees list of tasks with current day's status
3. Taps quick action to log progress
4. Smart suggestion appears if applicable
5. Badge updates in real-time

### 4.2 Tasks Tab

**Purpose**: Task management and organization

**Features**:
- Paginated task list (6 tasks per page)
- Long-press to reveal Edit/Delete buttons
- Reorder tasks functionality
- Add new task button
- Streak badge display per task
- Task type icons

**User Flow - Creating a Task**:
1. Tap "+" button
2. Enter task name
3. Select task type (Boolean/Count/Duration/Timer)
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
- Task list with navigation to detail view
- Per-task statistics:
  - Current streak
  - Longest streak
  - 7-day average
  - Completion rate
- Bar charts with minimum/goal reference lines
- Calendar heatmap (last 30 days, GitHub-style)
- Long-press calendar cells to edit past entries
- Historical entry list with edit capability

**Visualizations**:
- **Bar Chart**: Daily values over 7 days with min/goal lines
- **Heatmap**: 30-day grid showing completion intensity
- **Stats Cards**: Current streak, longest streak, average, completion %

### 4.4 Settings Tab

**Purpose**: App configuration and preferences

**Features**:
- App version display
- Badge settings toggle
- HealthKit permissions management
- Data export options (future)
- About and help sections

---

## 5. Features

### 5.1 Task Creation & Editing

**Inputs**:
- Task name (required)
- Task type (required): Boolean, Count, Duration, Timer
- Icon selection (optional)
- Unit selection (count tasks only): None, Pages, Cups, Steps, Custom
- Minimum value (required for non-boolean)
- Goal value (optional toggle)
- App integrations:
  - HealthKit (duration tasks): All workouts or specific type
  - PushFit Pro (count tasks): Enable/disable toggle

**Validation**:
- Name cannot be empty
- Minimum value must be a valid number
- Goal value must be greater than minimum (if set)

**UI Adaptation**:
- Boolean tasks: No Targets section shown
- Count tasks: Unit selector + PushFit Pro option
- Duration tasks: HealthKit integration option
- Timer tasks: Time-based input

### 5.2 Daily Logging

**Quick Actions**:
- **Boolean**: Single "Done" button
- **Count**: Stepper with increment buttons
- **Duration**: Numeric input with minute unit
- **Timer**: Start/Stop/Resume functionality

**Smart Suggestions**:
- Analyzes yesterday's entry
- Suggests incremental improvement:
  - Count: Yesterday's value + 1
  - Duration: Yesterday's value + 5 minutes
- Displayed as helpful hint below task

**Entry Management**:
- Create new entry
- Update existing entry
- Add optional note
- Edit past entries via Stats heatmap

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
- Prominent display in Stats detail view
- Longest streak preserved for motivation

### 5.4 Analytics & Visualization

**Bar Chart (7 days)**:
- X-axis: Past 7 days
- Y-axis: Entry values
- Reference lines: Minimum (dashed), Goal (dotted)
- Color coding: Below min (gray), Above min (blue), At goal (green)

**Calendar Heatmap (30 days)**:
- Grid layout: 7 columns (days of week)
- Color intensity: Based on entry value relative to goal
- Gray: No entry
- Light blue: Meets minimum
- Dark blue: Meets/exceeds goal
- Long-press: Edit past entry

**Statistics Cards**:
- Current Streak: Days + fire icon
- Longest Streak: Days + trophy icon
- 7-Day Average: Value + unit
- Completion Rate: Percentage + checkmark icon

### 5.5 App Badge

**Behavior**:
- Shows count of incomplete tasks for current day
- Updates when:
  - App becomes active
  - User completes/uncompletes a task
  - Day changes
- Can be disabled in Settings
- Requires user permission (requested on first launch)

---

## 6. Task Types

### 6.1 Boolean (Yes/No)

**Use Case**: Binary completion tracking (e.g., "Meditated", "Called Mom")

**Properties**:
- Minimum: Always 1 (implicit)
- Goal: Not applicable
- Value: 0 (not done) or 1 (done)

**UI**:
- Single "Done" button in Today view
- No Targets section in editor
- No unit or integration options

**Example**: "Meditation" - Did I meditate today? Yes or No.

### 6.2 Count

**Use Case**: Countable activities (e.g., "Pushups", "Pages Read", "Glasses of Water")

**Properties**:
- Minimum: User-defined number
- Goal: Optional user-defined number
- Value: Integer count
- Unit: None, Pages, Cups, Steps, or Custom

**UI**:
- Stepper with +/- buttons
- Unit selector in editor
- PushFit Pro integration option

**Integrations**:
- PushFit Pro: Sync rep counts automatically

**Example**: "Pushups" - Minimum: 5, Goal: 20 pushups

### 6.3 Duration

**Use Case**: Time-based activities tracked manually (e.g., "Reading", "Study Time")

**Properties**:
- Minimum: User-defined minutes
- Goal: Optional user-defined minutes
- Value: Integer minutes
- Unit: Always "minutes"

**UI**:
- Numeric input field
- HealthKit integration option

**Integrations**:
- HealthKit: Sync workout durations from Fitness app
- Filter by workout type (Running, Cycling, etc.) or All

**Example**: "Reading" - Minimum: 10 minutes, Goal: 30 minutes

### 6.4 Timer

**Use Case**: Real-time tracking with start/stop functionality (e.g., "Focus Work", "Running")

**Properties**:
- Minimum: User-defined minutes
- Goal: Optional user-defined minutes
- Value: Timed minutes (from timer)

**UI**:
- Start/Stop/Resume buttons
- Live timer display
- Background tracking support (future)

**Example**: "Focus Work" - Minimum: 25 minutes (Pomodoro), Goal: 120 minutes

---

## 7. Data Model

### 7.1 Schema Version 2 (Current)

**Task Entity**:
```swift
- id: UUID
- name: String
- taskType: TaskType (.boolean, .count, .duration, .timer)
- minimumValue: Double
- goalValue: Double? (optional)
- unit: String? (optional, for count tasks)
- healthKitWorkoutType: String? (optional, for duration tasks)
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

**Purpose**: Sync workout data for duration tasks

**Supported Task Types**: Duration

**Features**:
- Read workout durations from Fitness app
- Filter by specific workout type (Running, Cycling, Yoga, etc.)
- Option to include all workout types
- Permission requested on first use

**User Flow**:
1. Create/edit duration task
2. Toggle "Fitness (HealthKit)" on
3. Select workout type or "All Workouts"
4. Grant permission when prompted
5. Workouts automatically sync to entries

**Technical**:
- Uses HealthKit framework
- Queries HKWorkout objects
- Filters by HKWorkoutActivityType
- Converts duration to minutes

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

### 9.3 Key Technologies

| Technology | Purpose |
|------------|---------|
| SwiftUI | Declarative UI framework |
| SwiftData | Data persistence |
| Observation | State management (@Observable) |
| Charts | Native iOS charts for analytics |
| HealthKit | Fitness data integration |
| UserDefaults | Settings persistence |
| NotificationCenter | Badge refresh coordination |

### 9.4 Project Structure

```
NonZero/
├── App/
│   └── NonZeroApp.swift (Entry point, ModelContainer setup)
├── Models/
│   ├── Task.swift (Task entity)
│   ├── Entry.swift (Entry entity)
│   └── TaskSchema.swift (Versioning)
├── ViewModels/
│   ├── TasksViewModel.swift
│   ├── TodayViewModel.swift
│   └── StatsViewModel.swift
├── Views/
│   ├── Today/ (Daily logging)
│   ├── Tasks/ (Task management)
│   ├── Stats/ (Analytics)
│   ├── Settings/ (Configuration)
│   └── Components/ (Reusable UI)
├── Data/
│   ├── DataStore.swift (Persistence wrapper)
│   ├── SeedData.swift (Sample data)
│   └── Formatting.swift (Value formatters)
└── Utilities/
    ├── HealthKitManager.swift
    ├── AppBadgeManager.swift
    └── DateHelpers.swift
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

**Extended Analytics**:
- 30/60/90-day views
- Trend analysis
- Goal achievement rates
- Comparison charts

**Timer Enhancements**:
- Background tracking
- Timer notifications
- Pause/resume state persistence

**Data Management**:
- Edit past entries (partially implemented)
- Export to CSV/JSON
- Import data
- Backup/restore

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

**Apple Watch**:
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

**US-7**: As a user, I want smart suggestions based on yesterday so I'm encouraged to improve incrementally.

**US-8**: As a user, I want to see which tasks I've completed today so I know what's left.

**US-9**: As a user, I want a badge showing incomplete tasks so I'm reminded without opening the app.

### Epic: Progress Tracking

**US-10**: As a user, I want to see my current streak so I'm motivated to maintain it.

**US-11**: As a user, I want a calendar heatmap so I can visualize my consistency over time.

**US-12**: As a user, I want bar charts with reference lines so I can see if I'm meeting my targets.

**US-13**: As a user, I want to edit past entries so I can correct mistakes or add forgotten data.

### Epic: Integrations

**US-14**: As a fitness enthusiast, I want to sync HealthKit workouts so I don't double-log exercise.

**US-15**: As a PushFit Pro user, I want to sync rep counts so my pushup progress is automatic.

---

## Appendix B: Glossary

| Term | Definition |
|------|------------|
| **Non-Zero Day** | A day where the user completes at least the minimum requirement for a task |
| **Streak** | Consecutive days with Non-Zero entries |
| **Minimum** | The threshold value that qualifies as a Non-Zero day |
| **Goal** | Optional target value beyond the minimum |
| **Entry** | A daily log record for a task |
| **Quick Action** | One-tap button for logging progress in Today view |
| **Smart Suggestion** | Context-aware recommendation based on previous performance |
| **Heatmap** | Calendar grid visualization showing completion intensity |
| **SwiftData** | Apple's modern persistence framework (iOS 17+) |
| **MVVM** | Model-View-ViewModel architectural pattern |

---

## Appendix C: Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-01-15 | Initial release |
| 1.1 | 2026-02-12 | - Added PushFit Pro integration<br>- Implemented schema versioning<br>- Hidden Targets for boolean tasks<br>- Improved app integrations UI |

---

**Document End**

*For questions or feedback about this specification, contact the development team.*
