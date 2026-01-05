import 'package:flutter/material.dart';

import '../services/bluetooth_obd_connection.dart';
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
        _conn = BluetoothObdConnection();
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
      _confidence = (result['confidence'] ?? 0.0) is num
          ? (result['confidence'] as num).toDouble()
          : 0.0;
      _status = 'Done';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Zero-Touch Car Diagnostics',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.cyan,
        elevation: 8,
        shadowColor: Colors.cyan.withOpacity(0.5),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.cyan.shade50,
              Colors.blue.shade50,
              Colors.teal.shade50,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Text('Transport:'),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _transport,
                      items: const [
                        DropdownMenuItem(
                          value: 'Simulation',
                          child: Text('Simulation (Dev)'),
                        ),
                        DropdownMenuItem(
                          value: 'Bluetooth',
                          child: Text('Bluetooth'),
                        ),
                        DropdownMenuItem(value: 'USB', child: Text('USB')),
                      ],
                      onChanged: (v) =>
                          setState(() => _transport = v ?? 'Simulation'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _connect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Connect'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _diagnose,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Diagnose'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.cyan.withOpacity(0.15),
                  border: Border.all(color: Colors.cyan, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status: $_status',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Diagnosis (confidence ${_confidence.toStringAsFixed(2)}):',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.lime.shade50,
                  border: Border.all(color: Colors.lime, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.lime.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  _diagnosis.isNotEmpty
                      ? _diagnosis
                      : 'No diagnosis yet. Click "Diagnose" to start!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.lime.shade900,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
