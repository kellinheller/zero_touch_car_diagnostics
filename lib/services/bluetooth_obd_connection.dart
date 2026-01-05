import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'obd_connection.dart';

class BluetoothObdConnection implements ObdConnection {
  BluetoothConnection? _conn;
  final _lineController = StreamController<String>.broadcast();
  final _buffer = StringBuffer();

  @override
  Stream<String> get lines => _lineController.stream;

  @override
  Future<void> connect() async {
    // Discover bonded devices and try to find typical ELM327 names
    final devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    final elm = devices.firstWhere(
      (d) => (d.name?.toLowerCase().contains('elm') ?? false) ||
              (d.name?.toLowerCase().contains('obd') ?? false),
      orElse: () => devices.isNotEmpty ? devices.first : (throw Exception('No paired Bluetooth devices found')),
    );
    _conn = await BluetoothConnection.toAddress(elm.address);
    _conn!.input!.listen(_onData, onDone: () => _lineController.close());
  }

  void _onData(Uint8List data) {
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
    final cmd = (command.endsWith('\r') ? command : '$command\r');
    _conn?.output.add(ascii.encode(cmd));
    await _conn?.output.allSent;
  }

  @override
  Future<void> disconnect() async {
    await _conn?.finish();
    await _conn?.close();
    await _lineController.close();
  }
}
