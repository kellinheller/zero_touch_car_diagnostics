/// Complete OBD-II Mode 01 PID definitions
/// Based on SAE J1979 standard for generic OBD-II PIDs
class ObdPid {
  final String pid;
  final String name;
  final String unit;
  final int minValue;
  final int maxValue;
  final String Function(List<int>) parser;

  const ObdPid({
    required this.pid,
    required this.name,
    required this.unit,
    required this.minValue,
    required this.maxValue,
    required this.parser,
  });
}

class ObdPidRegistry {
  // All generic OBD-II Mode 01 PIDs
  static final Map<String, ObdPid> pids = {
    '00': ObdPid(
      pid: '00',
      name: 'PIDs supported [01-20]',
      unit: 'bitfield',
      minValue: 0,
      maxValue: 0xFFFFFFFF,
      parser: (bytes) => '0x${bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}',
    ),
    '01': ObdPid(
      pid: '01',
      name: 'Monitor status since DTCs cleared',
      unit: 'bitfield',
      minValue: 0,
      maxValue: 0xFFFFFFFF,
      parser: (bytes) => '0x${bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}',
    ),
    '02': ObdPid(
      pid: '02',
      name: 'Freeze DTC',
      unit: 'code',
      minValue: 0,
      maxValue: 0xFFFF,
      parser: (bytes) => bytes.length >= 2 ? 'P${bytes[0].toRadixString(16)}${bytes[1].toRadixString(16)}' : 'N/A',
    ),
    '03': ObdPid(
      pid: '03',
      name: 'Fuel system status',
      unit: 'status',
      minValue: 0,
      maxValue: 255,
      parser: (bytes) => bytes.isNotEmpty ? _fuelSystemStatus(bytes[0]) : 'N/A',
    ),
    '04': ObdPid(
      pid: '04',
      name: 'Calculated engine load',
      unit: '%',
      minValue: 0,
      maxValue: 100,
      parser: (bytes) => bytes.isNotEmpty ? '${(bytes[0] * 100 / 255).toStringAsFixed(1)}' : '0',
    ),
    '05': ObdPid(
      pid: '05',
      name: 'Engine coolant temperature',
      unit: '°C',
      minValue: -40,
      maxValue: 215,
      parser: (bytes) => bytes.isNotEmpty ? '${bytes[0] - 40}' : '-40',
    ),
    '06': ObdPid(
      pid: '06',
      name: 'Short term fuel trim—Bank 1',
      unit: '%',
      minValue: -100,
      maxValue: 99,
      parser: (bytes) => bytes.isNotEmpty ? '${((bytes[0] - 128) * 100 / 128).toStringAsFixed(1)}' : '0',
    ),
    '07': ObdPid(
      pid: '07',
      name: 'Long term fuel trim—Bank 1',
      unit: '%',
      minValue: -100,
      maxValue: 99,
      parser: (bytes) => bytes.isNotEmpty ? '${((bytes[0] - 128) * 100 / 128).toStringAsFixed(1)}' : '0',
    ),
    '08': ObdPid(
      pid: '08',
      name: 'Short term fuel trim—Bank 2',
      unit: '%',
      minValue: -100,
      maxValue: 99,
      parser: (bytes) => bytes.isNotEmpty ? '${((bytes[0] - 128) * 100 / 128).toStringAsFixed(1)}' : '0',
    ),
    '09': ObdPid(
      pid: '09',
      name: 'Long term fuel trim—Bank 2',
      unit: '%',
      minValue: -100,
      maxValue: 99,
      parser: (bytes) => bytes.isNotEmpty ? '${((bytes[0] - 128) * 100 / 128).toStringAsFixed(1)}' : '0',
    ),
    '0A': ObdPid(
      pid: '0A',
      name: 'Fuel pressure',
      unit: 'kPa',
      minValue: 0,
      maxValue: 765,
      parser: (bytes) => bytes.isNotEmpty ? '${bytes[0] * 3}' : '0',
    ),
    '0B': ObdPid(
      pid: '0B',
      name: 'Intake manifold absolute pressure',
      unit: 'kPa',
      minValue: 0,
      maxValue: 255,
      parser: (bytes) => bytes.isNotEmpty ? '${bytes[0]}' : '0',
    ),
    '0C': ObdPid(
      pid: '0C',
      name: 'Engine RPM',
      unit: 'rpm',
      minValue: 0,
      maxValue: 16383,
      parser: (bytes) => bytes.length >= 2 ? '${((bytes[0] * 256 + bytes[1]) / 4).toInt()}' : '0',
    ),
    '0D': ObdPid(
      pid: '0D',
      name: 'Vehicle speed',
      unit: 'km/h',
      minValue: 0,
      maxValue: 255,
      parser: (bytes) => bytes.isNotEmpty ? '${bytes[0]}' : '0',
    ),
    '0E': ObdPid(
      pid: '0E',
      name: 'Timing advance',
      unit: '° before TDC',
      minValue: -64,
      maxValue: 63,
      parser: (bytes) => bytes.isNotEmpty ? '${(bytes[0] / 2) - 64}' : '-64',
    ),
    '0F': ObdPid(
      pid: '0F',
      name: 'Intake air temperature',
      unit: '°C',
      minValue: -40,
      maxValue: 215,
      parser: (bytes) => bytes.isNotEmpty ? '${bytes[0] - 40}' : '-40',
    ),
    '10': ObdPid(
      pid: '10',
      name: 'MAF air flow rate',
      unit: 'g/s',
      minValue: 0,
      maxValue: 655,
      parser: (bytes) => bytes.length >= 2 ? '${((bytes[0] * 256 + bytes[1]) / 100).toStringAsFixed(2)}' : '0',
    ),
    '11': ObdPid(
      pid: '11',
      name: 'Throttle position',
      unit: '%',
      minValue: 0,
      maxValue: 100,
      parser: (bytes) => bytes.isNotEmpty ? '${(bytes[0] * 100 / 255).toStringAsFixed(1)}' : '0',
    ),
    '12': ObdPid(
      pid: '12',
      name: 'Commanded secondary air status',
      unit: 'status',
      minValue: 0,
      maxValue: 255,
      parser: (bytes) => bytes.isNotEmpty ? _secondaryAirStatus(bytes[0]) : 'N/A',
    ),
    '13': ObdPid(
      pid: '13',
      name: 'Oxygen sensors present',
      unit: 'bitfield',
      minValue: 0,
      maxValue: 255,
      parser: (bytes) => bytes.isNotEmpty ? '0x${bytes[0].toRadixString(16).padLeft(2, '0')}' : '0x00',
    ),
    '14': ObdPid(
      pid: '14',
      name: 'O2 Sensor 1 Voltage',
      unit: 'V',
      minValue: 0,
      maxValue: 1,
      parser: (bytes) => bytes.isNotEmpty ? '${(bytes[0] / 200).toStringAsFixed(3)}' : '0',
    ),
    '1C': ObdPid(
      pid: '1C',
      name: 'OBD standards',
      unit: 'standard',
      minValue: 0,
      maxValue: 255,
      parser: (bytes) => bytes.isNotEmpty ? _obdStandard(bytes[0]) : 'Unknown',
    ),
    '1F': ObdPid(
      pid: '1F',
      name: 'Run time since engine start',
      unit: 'seconds',
      minValue: 0,
      maxValue: 65535,
      parser: (bytes) => bytes.length >= 2 ? '${bytes[0] * 256 + bytes[1]}' : '0',
    ),
    '21': ObdPid(
      pid: '21',
      name: 'Distance traveled with MIL on',
      unit: 'km',
      minValue: 0,
      maxValue: 65535,
      parser: (bytes) => bytes.length >= 2 ? '${bytes[0] * 256 + bytes[1]}' : '0',
    ),
    '2F': ObdPid(
      pid: '2F',
      name: 'Fuel Tank Level Input',
      unit: '%',
      minValue: 0,
      maxValue: 100,
      parser: (bytes) => bytes.isNotEmpty ? '${(bytes[0] * 100 / 255).toStringAsFixed(1)}' : '0',
    ),
    '31': ObdPid(
      pid: '31',
      name: 'Distance traveled since codes cleared',
      unit: 'km',
      minValue: 0,
      maxValue: 65535,
      parser: (bytes) => bytes.length >= 2 ? '${bytes[0] * 256 + bytes[1]}' : '0',
    ),
    '33': ObdPid(
      pid: '33',
      name: 'Absolute Barometric Pressure',
      unit: 'kPa',
      minValue: 0,
      maxValue: 255,
      parser: (bytes) => bytes.isNotEmpty ? '${bytes[0]}' : '0',
    ),
    '42': ObdPid(
      pid: '42',
      name: 'Control module voltage',
      unit: 'V',
      minValue: 0,
      maxValue: 65,
      parser: (bytes) => bytes.length >= 2 ? '${((bytes[0] * 256 + bytes[1]) / 1000).toStringAsFixed(3)}' : '0',
    ),
    '43': ObdPid(
      pid: '43',
      name: 'Absolute load value',
      unit: '%',
      minValue: 0,
      maxValue: 25700,
      parser: (bytes) => bytes.length >= 2 ? '${((bytes[0] * 256 + bytes[1]) * 100 / 255).toStringAsFixed(1)}' : '0',
    ),
    '44': ObdPid(
      pid: '44',
      name: 'Fuel–Air commanded equivalence ratio',
      unit: 'ratio',
      minValue: 0,
      maxValue: 2,
      parser: (bytes) => bytes.length >= 2 ? '${((bytes[0] * 256 + bytes[1]) / 32768).toStringAsFixed(3)}' : '0',
    ),
    '45': ObdPid(
      pid: '45',
      name: 'Relative throttle position',
      unit: '%',
      minValue: 0,
      maxValue: 100,
      parser: (bytes) => bytes.isNotEmpty ? '${(bytes[0] * 100 / 255).toStringAsFixed(1)}' : '0',
    ),
    '46': ObdPid(
      pid: '46',
      name: 'Ambient air temperature',
      unit: '°C',
      minValue: -40,
      maxValue: 215,
      parser: (bytes) => bytes.isNotEmpty ? '${bytes[0] - 40}' : '-40',
    ),
    '47': ObdPid(
      pid: '47',
      name: 'Absolute throttle position B',
      unit: '%',
      minValue: 0,
      maxValue: 100,
      parser: (bytes) => bytes.isNotEmpty ? '${(bytes[0] * 100 / 255).toStringAsFixed(1)}' : '0',
    ),
    '49': ObdPid(
      pid: '49',
      name: 'Accelerator pedal position D',
      unit: '%',
      minValue: 0,
      maxValue: 100,
      parser: (bytes) => bytes.isNotEmpty ? '${(bytes[0] * 100 / 255).toStringAsFixed(1)}' : '0',
    ),
    '4A': ObdPid(
      pid: '4A',
      name: 'Accelerator pedal position E',
      unit: '%',
      minValue: 0,
      maxValue: 100,
      parser: (bytes) => bytes.isNotEmpty ? '${(bytes[0] * 100 / 255).toStringAsFixed(1)}' : '0',
    ),
    '4C': ObdPid(
      pid: '4C',
      name: 'Commanded throttle actuator',
      unit: '%',
      minValue: 0,
      maxValue: 100,
      parser: (bytes) => bytes.isNotEmpty ? '${(bytes[0] * 100 / 255).toStringAsFixed(1)}' : '0',
    ),
    '4D': ObdPid(
      pid: '4D',
      name: 'Time run with MIL on',
      unit: 'minutes',
      minValue: 0,
      maxValue: 65535,
      parser: (bytes) => bytes.length >= 2 ? '${bytes[0] * 256 + bytes[1]}' : '0',
    ),
    '4E': ObdPid(
      pid: '4E',
      name: 'Time since trouble codes cleared',
      unit: 'minutes',
      minValue: 0,
      maxValue: 65535,
      parser: (bytes) => bytes.length >= 2 ? '${bytes[0] * 256 + bytes[1]}' : '0',
    ),
    '51': ObdPid(
      pid: '51',
      name: 'Fuel Type',
      unit: 'type',
      minValue: 0,
      maxValue: 255,
      parser: (bytes) => bytes.isNotEmpty ? _fuelType(bytes[0]) : 'Unknown',
    ),
    '52': ObdPid(
      pid: '52',
      name: 'Ethanol fuel %',
      unit: '%',
      minValue: 0,
      maxValue: 100,
      parser: (bytes) => bytes.isNotEmpty ? '${(bytes[0] * 100 / 255).toStringAsFixed(1)}' : '0',
    ),
    '5C': ObdPid(
      pid: '5C',
      name: 'Engine oil temperature',
      unit: '°C',
      minValue: -40,
      maxValue: 210,
      parser: (bytes) => bytes.isNotEmpty ? '${bytes[0] - 40}' : '-40',
    ),
    '5E': ObdPid(
      pid: '5E',
      name: 'Engine fuel rate',
      unit: 'L/h',
      minValue: 0,
      maxValue: 3276,
      parser: (bytes) => bytes.length >= 2 ? '${((bytes[0] * 256 + bytes[1]) * 0.05).toStringAsFixed(2)}' : '0',
    ),
  };

