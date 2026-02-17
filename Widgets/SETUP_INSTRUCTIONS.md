# Live Activity Setup Instructions

## Overview
This guide will help you add Live Activities to NonZero, enabling timer display on the lock screen and Dynamic Island.

## Step 1: Enable Live Activities in Main App

1. Open **NonZeroDays.xcodeproj** in Xcode
2. Select the **NonZeroDays** target (main app)
3. Go to **Info** tab
4. Add a new entry:
   - **Key**: `NSSupportsLiveActivities`
   - **Type**: Boolean
   - **Value**: YES

## Step 2: Create Widget Extension Target

1. In Xcode, go to **File → New → Target**
2. Select **Widget Extension**
3. Configuration:
   - **Product Name**: `NonZeroWidgets`
   - **Include Live Activity**: ✅ **Check this box**
   - **Include Configuration Intent**: ❌ Leave unchecked
4. Click **Finish**
5. When asked "Activate 'NonZeroWidgets' scheme?", click **Activate**

## Step 3: Add Files to Widget Extension

1. **Delete** the auto-generated files:
   - `NonZeroWidgets.swift` (we have a custom one)
   - `NonZeroWidgetsLiveActivity.swift` (we have a custom one)
   - `NonZeroWidgetsBundle.swift` (we have a custom one)

2. **Add** our custom widget files:
   - Right-click **NonZeroWidgets** folder in Xcode
   - Select **Add Files to "NonZeroDays"**
   - Navigate to `/Widgets/` folder
   - Select:
     - `NonZeroWidgets.swift`
     - `TimerLiveActivity.swift`
   - **Target Membership**: Check **NonZeroWidgets** only
   - Click **Add**

## Step 4: Share Activity Attributes

The `TimerActivityAttributes.swift` file needs to be accessible by both the main app and the widget.

1. Select `TimerActivityAttributes.swift` in Xcode
2. In the **File Inspector** (right panel), check **Target Membership** for:
   - ✅ **NonZeroDays** (main app)
   - ✅ **NonZeroWidgets** (widget extension)

## Step 5: Configure Widget Extension Capabilities

1. Select **NonZeroWidgets** target
2. Go to **Signing & Capabilities** tab
3. Ensure the following:
   - **Team**: Same as main app
   - **Bundle Identifier**: `com.yourteam.NonZeroDays.NonZeroWidgets`
   - **iOS Deployment Target**: 17.0 or later

## Step 6: Update App Group (If Needed)

If you plan to share data between app and widget in the future:

1. Main app target → **Signing & Capabilities**
2. Click **+ Capability** → **App Groups**
3. Add group: `group.com.yourteam.NonZeroDays`
4. Repeat for **NonZeroWidgets** target with same group ID

## Step 7: Build and Test

1. Select **NonZeroDays** scheme (or **NonZeroWidgets** to test widget directly)
2. Build and run on a **real device** (iOS 17.0+)
   - ⚠️ Live Activities don't work in Simulator very well
3. Test the timer:
   - Start a timer for a task
   - Lock your device
   - You should see the timer on the lock screen!
   - On iPhone 14 Pro/15 Pro, it appears in the Dynamic Island

## Troubleshooting

### Live Activity doesn't appear
- Check that `NSSupportsLiveActivities` is set to YES in main app
- Ensure you're testing on a real device (not simulator)
- Check Console logs for any ActivityKit errors

### Build errors
- Make sure `TimerActivityAttributes.swift` is included in both targets
- Verify iOS deployment target is 17.0+ for widget extension
- Clean build folder (Product → Clean Build Folder)

### Activity starts but doesn't update
- Live Activities update automatically based on time
- Make sure you're using `Date()` for startTime, not elapsed seconds

## What You'll See

**Lock Screen:**
```
┌──────────────────────────────────┐
│ ⏱️  Reading                       │
│ 🕐 15:23                          │
│ 🛑 Tap to stop                    │
└──────────────────────────────────┘
```

**Dynamic Island (iPhone 14 Pro+):**
- Compact: Timer icon + elapsed time
- Expanded: Task name, large timer, hint text

## iOS Deployment Target

Make sure **both targets** have:
- **iOS 17.0** or later (for Live Activities support)

## Code Files Summary

- **TimerActivityAttributes.swift**: Shared data model ✅ Created
- **TimerManager.swift**: Updated with Live Activity integration ✅ Updated
- **TodayViewModel.swift**: Passes task name to timer ✅ Updated
- **NonZeroWidgets.swift**: Widget bundle ✅ Created
- **TimerLiveActivity.swift**: Lock screen & Dynamic Island UI ✅ Created
