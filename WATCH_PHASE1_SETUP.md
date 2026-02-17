# Phase 1: Shared Framework & App Groups Setup

This guide will help you set up the shared code infrastructure needed for the Apple Watch companion app.

## Overview

We need to:
1. Create a shared framework for code reuse between iOS and watchOS
2. Configure App Groups for data sharing
3. Move shared code to the framework
4. Update DataStore to use App Groups container

**Estimated time:** 2-3 hours

---

## Step 1: Create NonZeroShared Framework

1. **Open Xcode** with `NonZeroDays.xcodeproj`

2. **Create new target:**
   - File → New → Target
   - Select **Framework** (under iOS)
   - Click **Next**
   - Product Name: `NonZeroShared`
   - Language: Swift
   - Click **Finish**
   - When asked about scheme, click **Activate** (or **Cancel** - doesn't matter)

3. **Verify framework created:**
   - You should see `NonZeroShared` folder in Project Navigator
   - It contains `NonZeroShared.h` - you can delete this file (we don't need it for Swift-only framework)

---

## Step 2: Move Models to Shared Framework

We'll move the Models folder to the shared framework so both iOS and Watch can access the same data models.

1. **In Xcode, select these files** (Cmd+Click to multi-select):
   - `Models/Task.swift`
   - `Models/Entry.swift`
   - `Models/TaskSchema.swift`

2. **Drag them into the `NonZeroShared` folder** in Project Navigator

3. **In the dialog that appears:**
   - ✅ Check **Copy items if needed**
   - Under **Add to targets**, make sure:
     - ✅ **NonZeroShared** is checked
     - ❌ **NonZeroDays** is UNCHECKED (we'll link the framework instead)
   - Click **Finish**

4. **Delete the original Models folder** from NonZeroDays target (if it still exists)

---

## Step 3: Move ViewModels to Shared Framework

1. **Select these files:**
   - `ViewModels/TodayViewModel.swift`
   - `ViewModels/TasksViewModel.swift`
   - `ViewModels/StatsViewModel.swift`

2. **Drag them into `NonZeroShared` folder**

3. **In the dialog:**
   - ✅ Check **Copy items if needed**
   - Add to targets:
     - ✅ **NonZeroShared** checked
     - ❌ **NonZeroDays** unchecked
   - Click **Finish**

---

## Step 4: Move Data Layer to Shared Framework

1. **Select these files:**
   - `Data/DataStore.swift`
   - `Data/TimerManager.swift`
   - `Data/SettingsManager.swift`
   - `Data/SeedData.swift` (optional, for testing)

2. **Drag them into `NonZeroShared` folder**

3. **In the dialog:**
   - ✅ Check **Copy items if needed**
   - Add to targets:
     - ✅ **NonZeroShared** checked
     - ❌ **NonZeroDays** unchecked
   - Click **Finish**

**Note:** DO NOT move `HealthKitManager.swift` - this is iOS-specific and stays in NonZeroDays.

---

## Step 5: Move Utilities to Shared Framework

1. **Select these files:**
   - `Utilities/DateHelpers.swift`
   - `Utilities/Formatting.swift`

2. **Drag them into `NonZeroShared` folder**

3. **In the dialog:**
   - ✅ Check **Copy items if needed**
   - Add to targets:
     - ✅ **NonZeroShared** checked
     - ❌ **NonZeroDays** unchecked

**Note:** Leave these files in NonZeroDays (iOS-specific):
- `SoundManager.swift`
- `AppBadgeManager.swift`
- `AppIconManager.swift`
- `DeviceHelper.swift`

---

## Step 6: Link NonZeroShared to NonZeroDays

Now we need to tell the iOS app to use the shared framework.

1. **Select `NonZeroDays` target** (the blue project icon at top of Project Navigator)

2. **Select `NonZeroDays` under TARGETS** (not PROJECTS)

3. **Go to "General" tab**

4. **Scroll to "Frameworks, Libraries, and Embedded Content"**

5. **Click the "+" button**

6. **Select `NonZeroShared.framework`** from the list

7. **Set it to "Embed & Sign"**

---

## Step 7: Import NonZeroShared in iOS Files

Now we need to add `import NonZeroShared` to files that use the moved code.

**Add this import to these files:**

1. **App/NonZeroApp.swift** - Add at top:
```swift
import SwiftUI
import SwiftData
import NonZeroShared  // ADD THIS
```

2. **Views/Today/TodayView.swift** - Add at top:
```swift
import SwiftUI
import NonZeroShared  // ADD THIS
```

3. **Views/Tasks/TasksListView.swift** - Add at top:
```swift
import SwiftUI
import NonZeroShared  // ADD THIS
```

4. **Views/Stats/StatsView.swift** - Add at top:
```swift
import SwiftUI
import NonZeroShared  // ADD THIS
```

5. **Views/Tasks/TaskEditorView.swift** - Add at top:
```swift
import SwiftUI
import NonZeroShared  // ADD THIS
```

6. **Views/Stats/TaskDetailView.swift** - Add at top:
```swift
import SwiftUI
import NonZeroShared  // ADD THIS
```

7. **Any other view files that use Task, Entry, or ViewModels**

---

## Step 8: Test iOS App with Shared Framework

1. **Clean build folder:** Shift + Cmd + K

2. **Build the project:** Cmd + B

3. **Fix any import errors** by adding `import NonZeroShared` to files that need it

4. **Run the app:** Cmd + R

5. **Verify everything works:**
   - Today tab loads tasks
   - Can log entries
   - Tasks tab shows tasks
   - Stats tab shows streaks
   - All functionality works as before

**Common error:** If you see "Cannot find 'Task' in scope", you forgot to add `import NonZeroShared` to that file.

---

## Step 9: Configure App Groups

App Groups allow iOS and watchOS to share data through a shared container.

### 9.1: Update NonZero.entitlements

1. **Open `NonZero.entitlements`** in Xcode

2. **Replace the contents with:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- HealthKit -->
    <key>com.apple.developer.healthkit</key>
    <true/>

    <!-- App Groups for data sharing with Watch -->
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.lewislee.nonzero</string>
    </array>
</dict>
</plist>
```

**Important:** Replace `com.lewislee.nonzero` with your actual bundle ID prefix if different. You can find your bundle ID in:
- Select **NonZeroDays** target → **General** tab → **Bundle Identifier**
- If it's `com.yourname.NonZeroDays`, use `group.com.yourname.nonzero`

3. **Save the file**

### 9.2: Enable App Groups in Xcode Capabilities

1. **Select NonZeroDays target**

2. **Go to "Signing & Capabilities" tab**

3. **Click "+ Capability"** button (top left)

4. **Select "App Groups"**

5. **Click the "+" button** under App Groups

6. **Enter:** `group.com.lewislee.nonzero` (or your bundle ID prefix)

7. **✅ Check the checkbox** next to the app group

---

## Step 10: Update DataStore for App Groups

Now we need to modify DataStore to save data in the App Groups container instead of the default location.

**Edit `NonZeroShared/Data/DataStore.swift`:**

Find this section near the top (around line 1-15) and add a new static method:

```swift
import Foundation
import SwiftData

@MainActor
class DataStore {
    static let shared = DataStore()

    var container: ModelContainer?
    var context: ModelContext?

    private init() {
        // Container and context will be set from the app initialization
    }

    // NEW METHOD: Get the App Groups container URL
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

    // ... rest of the file stays the same
```

**Important:** Replace `group.com.lewislee.nonzero` with your actual app group identifier.

---

## Step 11: Update NonZeroApp to Use App Groups Container

**Edit `App/NonZeroApp.swift`:**

Replace the `init()` method (lines 8-20):

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

---

## Step 12: Final Testing

1. **Clean build folder:** Shift + Cmd + K

2. **Delete the app** from simulator/device (to clear old database location)

3. **Build and run:** Cmd + R

4. **Test all functionality:**
   - Create tasks
   - Log entries
   - Check stats
   - Close and reopen app (data should persist)

5. **Verify App Groups container:**
   - Add this temporary debug code to `NonZeroApp.swift` in `init()`:
   ```swift
   let containerURL = DataStore.appGroupContainerURL()
   print("📁 Database location: \(containerURL)")
   ```
   - Run app and check console - you should see a path like:
     `/Users/.../Library/Group Containers/group.com.lewislee.nonzero/NonZero.sqlite`

---

## Step 13: Commit Your Changes

Once everything works, commit this phase:

```bash
git add .
git commit -m "Phase 1: Setup shared framework and App Groups

- Created NonZeroShared framework for code reuse
- Moved Models, ViewModels, Data, and Utilities to shared
- Configured App Groups for data sharing
- Updated DataStore to use App Groups container
- iOS app tested and working with shared framework"
```

---

## What's Next?

**Phase 2:** Create watchOS app target and basic UI

You're now ready to create the Apple Watch target! The shared framework will automatically be available to the Watch app, and both apps will read/write to the same database via App Groups.

---

## Troubleshooting

### "Cannot find 'Task' in scope"
- **Fix:** Add `import NonZeroShared` to the top of the file

### "No such module 'NonZeroShared'"
- **Fix:** Make sure NonZeroShared framework is added to "Frameworks, Libraries, and Embedded Content" in NonZeroDays target → General tab

### "App Group container not found"
- **Fix:** Check that:
  1. App Group identifier matches exactly in both entitlements and code
  2. App Group is enabled in Signing & Capabilities
  3. The checkbox is checked for the app group

### App crashes on launch after moving to App Groups
- **Fix:** Delete the app from device/simulator (old database is in wrong location), then reinstall

### Build errors about duplicate files
- **Fix:** Make sure files are only in NonZeroShared target, not in both NonZeroShared AND NonZeroDays. Check file inspector (right sidebar) and uncheck NonZeroDays target membership.

---

## Summary

✅ Created shared framework (NonZeroShared)
✅ Moved platform-independent code to framework
✅ Linked framework to iOS app
✅ Configured App Groups for data sharing
✅ Updated DataStore to use App Groups container
✅ Tested iOS app works correctly

**Status:** Ready for Phase 2 (watchOS target creation)
