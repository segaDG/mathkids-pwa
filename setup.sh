#!/bin/bash
set -e

echo "========================================"
echo "  MathKids - Setup & Build Script"
echo "========================================"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check prerequisites
echo ""
echo "${YELLOW}[1/7] Checking prerequisites...${NC}"

if ! command -v node &> /dev/null; then
    echo "${RED}Node.js not found! Install it first:${NC}"
    echo "  brew install node"
    echo "  OR download from https://nodejs.org/"
    exit 1
fi
echo "  Node.js: $(node -v)"
echo "  npm: $(npm -v)"

if ! command -v java &> /dev/null; then
    echo "${YELLOW}  WARNING: Java not found. Needed for Android builds.${NC}"
    echo "  Install: brew install --cask temurin"
fi

# Install dependencies
echo ""
echo "${YELLOW}[2/7] Installing npm dependencies...${NC}"
npm install

# Initialize Capacitor (if not already done)
echo ""
echo "${YELLOW}[3/7] Initializing Capacitor...${NC}"
if [ ! -f "node_modules/@capacitor/cli/bin/capacitor" ]; then
    echo "  Capacitor CLI not found after install, retrying..."
    npm install
fi

# Add Android platform
echo ""
echo "${YELLOW}[4/7] Adding Android platform...${NC}"
if [ ! -d "android" ]; then
    npx cap add android
    echo "${GREEN}  Android platform added!${NC}"
else
    echo "  Android platform already exists"
fi

# Copy Android icons to proper resource directories
echo ""
echo "${YELLOW}[5/7] Setting up Android resources...${NC}"

ANDROID_RES="android/app/src/main/res"
if [ -d "$ANDROID_RES" ]; then
    # Create mipmap directories
    for density in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
        mkdir -p "$ANDROID_RES/mipmap-$density"
    done

    # Copy and resize icons
    if command -v sips &> /dev/null; then
        sips -z 48 48 www/icons/icon-512x512.png --out "$ANDROID_RES/mipmap-mdpi/ic_launcher.png" 2>/dev/null
        sips -z 72 72 www/icons/icon-512x512.png --out "$ANDROID_RES/mipmap-hdpi/ic_launcher.png" 2>/dev/null
        sips -z 96 96 www/icons/icon-512x512.png --out "$ANDROID_RES/mipmap-xhdpi/ic_launcher.png" 2>/dev/null
        sips -z 144 144 www/icons/icon-512x512.png --out "$ANDROID_RES/mipmap-xxhdpi/ic_launcher.png" 2>/dev/null
        sips -z 192 192 www/icons/icon-512x512.png --out "$ANDROID_RES/mipmap-xxxhdpi/ic_launcher.png" 2>/dev/null

        # Round icons (same as regular for now)
        for density in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
            cp "$ANDROID_RES/mipmap-$density/ic_launcher.png" "$ANDROID_RES/mipmap-$density/ic_launcher_round.png"
        done

        # Foreground icons for adaptive icons
        for density in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
            cp "$ANDROID_RES/mipmap-$density/ic_launcher.png" "$ANDROID_RES/mipmap-$density/ic_launcher_foreground.png"
        done

        echo "${GREEN}  Android icons configured!${NC}"
    else
        echo "${YELLOW}  sips not available, copy icons manually${NC}"
    fi

    # Update strings.xml with app name
    STRINGS_FILE="$ANDROID_RES/values/strings.xml"
    if [ -f "$STRINGS_FILE" ]; then
        sed -i '' 's|<string name="app_name">.*</string>|<string name="app_name">MathKids</string>|' "$STRINGS_FILE"
        sed -i '' 's|<string name="title_activity_main">.*</string>|<string name="title_activity_main">MathKids</string>|' "$STRINGS_FILE"
        echo "${GREEN}  App name updated in strings.xml${NC}"
    fi

    # Update colors.xml for splash screen
    COLORS_FILE="$ANDROID_RES/values/colors.xml"
    if [ -f "$COLORS_FILE" ]; then
        # Backup original
        cp "$COLORS_FILE" "${COLORS_FILE}.bak"
        cat > "$COLORS_FILE" << 'COLORSEOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="colorPrimary">#6D28D9</color>
    <color name="colorPrimaryDark">#1a1a2e</color>
    <color name="colorAccent">#FFD700</color>
</resources>
COLORSEOF
        echo "${GREEN}  Colors updated!${NC}"
    fi
fi

# Sync web app to Android
echo ""
echo "${YELLOW}[6/7] Syncing web app to Android...${NC}"
npx cap sync android

# Done
echo ""
echo "${YELLOW}[7/7] Setup complete!${NC}"
echo ""
echo "========================================"
echo "${GREEN}  MathKids is ready!${NC}"
echo "========================================"
echo ""
echo "Next steps:"
echo ""
echo "  ${GREEN}1. Test PWA locally:${NC}"
echo "     npx serve www"
echo "     Open http://localhost:3000"
echo ""
echo "  ${GREEN}2. Open in Android Studio:${NC}"
echo "     npx cap open android"
echo ""
echo "  ${GREEN}3. Build debug APK:${NC}"
echo "     cd android && ./gradlew assembleDebug"
echo "     APK: android/app/build/outputs/apk/debug/app-debug.apk"
echo ""
echo "  ${GREEN}4. Build release AAB (for Play Store):${NC}"
echo "     See BUILD_GUIDE.md for signing and release steps"
echo ""
