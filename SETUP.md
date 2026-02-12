# NonZero - Quick Setup Guide

Follow these steps to get your NonZero app running in Xcode.

## Prerequisites

- ✅ macOS with Xcode 15.0 or later
- ✅ iOS 17.0+ target device or simulator

## Setup Steps

### Step 1: Create Xcode Project

1. Open Xcode
2. Click **"Create New Project"** or **File → New → Project**
3. Select **iOS** platform, then **App** template
4. Click **Next**

### Step 2: Configure Project Settings

Fill in the project details:

| Setting | Value |
|---------|-------|
| Product Name | `NonZero` |
| Team | Your Apple Developer Account (or leave as None for simulator) |
| Organization Identifier | `com.yourname` (or similar) |
| Interface | **SwiftUI** ⚠️ |
| Storage | **None** ⚠️ (we implement SwiftData manually) |
| Language | **Swift** |
| Include Tests | Optional (recommended for Phase 2) |

**Important**: Make sure to select **SwiftUI** for Interface!

### Step 3: Set Deployment Target

1. Select your project in the navigator (blue icon at top)
2. Select the **NonZero** target
3. Go to **General** tab
4. Set **Minimum Deployments → iOS** to **17.0**

### Step 4: Delete Default Files

In the Project Navigator, **delete**:
- ❌ `ContentView.swift` (we have our own)
- ❌ Keep `NonZeroApp.swift` for now (we'll replace it)
- ❌ `Assets.xcassets` - Keep this!
- ❌ `Preview Content` folder - Keep this!

### Step 5: Add NonZero Files

#### Option A: Manual (Drag & Drop)

1. In Finder, open the `NonZero/` folder you just created
2. Drag all folders (`App/`, `Models/`, `Data/`, etc.) into Xcode
3. In the dialog that appears:
   - ✅ Check "Copy items if needed"
   - ✅ Check "Create groups" (not folder references)
   - ✅ Ensure your target is checked
4. Click **Finish**

#### Option B: Add Files Individually

For each folder:
1. Right-click your project in Navigator
2. **New Group** → Name it (e.g., "Models")
3. Right-click the new group
4. **Add Files to "NonZero"...**
5. Navigate to the folder and select .swift files
6. Repeat for all folders

### Step 6: Verify Project Structure

Your Project Navigator should look like this:

```
NonZero
├── App
│   └── NonZeroApp.swift
├── Models
│   ├── Task.swift
│   └── Entry.swift
├── Data
│   ├── DataStore.swift
│   └── SeedData.swift
├── ViewModels
│   ├── TasksViewModel.swift
│   ├── TodayViewModel.swift
│   └── StatsViewModel.swift
├── Views
│   ├── Tasks
│   │   ├── TasksListView.swift
│   │   └── TaskEditorView.swift
│   ├── Today
│   │   ├── TodayView.swift
│   │   └── EntryEditorSheet.swift
│   ├── Stats
│   │   ├── StatsView.swift
│   │   └── TaskDetailView.swift
│   └── Components
│       ├── NonZeroBadge.swift
│       └── CalendarHeatmapView.swift
├── Utilities
│   ├── DateHelpers.swift
│   └── Formatting.swift
└── Assets.xcassets
```

### Step 7: Build the App

1. Select a simulator from the scheme picker:
   - **Product → Destination → iPhone 15 Pro** (recommended)
   - Or any iOS 17+ device

2. Press **Cmd + R** or click the **Play** button

3. Wait for build to complete (first build may take 30-60 seconds)

### Step 8: Test the App

The app should launch showing three tabs:
- **Today**: Empty state (no tasks yet)
- **Tasks**: "No Tasks" message
- **Stats**: "No Stats Yet" message

### Step 9 (Optional): Add Sample Data

To test with pre-populated data:

1. Open [NonZeroApp.swift](NonZero/App/NonZeroApp.swift)
2. Find this line (around line 24):
   ```swift
   // SeedData.createSampleData(in: modelContext)
   ```
3. **Uncomment it**:
   ```swift
   SeedData.createSampleData(in: modelContext)
   ```
4. **Build and run again** (Cmd + R)
5. You should now see sample tasks and data!

⚠️ **Note**: Sample data only loads once. To reset:
- **Product → Destination → Manage Run Destinations**
- Right-click simulator → **Erase All Content and Settings**
- Build again

## Troubleshooting

### ❌ "No such module 'SwiftData'"
**Fix**: Ensure deployment target is iOS 17.0+

### ❌ Build errors about missing files
**Fix**:
1. Clean build folder: **Product → Clean Build Folder** (Cmd+Shift+K)
2. Verify all .swift files are added to your target:
   - Select file → Show File Inspector (right panel)
   - Check "Target Membership" has NonZero checked

### ❌ "Type 'Task' is ambiguous"
**Fix**: Make sure you deleted the default `ContentView.swift` that might have conflicting code

### ❌ Previews not working
**Fix**:
- Restart Xcode
- Some previews require specific iOS version
- Canvas can be flaky - the app will still work!

### ❌ Data not saving between launches
**Fix**:
- This is normal in simulator if you reinstall
- SwiftData persists automatically
- Check you didn't set `isStoredInMemoryOnly: true`

## Next Steps

### 1. Create Your First Task
- Go to **Tasks** tab
- Tap **+** button
- Create a simple task (e.g., "Pushups", Count type, minimum 1)

### 2. Log Today's Entry
- Go to **Today** tab
- Use quick action buttons to log
- Try the edit button (pencil icon) to add notes

### 3. View Your Stats
- Go to **Stats** tab
- Select your task
- View your streak and calendar!

## Customization Tips

### Change App Colors
Edit [NonZeroBadge.swift](NonZero/Views/Components/NonZeroBadge.swift) line 13:
```swift
.fill(isNonZero ? Color.blue : Color.gray.opacity(0.3))  // Try .blue, .orange, .purple
```

### Adjust Quick Action Buttons
Edit [TodayView.swift](NonZero/Views/Today/TodayView.swift) lines 135, 145:
```swift
// For count tasks - change these values:
ForEach([1.0, 5.0, 10.0], id: \.self)  // Try [1, 3, 5] or [5, 10, 25]

// For time tasks - change these minutes:
ForEach([5.0, 15.0, 30.0], id: \.self)  // Try [10, 20, 60]
```

### Add App Icon
1. Design a 1024x1024 PNG icon
2. Open `Assets.xcassets`
3. Click `AppIcon`
4. Drag your icon into the slot

## Running on Your iPhone

1. Connect iPhone via cable
2. Trust computer on iPhone
3. Select your iPhone from scheme picker
4. If you get signing errors:
   - Go to **Signing & Capabilities** tab
   - Select **Team** (your Apple ID)
   - Xcode will generate a free provisioning profile
5. Press **Cmd + R**

## Need Help?

- Check [README.md](README.md) for architecture details
- Review code comments in key files
- Join iOS development communities on Reddit/Discord

---

Happy building! 🚀
