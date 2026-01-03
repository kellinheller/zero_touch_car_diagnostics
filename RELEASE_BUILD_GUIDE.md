# Release Build Guide - v1.0.0

Complete guide for building and releasing Android APK and iOS IPA binaries.

## Quick Start

### Option 1: Automated Build (Recommended)
```bash
# Build Android APK only
./build_android.sh

# Build iOS IPA only (requires macOS + Xcode)
./build_ios.sh

# Build both (interactive menu)
./build_release.sh
```

### Option 2: Manual Build
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## Build Scripts Overview

### 1. `build_android.sh`
- **Purpose**: Automated Android APK release build
- **Requirements**: Flutter SDK, Java 17 LTS, Android SDK
- **Output**: `build/app/outputs/flutter-apk/app-release.apk`
- **Time**: 2-5 minutes
- **Features**:
  - Automatic Java version verification
  - Gradle daemon management
  - Clean and optimized build
  - Error handling and validation

**Usage**:
```bash
./build_android.sh
```

### 2. `build_ios.sh`
- **Purpose**: Automated iOS IPA release build
- **Requirements**: macOS, Xcode 13+, CocoaPods
- **Output**: `build/ios_build/ipa/Runner.ipa`
- **Time**: 5-10 minutes
- **Features**:
  - Pod dependency management
  - Automatic signing (requires provisioning profiles)
  - IPA export with distribution settings

**Usage**:
```bash
# macOS only
./build_ios.sh
```

### 3. `build_release.sh`
- **Purpose**: Interactive menu for building Android, iOS, or both
- **Requirements**: Flutter SDK, Java 17 LTS, (macOS + Xcode for iOS)
- **Features**:
  - Menu-driven selection
  - Combined build monitoring
  - Build summary and verification

**Usage**:
```bash
./build_release.sh           # Interactive mode
./build_release.sh 1         # Android only
./build_release.sh 2         # iOS only
./build_release.sh 3         # Both platforms
```

### 4. `check_build_status.sh`
- **Purpose**: Monitor ongoing build progress
- **Features**:
  - Real-time Gradle process monitoring
  - Build log tail output
  - APK readiness verification
  - Status indicators

**Usage**:
```bash
./check_build_status.sh      # Check once
watch -n 5 ./check_build_status.sh  # Monitor every 5 seconds
```

### 5. `upload_to_github_release.sh`
- **Purpose**: Upload binaries to GitHub Release
- **Requirements**: GitHub CLI (gh), GitHub authentication
- **Features**:
  - Automatic release tag validation
  - APK and IPA upload
  - File size verification
  - Release URL display

**Usage**:
```bash
./upload_to_github_release.sh           # Default (v1.0.0)
./upload_to_github_release.sh v2.0.0    # Specific version
./upload_to_github_release.sh v1.0.0 path/to/apk.apk path/to/ipa.ipa
```

## Environment Setup

### Java 17 LTS (Required for Android)
```bash
# Check current Java version
java -version

# Should show:
# openjdk version "17.0.x"
```

### Android SDK
```bash
# Required components:
# - API 21+ (minimum)
# - Build Tools 33.0+
# - NDK 28.x
# - Platform Tools

# Check Android SDK setup
flutter doctor -v
```

### iOS Prerequisites (macOS only)
```bash
# Install Xcode command-line tools
xcode-select --install

# Install CocoaPods
sudo gem install cocoapods

# Verify setup
flutter doctor -v
```

## GitHub CLI Setup

For uploading to GitHub releases, install and configure GitHub CLI:

```bash
# Install (macOS with Homebrew)
brew install gh

# Or install from: https://cli.github.com

# Authenticate
gh auth login
```

## Build Process Details

### Android APK Build Steps

1. **Clean environment**
   ```bash
   rm -rf build/
   flutter clean
   ```

2. **Get dependencies**
   ```bash
   flutter pub get
   ```

3. **Stop Gradle daemon**
   ```bash
   flutter clean
   ```

4. **Build release APK**
   ```bash
   flutter build apk --release
   ```

5. **Output**
   - Location: `build/app/outputs/flutter-apk/app-release.apk`
   - Size: 40-60 MB (typical)
   - Signature: Release key (needs configuration for Play Store)

### iOS IPA Build Steps

1. **Install CocoaPods dependencies**
   ```bash
   cd ios
   pod install --repo-update
   cd ..
   ```

