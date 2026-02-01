# ZTCD v1.31 Release Instructions

## Current Status

✅ **Code committed** to local git repository (commit: 86ce517)
✅ **Version updated** to 1.31.0 (build 131) in pubspec.yaml
✅ **Git remote configured**: https://github.com/mark/zero_touch_car_diagnostics_vs2.git
✅ **All Flipper Zero components removed** - Clean OBD-II focused architecture

## Issue Encountered

The Flutter snap installation has a git repository detection issue that prevents building. This is a known issue with snap-installed Flutter when used outside of a git repository context.

## Solution Options

### Option 1: Fix Flutter Installation (Recommended)

```bash
# Remove snap Flutter
sudo snap remove flutter

# Install Flutter via git clone (official method)
cd ~
git clone https://github.com/flutter/flutter.git -b stable
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# Verify installation
flutter doctor -v

# Build APK
cd /home/mark/zero_touch_car_diagnostics
flutter pub get
flutter build apk --release --build-name=1.31.0 --build-number=131

# APK will be at: build/app/outputs/flutter-apk/app-release.apk
```

### Option 2: Use Android Studio

1. Install Android Studio: https://developer.android.com/studio
2. Open project: `/home/mark/zero_touch_car_diagnostics`
3. Tools → Flutter → Flutter Pub Get
4. Build → Flutter → Build APK
5. APK location: `build/app/outputs/flutter-apk/app-release.apk`

### Option 3: Use Docker (Clean Environment)

```bash
# Build with official Flutter Docker image
docker run --rm -v $(pwd):/app -w /app cirrusci/flutter:stable sh -c "
  flutter pub get && 
  flutter build apk --release --build-name=1.31.0 --build-number=131
"

# APK will be at: build/app/outputs/flutter-apk/app-release.apk
```

## After Building APK

### 1. Rename and Prepare APK

```bash
cd /home/mark/zero_touch_car_diagnostics
mkdir -p build/release
cp build/app/outputs/flutter-apk/app-release.apk build/release/ZTCD_v1.31.0.apk
```

### 2. Create GitHub Repository

Go to https://github.com/new and create `zero_touch_car_diagnostics_vs2`

### 3. Push Code to GitHub

```bash
cd /home/mark/zero_touch_car_diagnostics

# If repository URL needs update (replace 'mark' with your actual GitHub username)
git remote set-url origin https://github.com/YOUR_USERNAME/zero_touch_car_diagnostics_vs2.git

# Push code
git branch -M main
git push -u origin main
```

### 4. Create Release Tag

```bash
git tag -a v1.31.0 -m "ZTCD v1.31.0 Release

Features:
- Gemini 2.5 Pro AI diagnostics
- 50+ OBD-II PIDs with auto-discovery
- Bluetooth keep-alive (no timeouts)
- GPS map with trip logging
- Route analysis with damage scoring
- Phone sensor integration
- Removed Flipper Zero backend (focus on ELM327/USB serial)

Build: 131
Platform: Android"

git push origin v1.31.0
```

### 5. Create GitHub Release

**Option A: Using GitHub CLI** (if installed)

```bash
# Install gh CLI
sudo snap install gh
gh auth login

# Create release with APK
gh release create v1.31.0 \
  build/release/ZTCD_v1.31.0.apk \
  --title "ZTCD v1.31.0" \
  --notes-file RELEASE_NOTES.md
```

**Option B: Manual Upload**

1. Go to: https://github.com/YOUR_USERNAME/zero_touch_car_diagnostics_vs2/releases/new
2. Tag: `v1.31.0`
3. Title: `ZTCD v1.31.0`
4. Description: See `RELEASE_NOTES.md` below
5. Upload `build/release/ZTCD_v1.31.0.apk`
6. Click "Publish release"

## Release Notes Template

Save this as `RELEASE_NOTES.md`:

```markdown
# Zero-Touch Car Diagnostics v1.31.0

## What's New

🎉 **Major Architecture Refactor**
- Removed Flipper Zero backend (~15,000 lines of C++)
- Streamlined to pure Flutter + native OBD plugins
- Focus: ELM327 Bluetooth + USB Serial (1260 modules)

## Features

✅ **AI-Powered Diagnostics**
- Google Gemini 2.5 Pro integration (free tier)
- Configurable API key in Settings
- Comprehensive vehicle health analysis

✅ **Comprehensive OBD-II Support**
- 50+ generic PIDs with auto-discovery
- Real-time monitoring dashboard
- ELM327 Bluetooth Classic support
- USB Serial adapter support (CH340/CP210x/FTDI)

✅ **Advanced Trip Features**
- GPS map with real-time tracking
- Automatic trip logging with sensor fusion
- Phone accelerometer & gyroscope integration
- Damage scoring algorithm
- Route analysis and recommendations

✅ **Reliability Improvements**
- Bluetooth keep-alive (no more timeouts)
- Activity tracking and reconnection
- Persistent settings storage

## Installation

1. Download `ZTCD_v1.31.0.apk`
2. Enable "Install from Unknown Sources" in Android settings
3. Install the APK
4. Open app → Settings → Configure Gemini API key
5. (Optional) Add Google Maps API key for full map features

## Requirements

- **Android**: 6.0+ (API 23+)
- **Hardware**: ELM327 Bluetooth or USB Serial OBD-II adapter
- **API Keys**: 
  - Gemini API (free): https://aistudio.google.com/app/apikey
  - Google Maps (optional): https://console.cloud.google.com/

## Documentation

- [README.md](README.md) - Full feature list and setup guide
- [OBD_INTEGRATION.md](OBD_INTEGRATION.md) - ELM327 integration details
- [CHANGES.md](CHANGES.md) - Detailed changelog

## Known Issues

- iOS Bluetooth Classic not supported (Apple limitation)
- Some vehicle-specific PIDs not yet implemented
- Background GPS tracking requires location permission

## Support

Report issues: https://github.com/YOUR_USERNAME/zero_touch_car_diagnostics_vs2/issues

---

**Full Changelog**: https://github.com/YOUR_USERNAME/zero_touch_car_diagnostics_vs2/compare/v1.0.0...v1.31.0
```

## Quick Reference

**Project Location**: `/home/mark/zero_touch_car_diagnostics`
**Git Status**: Committed, ready to push
**Version**: 1.31.0 (build 131)
**Target Repository**: zero_touch_car_diagnostics_vs2

## Next Steps Summary

1. Fix Flutter installation (choose Option 1, 2, or 3 above)
2. Build APK
3. Create GitHub repository
4. Push code: `git push -u origin main --tags`
5. Upload APK to GitHub Releases

