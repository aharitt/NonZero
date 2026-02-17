# Live Activity Setup Checklist

Follow these steps in order to get timer Live Activities working on your lock screen.

## ✅ Checklist

### Step 1: Open Xcode
```bash
open /Users/lewislee/Library/CloudStorage/OneDrive-Personal/Projects/NonZero/NonZero.xcodeproj
```

### Step 2: Create Widget Extension Target
- [ ] File → New → Target
- [ ] Select **Widget Extension**
- [ ] Product Name: `NonZeroWidgets`
- [ ] ✅ **Check** "Include Live Activity"
- [ ] ❌ **Uncheck** "Include Configuration Intent"
- [ ] Click **Finish**
- [ ] Click **Activate** when prompted

### Step 3: Clean Up Auto-Generated Files
Delete these 3 files from NonZeroWidgets folder:
- [ ] NonZeroWidgets.swift (delete)
- [ ] NonZeroWidgetsLiveActivity.swift (delete)
- [ ] NonZeroWidgetsBundle.swift (delete)

### Step 4: Add Our Custom Files
- [ ] Right-click NonZeroWidgets folder
- [ ] Add Files to "NonZero"
- [ ] Navigate to Widgets folder
- [ ] Select: `NonZeroWidgets.swift` and `TimerLiveActivity_Simple.swift`
- [ ] **Target Membership**: Only NonZeroWidgets checked
- [ ] Click Add

### Step 5: Share TimerActivityAttributes
- [ ] Find `TimerActivityAttributes.swift` in project (Data folder)
- [ ] File Inspector → Target Membership
- [ ] ✅ Check **NonZero**
- [ ] ✅ Check **NonZeroWidgets**

### Step 6: Configure Bundle ID
- [ ] Select NonZeroWidgets target
- [ ] Signing & Capabilities tab
- [ ] Set Bundle Identifier to: `[your-main-bundle-id].NonZeroWidgets`
  - Example: If main is `com.lewislee.NonZero`, use `com.lewislee.NonZero.NonZeroWidgets`

### Step 7: Match Version Numbers
- [ ] NonZeroWidgets target → General tab
- [ ] Set Version: `27`
- [ ] Set Build: `27`

### Step 8: Build and Test
- [ ] Select **NonZero** scheme (top bar)
- [ ] Build (Cmd+B)
- [ ] Run on **real device** (iOS 17+)
- [ ] Start a timer in the app
- [ ] Lock your device
- [ ] Check lock screen for timer display

## 🔍 Verification

After setup, verify:
1. NonZeroWidgets target exists in project
2. TimerActivityAttributes.swift has both targets checked
3. Bundle ID follows naming pattern
4. Version/build numbers match

## 🧪 Test on Real Device

**Important**: Live Activities work poorly on Simulator. Test on:
- iPhone with iOS 17.0 or later
- Real physical device, not simulator

## 📝 If It Still Doesn't Work

Check Console logs while running:
1. Xcode → Window → Devices and Simulators
2. Select your device
3. Click "Open Console"
4. Filter for "Live Activity" or "ActivityKit"
5. Look for error messages

## 🎯 Expected Result

When you start a timer and lock your device, you should see:

**Lock Screen:**
```
⏱️  [Task Name]
🕐 0:05
🛑 Tap to stop
```

**Dynamic Island** (iPhone 14 Pro+):
- Compact: Timer icon + elapsed time
- Expanded: Full task name + large timer

## 💡 Troubleshooting

**Memory issues**: We're using the simplified version (TimerLiveActivity_Simple) which uses less memory.

**Still not appearing**: Make sure:
- NSSupportsLiveActivities = YES in Info.plist ✅ (already set)
- Testing on real device, not simulator
- Live Activities enabled in Settings → NonZero (check first launch)
- Console shows "Live Activity started for task: [name]"

**Build errors**:
- Clean build folder: Product → Clean Build Folder
- Restart Xcode
- Check both targets have iOS 17.0+ deployment target
