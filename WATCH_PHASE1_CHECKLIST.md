# Phase 1 Quick-Start Checklist

Follow this checklist step-by-step. Detailed instructions are in `WATCH_PHASE1_SETUP.md`.

---

## Part 1: Xcode Manual Steps (30 min)

### Create Shared Framework
- [ ] File → New → Target → Framework → Name: `NonZeroShared`
- [ ] Delete `NonZeroShared.h` (not needed)

### Move Files to NonZeroShared
- [ ] Drag `Models/` folder → NonZeroShared (✅ NonZeroShared target, ❌ NonZeroDays target)
- [ ] Drag `ViewModels/` folder → NonZeroShared (✅ NonZeroShared, ❌ NonZeroDays)
- [ ] Drag these from `Data/` → NonZeroShared:
  - [ ] `DataStore.swift`
  - [ ] `TimerManager.swift`
  - [ ] `SettingsManager.swift`
  - [ ] `SeedData.swift` (optional)
- [ ] Drag these from `Utilities/` → NonZeroShared:
  - [ ] `DateHelpers.swift`
  - [ ] `Formatting.swift`
- [ ] Leave these in NonZeroDays (iOS-specific):
  - `HealthKitManager.swift`
  - `SoundManager.swift`
  - `AppBadgeManager.swift`
  - `AppIconManager.swift`
  - `DeviceHelper.swift`

### Link Framework
- [ ] NonZeroDays target → General → "Frameworks, Libraries, and Embedded Content"
- [ ] Click "+" → Add `NonZeroShared.framework` → Set to "Embed & Sign"

---

## Part 2: Code Updates (15 min)

### Update DataStore
- [ ] Open `NonZeroShared/Data/DataStore.swift`
- [ ] Add `appGroupContainerURL()` method (see WATCH_PHASE1_CODE_UPDATES.md)

### Update NonZeroApp
- [ ] Open `App/NonZeroApp.swift`
- [ ] Add `import NonZeroShared` at top
- [ ] Replace `init()` to use App Groups container (see WATCH_PHASE1_CODE_UPDATES.md)

### Add Imports to View Files
Add `import NonZeroShared` to these files:

- [ ] `Views/Today/TodayView.swift`
- [ ] `Views/Tasks/TasksListView.swift`
- [ ] `Views/Stats/StatsView.swift`
- [ ] `Views/Tasks/TaskEditorView.swift`
- [ ] `Views/Stats/TaskDetailView.swift`
- [ ] `Views/Today/EntryEditorSheet.swift`
- [ ] `Views/Tasks/ReorderTasksView.swift`
- [ ] `Views/Components/CalendarHeatmapView.swift`
- [ ] `Views/Components/PastEntryEditorSheet.swift`
- [ ] `Data/HealthKitManager.swift`
- [ ] `Utilities/AppBadgeManager.swift`
- [ ] `Utilities/AppIconManager.swift`

**Tip:** Build (Cmd+B) after each import to catch missing ones

---

## Part 3: Configure App Groups (15 min)

### Update Entitlements File
- [ ] Open `NonZero.entitlements`
- [ ] Add App Groups section (see WATCH_PHASE1_SETUP.md Step 9.1)
- [ ] Use identifier: `group.com.lewislee.nonzero` (or your bundle ID prefix)

### Enable in Xcode Capabilities
- [ ] NonZeroDays target → Signing & Capabilities
- [ ] Click "+ Capability" → Add "App Groups"
- [ ] Click "+" under App Groups
- [ ] Enter: `group.com.lewislee.nonzero`
- [ ] ✅ Check the checkbox

---

## Part 4: Testing (10 min)

- [ ] Clean build folder (Shift+Cmd+K)
- [ ] Delete app from simulator/device (clears old database location)
- [ ] Build (Cmd+B) - should succeed with no errors
- [ ] Run (Cmd+R)
- [ ] Test all features:
  - [ ] Today tab loads
  - [ ] Can create tasks
  - [ ] Can log entries
  - [ ] Tasks tab works
  - [ ] Stats tab works
  - [ ] Close and reopen app (data persists)

### Verify App Groups Location
- [ ] Add debug print to `NonZeroApp.swift` init():
  ```swift
  print("📁 Database location: \(containerURL)")
  ```
- [ ] Check console for path containing `Group Containers/group.com.lewislee.nonzero`

---

## Part 5: Commit

- [ ] Test everything works
- [ ] Remove debug print statements
- [ ] Commit changes:
  ```bash
  git add .
  git commit -m "Phase 1: Setup shared framework and App Groups"
  ```

---

## Success Criteria

✅ iOS app builds without errors
✅ All tabs work correctly
✅ Data persists across app restarts
✅ Database is in App Groups container (verified via console log)
✅ No crashes or warnings

---

## If You Get Stuck

### Common Issues:

**"Cannot find 'Task' in scope"**
→ Add `import NonZeroShared` to that file

**"No such module 'NonZeroShared'"**
→ Check framework is linked in NonZeroDays target → General → Frameworks

**"App Group container not found"**
→ Check app group identifier matches in both code and entitlements

**Build errors about duplicate files**
→ Files should only be in NonZeroShared target, not both

---

## Time Estimate

- Xcode manual steps: 30 minutes
- Code updates: 15 minutes
- App Groups config: 15 minutes
- Testing: 10 minutes
- **Total: ~70 minutes**

---

## What's Next?

After Phase 1 is complete:

**→ Phase 2:** Create watchOS app target and basic UI

---

## Need Help?

- Detailed instructions: `WATCH_PHASE1_SETUP.md`
- Code changes: `WATCH_PHASE1_CODE_UPDATES.md`
- Full plan: `~/.claude/plans/stateful-mixing-haven.md`
