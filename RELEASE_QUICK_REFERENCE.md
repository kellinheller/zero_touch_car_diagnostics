# Quick Release Reference Card

## Build Commands

### Android APK
```bash
./build_android.sh
# Output: build/app/outputs/flutter-apk/app-release.apk (45-55 MB)
# Time: 2-5 minutes
```

### iOS IPA (macOS only)
```bash
./build_ios.sh
# Output: build/ios_build/ipa/Runner.ipa (85-120 MB)
# Time: 5-10 minutes
```

### Both Platforms (Interactive)
```bash
./build_release.sh
# Select: 1 (Android), 2 (iOS), or 3 (Both)
```

## Monitor Build

```bash
# Check status once
./check_build_status.sh

# Monitor continuously (every 5 seconds)
watch -n 5 ./check_build_status.sh
```

## Upload to GitHub

```bash
# Upload both APK and IPA (if available)
./upload_to_github_release.sh

# Upload to specific version
./upload_to_github_release.sh v2.0.0

# Manual upload
gh release upload v1.0.0 build/app/outputs/flutter-apk/app-release.apk
gh release upload v1.0.0 build/ios_build/ipa/Runner.ipa
```

## Test on Device

```bash
# Android
adb devices  # Verify device connected
adb install -r build/app/outputs/flutter-apk/app-release.apk

# iOS
# Use Xcode or TestFlight
open build/ios_build/ipa/Runner.ipa
```

## Troubleshooting Quick Fixes

```bash
# Java version mismatch
java -version  # Should show 17.0.x

# Clear gradle cache
flutter clean && rm -rf ~/.gradle

# Reset NDK
rm -rf ~/Android/Sdk/ndk && ./build_android.sh

# CocoaPods issues (iOS)
rm -rf ios/Pods ios/Podfile.lock && cd ios && pod install --repo-update && cd ..
```

## File Locations

| Component | Path | Size |
|-----------|------|------|
| Android APK | `build/app/outputs/flutter-apk/app-release.apk` | 45-55 MB |
| iOS IPA | `build/ios_build/ipa/Runner.ipa` | 85-120 MB |
| Build Log | `build_android.log` (if using build script) | Varies |
| Release Tag | GitHub v1.0.0 | - |

## Environment Check

```bash
flutter doctor -v
# Should show: ✓ Flutter | ✓ Android SDK | ✓ Xcode (macOS)

java -version
# Should show: openjdk version "17.0.x"

gh auth status
# Should show: Logged in
```

## Full Release Workflow

1. **Build Android**
   ```bash
   ./build_android.sh
   # Wait for completion (2-5 min)
   ```

2. **Test APK**
   ```bash
   adb install -r build/app/outputs/flutter-apk/app-release.apk
   # Test on device
   ```

3. **Upload to GitHub**
   ```bash
   ./upload_to_github_release.sh v1.0.0
   ```

4. **iOS (macOS only)**
   ```bash
   ./build_ios.sh
   gh release upload v1.0.0 build/ios_build/ipa/Runner.ipa
   ```

## Important Notes

- **Java 17 LTS required** - Android builds need Java 17, not Java 21
- **macOS needed for iOS** - iOS builds can only run on macOS with Xcode
- **Release key signing** - For Play Store, APK must be signed with release key
- **Provisioning profiles** - iOS IPA requires valid provisioning profiles
- **Network required** - Gradle downloads dependencies (large files)

---
**Last Updated**: v1.0.0 Release
**Documentation**: See [RELEASE_BUILD_GUIDE.md](RELEASE_BUILD_GUIDE.md) for details
