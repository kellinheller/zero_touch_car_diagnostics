#!/bin/bash

# Upload release binaries to GitHub Release
# Usage: ./upload_to_github_release.sh [tag] [apk_file] [ipa_file]

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
echo "║  Uploading Binaries to GitHub Release                 ║"
echo "╚════════════════════════════════════════════════════════╝"
echo -e "${NC}"

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

# Check prerequisites
print_header "Checking Prerequisites"

command -v gh &> /dev/null || error_exit "GitHub CLI (gh) not found. Install with: curl -sS https://webi.sh/gh | sh"

echo -e "${GREEN}✓ GitHub CLI found${NC}"

# Get inputs
RELEASE_TAG="${1:-v1.0.0}"
APK_FILE="${2:-}"
IPA_FILE="${3:-}"

# If no files specified, use defaults
if [ -z "$APK_FILE" ]; then
    APK_FILE="build/app/outputs/flutter-apk/app-release.apk"
fi

if [ -z "$IPA_FILE" ]; then
    IPA_FILE="build/ios_build/ipa/Runner.ipa"
fi

print_header "Release Configuration"

echo "Release Tag: $RELEASE_TAG"
echo "APK File: $APK_FILE"
echo "IPA File: $IPA_FILE"
echo ""

# Verify release exists
if ! gh release view "$RELEASE_TAG" &> /dev/null; then
    error_exit "Release $RELEASE_TAG does not exist. Create it first with: gh release create $RELEASE_TAG"
fi

echo -e "${GREEN}✓ Release $RELEASE_TAG found${NC}"
echo ""

# Upload APK if it exists
if [ -f "$APK_FILE" ]; then
    print_header "Uploading Android APK"
    
    APK_SIZE=$(ls -lh "$APK_FILE" | awk '{print $5}')
    echo "File: $APK_FILE"
    echo "Size: $APK_SIZE"
    echo ""
    
    echo "Uploading to GitHub Release..."
    if gh release upload "$RELEASE_TAG" "$APK_FILE" --clobber; then
        echo -e "${GREEN}✅ APK uploaded successfully${NC}"
    else
        error_exit "Failed to upload APK"
    fi
    echo ""
else
    echo -e "${YELLOW}⚠ APK file not found: $APK_FILE${NC}"
    echo ""
fi

# Upload IPA if it exists
if [ -f "$IPA_FILE" ]; then
    print_header "Uploading iOS IPA"
    
    IPA_SIZE=$(ls -lh "$IPA_FILE" | awk '{print $5}')
    echo "File: $IPA_FILE"
    echo "Size: $IPA_SIZE"
    echo ""
    
    echo "Uploading to GitHub Release..."
    if gh release upload "$RELEASE_TAG" "$IPA_FILE" --clobber; then
        echo -e "${GREEN}✅ IPA uploaded successfully${NC}"
    else
        error_exit "Failed to upload IPA"
    fi
    echo ""
else
    echo -e "${YELLOW}⚠ IPA file not found: $IPA_FILE${NC}"
    echo "Note: iOS builds can only be created on macOS with Xcode"
    echo ""
fi

# Show release info
print_header "Release Information"

gh release view "$RELEASE_TAG" --json assets

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Upload completed!${NC}"
echo ""
echo "Release URL: https://github.com/donniebrasc/zero_touch_car_diagnostics_vs2/releases/tag/$RELEASE_TAG"
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
