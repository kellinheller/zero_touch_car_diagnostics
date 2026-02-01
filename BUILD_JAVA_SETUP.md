# How to Build v1.0.0 Release Binaries

This guide explains how to resolve the Java 25 compatibility issue and successfully build Android and iOS binaries for the v1.0.0 release.

## The Problem

The current build environment has **Java 25**, which the Kotlin compiler doesn't recognize. This causes the build to fail with:

```
java.lang.IllegalArgumentException: 25.0.1
```

## The Solution

Use **Java 21 LTS** (recommended) or **Java 17 LTS** instead.

### Option 1: Using SDKMAN (Linux/macOS)

SDKMAN is a tool for managing Java versions side-by-side.

#### Install SDKMAN
```bash
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
```

#### Install Java 21 LTS
```bash
sdk install java 21.0.5-tem
```

#### Switch to Java 21 for this terminal session
```bash
sdk use java 21.0.5-tem
```

#### Verify Java version
```bash
java -version
# Should show: openjdk version "21.0.5"
```

#### Build your app
```bash
cd /home/kal/zero_touch_car_diagnostics
flutter clean
flutter build apk --release
```

### Option 2: Using Docker (Any OS)

If you don't want to install Java locally, use Docker:

#### Create Dockerfile
```dockerfile
FROM openjdk:21-slim

# Install required tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable /flutter
ENV PATH="/flutter/bin:${PATH}"

# Setup Flutter
RUN flutter precache
RUN flutter config --no-analytics
RUN flutter doctor

WORKDIR /app
COPY . .

# Build APK
RUN flutter build apk --release
```

#### Build with Docker
```bash
docker build -t zero-touch-release .
docker run -v $(pwd)/build:/app/build zero-touch-release
```

### Option 3: Using GitHub Actions (Recommended for CI/CD)

Create `.github/workflows/build-release.yml`:

```yaml
name: Build Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Java
        uses: actions/setup-java@v3
        with:
          java-version: '21'
          distribution: 'temurin'
      
      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: 'stable'
      
      - name: Build APK
        run: flutter build apk --release
      
      - name: Upload APK to Release
        uses: softprops/action-gh-release@v1
        if: startsWith(github.ref, 'refs/tags/')
        with:
          files: build/app/outputs/flutter-apk/app-release.apk
```

## Manual Build Steps (After Java is Fixed)

### For Android APK

```bash
# Navigate to project
cd /home/kal/zero_touch_car_diagnostics

# Verify Java version
java -version
# Should show: openjdk version "21.0.x"

# Clean previous builds
flutter clean
rm -rf android/app/build
rm -rf build

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release

# Verify build output
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

### For Android App Bundle (for Play Store)

```bash
flutter build aab --release

# Output will be at:
# build/app/outputs/bundle/release/app-release.aab
```

### For iOS IPA

```bash
cd /home/kal/zero_touch_car_diagnostics

# Install Pod dependencies
cd ios
pod install
cd ..

# Build iOS release
flutter build ios --release

# Using Xcode to create IPA
xcodebuild \
  -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -derivedDataPath build/ios_build \
  archive \
  -archivePath build/ios_build/Runner.xcarchive

xcodebuild \
  -exportArchive \
  -archivePath build/ios_build/Runner.xcarchive \
  -exportOptionsPlist ios/ExportOptions.plist \
  -exportPath build/ios_build/ipa
```

## Expected Output

After successful builds, you should have:

```
✅ Android APK:
   build/app/outputs/flutter-apk/app-release.apk (45-55 MB)

✅ Android App Bundle:
   build/app/outputs/bundle/release/app-release.aab (35-45 MB)

✅ iOS IPA:
   build/ios_build/ipa/Runner.ipa (80-120 MB)
```

## Uploading to GitHub Release

### Using gh CLI
```bash
# Install gh CLI: https://cli.github.com/

cd /home/kal/zero_touch_car_diagnostics

# Upload APK
gh release upload v1.0.0 build/app/outputs/flutter-apk/app-release.apk

# Upload AAB
gh release upload v1.0.0 build/app/outputs/bundle/release/app-release.aab

# Upload IPA
gh release upload v1.0.0 build/ios_build/ipa/Runner.ipa
```

### Using Web Browser
1. Go to: https://github.com/donniebrasc/zero_touch_car_diagnostics_vs2/releases
2. Find `v1.0.0` release
3. Click "Edit"
4. Drag and drop APK/IPA files into the assets section
5. Save

## Troubleshooting

### "gradle-8.13 version not compatible with Java 25"
**Solution**: Use Java 21 LTS instead (see above)

### "Pod install fails"
```bash
cd ios
pod repo update
pod install --repo-update
cd ..
```

### "Flutter not found"
```bash
# Install Flutter
git clone https://github.com/flutter/flutter.git -b stable ~/flutter
export PATH="$PATH:~/flutter/bin"
```

### "Xcode command not found" (macOS)
```bash
sudo xcode-select --install
# Or set path:
sudo xcode-select --reset
```

## Verification Before Upload

Before uploading binaries to GitHub, test them:

```bash
# Install APK on connected Android device
adb install build/app/outputs/flutter-apk/app-release.apk

# Or use flutter
flutter install build/app/outputs/flutter-apk/app-release.apk
```

---

## Quick Reference

**Java 21 LTS Download**: https://adoptium.net/temurin/releases/?version=21
**Flutter SDK**: https://flutter.dev/docs/get-started/install
**GitHub CLI**: https://cli.github.com/

---

**Project**: Zero-Touch Car Diagnostics  
**Release**: v1.0.0  
**Repository**: https://github.com/donniebrasc/zero_touch_car_diagnostics_vs2