2. **Build Flutter for iOS**
   ```bash
   flutter build ios --release
   ```

3. **Create archive**
   ```bash
   xcodebuild archive -workspace ios/Runner.xcworkspace \
     -scheme Runner \
     -configuration Release \
     -archivePath build/ios_build/Runner.xcarchive
   ```

4. **Export IPA**
   ```bash
   xcodebuild exportArchive \
     -archivePath build/ios_build/Runner.xcarchive \
     -exportOptionsPlist ios/ExportOptions.plist \
     -exportPath build/ios_build/ipa
   ```

5. **Output**
   - Location: `build/ios_build/ipa/Runner.ipa`
   - Size: 80-120 MB (typical)
   - Requires: Signing certificate, provisioning profile

## Troubleshooting

### Android Build Issues

**Java version mismatch**
```bash
# Verify Java version
java -version

# Should be 17.0.x
# If wrong, export correct PATH:
export PATH="/usr/lib/jvm/java-17-openjdk-amd64/bin:$PATH"
```

**Gradle daemon issues**
```bash
# Stop daemon
flutter clean

# Remove gradle cache
rm -rf ~/.gradle

# Rebuild
./build_android.sh
```

**NDK missing**
```bash
# Remove corrupted NDK
rm -rf ~/Android/Sdk/ndk

# Rebuild (will re-download NDK)
./build_android.sh
```

### iOS Build Issues (macOS)

**CocoaPods issues**
```bash
# Remove Pods and lock file
rm -rf ios/Pods ios/Podfile.lock

# Reinstall
cd ios && pod install --repo-update && cd ..
```

**Signing issues**
```bash
# Verify signing certificate
security find-identity -v -p codesigning

# Update ExportOptions.plist with correct team ID
```

## Upload to GitHub Release

### Prerequisites
- GitHub CLI installed
- Authenticated with `gh auth login`
- Release tag created (v1.0.0)

### Upload APK
```bash
gh release upload v1.0.0 build/app/outputs/flutter-apk/app-release.apk
```

### Upload IPA
```bash
gh release upload v1.0.0 build/ios_build/ipa/Runner.ipa
```

### Upload Both
```bash
./upload_to_github_release.sh v1.0.0
```

## App Store Submission (Optional)

### Google Play Store

**Requirements**:
- Google Play Developer account ($25)
- Release signed APK
- Privacy policy URL
- Icon, screenshots, description

**Process**:
1. Sign APK with release key
2. Create app listing in Play Console
3. Upload APK
4. Fill in metadata
5. Submit for review

**Documentation**: https://developer.android.com/google-play/launch

### Apple App Store

**Requirements**:
- Apple Developer account ($99/year)
- Signed IPA with distribution certificate
- Privacy policy URL
- Screenshots, description

**Process**:
1. Create app in App Store Connect
2. Configure app capabilities
3. Create Test Flight build (IPA)
4. Test with TestFlight beta testers
5. Submit for App Review

**Documentation**: https://developer.apple.com/app-store-connect/

## Verification Checklist

- [ ] APK/IPA built successfully
- [ ] File size reasonable (APK: 40-60MB, IPA: 80-120MB)
- [ ] Tested on physical device
- [ ] Version number matches release tag (v1.0.0)
- [ ] Uploaded to GitHub Release
- [ ] Release notes updated
- [ ] (Optional) Submitted to app stores

## Next Steps

1. **Test on Device**
   ```bash
   # Android
   adb install -r build/app/outputs/flutter-apk/app-release.apk

   # iOS
   # Install via Xcode or TestFlight
   ```

2. **Upload to Release**
   ```bash
   ./upload_to_github_release.sh v1.0.0
   ```

3. **Announce Release**
   - Update GitHub Release notes
   - Post on social media
   - Notify users

## References

- [Flutter Build Documentation](https://docs.flutter.dev/deployment/android)
- [Android App Release Guide](https://developer.android.com/guide/app-bundle)
- [iOS App Release Guide](https://developer.apple.com/ios/release-notes/)
- [Google Play Store Launch](https://developer.android.com/google-play/launch)
- [App Store Connect](https://developer.apple.com/app-store-connect/)

## Support

For issues with build scripts:
1. Check logs in build output
2. Run `flutter doctor -v` to verify environment
3. Clean and rebuild: `flutter clean && ./build_android.sh`
4. Check GitHub Issues: https://github.com/donniebrasc/zero_touch_car_diagnostics_vs2/issues
