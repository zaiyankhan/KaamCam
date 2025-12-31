#!/bin/bash

# KaamCam Cordova Build Script
# This script builds the web app and prepares it for Cordova

set -e

echo "==================================="
echo "KaamCam Cordova Build Script"
echo "==================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
WEB_PROJECT_DIR="$(dirname "$0")/.."
CORDOVA_DIR="${WEB_PROJECT_DIR}/kaamcam-mobile"
WWW_DIR="${CORDOVA_DIR}/www"

# Check if Cordova project exists
if [ ! -d "$CORDOVA_DIR" ]; then
    echo -e "${YELLOW}Cordova project not found. Creating...${NC}"
    
    cd "$WEB_PROJECT_DIR"
    cordova create kaamcam-mobile com.kaamcam.app KaamCam
    
    cd "$CORDOVA_DIR"
    
    # Copy config.xml
    cp "${WEB_PROJECT_DIR}/cordova-template/config.xml" ./config.xml
    
    # Add platforms
    echo -e "${YELLOW}Adding Android platform...${NC}"
    cordova platform add android
    
    # Install plugins
    echo -e "${YELLOW}Installing plugins...${NC}"
    cordova plugin add cordova-plugin-device
    cordova plugin add cordova-plugin-camera
    cordova plugin add cordova-plugin-geolocation
    cordova plugin add cordova-plugin-file
    cordova plugin add cordova-plugin-network-information
    cordova plugin add cordova-plugin-statusbar
    cordova plugin add cordova-plugin-splashscreen
    cordova plugin add cordova-plugin-media-capture
    cordova plugin add cordova-plugin-inappbrowser
    cordova plugin add cordova-plugin-whitelist
    
    echo -e "${GREEN}Cordova project created successfully!${NC}"
fi

# Build web app
echo -e "${YELLOW}Building web app...${NC}"
cd "$WEB_PROJECT_DIR"
npm run build

# Clear www directory
echo -e "${YELLOW}Preparing www directory...${NC}"
rm -rf "$WWW_DIR"/*

# Copy built files
echo -e "${YELLOW}Copying built files...${NC}"
cp -r dist/public/* "$WWW_DIR/"

# Update index.html for Cordova
echo -e "${YELLOW}Updating index.html for Cordova...${NC}"
cat > "$WWW_DIR/cordova-init.js" << 'EOF'
// Cordova initialization
document.addEventListener('deviceready', function() {
    console.log('Cordova device ready');
    
    // Set status bar
    if (window.StatusBar) {
        StatusBar.backgroundColorByHexString('#10B981');
        StatusBar.styleLightContent();
    }
    
    // Dispatch custom event for React app
    document.dispatchEvent(new CustomEvent('cordovaReady'));
}, false);
EOF

# Add cordova.js reference to index.html if not present
if ! grep -q "cordova.js" "$WWW_DIR/index.html"; then
    sed -i 's/<head>/<head>\n    <script src="cordova.js"><\/script>\n    <script src="cordova-init.js"><\/script>/' "$WWW_DIR/index.html"
fi

# Build Android
echo -e "${YELLOW}Building Android APK...${NC}"
cd "$CORDOVA_DIR"
cordova build android

echo ""
echo -e "${GREEN}==================================="
echo "Build Complete!"
echo "===================================${NC}"
echo ""
echo "Debug APK location:"
echo "${CORDOVA_DIR}/platforms/android/app/build/outputs/apk/debug/app-debug.apk"
echo ""
echo "To build release APK:"
echo "  cd ${CORDOVA_DIR}"
echo "  cordova build android --release"
echo ""
echo "To run on device:"
echo "  cordova run android --device"
