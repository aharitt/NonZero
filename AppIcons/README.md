# NonZero App Icons

Dynamic app icons that change based on your daily task completion!

## 📱 Icon Designs

### 😔 Zero Icon (Default)
- **Appearance:** Sad face with gloomy gray-blue colors (#6B7280)
- **Badge:** "0" at the bottom
- **When shown:** 0-19% of daily tasks completed
- **Purpose:** Motivates you to start completing tasks

### 😊 Non-Zero Icon
- **Appearance:** Happy smiling face with bright green (#34C759)
- **Badge:** Checkmark at the bottom
- **When shown:** 20%+ of daily tasks completed
- **Purpose:** Celebrates your progress and keeps you motivated

## 🎨 Preview

Open [preview.html](preview.html) in your browser to see both icons at different sizes!

```bash
open preview.html
```

## 🔄 Converting SVG to PNG

Run the conversion script to generate PNG files:

```bash
./convert.sh
```

This will create:
- `AppIconNonZero@2x.png` (120×120)
- `AppIconNonZero@3x.png` (180×180)
- `AppIconZero@2x.png` (120×120) - for reference
- `AppIconZero@3x.png` (180×180) - for reference

## 📦 Setup in Xcode

### Step 1: Add Default Icon (Zero Icon)
1. Open your Xcode project
2. Go to Assets.xcassets → AppIcon
3. Drag `AppIconZero.svg` or use the generated PNGs
4. Fill in all required sizes

### Step 2: Add Alternate Icon (Non-Zero Icon)
1. Drag `AppIconNonZero@2x.png` and `AppIconNonZero@3x.png` into your project
2. **IMPORTANT:** Do NOT add to Asset Catalog
3. Add to file system under your project folder
4. Make sure "NonZeroDays" target is checked

### Step 3: Configure Info.plist
See [DYNAMIC_ICON_SETUP.md](../DYNAMIC_ICON_SETUP.md) for Info.plist configuration

## 🛠️ Manual Conversion (If Script Fails)

### Option 1: Online Converter
1. Go to https://cloudconvert.com/svg-to-png
2. Upload `AppIconNonZero.svg`
3. Convert to 120×120 → save as `AppIconNonZero@2x.png`
4. Convert to 180×180 → save as `AppIconNonZero@3x.png`

### Option 2: Install librsvg
```bash
brew install librsvg
./convert.sh
```

### Option 3: Use Design Software
- Open SVG in Sketch, Figma, Illustrator, or Affinity Designer
- Export as PNG at 120×120 and 180×180 pixels

## 🎯 Design Specifications

**Colors:**
- Zero Icon: `#6B7280` (gray-blue), `#4B5563` (darker)
- Non-Zero Icon: `#34C759` (iOS green), `#52D97C` (lighter green)

**Features:**
- 1024×1024 base resolution (scales down cleanly)
- 180px corner radius for iOS rounded corners
- Bold, simple features for small size clarity
- Emoji-style faces for universal appeal

**iOS Icon Sizes:**
- @1x: 60×60 (older devices)
- @2x: 120×120 (iPhone)
- @3x: 180×180 (iPhone Pro, Plus)

## 📝 Customization

Want to modify the icons?

1. Edit the SVG files directly (they're just XML text)
2. Or open them in any vector editor
3. Keep the same size (1024×1024) for best quality
4. Re-run `./convert.sh` after changes

**Common modifications:**
- Change colors: Edit the `fill="#..."` attributes
- Adjust face: Modify the `<path>` elements
- Change badge: Edit the text or checkmark elements

## 🎨 Design Tips

**For sad icon:**
- Darker, muted colors
- Downturned mouth
- Heavy, droopy eyes
- Minimal highlights

**For happy icon:**
- Bright, saturated colors
- Upturned smile
- Sparkly eyes or highlights
- Light effects (sparkles, gradients)

Enjoy your dynamic app icons! 🚀
