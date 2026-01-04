#!/bin/bash

# Final Android APK Release Build Script
# Zero-Touch Car Diagnostics v1.0.0

set -e

cd "$(dirname "$0")"

echo "╔══════════════════════════════════════════════════════════╗"
echo "║                                                          ║"
echo "║   🚀 FINAL ANDROID APK RELEASE BUILD                     ║"
echo "║   Zero-Touch Car Diagnostics v1.0.0                      ║"
echo "║                                                          ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Set up Java 17 LTS environment
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:/usr/bin:/bin:/usr/sbin:/sbin:/home/kal/Public/flutter/bin

# Verify Java
echo "✓ Verifying Java setup..."
java -version
echo ""

# Clean
echo "✓ Cleaning previous builds..."
flutter clean
rm -rf build android/app/build
echo "  Clean complete"
echo ""

# Get dependencies
echo "✓ Getting dependencies..."
flutter pub get
echo "  Dependencies resolved"
echo ""

# Build APK
echo "🚀 Building Android APK release..."
echo "   This may take 3-10 minutes..."
echo ""

flutter build apk --release

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo ""

# Verify build
if [ -f build/app/outputs/flutter-apk/app-release.apk ]; then
    echo "✅ BUILD SUCCESSFUL!"
    echo ""
    echo "📦 APK Details:"
    ls -lh build/app/outputs/flutter-apk/app-release.apk
    echo ""
    echo "Checksum:"
    md5sum build/app/outputs/flutter-apk/app-release.apk
    echo ""
    echo "File type:"
    file build/app/outputs/flutter-apk/app-release.apk
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    echo "🎉 APK is ready for release!"
    echo ""
    echo "Next steps:"
    echo "  1. Test on Android device:"
    echo "     adb install -r build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    echo "  2. Upload to GitHub:"
    echo "     gh release upload v1.0.0 build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    echo "  3. Or upload manually at:"
    echo "     https://github.com/donniebrasc/zero_touch_car_diagnostics_vs2/releases/tag/v1.0.0"
    echo ""
else
    echo "❌ BUILD FAILED"
    echo ""
    echo "Check the output above for error details."
    exit 1
fi

echo "═══════════════════════════════════════════════════════════"
