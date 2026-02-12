# HealthKit Integration Setup Guide

NonZero can now sync exercise time directly from the Fitness app using HealthKit!

## Prerequisites

- iOS 17.0+
- Xcode 26.2+
- Real device (HealthKit doesn't work in simulator)

## Setup Steps

### Step 1: Enable HealthKit Capability in Xcode

1. Open your **NonZero.xcodeproj** in Xcode
2. Select your project in the navigator (blue icon)
3. Select the **NonZero** target
4. Go to **Signing & Capabilities** tab
5. Click the **+ Capability** button
6. Search for and add **HealthKit**

### Step 2: Add Privacy Description

1. In the project navigator, find and select **Info.plist**
   - If you don't see Info.plist, go to **Info** tab in target settings
2. Add a new row with:
   - **Key**: `Privacy - Health Share Usage Description`
   - **Type**: String
   - **Value**: `NonZero needs access to your workout data to automatically track exercise time.`

3. Add another row with:
   - **Key**: `Privacy - Health Update Usage Description`
   - **Type**: String
   - **Value**: `NonZero needs to read your workout data.`

### Step 3: Build and Run

1. Connect your **real iPhone** (HealthKit doesn't work in simulator)
2. Build and run (`Cmd + R`)
3. When you enable HealthKit for a task, iOS will prompt for permission

---

## How to Use HealthKit Integration

### 1. Create a Time-Based Task with HealthKit

1. Go to **Tasks** tab → Tap **+**
2. Name: "Running" (or any exercise)
3. Type: **Time**
4. Set minimum and goal
5. **Toggle "Sync from Fitness app"** ✓
6. Select workout type (e.g., "Running")
7. Save

### 2. Sync Your Workout Data

**Option A: Manual Sync**
- Go to **Today** tab
- Tap the **heart sync button** (top right)
- NonZero will fetch today's workout data from Fitness app

**Option B: Pull to Refresh**
- Go to **Today** tab
- Pull down to refresh
- HealthKit data syncs automatically

### 3. What Gets Synced

- ✅ Workout duration (in minutes)
- ✅ Specific workout type (Running, Cycling, etc.)
- ✅ All workouts (if you select "All Workouts")
- ✅ Only today's data
- ✅ Auto-creates entry if none exists
- ✅ Updates existing entry if HealthKit has more time

---

## Supported Workout Types

NonZero supports these Fitness app workout types:

- Running
- Walking
- Cycling
- Swimming
- Yoga
- Strength Training
- HIIT
- Dance
- Hiking
- Elliptical
- Rowing
- Stairs
- Functional Training
- Cross Training
- Other

You can also select **"All Workouts"** to sync total exercise time regardless of type.

---

## Example Use Cases

### Use Case 1: Track Running
1. Create task "Running" with HealthKit sync
2. Select "Running" workout type
3. Go for a run and track it in Fitness app
4. Open NonZero → Tap sync button
5. Your run time appears automatically! 🎉

### Use Case 2: Track Total Exercise
1. Create task "Exercise" with HealthKit sync
2. Select "All Workouts"
3. Do any workout in Fitness app
4. Sync in NonZero
5. All workout time counts toward your goal!

### Use Case 3: Morning Yoga
1. Create task "Morning Yoga" with HealthKit
2. Select "Yoga" workout type
3. Do yoga and track in Fitness app
4. Auto-sync when you open NonZero

---

## Troubleshooting

### ❌ "HealthKit is not available"
**Fix**: You're on simulator. Use a real iPhone.

### ❌ Sync button doesn't appear
**Fix**:
1. Make sure you created a Time task with HealthKit enabled
2. Check HealthKit capability is added in Xcode

### ❌ Permission denied
**Fix**:
1. Go to iPhone **Settings** → **Privacy & Security** → **Health**
2. Find **NonZero**
3. Enable **Workouts** permission

### ❌ No data synced
**Fix**:
1. Make sure you have workouts in Fitness app for today
2. Check the workout type matches (or use "All Workouts")
3. Check you granted HealthKit permission

### ❌ Build errors about HealthKit
**Fix**:
1. Make sure HealthKit capability is added in Xcode
2. Clean build folder (`Cmd + Shift + K`)
3. Rebuild (`Cmd + R`)

---

## Technical Details

### How It Works

1. **Permission**: On first use, iOS prompts for HealthKit access
2. **Data Fetch**: Queries all workouts for today
3. **Filtering**: Filters by workout type if specified
4. **Calculation**: Sums workout duration in minutes
5. **Update**: Creates or updates entry with synced time

### Privacy & Security

- ✅ Data stays on your device (HealthKit is local)
- ✅ No data sent to cloud
- ✅ You control permissions
- ✅ Can revoke access anytime in Settings
- ✅ Only reads workout duration, nothing else

### Performance

- Fast: Queries only today's data
- Efficient: Uses HealthKit's native query API
- Battery-friendly: No background syncing
- Manual control: You trigger sync when needed

---

## Advanced Features

### Multiple HealthKit Tasks

You can create multiple tasks that sync different workout types:

- Task 1: "Running" → Syncs Running workouts
- Task 2: "Cycling" → Syncs Cycling workouts
- Task 3: "Total Exercise" → Syncs All workouts

### Combining Manual + HealthKit

HealthKit sync only **updates** if it has more time:
- Manual entry: 30 min
- HealthKit sync: 45 min → Updates to 45 min
- HealthKit sync: 20 min → Keeps 30 min (doesn't decrease)

This prevents losing manually-entered time!

---

## Notes

- HealthKit only works on **real devices** (not simulator)
- Sync is **manual** (tap button or pull to refresh)
- Only syncs **today's** workout data
- Entries created by HealthKit have note: "Synced from Fitness app"
- Original implementation of NonZero works fine without HealthKit

---

**Enjoy automatic workout tracking! 🏃‍♂️💪🧘‍♀️**
