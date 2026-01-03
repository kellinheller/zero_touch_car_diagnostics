#!/bin/bash

# Combined build script for Android APK and iOS IPA
# Builds both platforms for Zero-Touch Car Diagnostics v1.0.0

set -e

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════╗"
echo "║  Building Zero-Touch Car Diagnostics v1.0.0            ║"
echo "║  Android APK + iOS IPA Release Build                  ║"
echo "╚════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# Function to print section headers
print_header() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo ""
}

# Function to handle errors
error_exit() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# Check for required tools
print_header "Checking Prerequisites"

command -v flutter &> /dev/null || error_exit "Flutter not found. Please install Flutter."
command -v java &> /dev/null || error_exit "Java not found. Please install Java 17 LTS."

echo -e "${GREEN}✓ Flutter found${NC}"
echo -e "${GREEN}✓ Java found${NC}"
echo ""

# Get build platform choice
if [ $# -eq 0 ]; then
    echo "Select platform to build:"
    echo "  1) Android APK only"
    echo "  2) iOS IPA only"
    echo "  3) Both (Android + iOS)"
    echo ""
    read -p "Enter choice (1-3): " CHOICE
else
    CHOICE=$1
fi

case $CHOICE in
    1)
        BUILD_ANDROID=true
        BUILD_IOS=false
        ;;
    2)
        BUILD_ANDROID=false
        BUILD_IOS=true
        ;;
    3)
        BUILD_ANDROID=true
        BUILD_IOS=true
        ;;
    *)
        error_exit "Invalid choice"
        ;;
esac

# Android Build
if [ "$BUILD_ANDROID" = true ]; then
    print_header "Building Android APK"
    
    if [ ! -f "build_android.sh" ]; then
        error_exit "build_android.sh not found"
    fi
    
    bash build_android.sh
    
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        echo -e "${GREEN}✅ Android APK built successfully${NC}"
        ls -lh build/app/outputs/flutter-apk/app-release.apk
    else
        error_exit "Android APK build failed"
    fi
    echo ""
fi

# iOS Build
if [ "$BUILD_IOS" = true ]; then
    print_header "Building iOS IPA"
    
    if [ ! -f "build_ios.sh" ]; then
        error_exit "build_ios.sh not found"
    fi
    
    bash build_ios.sh
    
    if [ -f "build/ios_build/ipa/Runner.ipa" ]; then
        echo -e "${GREEN}✅ iOS IPA built successfully${NC}"
        ls -lh build/ios_build/ipa/Runner.ipa
    else
        error_exit "iOS IPA build failed"
    fi
    echo ""
fi

# Summary
print_header "Build Summary"

if [ "$BUILD_ANDROID" = true ] && [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    echo -e "${GREEN}✅ Android APK:${NC}"
    echo "   $(pwd)/build/app/outputs/flutter-apk/app-release.apk"
    APK_SIZE=$(ls -lh build/app/outputs/flutter-apk/app-release.apk | awk '{print $5}')
    echo "   Size: $APK_SIZE"
    echo ""
fi

if [ "$BUILD_IOS" = true ] && [ -f "build/ios_build/ipa/Runner.ipa" ]; then
    echo -e "${GREEN}✅ iOS IPA:${NC}"
    echo "   $(pwd)/build/ios_build/ipa/Runner.ipa"
    IPA_SIZE=$(ls -lh build/ios_build/ipa/Runner.ipa | awk '{print $5}')
    echo "   Size: $IPA_SIZE"
    echo ""
fi

echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Build completed successfully!${NC}"
echo ""
echo "Next steps:"
echo "  1. Test the binaries on real devices"
echo "  2. Upload to GitHub Release"
echo "  3. (Optional) Submit to Play Store and App Store"
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
