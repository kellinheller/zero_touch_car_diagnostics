import 'dart:async';

import 'package:flutter/services.dart';

class ObdService {
  static const MethodChannel _channel = MethodChannel('zero_touch.obd');

  static Future<bool> connect(String address) async {
    final res = await _channel.invokeMethod<bool>('connect', {'address': address});
    return res ?? false;
  }

  static Future<bool> disconnect() async {
    final res = await _channel.invokeMethod<bool>('disconnect');
    return res ?? false;
  }

  static Future<String> sendCommand(String cmd) async {
    final res = await _channel.invokeMethod<String>('sendCommand', {'cmd': cmd});
    return res ?? '';
  }

  static Future<Map<String, dynamic>> ping() async {
    final res = await _channel.invokeMethod('ping');
    if (res is Map) return Map<String, dynamic>.from(res);
    return {'healthy': false, 'response': ''};
  }

  static Future<List<Map<String, String>>> listPaired() async {
    final res = await _channel.invokeMethod<List>('listPaired');
    if (res == null) return [];
    return res.map((e) => Map<String, String>.from(e)).toList();
  }

  static Future<List<Map<String, String>>> scanDevices({int timeoutSeconds = 8}) async {
    final res = await _channel.invokeMethod<List>('scan', {'timeout': timeoutSeconds});
    if (res == null) return [];
    return res.map((e) => Map<String, String>.from(e)).toList();
  }

  static Future<bool> pair(String address) async {
    final res = await _channel.invokeMethod<bool>('pair', {'address': address});
    return res ?? false;
  }

  static Future<dynamic> requestPid(String pid) async {}
}
