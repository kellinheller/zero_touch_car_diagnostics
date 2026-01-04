import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:usb_serial/usb_serial.dart';
import 'obd_connection.dart';

class UsbObdConnection implements ObdConnection {
  UsbPort? _port;
  final _lineController = StreamController<String>.broadcast();
  final _buffer = StringBuffer();

  @override
  Stream<String> get lines => _lineController.stream;

  @override
  Future<void> connect() async {
    final devices = await UsbSerial.listDevices();
    if (devices.isEmpty) throw Exception('No USB devices found');
    // Pick first; production should filter by vendor/product or user selection
    _port = await devices.first.create();
    if (!await _port!.open()) throw Exception('Failed to open USB port');
    await _port!.setDTR(true);
    await _port!.setRTS(true);
    await _port!.setPortParameters(38400, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);
    _port!.inputStream?.listen(_onData, onDone: () => _lineController.close());
  }

  void _onData(Uint8List data) {
    final chunk = ascii.decode(data);
    _buffer.write(chunk);
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
    await _port?.write(Uint8List.fromList(ascii.encode(cmd)));
  }

  @override
  Future<void> disconnect() async {
    await _port?.close();
    await _lineController.close();
  }
}
