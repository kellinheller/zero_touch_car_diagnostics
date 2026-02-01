#!/bin/bash
# ZTCD v1.31 Build and Release Script
# Usage: ./build_and_release.sh <your-github-username>

set -e

GITHUB_USERNAME="${1:-mark}"
REPO_NAME="zero_touch_car_diagnostics_vs2"
VERSION="1.31.0"
BUILD_NUMBER="131"

echo "========================================"
echo "ZTCD v${VERSION} Build and Release"
echo "========================================"
echo ""

# 1. Update git remote with correct username
echo "[1/5] Setting up Git remote..."
git remote remove origin 2>/dev/null || true
git remote add origin "https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"
echo "✓ Remote set to: https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"
echo ""

# 2. Build APK (workaround for snap Flutter git issues)
echo "[2/5] Building Android APK..."
echo "Note: Git warnings from Flutter snap are harmless and will be ignored."
echo ""

# Create a wrapper script that ignores git errors
cat > /tmp/flutter_build.sh << 'FLUTTER_SCRIPT'
#!/bin/bash
cd /home/mark/zero_touch_car_diagnostics
export GIT_DIR=""
export GIT_WORK_TREE=""

# Run flutter commands, ignore git warnings
(/snap/bin/flutter pub get 2>&1 | grep -v "fatal: not a git repository" | grep -v "^$" || true) &
PID1=$!

# Wait for pub get
wait $PID1
echo "Dependencies fetched"

# Build APK
/snap/bin/flutter build apk --release --build-name=1.31.0 --build-number=131 2>&1 | grep -v "fatal: not a git repository" | grep -v "^$" || true
FLUTTER_SCRIPT

chmod +x /tmp/flutter_build.sh
bash /tmp/flutter_build.sh

if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
    APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
    echo "✓ APK built successfully: $APK_PATH ($APK_SIZE)"
    
    # Rename APK
    cp "$APK_PATH" "build/ZTCD_v${VERSION}.apk"
    echo "✓ APK copied to: build/ZTCD_v${VERSION}.apk"
else
    echo "✗ APK build failed. Check Flutter installation."
    exit 1
fi
echo ""

# 3. Create release tag
echo "[3/5] Creating git tag v${VERSION}..."
git tag -a "v${VERSION}" -m "ZTCD v${VERSION} Release

Features:
- Gemini 2.5 Pro AI diagnostics
- 50+ OBD-II PIDs with auto-discovery
- Bluetooth keep-alive (no timeouts)
- GPS map with trip logging
- Route analysis with damage scoring
- Phone sensor integration
- Removed Flipper Zero backend (focus on ELM327/USB serial)

Build: ${BUILD_NUMBER}
Platform: Android
" 2>/dev/null || echo "Tag already exists, skipping..."
echo ""

# 4. Push to GitHub
echo "[4/5] Pushing to GitHub..."
echo "You may be prompted for GitHub credentials or need to configure:"
echo "  - Personal Access Token (classic)"
echo "  - Or: gh auth login"
echo ""
git push -u origin main --tags
echo "✓ Pushed to GitHub"
echo ""

# 5. Create GitHub release (requires 'gh' CLI)
echo "[5/5] Creating GitHub release..."
if command -v gh &> /dev/null; then
    gh release create "v${VERSION}" \
        "build/ZTCD_v${VERSION}.apk" \
        --title "ZTCD v${VERSION}" \
        --notes "# Zero-Touch Car Diagnostics v${VERSION}

## What's New
- **Removed Flipper Zero backend** - Streamlined to focus exclusively on automotive OBD-II diagnostics
- **ELM327 Bluetooth** + **USB Serial (1260 modules)** support
- Clean architecture: Pure Flutter + native OBD plugins

## Features
✅ **Gemini 2.5 Pro AI Diagnostics** - Free tier with configurable API key
✅ **50+ OBD-II PIDs** - Auto-discovery of supported sensors
✅ **Bluetooth Keep-Alive** - No more connection timeouts
✅ **GPS Map Integration** - Real-time tracking with route polylines
✅ **Trip Logging** - Automatic recording with sensor fusion
✅ **Route Analysis** - Damage scoring and route recommendations
✅ **Phone Sensors** - Accelerometer and gyroscope integration

## Installation
1. Download \`ZTCD_v${VERSION}.apk\`
2. Enable \"Install from Unknown Sources\" in Android settings
3. Install the APK
4. Configure Gemini API key in Settings
5. Add Google Maps API key to enjoy map features

## Requirements
- Android 6.0+ (API 23+)
- ELM327 Bluetooth adapter or USB serial OBD-II adapter
- Google Gemini API key (free tier)
- Optional: Google Maps API key

## Documentation
- [README.md](https://github.com/${GITHUB_USERNAME}/${REPO_NAME}/blob/main/README.md)
- [OBD Integration Guide](https://github.com/${GITHUB_USERNAME}/${REPO_NAME}/blob/main/OBD_INTEGRATION.md)
- [Changes Log](https://github.com/${GITHUB_USERNAME}/${REPO_NAME}/blob/main/CHANGES.md)

---
**Full Changelog**: https://github.com/${GITHUB_USERNAME}/${REPO_NAME}/commits/v${VERSION}
"
    echo "✓ GitHub release created!"
else
    echo "⚠ GitHub CLI (gh) not installed. Install with:"
    echo "   sudo snap install gh"
    echo "   gh auth login"
    echo ""
    echo "Or create release manually at:"
    echo "   https://github.com/${GITHUB_USERNAME}/${REPO_NAME}/releases/new?tag=v${VERSION}"
    echo ""
    echo "Upload file: build/ZTCD_v${VERSION}.apk"
fi
echo ""

echo "========================================"
echo "✓ Build and Release Complete!"
echo "========================================"
echo ""
echo "APK Location: build/ZTCD_v${VERSION}.apk"
echo "Repository: https://github.com/${GITHUB_USERNAME}/${REPO_NAME}"
echo "Release: https://github.com/${GITHUB_USERNAME}/${REPO_NAME}/releases/tag/v${VERSION}"
echo ""
