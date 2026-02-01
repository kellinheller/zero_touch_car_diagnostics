import 'dart:async';
import 'obd_connection.dart';

class Elm327Protocol {
  final ObdConnection transport;
  Elm327Protocol(this.transport);

  Future<void> initialize() async {
    await transport.connect();
    // Basic ELM init sequence
    await transport.write('ATZ');
    await transport.write('ATE0'); // echo off
    await transport.write('ATL0'); // linefeeds off
    await transport.write('ATS0'); // printing of spaces off
    await transport.write('ATH0'); // headers off
    await transport.write('ATSP0'); // auto protocol
  }

  Future<String?> query(String modePid) async {
    // Example: '01 0C' for RPM
    await transport.write(modePid);
    return await transport.lines.firstWhere((l) => l.isNotEmpty && !l.startsWith('AT'), orElse: () => '');
  }
}

class ObdPidParser {
  static int parseRpm(String hexResponse) {
    // Response like: 41 0C AA BB -> RPM = ((A*256)+B)/4
    final bytes = _extractDataBytes(hexResponse);
    if (bytes.length < 4) return 0;
    final a = bytes[2];
    final b = bytes[3];
    return (((a * 256) + b) ~/ 4);
  }

  static int parseSpeed(String hexResponse) {
    // 41 0D VV -> speed km/h
    final bytes = _extractDataBytes(hexResponse);
    if (bytes.length < 3) return 0;
    return bytes[2];
  }

  static int parseCoolantTemp(String hexResponse) {
    // 41 05 VV -> temp C = VV - 40
    final bytes = _extractDataBytes(hexResponse);
    if (bytes.length < 3) return 0;
    return bytes[2] - 40;
  }

  static List<int> _extractDataBytes(String hex) {
    final parts = hex.trim().split(RegExp(r"\s+"));
    return parts.where((p) => p.length == 2).map((p) => int.tryParse(p, radix: 16) ?? 0).toList();
  }
}
