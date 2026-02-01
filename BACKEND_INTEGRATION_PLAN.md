# Backend Integration Plan for Serial Device Car Diagnostics

## Overview

This document outlines how to integrate the serial device C++ backend into the Flutter mobile app (Android/iOS) to enable device communication, firmware updates, and diagnostics.

---

## Current State

### Flutter App

- **Location:** `/home/kal/zero_touch_car_diagnostics/`
- **Status:** Core diagnostics framework in place
- **Main entry:** `lib/main.dart`
- **Platforms ready:** Android, iOS

### Serial Device Backend

- **Location:** `backend/`
- **Language:** C++ (Unix/Linux cross-compatible)
- **Key components:**
  - **Device Serial:** `serialfinder.*` — Device discovery and communication
  - **Operations:** `abstractoperation.*`, `simpleserialoperation.*` — Base and serial operations
  - **Utilities:** Compression (gzip, tar), file management, version info
  - **Helpers:** Device info, firmware helpers, remote file fetcher

---

## Integration Strategy

### Option 1: Native C++ Library (Recommended for Full Functionality)

**Approach:** Compile serial device backend as a native Android/iOS library and expose via Flutter Platform Channels.

#### Android Setup

1. **Create a Kotlin wrapper** at `android/app/src/main/kotlin/com/zero_touch/diagnostics/FlipperBackend.kt`:

   ```kotlin
   package com.zero_touch.diagnostics

   import io.flutter.embedding.engine.FlutterEngine
   import io.flutter.embedding.engine.dart.DartExecutor
   import io.flutter.plugin.common.MethodChannel

   class FlipperBackendChannel {
       companion object {
           private const val CHANNEL = "com.zero_touch/flipper_backend"
       }

       fun setupChannel(flutterEngine: FlutterEngine) {
           val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
           channel.setMethodCallHandler { call, result ->
               when (call.method) {
                   "getDevices" -> {
                       // Call native C++ code to discover devices
                       result.success(listOf()) // Placeholder
                   }
                   "connectDevice" -> {
                       // Call native C++ connectDevice(deviceId)
                       result.success(true)
                   }
                   "installFirmware" -> {
                       val fwPath = call.argument<String>("path")
                       // Call native C++ install logic
                       result.success(null)
                   }
                   else -> result.notImplemented()
               }
           }
       }
   }
   ```

2. **Create CMake build config** at `android/app/CMakeLists.txt`:

   ```cmake
   cmake_minimum_required(VERSION 3.18)
   project(zero_touch_car_diagnostics)

   # Add serial device backend as a subdirectory
   add_subdirectory(../../backend serial_device_backend)

   # Create a wrapper library
   add_library(serial_bridge SHARED serial_bridge.cpp)
   target_link_libraries(serial_bridge PRIVATE serial_device_backend)
   ```

3. **Create JNI bridge** at `android/app/src/main/cpp/serial_bridge.cpp`:

   ```cpp
   #include <jni.h>
   #include <string>
   #include "../../backend/serialfinder.h"
   #include "../../backend/deviceregistry.h"

   extern "C" {
       JNIEXPORT jobjectArray JNICALL
       Java_com_zero_touch_diagnostics_SerialDeviceBackend_getDevices(JNIEnv *env, jobject) {
           // Call C++ SerialFinder to enumerate devices
           // Convert results to Java String array
           return nullptr; // Placeholder
       }
   }
   ```

4. **Update** `android/app/build.gradle.kts` to link CMake:

   ```kotlin
   android {
       externalNativeBuild {
           cmake {
               path = file("CMakeLists.txt")
           }
       }
   }
   ```

#### iOS Setup

1. **Create Objective-C bridge** at `ios/Runner/FlipperBackend.swift`:

   ```swift
   import Flutter

   class FlipperBackendChannel {
       static func setup(with controller: FlutterViewController) {
           let channel = FlutterMethodChannel(
               name: "com.zero_touch/flipper_backend",
               binaryMessenger: controller.binaryMessenger
           )
           
           channel.setMethodCallHandler { call, result in
               switch call.method {
               case "getDevices":
                   // Call native C++ via Bridging-Header
                   result([])
               case "connectDevice":
                   result(true)
               default:
                   result(FlutterMethodNotImplemented)
               }
           }
       }
   }
   ```

2. **Create Xcode bridging header** at `ios/Runner/FlipperBackend-Bridging-Header.h`:

   ```objc
   #ifndef FlipperBackend_Bridging_Header_h
   #define FlipperBackend_Bridging_Header_h

   #include "../../../backend/serialfinder.h"
   #include "../../../backend/deviceregistry.h"

   #endif
   ```

3. **Update** `ios/Runner/GeneratedPluginRegistrant.swift` to call setup in `main()`.

---

### Option 2: Lighter Integration (Serial Passthrough)

**Approach:** Keep serial device backend in a background service; communicate over USB/Bluetooth from Flutter.

