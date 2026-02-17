# Phase 1: Code Updates

These are the exact code changes you'll need to make after completing the manual Xcode setup steps.

---

## Update 1: DataStore.swift

**File:** `NonZeroShared/Data/DataStore.swift` (after moving to shared framework)

**Add this method** after the `init()` method and before the `// MARK: - Task Operations` comment:

```swift
// MARK: - App Groups Support

/// Returns the URL for the shared App Groups container
/// This allows iOS and watchOS to share the same database
static func appGroupContainerURL() -> URL {
    // App Group identifier - must match entitlements
    let appGroupIdentifier = "group.com.lewislee.nonzero"

    guard let containerURL = FileManager.default.containerURL(
        forSecurityApplicationGroupIdentifier: appGroupIdentifier
    ) else {
        fatalError("App Group container not found. Check entitlements and bundle ID.")
    }

    return containerURL.appendingPathComponent("NonZero.sqlite")
}
```

**Location:** Insert after line 12 (after the `init()` method)

---

## Update 2: NonZeroApp.swift

**File:** `App/NonZeroApp.swift`

**Replace the `init()` method** (currently lines 8-20) with:

```swift
init() {
    do {
        // Use App Groups container for data sharing with Watch
        let containerURL = DataStore.appGroupContainerURL()
        let modelConfiguration = ModelConfiguration(url: containerURL, isStoredInMemoryOnly: false)

        modelContainer = try ModelContainer(
            for: Task.self, Entry.self,
            migrationPlan: TaskMigrationPlan.self,
            configurations: modelConfiguration
        )
    } catch {
        fatalError("Failed to create ModelContainer: \(error)")
    }
}
```

**Also add import at the top** (after line 2):

```swift
import SwiftUI
import SwiftData
import NonZeroShared  // ADD THIS LINE
```

---

## Update 3: Add imports to view files

Add `import NonZeroShared` to these files (at the top, after existing imports):

### Required imports:

1. **Views/Today/TodayView.swift**
   ```swift
   import SwiftUI
   import NonZeroShared  // ADD THIS
   ```

2. **Views/Tasks/TasksListView.swift**
   ```swift
   import SwiftUI
   import NonZeroShared  // ADD THIS
   ```

3. **Views/Stats/StatsView.swift**
   ```swift
   import SwiftUI
   import NonZeroShared  // ADD THIS
   ```

4. **Views/Tasks/TaskEditorView.swift**
   ```swift
   import SwiftUI
   import NonZeroShared  // ADD THIS
   ```

5. **Views/Stats/TaskDetailView.swift**
   ```swift
   import SwiftUI
   import NonZeroShared  // ADD THIS
   ```

6. **Views/Today/EntryEditorSheet.swift**
   ```swift
   import SwiftUI
   import NonZeroShared  // ADD THIS
   ```

7. **Views/Tasks/ReorderTasksView.swift**
   ```swift
   import SwiftUI
   import NonZeroShared  // ADD THIS
   ```

8. **Views/Components/CalendarHeatmapView.swift**
   ```swift
   import SwiftUI
   import NonZeroShared  // ADD THIS
   ```

9. **Views/Components/PastEntryEditorSheet.swift**
   ```swift
   import SwiftUI
   import NonZeroShared  // ADD THIS
   ```

10. **Data/HealthKitManager.swift** (uses Task model)
    ```swift
    import Foundation
    import HealthKit
    import NonZeroShared  // ADD THIS
    ```

11. **Utilities/AppBadgeManager.swift** (uses Task model)
    ```swift
    import Foundation
    import UserNotifications
    import NonZeroShared  // ADD THIS
    ```

12. **Utilities/AppIconManager.swift** (uses Task model)
    ```swift
    import UIKit
    import SwiftData
    import NonZeroShared  // ADD THIS
    ```

---

## How to Apply These Updates

### Method 1: Manual Copy-Paste (Recommended)
1. Open each file in Xcode
2. Copy the code from this document
3. Paste it in the specified location
4. Build to verify (Cmd+B)

### Method 2: Let Claude Apply (Faster)
After you've completed the Xcode manual steps (creating framework, moving files), you can ask me:

"Apply the code updates from WATCH_PHASE1_CODE_UPDATES.md"

And I'll use the Edit tool to apply all these changes automatically.

---

## Verification Checklist

After applying all updates:

✅ Clean build (Shift+Cmd+K)
✅ Build succeeds (Cmd+B)
✅ No "Cannot find 'Task' in scope" errors
✅ No "No such module 'NonZeroShared'" errors
✅ App runs without crashes (Cmd+R)
✅ Can create and log tasks
✅ Data persists after app restart
✅ Console shows App Groups path (add debug print to verify)

---

## Quick Reference: App Group Identifier

**Default:** `group.com.lewislee.nonzero`

**If your bundle ID is different:**
- Find your bundle ID: NonZeroDays target → General → Bundle Identifier
- If bundle ID is `com.example.NonZeroDays`
- Then app group should be `group.com.example.nonzero`
- Update BOTH places:
  1. `NonZero.entitlements` (the `<string>` value)
  2. `DataStore.swift` (the `appGroupIdentifier` constant)

---

## What This Enables

Once Phase 1 is complete:

✅ Shared code can be used by both iOS and watchOS
✅ Both apps will read/write to the same database
✅ Changes on iPhone instantly visible on Watch (via shared storage)
✅ Changes on Watch instantly visible on iPhone (via shared storage)
✅ Foundation for Watch Connectivity real-time sync in Phase 4

---

## Next Steps

After Phase 1 is complete and tested:

**→ Phase 2:** Create watchOS app target with basic UI
