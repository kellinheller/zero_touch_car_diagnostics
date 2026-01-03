#!/bin/bash

# Monitor the Android APK build status
# Shows real-time progress of the Gradle build

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

APK_FILE="build/app/outputs/flutter-apk/app-release.apk"
BUILD_LOG="build_android.log"

print_status() {
    echo -e "${CYAN}════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════${NC}"
    echo ""
}

if [ -f "$APK_FILE" ]; then
    print_status "✅ BUILD COMPLETE"
    echo -e "${GREEN}Android APK is ready!${NC}"
    echo ""
    echo "File: $APK_FILE"
    echo "Size: $(ls -lh "$APK_FILE" | awk '{print $5}')"
    echo "Created: $(ls -l "$APK_FILE" | awk '{print $6, $7, $8}')"
    echo ""
    echo "Next steps:"
    echo "  1. Test on device: adb install -r \"$APK_FILE\""
    echo "  2. Upload to GitHub: ./upload_to_github_release.sh"
    exit 0
fi

# Check for Gradle daemon
if pgrep -f "gradle" > /dev/null 2>&1; then
    print_status "⏳ BUILD IN PROGRESS"
    echo ""
    echo "Gradle is actively building..."
    echo ""
    
    # Show process info
    echo "Process Information:"
    pgrep -f "gradle" | while read PID; do
        PS_OUTPUT=$(ps aux | grep "^[^ ]* *$PID ")
        if [ ! -z "$PS_OUTPUT" ]; then
            echo "  PID: $PID"
            echo "  Memory: $(echo "$PS_OUTPUT" | awk '{print $6}') KB"
            echo "  CPU: $(echo "$PS_OUTPUT" | awk '{print $3}')%"
        fi
    done
    echo ""
    
    # Show build log if available
    if [ -f "$BUILD_LOG" ]; then
        echo "Last 15 lines of build output:"
        echo ""
        tail -15 "$BUILD_LOG"
    else
        echo "Waiting for build to start..."
        echo "The build typically takes 2-5 minutes."
    fi
    echo ""
    echo "🔄 Rerun this script to check progress"
    exit 0
fi

# Build not running and APK not found
if [ -f "build_android.log" ]; then
    print_status "❌ BUILD FAILED"
    echo ""
    echo "Check the build log for details:"
    echo ""
    tail -30 "$BUILD_LOG"
    exit 1
else
    print_status "⚙️ BUILD NOT STARTED"
    echo ""
    echo "Run the following to start the build:"
    echo "  ./build_android.sh"
    echo ""
    echo "Or for combined Android + iOS build:"
    echo "  ./build_release.sh"
    exit 0
fi