#!/bin/bash
# KaamCam Icon Generator Script
# Requires ImageMagick: brew install imagemagick (macOS) or apt install imagemagick (Linux)

SOURCE_ICON="res/icon-source.png"

if [ ! -f "$SOURCE_ICON" ]; then
    echo "Error: Source icon not found at $SOURCE_ICON"
    echo "Please place your 1024x1024 icon at res/icon-source.png"
    exit 1
fi

echo "Generating Android icons..."
# Android icons
convert "$SOURCE_ICON" -resize 36x36 res/android/icon-ldpi.png
convert "$SOURCE_ICON" -resize 48x48 res/android/icon-mdpi.png
convert "$SOURCE_ICON" -resize 72x72 res/android/icon-hdpi.png
convert "$SOURCE_ICON" -resize 96x96 res/android/icon-xhdpi.png
convert "$SOURCE_ICON" -resize 144x144 res/android/icon-xxhdpi.png
convert "$SOURCE_ICON" -resize 192x192 res/android/icon-xxxhdpi.png

# Android adaptive icons (foreground)
convert "$SOURCE_ICON" -resize 81x81 res/android/icon-ldpi-foreground.png
convert "$SOURCE_ICON" -resize 108x108 res/android/icon-mdpi-foreground.png
convert "$SOURCE_ICON" -resize 162x162 res/android/icon-hdpi-foreground.png
convert "$SOURCE_ICON" -resize 216x216 res/android/icon-xhdpi-foreground.png
convert "$SOURCE_ICON" -resize 324x324 res/android/icon-xxhdpi-foreground.png
convert "$SOURCE_ICON" -resize 432x432 res/android/icon-xxxhdpi-foreground.png

echo "Generating iOS icons..."
# iOS icons
convert "$SOURCE_ICON" -resize 20x20 res/ios/icon-20.png
convert "$SOURCE_ICON" -resize 40x40 res/ios/icon-20@2x.png
convert "$SOURCE_ICON" -resize 60x60 res/ios/icon-20@3x.png
convert "$SOURCE_ICON" -resize 29x29 res/ios/icon-29.png
convert "$SOURCE_ICON" -resize 58x58 res/ios/icon-29@2x.png
convert "$SOURCE_ICON" -resize 87x87 res/ios/icon-29@3x.png
convert "$SOURCE_ICON" -resize 40x40 res/ios/icon-40.png
convert "$SOURCE_ICON" -resize 80x80 res/ios/icon-40@2x.png
convert "$SOURCE_ICON" -resize 120x120 res/ios/icon-40@3x.png
convert "$SOURCE_ICON" -resize 120x120 res/ios/icon-60@2x.png
convert "$SOURCE_ICON" -resize 180x180 res/ios/icon-60@3x.png
convert "$SOURCE_ICON" -resize 76x76 res/ios/icon-76.png
convert "$SOURCE_ICON" -resize 152x152 res/ios/icon-76@2x.png
convert "$SOURCE_ICON" -resize 167x167 res/ios/icon-83.5@2x.png
convert "$SOURCE_ICON" -resize 1024x1024 res/ios/icon-1024.png

echo "Generating splash screens..."
# Android splash screens (emerald green background with centered logo)
generate_splash() {
    local width=$1
    local height=$2
    local output=$3
    local logo_size=$(( width < height ? width / 3 : height / 3 ))
    
    convert -size ${width}x${height} xc:'#10B981' \
        \( "$SOURCE_ICON" -resize ${logo_size}x${logo_size} \) \
        -gravity center -composite "$output"
}

# Android portrait splashes
generate_splash 240 320 res/android/screen-ldpi-portrait.png
generate_splash 320 480 res/android/screen-mdpi-portrait.png
generate_splash 480 800 res/android/screen-hdpi-portrait.png
generate_splash 720 1280 res/android/screen-xhdpi-portrait.png
generate_splash 960 1600 res/android/screen-xxhdpi-portrait.png
generate_splash 1280 1920 res/android/screen-xxxhdpi-portrait.png

# iOS universal splash
generate_splash 2732 2732 res/ios/Default@2x~universal~anyany.png

echo "All icons and splash screens generated successfully!"
echo ""
echo "Generated files:"
echo "  - Android icons: res/android/icon-*.png"
echo "  - iOS icons: res/ios/icon-*.png"
echo "  - Android splashes: res/android/screen-*.png"
echo "  - iOS splash: res/ios/Default@2x~universal~anyany.png"