- **Pros:** Simpler Flutter integration, less compilation hassle
- **Cons:** Requires a companion daemon or separate binary on device

**Steps:**

1. Compile serial device backend as a standalone binary for Android (`arm64-v8a`) and iOS (`armv7`, `arm64`)
2. Bundle binary in app assets
3. Extract and run at startup
4. Communicate via named sockets or HTTP server on localhost

---

### Option 3: Dart/Native Port (For Core Features Only)

**Approach:** Port critical device communication logic to Dart using `dart:ffi` or a simpler Kotlin/Swift layer.

- **Pros:** Pure Dart, no C++ compilation
- **Cons:** Requires background service management; lower-level integration

---

## Files to Port / Recompile

### High Priority (Device Communication)

- `serialfinder.h/cpp` — USB/Serial device enumeration (essential)
- `deviceregistry.h/cpp` — Device registry management
- `abstractoperation.h/cpp` — Base operation interface

### Medium Priority (Utilities)

- `simpleserialoperation.h/cpp` — Serial operations
- `logger.h/cpp` — Logging utilities
- `preferences.h/cpp` — Configuration management

### Low Priority (Optional)

- Compression utilities (`tarzipcompressor.*`, `gzipcompressor.*`)
- File management (`filenode.*`)
- Version info (`versioninfo.*`)

---

## Immediate Next Steps

### 1. Verify Android SDK / NDK Installation

```bash
# Check if Android SDK is installed
ls -la $ANDROID_SDK_ROOT/ndk

# If missing, install via Android Studio or CLI:
# https://developer.android.com/studio/install

# Accept SDK licenses
yes | sdkmanager --licenses
```

### 2. Resolve Gradle Build Issues

- Android NDK 28.2.13676358 license must be accepted
- Run: `sdkmanager --licenses`
- Retry: `cd android && ./gradlew assembleRelease`

### 3. Create Minimal Dart-to-Native Bridge (Quick Win)

- Create `lib/services/flipper_service.dart` to define method channel
- Stub implementation for now (returns mock data)
- Allows UI development to proceed independently

### 4. Plan C++ Recompilation

- Analyze serial device CMake/dependencies
- Identify which libs can compile without Qt (e.g., protobuf RPC, serial finder)
- Set up NDK cross-compilation environment

---

## Example: Simple Dart-Native Bridge (Can Start Now)

**File:** `lib/services/flipper_service.dart`

```dart
import 'package:flutter/services.dart';

class FlipperService {
  static const platform = MethodChannel('com.zero_touch/flipper_backend');

  static Future<List<String>> getDevices() async {
    try {
      final devices = await platform.invokeMethod<List>('getDevices');
      return devices?.cast<String>() ?? [];
    } catch (e) {
      print('Failed to get devices: $e');
      return [];
    }
  }

  static Future<bool> connectDevice(String deviceId) async {
    try {
      final result = await platform.invokeMethod<bool>(
        'connectDevice',
        {'deviceId': deviceId},
      );
      return result ?? false;
    } catch (e) {
      print('Failed to connect: $e');
      return false;
    }
  }

  static Future<void> installFirmware(String filePath) async {
    try {
      await platform.invokeMethod<void>(
        'installFirmware',
        {'path': filePath},
      );
    } catch (e) {
      print('Failed to install firmware: $e');
    }
  }
}
```

**Usage in UI:**

```dart
class DeviceListScreen extends StatefulWidget {
  @override
  _DeviceListScreenState createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  List<String> devices = [];

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  void _loadDevices() async {
    final foundDevices = await FlipperService.getDevices();
    setState(() {
      devices = foundDevices;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connected Devices')),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(devices[index]),
            onTap: () => FlipperService.connectDevice(devices[index]),
          );
        },
      ),
    );
  }
}
```

---

## Build & Deployment Checklist

- [ ] Android SDK & NDK 28.2.13676358 installed
- [ ] `sdkmanager --licenses` executed
- [ ] Kotlin/Swift platform channels stubbed
- [ ] Dart service layer created (`FlipperService`)
- [ ] Serial device CMake config analyzed for Android NDK cross-compilation
- [ ] JNI bridge skeleton in place
- [ ] iOS bridging header configured
- [ ] Test build: `flutter build apk --debug` (with licenses accepted)
- [ ] Test build: `flutter build ios` (on macOS with Xcode)
- [ ] Integration tests written for device discovery and connection

---

## Resources

- [Flutter Platform Channels](https://flutter.dev/docs/development/platform-integration/platform-channels)
- [Android NDK Build Setup](https://developer.android.com/ndk/guides/cmake)
- [iOS Native Integration](https://flutter.dev/docs/development/platform-integration/ios/c-interop)
- [Serial Device GitHub](https://github.com/flipperdevices/flipperzero-firmware)

---

**Last Updated:** 2025-12-23  
**Status:** Planning Phase – Ready for implementation
