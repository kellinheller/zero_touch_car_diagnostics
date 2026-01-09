import 'dart:async';

import 'obd_chip.dart';

/// Generic OBD2 protocol handler supporting multiple chips
class OBD2Protocol {
  late final OBDChipType chipType;
  final Duration responseTimeout;

  OBD2Protocol({this.responseTimeout = const Duration(seconds: 5)});

  final _responseQueue = <String>[];

  /// Standard OBD2 PIDs (Parameter IDs) supported across all chips
  static const Map<String, String> standardPIDs = {
    // Mode 01 - Show current data
    '0100': 'Supported PIDs (01-20)',
    '0101': 'Monitor status since DTCs cleared',
    '0102': 'DTC that triggered MIL',
    '0103': 'Fuel system status',
    '0104': 'Engine load',
    '0105': 'Engine coolant temperature',
    '0106': 'Short-term fuel trim (Bank 1)',
    '0107': 'Long-term fuel trim (Bank 1)',
    '0108': 'Short-term fuel trim (Bank 2)',
    '0109': 'Long-term fuel trim (Bank 2)',
    '010A': 'Fuel pressure (fuel injection pressure)',
    '010B': 'Intake manifold absolute pressure',
    '010C': 'Engine speed',
    '010D': 'Vehicle speed',
    '010E': 'Timing advance',
    '010F': 'Intake air temperature',
    '0110': 'Mass air flow sensor (MAF) air flow rate',
    '0111': 'Throttle position',
    '0112': 'Secondary air status',
    '0113': 'Oxygen sensors present',
    '0114': 'Oxygen sensor 1 (Bank 1, Sensor 1)',
    '0115': 'Oxygen sensor 2 (Bank 1, Sensor 2)',
    '0116': 'Oxygen sensor 3 (Bank 2, Sensor 1)',
    '0117': 'Oxygen sensor 4 (Bank 2, Sensor 2)',
    '0118': 'Oxygen sensor 5 (Bank 1, Sensor 3)',
    '0119': 'Oxygen sensor 6 (Bank 1, Sensor 4)',
    '011A': 'Oxygen sensor 7 (Bank 2, Sensor 3)',
    '011B': 'Oxygen sensor 8 (Bank 2, Sensor 4)',
    '011C': 'OBD standards this vehicle conforms to',
    '011D': 'Oxygen sensors present (legacy)',
    '011E': 'Auxiliary input status',
    '011F': 'Run time since engine start',
    '0120': 'Supported PIDs (21-40)',
  };

  /// Advanced PIDs for specific chips
  const Map<OBDChipType, Map<String, String>> advancedPIDs = {
    OBDChipType.elm329: {
      '0121': 'Distance traveled with MIL on',
      '0122': 'Fuel rail pressure (diesel)',
    },
    OBDChipType.stm1110: {
      '0121': 'Distance traveled with MIL on',
      '0122': 'Fuel rail pressure (diesel)',
      '0123': 'Fuel rail pressure (gasoline)',
      '0124': 'Commanded EGR valve position',
      '0125': 'EGR error',
    },
  };

  /// Build a PID query command
  String buildPIDCommand(String pid, {String mode = '01'}) {
    return '$mode$pid\r';
  }

  /// Parse OBD2 response
  Map<String, dynamic> parseResponse(String response) {
    final result = <String, dynamic>{};

    // Remove spaces and line breaks
    final cleaned = response
        .replaceAll(' ', '')
        .replaceAll('\r', '')
        .replaceAll('\n', '');

    if (cleaned.contains('>')) {
      // ELM327 style prompt - error
      result['error'] = 'No response from vehicle';
      return result;
    }

    if (cleaned.isEmpty) {
      result['error'] = 'Empty response';
      return result;
    }

    // Parse mode and PID from response
    if (cleaned.length >= 4) {
      final mode = cleaned.substring(0, 2);
      final pid = cleaned.substring(2, 4);
      final data = cleaned.length > 4 ? cleaned.substring(4) : '';

      result['mode'] = mode;
      result['pid'] = pid;
      result['data'] = data;
      result['raw'] = response;
    }

    return result;
  }

  /// Check if adapter responds (connectivity test)
  Future<bool> testConnection(Stream<String> responseStream) async {
    try {
      final sub = responseStream.listen(
        (line) => _responseQueue.add(line),
        cancelOnError: true,
      );

      await Future.delayed(const Duration(milliseconds: 500));
      sub.cancel();

      return _responseQueue.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Auto-detect protocol
  Future<String> detectProtocol(Stream<String> responseStream) async {
    // Send protocol detection command
    return 'ATSP0\r'; // Auto protocol detection
  }

  /// Get list of supported PID commands for this chip
  List<String> getSupportedPIDs() {
    final allPIDs = [...standardPIDs.entries];

    if (advancedPIDs.containsKey(chipType)) {
      allPIDs.addAll(advancedPIDs[chipType]!.entries);
    }

    return allPIDs.map((e) => e.key).toList();
  }

  /// Get PID description
  String getPIDDescription(String pid) {
    if (standardPIDs.containsKey(pid)) {
      return standardPIDs[pid]!;
    }

    if (advancedPIDs.containsKey(chipType) &&
        advancedPIDs[chipType]!.containsKey(pid)) {
      return advancedPIDs[chipType]![pid]!;
    }

    return 'Unknown PID';
  }
}

/// Simple async lock for response handling
class AsyncLock {
  bool _locked = false;
  final _waiters = <Completer<void>>[];

  Future<void> lock() async {
    while (_locked) {
      final completer = Completer<void>();
      _waiters.add(completer);
      await completer.future;
    }
    _locked = true;
  }

  void unlock() {
    if (_waiters.isNotEmpty) {
      _waiters.removeAt(0).complete();
    } else {
      _locked = false;
    }
  }
}
