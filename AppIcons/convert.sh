#!/bin/bash

# NonZero App Icons - SVG to PNG Converter
# This script converts the SVG icons to PNG format at required sizes for iOS

echo "🎨 Converting NonZero App Icons..."
echo ""

# Check if we're in the right directory
if [ ! -f "AppIconZero.svg" ] || [ ! -f "AppIconNonZero.svg" ]; then
    echo "❌ Error: SVG files not found. Please run this script from the AppIcons directory."
    exit 1
fi

# Function to convert SVG to PNG using available tools
convert_svg() {
    local input=$1
    local output=$2
    local size=$3

    # Try qlmanage (built into macOS)
    if command -v qlmanage &> /dev/null; then
        # Create a temp directory for qlmanage output
        temp_dir=$(mktemp -d)
        qlmanage -t -s $size -o "$temp_dir" "$input" &> /dev/null

        # Find the generated PNG and move it
        generated_png=$(find "$temp_dir" -name "*.png" | head -n 1)
        if [ -n "$generated_png" ]; then
            # Use sips to resize to exact dimensions (qlmanage might not be exact)
            sips -z $size $size "$generated_png" --out "$output" &> /dev/null
            rm -rf "$temp_dir"
            return 0
        fi
        rm -rf "$temp_dir"
    fi

    # Try rsvg-convert (can be installed via Homebrew: brew install librsvg)
    if command -v rsvg-convert &> /dev/null; then
        rsvg-convert -w $size -h $size "$input" -o "$output"
        return 0
    fi

    # Try ImageMagick convert (can be installed via Homebrew: brew install imagemagick)
    if command -v convert &> /dev/null; then
        convert -background none -resize ${size}x${size} "$input" "$output"
        return 0
    fi

    # Try Inkscape (can be installed via Homebrew: brew install inkscape)
    if command -v inkscape &> /dev/null; then
        inkscape -w $size -h $size "$input" -o "$output" &> /dev/null
        return 0
    fi

    return 1
}

# Convert Zero Icon (Default - will be in Assets.xcassets)
echo "Converting Zero Icon (Default)..."
# We'll keep this as reference, but the default icon should be in Assets.xcassets
convert_svg "AppIconZero.svg" "AppIconZero@2x.png" 120
convert_svg "AppIconZero.svg" "AppIconZero@3x.png" 180

# Convert Non-Zero Icon (Alternate)
echo "Converting Non-Zero Icon (Alternate)..."
convert_svg "AppIconNonZero.svg" "AppIconNonZero@2x.png" 120
convert_svg "AppIconNonZero.svg" "AppIconNonZero@3x.png" 180

# Check if any conversion worked
if [ -f "AppIconNonZero@2x.png" ]; then
    echo ""
    echo "✅ Conversion successful!"
    echo ""
    echo "Generated files:"
    ls -lh *.png 2>/dev/null | awk '{print "   " $9 " (" $5 ")"}'
    echo ""
    echo "📋 Next steps:"
    echo "   1. Add AppIconNonZero@2x.png and AppIconNonZero@3x.png to your Xcode project"
    echo "   2. Make sure they are NOT in an Asset Catalog"
    echo "   3. Add them to the NonZeroDays target"
    echo "   4. Update Info.plist with alternate icons configuration"
    echo "   5. For the default icon, update your AppIcon in Assets.xcassets with AppIconZero.svg"
    echo ""
    echo "📖 See DYNAMIC_ICON_SETUP.md for detailed instructions"
else
    echo ""
    echo "⚠️  Automatic conversion failed. You can manually convert the SVG files:"
    echo ""
    echo "Option 1: Use an online converter"
    echo "   • Open https://cloudconvert.com/svg-to-png"
    echo "   • Upload AppIconNonZero.svg"
    echo "   • Set size to 120x120, download as AppIconNonZero@2x.png"
    echo "   • Set size to 180x180, download as AppIconNonZero@3x.png"
    echo ""
    echo "Option 2: Install conversion tools"
    echo "   • brew install librsvg"
    echo "   • Then run this script again"
    echo ""
    echo "Option 3: Use design software"
    echo "   • Open the SVG in Sketch, Figma, or Illustrator"
    echo "   • Export as PNG at 120x120 and 180x180"
fi

echo ""
