#!/bin/bash

# Complete Release Build Script
# Zero-Touch Car Diagnostics v1.0.0
# Builds Android APK + Backend Binary Files

set -e

cd "$(dirname "$0")"

echo "╔═══════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                           ║"
echo "║            🚀 COMPLETE RELEASE BUILD - v1.0.0                             ║"
echo "║            Android APK + Backend Binary (.bin) Files                      ║"
echo "║                                                                           ║"
echo "╚═══════════════════════════════════════════════════════════════════════════╝"
echo ""

# Set up Java 17 LTS environment
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:/usr/bin:/bin:/usr/sbin:/sbin:/home/kal/Public/flutter/bin

# Verify Java
echo "✓ Verifying Java setup..."
java -version
echo ""

# ==================== STAGE 1: FLUTTER/ANDROID BUILD ====================

echo "════════════════════════════════════════════════════════════════════════════"
echo "STAGE 1: Building Android APK Release"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""

# Clean
echo "✓ Cleaning previous builds..."
flutter clean
rm -rf build android/app/build
echo "  Clean complete"
echo ""

# Get dependencies
echo "✓ Getting Flutter dependencies..."
flutter pub get
echo "  Dependencies resolved"
echo ""

# Run tests
echo "✓ Running tests..."
flutter test --reporter expanded 2>&1 | tail -10
echo ""

# Build APK
echo "🚀 Building Android APK release..."
echo "   This may take 5-15 minutes..."
echo ""

flutter build apk --release --verbose 2>&1 | tail -50 &
BUILD_PID=$!

# Monitor build with timeout
echo "Monitoring build... (this may take a while)"
for i in {1..180}; do
    if [ -f build/app/outputs/flutter-apk/app-release.apk ]; then
        echo ""
        echo "✅ APK BUILD COMPLETE!"
        wait $BUILD_PID 2>/dev/null || true
        break
    fi
    if ! kill -0 $BUILD_PID 2>/dev/null; then
        wait $BUILD_PID
        if [ $? -eq 0 ]; then
            echo ""
            echo "✅ APK BUILD COMPLETE!"
        else
            echo ""
            echo "❌ APK BUILD FAILED"
            exit 1
        fi
        break
    fi
    printf "."
    sleep 1
done

echo ""

# Verify APK
if [ -f build/app/outputs/flutter-apk/app-release.apk ]; then
    echo ""
    echo "✅ APK BUILD SUCCESSFUL!"
    echo ""
    echo "📦 APK Details:"
    ls -lh build/app/outputs/flutter-apk/app-release.apk
    APK_SIZE=$(stat -f%z build/app/outputs/flutter-apk/app-release.apk 2>/dev/null || stat -c%s build/app/outputs/flutter-apk/app-release.apk)
    echo "   Size: $(numfmt --to=iec $APK_SIZE 2>/dev/null || echo "$APK_SIZE bytes")"
    echo ""
    MD5=$(md5sum build/app/outputs/flutter-apk/app-release.apk | awk '{print $1}')
    echo "   MD5: $MD5"
    echo ""
    FILE_TYPE=$(file build/app/outputs/flutter-apk/app-release.apk)
    echo "   Type: $FILE_TYPE"
    echo ""
else
    echo "❌ APK BUILD FAILED"
    echo "Check the build log for details"
    exit 1
fi

# ==================== STAGE 2: C++ BACKEND BUILD ====================

echo ""
echo "════════════════════════════════════════════════════════════════════════════"
echo "STAGE 2: Building C++ Backend Binary Files"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""

if [ -d "backend" ]; then
    echo "✓ Found backend directory"
    echo ""
    
    # Create build directory for backend
    mkdir -p backend/build
    cd backend/build
    
    # Check if CMake is available
    if command -v cmake &> /dev/null; then
        echo "🚀 Building C++ backend with CMake..."
        cmake .. -DCMAKE_BUILD_TYPE=Release
        make -j$(nproc)
        
        if [ -f "bin/applicationbackend.bin" ] || [ -f "libapplicationbackend.so" ]; then
            echo "✅ BACKEND BUILD SUCCESSFUL!"
            echo ""
            echo "📦 Backend Binary Details:"
            find . -name "*.bin" -o -name "*.so" | head -10
        else
            echo "⚠️  Backend build completed but binary file not found"
        fi
    else
        echo "⚠️  CMake not found. Install with: sudo apt-get install cmake"
        echo "   Manual backend build required"
    fi
    
    cd ../..
else
    echo "⚠️  Backend directory not found"
fi

echo ""

# ==================== FINAL SUMMARY ====================

echo "════════════════════════════════════════════════════════════════════════════"
echo "BUILD SUMMARY"
echo "════════════════════════════════════════════════════════════════════════════"
echo ""

if [ -f build/app/outputs/flutter-apk/app-release.apk ]; then
    echo "✅ ANDROID APK: READY"
    echo "   Location: build/app/outputs/flutter-apk/app-release.apk"
    echo ""
fi

if [ -f backend/build/bin/applicationbackend.bin ] 2>/dev/null || [ -f backend/build/libapplicationbackend.so ] 2>/dev/null; then
    echo "✅ BACKEND BINARY: READY"
    echo "   Location: backend/build/"
    echo ""
fi

echo "════════════════════════════════════════════════════════════════════════════"
echo ""
echo "🎉 RELEASE BUILD COMPLETE!"
echo ""
echo "Next steps:"
echo "  1. Test APK on device: adb install -r build/app/outputs/flutter-apk/app-release.apk"
echo "  2. Upload to GitHub: gh release upload v1.0.0 build/app/outputs/flutter-apk/app-release.apk"
echo "  3. Or use script: ./upload_to_github_release.sh v1.0.0"
echo ""
echo "════════════════════════════════════════════════════════════════════════════"
