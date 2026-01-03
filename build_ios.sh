#!/bin/bash

# Build iOS IPA for Zero-Touch Car Diagnostics v1.0.0
# This script builds the iOS app and creates an IPA file

set -e

echo "🔧 Building iOS IPA for Zero-Touch Car Diagnostics v1.0.0..."
echo ""

cd "$(dirname "$0")"

# Verify Flutter is available
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found in PATH"
    exit 1
fi

echo "✓ Flutter found"
echo ""

# Check for Xcode
if ! command -v xcode-select &> /dev/null; then
    echo "❌ Xcode not found"
    echo "Please install Xcode from App Store"
    exit 1
fi

echo "✓ Xcode found"
echo ""

echo "✓ Cleaning previous builds..."
flutter clean
rm -rf ios/Pods
rm -rf ios/Podfile.lock
rm -rf build

echo ""
echo "✓ Getting dependencies..."
flutter pub get

echo ""
echo "✓ Installing Pod dependencies..."
cd ios
pod install --repo-update 2>/dev/null || pod install
cd ..

echo ""
echo "🚀 Building iOS app (this may take 5-15 minutes)..."
flutter build ios --release

echo ""
echo "✓ iOS app built successfully"
echo ""

# Create IPA using xcodebuild
echo "🔨 Creating IPA file..."

DERIVED_DATA="build/ios_build"
ARCHIVE_PATH="$DERIVED_DATA/Runner.xcarchive"
IPA_PATH="$DERIVED_DATA/ipa"

mkdir -p "$DERIVED_DATA"

echo "✓ Creating archive..."
xcodebuild \
  -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -derivedDataPath "$DERIVED_DATA" \
  -archivePath "$ARCHIVE_PATH" \
  archive

echo ""
echo "✓ Exporting IPA..."

# Check if ExportOptions.plist exists
if [ ! -f "ios/ExportOptions.plist" ]; then
    echo "⚠️  ExportOptions.plist not found"
    echo "    Using default ad-hoc export"
    
    # Create a default export options file
    cat > ios/ExportOptions.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>ad-hoc</string>
    <key>teamID</key>
    <string></string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>stripSwiftSymbols</key>
    <true/>
</dict>
</plist>
EOF
fi

xcodebuild \
  -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportOptionsPlist ios/ExportOptions.plist \
  -exportPath "$IPA_PATH"

echo ""

# Check if IPA was created
if [ -f "$IPA_PATH/Runner.ipa" ]; then
    echo "✅ IPA BUILD SUCCESSFUL!"
    echo ""
    ls -lh "$IPA_PATH/Runner.ipa"
    echo ""
    echo "IPA ready at: $IPA_PATH/Runner.ipa"
else
    echo "❌ IPA BUILD FAILED"
    echo "Check Xcode build output above"
    exit 1
fi
