# Dynamic App Icon Setup Guide

## Overview
The app now changes its icon automatically based on daily task completion:
- **0-19% complete**: Shows "0" icon (default)
- **20-100% complete**: Shows "non-zero" icon

## Setup Steps

### 1. Create Icon Assets

You need to create two sets of app icons:

#### Default Icon (Zero Icon)
- Shows "0" or indicates no tasks completed
- This will be your primary app icon

#### Non-Zero Icon (Active Icon)
- Shows a different visual to indicate tasks are being completed
- Could show a checkmark, number, or different color variation

**Icon Sizes Required (for each set):**
- 180x180 pixels (iPhone @3x)
- 120x120 pixels (iPhone @2x)
- 60x60 pixels (iPhone @1x)

**Recommended Design:**
- Default: Blue/gray icon with "0" badge or dimmed appearance
- Non-Zero: Bright green icon with checkmark or energetic appearance

### 2. Add Icons to Xcode Project

1. **Create a new folder in your project:**
   - Right-click on `NonZero` folder in Xcode
   - Select "New Group"
   - Name it "AppIcons"

2. **Add the alternate icon files:**
   - Drag your non-zero icon images into the `AppIcons` folder
   - **IMPORTANT**: Do NOT add them to an asset catalog
   - Name them exactly:
     - `AppIconNonZero@2x.png` (120x120)
     - `AppIconNonZero@3x.png` (180x180)
   - Make sure "Copy items if needed" is checked
   - Make sure "NonZeroDays" target is selected

### 3. Configure Info.plist

Add the following to your `Info.plist` file:

1. Open `NonZeroDays/Info.plist` (or edit it as source code)
2. Add this configuration:

```xml
<key>CFBundleIcons</key>
<dict>
    <key>CFBundleAlternateIcons</key>
    <dict>
        <key>AppIconNonZero</key>
        <dict>
            <key>CFBundleIconFiles</key>
            <array>
                <string>AppIconNonZero</string>
            </array>
            <key>UIPrerenderedIcon</key>
            <false/>
        </dict>
    </dict>
    <key>CFBundlePrimaryIcon</key>
    <dict>
        <key>CFBundleIconFiles</key>
        <array>
            <string>AppIcon</string>
        </array>
    </dict>
</dict>
```

**Or using Xcode's property list editor:**
1. Right-click on `Info.plist` → Open As → Source Code
2. Add the XML above before the closing `</dict></plist>` tags
3. Save the file

### 4. Update Privacy Description (Required)

The app icon change triggers a system alert the first time. You should add a description:

In `Info.plist`, add:
```xml
<key>NSIconChangePermission</key>
<string>NonZero updates its app icon based on your daily progress to keep you motivated!</string>
```

### 5. Build and Test

1. Build and run the app on a real device (Simulator might not show icon changes)
2. Create a few tasks
3. Complete 0 tasks → Should show default "0" icon
4. Complete 20% or more tasks → Icon should change to "non-zero" icon

**Note:** The first time the icon changes, iOS will show an alert to the user. This is normal behavior and only happens once.

## Customization

### Change the Threshold

In `AppIconManager.swift`, modify the threshold value:

```swift
let threshold = 0.2 // Change to 0.5 for 50%, 0.1 for 10%, etc.
```

### Add More Icon Variations

You can add multiple icon variations (e.g., 0%, 25%, 50%, 75%, 100%):

1. Create additional icon sets with names like:
   - `AppIcon25`
   - `AppIcon50`
   - `AppIcon75`
   - `AppIcon100`

2. Add them to `Info.plist` under `CFBundleAlternateIcons`

3. Update `AppIconManager.updateIcon()` logic:

```swift
func updateIcon(completionPercentage: Double) {
    let targetIcon: String?

    switch completionPercentage {
    case 0..<0.25:
        targetIcon = nil // Default (0%)
    case 0.25..<0.50:
        targetIcon = "AppIcon25"
    case 0.50..<0.75:
        targetIcon = "AppIcon50"
    case 0.75..<1.0:
        targetIcon = "AppIcon75"
    default:
        targetIcon = "AppIcon100"
    }

    if UIApplication.shared.alternateIconName != targetIcon {
        changeIcon(to: targetIcon)
    }
}
```

## Troubleshooting

**Icon not changing:**
- Make sure you're testing on a real device (not simulator)
- Check that icon files are added to the target
- Verify Info.plist configuration is correct
- Check console for error messages

**Build errors:**
- Ensure icon filenames match exactly (case-sensitive)
- Verify icons are in the correct size (use `sips -g pixelWidth -g pixelHeight filename.png` in Terminal to check)

**Icon changes but looks wrong:**
- iOS caches app icons - delete and reinstall the app
- Make sure you're using PNG format
- Ensure transparency is handled correctly (iOS adds rounded corners automatically)

## Design Resources

**Icon Design Tools:**
- [Figma](https://figma.com) - Free design tool
- [Sketch](https://sketch.com) - Mac app design
- [Canva](https://canva.com) - Online design with templates

**iOS Icon Templates:**
- Search for "iOS app icon template" to find PSD/Sketch templates
- Apple's Human Interface Guidelines for iOS icons

**Color Suggestions:**
- Default (0%): `#8E8E93` (gray) or `#007AFF` (blue) dimmed
- Non-Zero: `#34C759` (green) or `#FF9500` (orange) for energy
