import 'elm327_protocol.dart';

class DiagnosticsService {
  final Elm327Protocol elm;
  DiagnosticsService(this.elm);

  Future<Map<String, dynamic>> sampleOnce() async {
    final rpmHex = await elm.query('01 0C') ?? '';
    final speedHex = await elm.query('01 0D') ?? '';
    final coolantHex = await elm.query('01 05') ?? '';

    final rpm = ObdPidParser.parseRpm(rpmHex);
    final speed = ObdPidParser.parseSpeed(speedHex);
    final coolant = ObdPidParser.parseCoolantTemp(coolantHex);

    return {
      'rpm': rpm,
      'speed_kmh': speed,
      'coolant_c': coolant,
      'raw': {
        '0C': rpmHex,
        '0D': speedHex,
        '05': coolantHex,
      }
    };
  }
}
