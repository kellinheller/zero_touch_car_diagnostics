# Pre-Release APK Quick Reference

## Fastest Method: GitHub Actions (2-3 clicks, 3-5 minutes)

### Step 1: Open GitHub
https://github.com/yourusername/zero_touch_car_diagnostics

### Step 2: Navigate to Actions
Click the **Actions** tab → Select **Build Release APK**

### Step 3: Run Workflow
Click **Run workflow** → Select branch → **Run workflow**

### Step 4: Download
Wait for completion → Click build → Download artifact `ZTCDv1.32.11.apk`

---

## Local Quick Build

### Prerequisites
```bash
# Install Java 17
sudo apt-get install -y openjdk-17-jdk

# Install/Update Flutter
# Download from: https://flutter.dev/docs/get-started/install/linux
# Or use existing installation
```

### One-Command Build
```bash
cd /home/kal/zero_touch_car_diagnostics
./build-prerelease-quick.sh
```

### Manual Build Steps
```bash
# Set up environment
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Navigate to project
cd /home/kal/zero_touch_car_diagnostics

# Clean & build
flutter clean
flutter pub get
flutter build apk --release --build-name=1.32.11 --build-number=33

# Output location
# build/app/outputs/flutter-apk/app-release.apk
```

---

## Via Git Tag (Automatic GitHub Actions)
```bash
git tag -a v1.32.11 -m "Pre-release v1.32.11"
git push origin v1.32.11
# Workflow triggers automatically
```

---

## Install APK on Device

### Using ADB
```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

### Manual Install
1. Connect device via USB
2. Transfer APK to device
3. Tap APK file to install
4. Grant permissions when prompted

---

## APK Details

| Property | Value |
|----------|-------|
| **App Name** | Zero-Touch Car Diagnostics |
| **Version** | 1.32.11 |
| **Build Number** | 33 |
| **Min SDK** | Android 5.0 (API 21) |
| **Target SDK** | Android 13+ |
| **Size** | ~50-60 MB |
| **Signing** | Debug key (pre-release) |

---

## Verification Checklist

After building:
- [ ] APK file exists at expected location
- [ ] File size is 50-60 MB
- [ ] Version shows as 1.32.11 in properties
- [ ] Installs without errors
- [ ] App launches without crashes

---

## First Run Checklist

After installation:
- [ ] Grant location permission
- [ ] Grant Bluetooth permission
- [ ] Add Gemini API key (Settings)
- [ ] Select OBD transport (Simulation for testing)
- [ ] Test dashboard (should show mock data in simulation mode)

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `Flutter not found` | Install Flutter: https://flutter.dev/docs/get-started/install |
| `Java not found` | `sudo apt-get install -y openjdk-17-jdk` |
| `Build fails with Gradle error` | Set `export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64` |
| `APK not created` | Check logs, ensure Android SDK is configured |
| `Installation fails` | Uninstall old version first: `adb uninstall com.example.zero_touch_car_diagnostics` |

---

## Build Times

- **GitHub Actions**: 3-5 minutes (includes setup)
- **Local (cached)**: 2-3 minutes (after first build)
- **Local (fresh)**: 5-10 minutes (first time setup)
- **Docker**: 10-15 minutes (includes image build)

---

## Documentation

- **Full Build Guide**: [BUILD_PRERELEASE_APK.md](BUILD_PRERELEASE_APK.md)
- **Integration Docs**: [OBD_INTEGRATION.md](OBD_INTEGRATION.md)
- **Main README**: [README.md](README.md)
- **Build Script**: [build-prerelease-quick.sh](build-prerelease-quick.sh)

---

## Support

For issues:
1. Check [BUILD_PRERELEASE_APK.md](BUILD_PRERELEASE_APK.md) troubleshooting section
2. Review [OBD_INTEGRATION.md](OBD_INTEGRATION.md) for setup details
3. Check GitHub Actions logs for build errors
4. Run `flutter doctor -v` for environment diagnostics

---

**Last Updated**: February 17, 2026
**Version**: 1.32.11
**Status**: Ready for Pre-Release Testing
