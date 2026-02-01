import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/services.dart';

/// Service to interact with serial device backend native code.
/// Provides device discovery, connection, and firmware management.
class SerialDeviceService {
  static const MethodChannel _channel =
      MethodChannel('com.zero_touch/flipper_backend');

  /// Get list of connected/discovered Flipper devices.
  static Future<List<String>> getDevices() async {
    try {
      final List<dynamic> devices =
          await _channel.invokeMethod<List<dynamic>>('getDevices') ?? [];
      return devices.cast<String>();
    } catch (e) {
      if (kDebugMode) {
        print('SerialDeviceService.getDevices() error: $e');
      }
      return [];
    }
  }

  /// Connect to a device by ID.
  static Future<bool> connectDevice(String deviceId) async {
    try {
      final bool? result = await _channel.invokeMethod<bool>(
        'connectDevice',
        {'deviceId': deviceId},
      );
      return result ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('SerialDeviceService.connectDevice() error: $e');
      }
      return false;
    }
  }

  /// Disconnect from the current device.
  static Future<void> disconnectDevice() async {
    try {
      await _channel.invokeMethod<void>('disconnectDevice');
    } catch (e) {
      if (kDebugMode) {
        print('SerialDeviceService.disconnectDevice() error: $e');
      }
    }
  }

  /// Install firmware from file path.
  static Future<void> installFirmware(String filePath) async {
    try {
      await _channel.invokeMethod<void>(
        'installFirmware',
        {'path': filePath},
      );
    } catch (e) {
      if (kDebugMode) {
        print('SerialDeviceService.installFirmware() error: $e');
      }
      rethrow;
    }
  }

  /// Get device information (name, version, etc).
  static Future<Map<String, dynamic>?> getDeviceInfo() async {
    try {
      final Map<dynamic, dynamic>? info =
          await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'getDeviceInfo',
      );
      return info?.cast<String, dynamic>();
    } catch (e) {
      if (kDebugMode) {
        print('SerialDeviceService.getDeviceInfo() error: $e');
      }
      return null;
    }
  }

  /// Perform a factory reset on the device.
  static Future<void> factoryReset() async {
    try {
      await _channel.invokeMethod<void>('factoryReset');
    } catch (e) {
      if (kDebugMode) {
        print('SerialDeviceService.factoryReset() error: $e');
      }
      rethrow;
    }
  }

  /// Start listening to device updates (screen frames, state changes).
  static Stream<Map<String, dynamic>> onDeviceUpdate() {
    final controller = StreamController<Map<String, dynamic>>();
    
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onDeviceUpdate') {
        final update = Map<String, dynamic>.from(call.arguments);
        controller.add(update);
      }
    });

    return controller.stream;
  }
}
