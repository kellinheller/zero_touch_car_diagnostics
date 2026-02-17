# Pre-Release APK Build Guide

## Quick Start: GitHub Actions (Recommended - Fastest)

### Option 1: Trigger via GitHub Web UI

1. Go to your repository on GitHub: https://github.com/yourusername/zero_touch_car_diagnostics
2. Click on the **Actions** tab
3. Select **Build Release APK** workflow from the list
4. Click **Run workflow** button
5. Select the branch (usually `main`)
6. Click **Run workflow**
7. Wait for the build to complete (usually 3-5 minutes)
8. Download the APK from the build artifacts

### Option 2: Trigger via GitHub CLI

```bash
# First, install GitHub CLI and authenticate
# Ubuntu/Debian:
sudo apt-get install -y gh
gh auth login

# Then trigger the workflow
gh workflow run build-release.yml

# Check workflow status
gh workflow view build-release.yml --all
```

### Option 3: Trigger via Git Tag (Automatic)

```bash
# Create and push a version tag
git tag -a v1.32.11 -m "Pre-release version 1.32.11"
git push origin v1.32.11

# The workflow will automatically trigger and build the APK
# Check progress in the Actions tab
```

---

## Local Build Method

### Prerequisites

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y \
  openjdk-17-jdk \
  git \
  curl \
  unzip \
  xz-utils \
  libglu1-mesa

# Set Java 17 as default (if multiple versions installed)
sudo update-alternatives --config java
```

### System Setup for Flutter

```bash
# Create Flutter directory
mkdir -p ~/dev
cd ~/dev

# Download Flutter 3.10.5 (or latest stable)
curl -o flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.10.5-stable.tar.xz
tar -xf flutter.tar.xz
rm flutter.tar.xz

# Add Flutter to PATH
export PATH="$PATH:$HOME/dev/flutter/bin"
echo 'export PATH="$PATH:$HOME/dev/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# Accept licenses
flutter config --android-sdk $ANDROID_SDK_ROOT
flutter doctor --android-licenses
```

### Build the APK

```bash
cd /home/kal/zero_touch_car_diagnostics

# Set Java environment
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Clean build directory
flutter clean
rm -rf build android/app/build

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release \
  --build-name=1.32.11 \
  --build-number=33 \
  -v

# APK location: build/app/outputs/flutter-apk/app-release.apk
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

### Troubleshooting Local Build

**Problem: Android SDK not found**
```bash
# Install Android SDK (if not already present)
flutter doctor --android-licenses
# Follow prompts to accept licenses
```

**Problem: Java version mismatch**
```bash
# Verify Java version
java -version
# Should show openjdk version "17"

# If needed, set JAVA_HOME explicitly before building
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
```

**Problem: Build fails with Kotlin error**
```bash
# Ensure Java 17 is being used (Java 25+ causes Kotlin compilation issues)
$JAVA_HOME/bin/java -version
flutter doctor -v | grep java
```

---

## Docker Build Method (Most Reliable)

### Build Using Docker

```dockerfile
# Save as Dockerfile.build
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    git \
    curl \
    unzip \
    xz-utils \
    libglu1-mesa \
    android-platform-tools \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV ANDROID_HOME=/opt/android-sdk
RUN mkdir -p $ANDROID_HOME

# Download and install Flutter
RUN curl -o /tmp/flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.10.5-stable.tar.xz && \
    tar -xf /tmp/flutter.tar.xz -C /opt && \
    rm /tmp/flutter.tar.xz
ENV PATH="/opt/flutter/bin:$PATH"

# Accept Flutter & Android licenses
RUN flutter config --no-analytics
RUN yes | flutter doctor --android-licenses || true

WORKDIR /app
COPY . .

# Build APK
RUN flutter pub get && \
    flutter build apk --release \
      --build-name=1.32.11 \
      --build-number=33

CMD cp build/app/outputs/flutter-apk/app-release.apk /output/
```

### Execute Docker Build

```bash
# Build Docker image
docker build -f Dockerfile.build -t ztcd-builder .

# Run build and output APK
mkdir -p output
docker run --rm \
  -v "$(pwd)/output:/output" \
  ztcd-builder

# Check output
ls -lh output/app-release.apk
```

---

## Output

After successful build, the APK will be located at:
- **Local build**: `build/app/outputs/flutter-apk/app-release.apk`
- **GitHub Actions**: Available in Actions → Artifacts

### APK Details
- **File**: ZTCDv1.32.11.apk
- **Size**: ~50-60 MB (approximate)
- **Platform**: Android 5.0+ (API level 21+)
- **Version**: 1.32.11 (Build 33)

---

## Testing the Pre-Release APK

### Installation

```bash
# Using adb (Android Debug Bridge)
adb install build/app/outputs/flutter-apk/app-release.apk

# Or via file manager on device
# Transfer APK to device and tap to install
```

### First Run Configuration

1. **Permissions**: Grant location, Bluetooth, and storage permissions
2. **Gemini API Key**: Add in Settings → Gemini Configuration
3. **Google Maps Key**: Configure in AndroidManifest.xml before rebuild if needed
4. **OBD Connection**: Select transport (Bluetooth, USB, or Simulation)

---

## CI/CD Workflow Details

The GitHub Actions workflow:
- **Trigger**: Manual (`workflow_dispatch`) or on version tags (`v*`)
- **Runtime**: ~3-5 minutes
- **Java**: temurin-17
- **Flutter**: Latest stable
- **Artifacts**: Stored for 30 days
- **Release**: Auto-creates GitHub Release with APK

### Workflow File

Located at: `.github/workflows/build-release.yml`

Configuration:
- Version: 1.32.11
- Build Number: 33
- Signing: Debug key (pre-release)
- Release APK name: `ZTCDv1.32.11.apk`

---

## Next Steps

1. **For Quick Build**: Use GitHub Actions (Option 1)
2. **For Local Control**: Run local build method
3. **For Reliability**: Use Docker build method
4. **For Distribution**: 
   - Test APK thoroughly
   - Generate signed release APK for production
   - Prepare Google Play Store submission

---

## Production Build (Signed APK)

To create a production-ready, signed APK:

```bash
# Generate signing key (one-time)
keytool -genkey -v -keystore ~/release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias release-key

# Configure signing in android/key.properties
cat > android/key.properties <<EOF
storePassword=<your_store_password>
keyPassword=<your_key_password>
keyAlias=release-key
storeFile=/path/to/release-key.jks
EOF

# Build signed release APK
flutter build apk --release \
  --build-name=1.32.11 \
  --build-number=33

# Signed APK available at:
# build/app/outputs/flutter-apk/app-release.apk
```

---

## Support

For build issues:
- Check Flutter doctor: `flutter doctor -v`
- Review build logs in GitHub Actions
- Verify Java version: `java -version` (must be 17 LTS or 21 LTS)
- Check Android SDK packages: `sdkmanager --list --all`
