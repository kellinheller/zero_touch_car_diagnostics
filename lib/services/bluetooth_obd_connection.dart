import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'obd_connection.dart';

class BluetoothObdConnection implements ObdConnection {
  BluetoothConnection? _conn;
  final _lineController = StreamController<String>.broadcast();
  final _buffer = StringBuffer();
  Timer? _keepAliveTimer;
  bool _isConnected = false;
  DateTime _lastActivity = DateTime.now();

  @override
  Stream<String> get lines => _lineController.stream;

  @override
  Future<void> connect() async {
    try {
      // Discover bonded devices and try to find typical ELM327 names
      final devices = await FlutterBluetoothSerial.instance.getBondedDevices();
      final elm = devices.firstWhere(
        (d) => (d.name?.toLowerCase().contains('elm') ?? false) ||
                (d.name?.toLowerCase().contains('obd') ?? false),
        orElse: () => devices.isNotEmpty ? devices.first : (throw Exception('No paired Bluetooth devices found')),
      );
      _conn = await BluetoothConnection.toAddress(elm.address);
      _isConnected = true;
      _lastActivity = DateTime.now();
      
      _conn!.input!.listen(
        _onData,
        onDone: () {
          _isConnected = false;
          _keepAliveTimer?.cancel();
          _lineController.close();
        },
        onError: (error) {
          print('Bluetooth connection error: $error');
          _isConnected = false;
          _keepAliveTimer?.cancel();
        },
      );
      
      // Start keep-alive mechanism
      _startKeepAlive();
    } catch (e) {
      _isConnected = false;
      rethrow;
    }
  }

  void _startKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (!_isConnected) {
        timer.cancel();
        return;
      }
      
      // Check if connection is stale (no activity for 30 seconds)
      final timeSinceLastActivity = DateTime.now().difference(_lastActivity);
      if (timeSinceLastActivity.inSeconds > 30) {
        // Send a simple command to keep connection alive
        try {
          await write('0100'); // Request supported PIDs (lightweight command)
        } catch (e) {
          print('Keep-alive failed: $e');
          _isConnected = false;
          timer.cancel();
        }
      }
    });
  }

  void _onData(Uint8List data) {
    _lastActivity = DateTime.now();
    final chunk = ascii.decode(data);
    _buffer.write(chunk);
    // Split by CR/LF typical for ELM327 ('\r' or '>')
    String text = _buffer.toString();
    int idx;
    while ((idx = text.indexOf('\r')) != -1) {
      final line = text.substring(0, idx).trim();
      if (line.isNotEmpty) _lineController.add(line);
      text = text.substring(idx + 1);
    }
    _buffer.clear();
    _buffer.write(text);
  }

  @override
  Future<void> write(String command) async {
      if (!_isConnected || _conn == null) {
        throw Exception('Bluetooth not connected');
      }
      _lastActivity = DateTime.now();
    final cmd = (command.endsWith('\r') ? command : '$command\r');
    _conn?.output.add(ascii.encode(cmd));
    await _conn?.output.allSent;
  }

  @override
  Future<void> disconnect() async {
      _isConnected = false;
      _keepAliveTimer?.cancel();
      _keepAliveTimer = null;
    await _conn?.finish();
    await _conn?.close();
    await _lineController.close();
  }
}
