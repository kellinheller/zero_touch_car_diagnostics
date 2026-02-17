#!/bin/bash

# Quick Pre-Release APK Build Script
# Zero-Touch Car Diagnostics v1.32.11

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_VERSION="1.32.11"
BUILD_NUMBER="33"

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}                                                           ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}   🚀 ZTCD Pre-Release APK Builder v${BUILD_VERSION}        ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}   Zero-Touch Car Diagnostics                             ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}                                                           ${BLUE}║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check prerequisites
echo -e "${YELLOW}[1/6]${NC} Checking prerequisites..."

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}✗ Flutter not found in PATH${NC}"
    echo "  Install Flutter from: https://flutter.dev/docs/get-started/install/linux"
    exit 1
fi
echo -e "${GREEN}  ✓ Flutter found${NC}"

# Check Java
if ! command -v java &> /dev/null; then
    echo -e "${RED}✗ Java not found in PATH${NC}"
    echo "  Install with: sudo apt-get install -y openjdk-17-jdk"
    exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | head -1 | grep -oP 'version "\K[\d.]+')
echo -e "${GREEN}  ✓ Java ${JAVA_VERSION} found${NC}"

# Verify Java 17+
if [[ ! "$JAVA_VERSION" =~ ^(17|18|19|20|21|22|23|24|25) ]]; then
    echo -e "${YELLOW}  ⚠ Warning: Java ${JAVA_VERSION} detected. Java 17 LTS+ recommended${NC}"
fi

echo ""

# Clean
echo -e "${YELLOW}[2/6]${NC} Cleaning previous builds..."
cd "$PROJECT_DIR"
flutter clean
rm -rf build android/app/build 2>/dev/null || true
echo -e "${GREEN}  ✓ Clean complete${NC}"
echo ""

# Get dependencies
echo -e "${YELLOW}[3/6]${NC} Getting dependencies..."
flutter pub get
echo -e "${GREEN}  ✓ Dependencies resolved${NC}"
echo ""

# Run Flutter doctor
echo -e "${YELLOW}[4/6]${NC} Running Flutter doctor..."
flutter doctor -v 2>&1 | tail -10
echo ""

# Build APK
echo -e "${YELLOW}[5/6]${NC} Building Release APK..."
echo "  Version: ${BUILD_VERSION}"
echo "  Build Number: ${BUILD_NUMBER}"
echo "  This may take 3-10 minutes..."
echo ""

if flutter build apk --release \
    --build-name="${BUILD_VERSION}" \
    --build-number="${BUILD_NUMBER}" \
    -v; then
    echo ""
    echo -e "${GREEN}  ✓ Build successful${NC}"
else
    echo ""
    echo -e "${RED}  ✗ Build failed${NC}"
    exit 1
fi

echo ""

# Verify output
echo -e "${YELLOW}[6/6]${NC} Verifying APK..."
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"

if [ -f "$APK_PATH" ]; then
    APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
    echo -e "${GREEN}  ✓ APK created successfully${NC}"
    echo "  Location: $APK_PATH"
    echo "  Size: $APK_SIZE"
else
    echo -e "${RED}  ✗ APK not found${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}                                                           ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}   ${GREEN}✓ Pre-Release APK Ready!${NC}                       ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}                                                           ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}   📦 ZTCDv${BUILD_VERSION}.apk                              ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}   📍 $APK_PATH   ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}                                                           ${BLUE}║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Installation instructions
echo -e "${YELLOW}Next Steps:${NC}"
echo ""
echo "1. Install on device:"
echo "   adb install -r $APK_PATH"
echo ""
echo "2. Or copy to device and install manually"
echo ""
echo "3. First run setup:"
echo "   - Grant required permissions (Location, Bluetooth, Storage)"
echo "   - Add Gemini API key in Settings"
echo "   - Configure OBD transport (Bluetooth/USB/Simulation)"
echo ""
echo -e "${YELLOW}Documentation:${NC}"
echo "  - Build Guide: BUILD_PRERELEASE_APK.md"
echo "  - Integration: OBD_INTEGRATION.md"
echo "  - README: README.md"
echo ""
