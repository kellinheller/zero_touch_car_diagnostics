#!/bin/bash

# Build Android APK with Java 17 LTS
# This script strips out conflicting Java versions from PATH

echo "🔧 Building Android APK for Zero-Touch Car Diagnostics v1.0.0..."
echo ""

# Set clean PATH - only system paths and Flutter
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/kal/Public/flutter/bin"

# Unset JAVA_HOME if set
unset JAVA_HOME

# Verify Java version
echo "✓ Checking Java version..."
java -version

echo ""
echo "✓ Cleaning previous builds..."
flutter clean
rm -rf android/app/build
rm -rf build

echo ""
echo "✓ Getting dependencies..."
flutter pub get

echo ""
echo "✓ Stopping gradle daemon..."
./android/gradlew --stop 2>/dev/null || true

echo ""
echo "🚀 Building Android APK (this may take 2-5 minutes)..."
flutter build apk --release

# Check if build was successful
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    echo ""
    echo "✅ BUILD SUCCESSFUL!"
    echo ""
    ls -lh build/app/outputs/flutter-apk/app-release.apk
    echo ""
    echo "APK ready at: build/app/outputs/flutter-apk/app-release.apk"
else
    echo ""
    echo "❌ BUILD FAILED"
    exit 1
fi
