import 'dart:async';
import 'dart:math';

import 'obd_connection.dart';

class SimulationObdConnection implements ObdConnection {
  final _lineController = StreamController<String>.broadcast();
  final Random _rng = Random();

  @override
  Stream<String> get lines => _lineController.stream;

  @override
  Future<void> connect() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Fake latency
  }

  @override
  Future<void> write(String command) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (command.trim() == '01 0C') {
      // Simulate RPM (1000–4000)
      final rpm = 1000 + _rng.nextInt(3000);
      final a = (rpm * 4) ~/ 256;
      final b = (rpm * 4) % 256;
      _lineController.add('41 0C ${a.toRadixString(16).padLeft(2, '0').toUpperCase()} ${b.toRadixString(16).padLeft(2, '0').toUpperCase()}');
    } else if (command.trim() == '01 0D') {
      // Simulate speed (0–120 km/h)
      final speed = _rng.nextInt(121);
      _lineController.add('41 0D ${speed.toRadixString(16).padLeft(2, '0').toUpperCase()}');
    } else if (command.trim() == '01 05') {
      // Simulate coolant (80–100 C)
      final coolant = 80 + _rng.nextInt(21);
      final raw = coolant + 40; // OBD encodes as temp+40
      _lineController.add('41 05 ${raw.toRadixString(16).padLeft(2, '0').toUpperCase()}');
    }
  }

  @override
  Future<void> disconnect() async {
    await _lineController.close();
  }
}
