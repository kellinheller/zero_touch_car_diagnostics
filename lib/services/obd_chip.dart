/// Enum for supported OBD2 chip types
enum OBDChipType {
  elm327, // Original ELM327 (HS/HS mode)
  elm329, // ELM329 variant
  stm1110, // STN1110 (clone chip)
  ltc1260, // LTC1260 chip
  generic, // Generic OBD2 adapter
  unknown, // Unknown chip
}

/// Represents information about an OBD2 chip
class OBDChipInfo {
  final OBDChipType type;
  final String name;
  final String version;
  final List<String> supportedProtocols;
  final bool supportsJ1939;
  final bool supportsISO14229;

  OBDChipInfo({
    required this.type,
    required this.name,
    required this.version,
    required this.supportedProtocols,
    this.supportsJ1939 = false,
    this.supportsISO14229 = false,
  });

  @override
  String toString() => '$name (v$version) - $type';
}

/// Chip identification patterns
class ChipDetector {
  static OBDChipType detectChipType(String response) {
    final lower = response.toLowerCase();

    if (lower.contains('elm327')) return OBDChipType.elm327;
    if (lower.contains('elm329')) return OBDChipType.elm329;
    if (lower.contains('stn1110')) return OBDChipType.stm1110;
    if (lower.contains('ltc1260') || lower.contains('1260'))
      return OBDChipType.ltc1260;
    if (lower.contains('obd') || lower.contains('kw1281'))
      return OBDChipType.generic;

    return OBDChipType.unknown;
  }

  static String getInitializationCommand(OBDChipType type) {
    switch (type) {
      case OBDChipType.elm327:
      case OBDChipType.elm329:
        return 'AT I'; // Request device info
      case OBDChipType.stm1110:
        return 'AT@1'; // STN1110 version info
      case OBDChipType.ltc1260:
        return 'AT I'; // Generic init
      default:
        return 'AT I'; // Default to ELM command
    }
  }

  static List<String> getSupportedProtocols(OBDChipType type) {
    switch (type) {
      case OBDChipType.elm327:
        return [
          'SAE J1850 PWM',
          'SAE J1850 VPW',
          'ISO 9141-2',
          'ISO 14230 KWP',
          'ISO 15765-4 CAN',
        ];
      case OBDChipType.elm329:
        return [
          'SAE J1850 PWM',
          'SAE J1850 VPW',
          'ISO 9141-2',
          'ISO 14230 KWP',
          'ISO 15765-4 CAN',
          'J1939',
        ];
      case OBDChipType.stm1110:
        return [
          'SAE J1850 PWM',
          'SAE J1850 VPW',
          'ISO 9141-2',
          'ISO 14230 KWP',
          'ISO 15765-4 CAN',
          'J1939',
          'ISO 14229-1',
        ];
      case OBDChipType.ltc1260:
        return ['ISO 9141-2', 'ISO 14230 KWP', 'ISO 15765-4 CAN'];
      default:
        return [
          'SAE J1850 PWM',
          'SAE J1850 VPW',
          'ISO 9141-2',
          'ISO 14230 KWP',
          'ISO 15765-4 CAN',
        ];
    }
  }
}
