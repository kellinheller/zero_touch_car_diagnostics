import 'package:flutter/material.dart';

// import '../services/bluetooth_obd_connection.dart';
import '../services/diagnostics_service.dart';
import '../services/elm327_protocol.dart';
import '../services/gemini_client.dart';
import '../services/obd_connection.dart';
import '../services/simulation_obd_connection.dart';
import '../services/usb_obd_connection.dart';

class DiagnosticsPage extends StatefulWidget {
  const DiagnosticsPage({super.key});

  @override
  State<DiagnosticsPage> createState() => _DiagnosticsPageState();
}

class _DiagnosticsPageState extends State<DiagnosticsPage> {
  String _transport = 'Simulation';
  String _status = 'Idle';
  String _diagnosis = '';
  double _confidence = 0.0;

  ObdConnection? _conn;
  Elm327Protocol? _elm;

  Future<void> _connect() async {
    setState(() => _status = 'Connecting...');
    try {
      if (_transport == 'Bluetooth') {
        // Bluetooth temporarily disabled due to package compatibility
        setState(() => _status = 'Bluetooth support disabled');
        return;
        // _conn = BluetoothObdConnection();
      } else if (_transport == 'USB') {
        _conn = UsbObdConnection();
      } else {
        _conn = SimulationObdConnection();
      }
      _elm = Elm327Protocol(_conn!);
      await _elm!.initialize();
      setState(() => _status = 'Connected');
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  Future<void> _diagnose() async {
    if (_elm == null) return;
    setState(() => _status = 'Sampling...');
    final telemetry = await DiagnosticsService(_elm!).sampleOnce();

    setState(() => _status = 'Sending to Gemini...');
    final gemini = GeminiClient();
    final result = await gemini.diagnose(telemetry);
    setState(() {
      _diagnosis = (result['diagnosis'] ?? '').toString();
      _confidence = (result['confidence'] ?? 0.0) is num ? (result['confidence'] as num).toDouble() : 0.0;
      _status = 'Done';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zero-Touch Car Diagnostics')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                const Text('Transport:'),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _transport,
                  items: const [
                    DropdownMenuItem(value: 'Simulation', child: Text('Simulation (Dev)')),
                    DropdownMenuItem(value: 'Bluetooth', child: Text('Bluetooth')),
                    DropdownMenuItem(value: 'USB', child: Text('USB')),
                  ],
                  onChanged: (v) => setState(() => _transport = v ?? 'Simulation'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: _connect, child: const Text('Connect')),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: _diagnose, child: const Text('Diagnose')),
              ]),
            ),
            const SizedBox(height: 12),
            Text('Status: $_status'),
            const SizedBox(height: 12),
            Text('Diagnosis (confidence ${_confidence.toStringAsFixed(2)}):'),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
              child: Text(_diagnosis.isNotEmpty ? _diagnosis : 'No diagnosis yet.'),
            ),
          ],
        ),
      ),
    );
  }
}