  // Helper functions for status decoding
  static String _fuelSystemStatus(int value) {
    switch (value) {
      case 0:
        return 'Not available';
      case 1:
        return 'Open loop';
      case 2:
        return 'Closed loop';
      case 4:
        return 'Open loop due to driving conditions';
      case 8:
        return 'Open loop due to system failure';
      case 16:
        return 'Closed loop, using O2 sensor feedback';
      default:
        return 'Unknown';
    }
  }

  static String _secondaryAirStatus(int value) {
    switch (value) {
      case 1:
        return 'Upstream';
      case 2:
        return 'Downstream of catalytic converter';
      case 4:
        return 'From outside atmosphere';
      case 8:
        return 'Pump commanded on';
      default:
        return 'Unknown';
    }
  }

  static String _obdStandard(int value) {
    final standards = {
      1: 'OBD-II (California ARB)',
      2: 'OBD (Federal EPA)',
      3: 'OBD and OBD-II',
      4: 'OBD-I',
      5: 'Not OBD compliant',
      6: 'EOBD (Europe)',
      7: 'EOBD and OBD-II',
    };
    return standards[value] ?? 'Unknown ($value)';
  }

  static String _fuelType(int value) {
    final types = {
      0: 'Not available',
      1: 'Gasoline',
      2: 'Methanol',
      3: 'Ethanol',
      4: 'Diesel',
      5: 'LPG',
      6: 'CNG',
      7: 'Propane',
      8: 'Electric',
      9: 'Bifuel (Gasoline/CNG)',
      10: 'Bifuel (Gasoline/LPG)',
      11: 'Bifuel (Gasoline/Ethanol)',
      12: 'Hybrid gasoline',
      13: 'Hybrid Ethanol',
      14: 'Hybrid Diesel',
      15: 'Hybrid Electric',
      16: 'Hybrid (regenerative)',
    };
    return types[value] ?? 'Unknown ($value)';
  }

  /// Get list of commonly monitored PIDs for dashboard
  static List<String> get dashboardPids => [
        '0C', // RPM
        '0D', // Speed
        '05', // Coolant temp
        '04', // Engine load
        '11', // Throttle position
        '10', // MAF
        '2F', // Fuel level
        '0F', // Intake air temp
      ];

  /// Get list of all supported PIDs
  static List<String> get allPids => pids.keys.toList()..sort();
}
