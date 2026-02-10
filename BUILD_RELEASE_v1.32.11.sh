#!/bin/bash

set -e

echo "=========================================="
echo "ZTCD v1.32.11 Release Build Script"
echo "=========================================="

# Go to repo root
cd "$(git rev-parse --show-toplevel)" || exit 1
echo "Working directory: $PWD"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}[1/8] Installing system dependencies...${NC}"
sudo apt update
sudo apt install -y git curl unzip xz-utils zip openjdk-17-jdk build-essential libssl-dev

echo -e "${YELLOW}[2/8] Installing Flutter SDK...${NC}"
if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$HOME/flutter"
  echo -e "${GREEN}Flutter SDK installed${NC}"
else
  echo -e "${GREEN}Flutter SDK already exists${NC}"
fi

export PATH="$HOME/flutter/bin:$PATH"
echo "export PATH=\"\$HOME/flutter/bin:\$PATH\"" >> ~/.bashrc

echo -e "${YELLOW}[3/8] Verifying Flutter installation...${NC}"
flutter --version
flutter doctor

echo -e "${YELLOW}[4/8] Setting up Android SDK environment...${NC}"
export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
export PATH="$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools:$PATH"

# Add to bashrc for future sessions
echo "export ANDROID_SDK_ROOT=\"\$HOME/Android/Sdk\"" >> ~/.bashrc
echo "export PATH=\$ANDROID_SDK_ROOT/emulator:\$ANDROID_SDK_ROOT/platform-tools:\$PATH" >> ~/.bashrc

echo -e "${YELLOW}[5/8] Installing Flutter dependencies...${NC}"
flutter clean
flutter pub get

echo -e "${YELLOW}[6/8] Building release APK...${NC}"
# Build with explicit version
flutter build apk --release --build-name=1.32.11 --build-number=33

echo -e "${YELLOW}[7/8] Renaming APK to ZTCDv1.32.11.apk...${NC}"
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
  cp build/app/outputs/flutter-apk/app-release.apk ZTCDv1.32.11.apk
  ls -lh ZTCDv1.32.11.apk
  echo -e "${GREEN}APK created successfully!${NC}"
else
  echo -e "${RED}ERROR: APK not found at build/app/outputs/flutter-apk/app-release.apk${NC}"
  exit 1
fi

echo -e "${YELLOW}[8/8] Committing APK and creating release tag...${NC}"
git add ZTCDv1.32.11.apk
git commit -m "build(release): add ZTCDv1.32.11.apk" || echo "No changes to commit"

# Delete old tag if it exists and recreate
git tag -d v1.32.11 2>/dev/null || true
git tag -a v1.32.11 -m "Release v1.32.11 - Dual LLM Support (Gemini 2.5 Pro + ChatGPT OpenAI)"

echo -e "${GREEN}=========================================="
echo "Build Complete!"
echo "==========================================${NC}"
echo ""
echo "Next steps:"
echo "1. Review changes: git log --oneline -5"
echo "2. Push to main:  git push origin main"
echo "3. Push tag:      git push origin v1.32.11"
echo "4. Create GitHub Release with APK (optional)"
echo ""
echo "APK location: $(pwd)/ZTCDv1.32.11.apk"
echo "Size: $(du -h ZTCDv1.32.11.apk | cut -f1)"
