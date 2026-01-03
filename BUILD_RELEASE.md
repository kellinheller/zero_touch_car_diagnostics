# Build Instructions for v1.0.0 Release

## Android Build

Due to Java 25 compatibility issues with the Kotlin compiler, the Android APK/AAB should be built using:
- Java 17 LTS or Java 21 LTS
- gradle-8.3 or compatible

### Build Commands:
```bash
# Clean build
flutter clean
rm -rf android/app/build

# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build aab --release
```

### Output Files:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

## iOS Build

### Prerequisites:
- Xcode 14+
- iOS 12.0 or higher deployment target
- CocoaPods

### Build Commands:
```bash
# Pod install
cd ios && pod install && cd ..

# Build iOS app
flutter build ios --release

# Create IPA
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Release -derivedDataPath build/ios_build archive -archivePath build/ios_build/Runner.xcarchive
xcodebuild -exportArchive -archivePath build/ios_build/Runner.xcarchive -exportOptionsPlist ios/ExportOptions.plist -exportPath build/ios_build/ipa
```

### Output Files:
- IPA: `build/ios_build/ipa/Runner.ipa`

## Testing Before Release

1. Run unit tests:
   ```bash
   flutter test
   ```

2. Run integration tests:
   ```bash
   flutter test integration_test/
   ```

3. Test on real devices

## Release Checklist

- [ ] All tests passing
- [ ] Flutter analyze shows no issues
- [ ] Android APK built and tested
- [ ] iOS IPA built and tested
- [ ] Version number updated (v1.0.0)
- [ ] Release notes prepared
- [ ] Git tag created (v1.0.0)
- [ ] Artifacts uploaded to GitHub Release
