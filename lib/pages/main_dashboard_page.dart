import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/bluetooth_obd_connection.dart';
import '../services/diagnostics_service.dart';
import '../services/elm327_protocol.dart';
import '../services/gemini_client.dart';
import '../services/obd_connection.dart';
import '../services/simulation_obd_connection.dart';
import '../services/usb_obd_connection.dart';
import '../services/settings_service.dart';
import '../services/obd_pid_registry.dart';
import '../services/trip_logging_service.dart';
import '../services/route_analyzer_service.dart';
import '../widgets/car_status_widget.dart';
import '../widgets/gauge_widget.dart';
import 'settings_page.dart';

class MainDashboardPage extends StatefulWidget {
  const MainDashboardPage({super.key});

  @override
  State<MainDashboardPage> createState() => _MainDashboardPageState();
}

class _MainDashboardPageState extends State<MainDashboardPage> with SingleTickerProviderStateMixin {
  // Connection
  String _transport = 'Simulation';
  String _status = 'Disconnected';
  ObdConnection? _conn;
  Elm327Protocol? _elm;

  // Map
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final List<LatLng> _routePoints = [];

  // OBD Data
  final Map<String, String> _obdData = {};
  final List<String> _supportedPids = [];
  Timer? _obdUpdateTimer;

  // Trip logging
  final _tripLogger = TripLoggingService();
  bool _isRecording = false;

  // Diagnosis
  String _diagnosis = '';
  double _confidence = 0.0;

  // Tab controller
  late TabController _tabController;

  // Settings
  final _settings = SettingsService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeLocation();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Geolocator.requestPermission();
  }

  Future<void> _initializeLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });

      // Update location stream
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );

      Geolocator.getPositionStream(locationSettings: locationSettings).listen((position) {
        setState(() {
          _currentPosition = position;
          _markers.clear();
          _markers.add(Marker(
            markerId: const MarkerId('current'),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: const InfoWindow(title: 'Current Location'),
          ));

          if (_isRecording) {
            _routePoints.add(LatLng(position.latitude, position.longitude));
            _polylines.clear();
            _polylines.add(Polyline(
              polylineId: const PolylineId('route'),
              points: _routePoints,
              color: Colors.blue,
              width: 4,
            ));
          }
        });

        _mapController?.animateCamera(
          CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
        );
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

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
      await _discoverSupportedPids();
      setState(() => _status = 'Connected');

      // Start periodic OBD data updates
      _startObdUpdates();
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  Future<void> _disconnect() async {
    _stopObdUpdates();
    if (_isRecording) {
      await _stopTrip();
    }
    await _conn?.disconnect();
    setState(() {
      _status = 'Disconnected';
      _elm = null;
      _conn = null;
      _obdData.clear();
    });
  }

  void _startObdUpdates() {
    _obdUpdateTimer?.cancel();
    _obdUpdateTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_elm == null) {
        timer.cancel();
        return;
      }

      try {
        final pidsToQuery = _supportedPids.isNotEmpty ? _supportedPids : ObdPidRegistry.allPids;
        for (final pid in pidsToQuery) {
          final response = await _elm!.query('01 $pid');
          if (response != null && response.isNotEmpty) {
            final bytes = _extractDataBytes(response);
            if (bytes.length >= 3) {
              // Remove mode and PID bytes, keep data
              final dataBytes = bytes.sublist(2);
              final pidDef = ObdPidRegistry.pids[pid];
              final value = pidDef != null ? pidDef.parser(dataBytes) : _formatRawBytes(dataBytes);
              setState(() {
                _obdData[pid] = value;
              });
            }
          }
        }

        // Log trip entry if recording
        if (_isRecording) {
          await _tripLogger.logEntry(_obdData);
        }
      } catch (e) {
        print('Error updating OBD data: $e');
      }
    });
  }

  void _stopObdUpdates() {
    _obdUpdateTimer?.cancel();
    _obdUpdateTimer = null;
  }

  List<int> _extractDataBytes(String hex) {
    final parts = hex.trim().split(RegExp(r"\s+"));
    return parts.where((p) => p.length == 2).map((p) => int.tryParse(p, radix: 16) ?? 0).toList();
  }

  String _formatRawBytes(List<int> dataBytes) {
    return dataBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ').toUpperCase();
  }

  Future<void> _discoverSupportedPids() async {
    if (_elm == null) return;
    _supportedPids.clear();

    for (var base = 0x00; base <= 0xC0; base += 0x20) {
      final pid = base.toRadixString(16).padLeft(2, '0').toUpperCase();
      final response = await _elm!.query('01 $pid');
      if (response == null || response.isEmpty) continue;

      final bytes = _extractDataBytes(response);
      if (bytes.length < 6) continue;

      final supported = _parseSupportedPidBits(bytes.sublist(2, 6), base);
      _supportedPids.addAll(supported);
    }

    _supportedPids.sort();
  }

  List<String> _parseSupportedPidBits(List<int> bitfieldBytes, int basePid) {
    final pids = <String>[];
    if (bitfieldBytes.length < 4) return pids;

    final bitfield = (bitfieldBytes[0] << 24) |
        (bitfieldBytes[1] << 16) |
        (bitfieldBytes[2] << 8) |
        bitfieldBytes[3];

    for (var i = 0; i < 32; i++) {
      final mask = 1 << (31 - i);
      if ((bitfield & mask) != 0) {
        final pidValue = basePid + i + 1;
        final pid = pidValue.toRadixString(16).padLeft(2, '0').toUpperCase();
        if (!_supportedPids.contains(pid)) {
          pids.add(pid);
        }
      }
    }
    return pids;
  }

  Future<void> _startTrip() async {
    await _tripLogger.startTrip();
    setState(() {
      _isRecording = true;
      _routePoints.clear();
      _polylines.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trip recording started')),
    );
  }

  Future<void> _stopTrip() async {
    await _tripLogger.stopTrip();
    setState(() {
      _isRecording = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trip recording stopped and saved')),
    );
  }

  Future<void> _diagnose() async {
    if (_elm == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please connect to OBD adapter first')),
      );
      return;
    }

    setState(() => _status = 'Diagnosing...');

    try {
      // Get comprehensive telemetry
      final telemetry = await DiagnosticsService(_elm!).sampleOnce();
      telemetry['realtime_data'] = _obdData;

      // Check if Gemini is configured
      final apiKey = await _settings.getGeminiApiKey();
      final useGemini = await _settings.getUseGemini();

      if (!useGemini || apiKey == null || apiKey.isEmpty) {
        setState(() {
          _status = 'Connected';
          _diagnosis = 'Please configure Gemini API key in Settings to enable AI diagnostics';
          _confidence = 0.0;
        });
        return;
      }

      setState(() => _status = 'Analyzing with Gemini...');

      final model = await _settings.getGeminiModel();
      final gemini = GeminiClient(apiKey: apiKey, modelName: model);
      final result = await gemini.diagnose(telemetry);

      setState(() {
        _diagnosis = (result['diagnosis'] ?? 'No diagnosis available').toString();
        _confidence = (result['confidence'] ?? 0.0) is num ? (result['confidence'] as num).toDouble() : 0.0;
        _status = 'Connected';
      });
    } catch (e) {
      setState(() {
        _status = 'Connected';
        _diagnosis = 'Error: $e';
        _confidence = 0.0;
      });
    }
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Car Status Widget
          CarStatusWidget(obdData: _obdData, isConnected: _status == 'Connected', isRecording: _isRecording),
          const SizedBox(height: 16),

          // Gauge Cluster
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                GaugeWidget(
                  label: 'RPM',
                  value: double.tryParse(_obdData['010C'] ?? '0') ?? 0.0,
                  maxValue: 8000,
                  unit: 'rpm',
                  color: Colors.blue,
                ),
                const SizedBox(width: 16),
                GaugeWidget(
                  label: 'Speed',
                  value: double.tryParse(_obdData['010D'] ?? '0') ?? 0.0,
                  maxValue: 200,
                  unit: 'km/h',
                  color: Colors.green,
                ),
                const SizedBox(width: 16),
                GaugeWidget(
                  label: 'Coolant Temp',
                  value: double.tryParse(_obdData['0105'] ?? '0') ?? 0.0,
                  maxValue: 120,
                  unit: '°C',
                  color: Colors.orange,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Map Preview
          Card(
            child: SizedBox(
              height: 220,
              child: _currentPosition == null
                  ? const Center(child: CircularProgressIndicator())
                  : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                        zoom: 15,
                      ),
                      markers: _markers,
                      polylines: _polylines,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      onMapCreated: (controller) => _mapController = controller,
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // Connection Controls
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Connection', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          value: _transport,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: 'Simulation', child: Text('Simulation (Dev)')),
                            DropdownMenuItem(value: 'Bluetooth', child: Text('Bluetooth')),
                            DropdownMenuItem(value: 'USB', child: Text('USB')),
                          ],
                          onChanged: (v) => setState(() => _transport = v ?? 'Simulation'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _status == 'Connected' || _status == 'Connecting...'
                          ? ElevatedButton.icon(
                              icon: const Icon(Icons.stop),
                              label: const Text('Disconnect'),
                              onPressed: _disconnect,
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            )
                          : ElevatedButton.icon(
                              icon: const Icon(Icons.bluetooth_connected),
                              label: const Text('Connect'),
                              onPressed: _connect,
                            ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        _status == 'Connected' ? Icons.check_circle : Icons.circle,
                        color: _status == 'Connected' ? Colors.green : Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text('Status: $_status'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Real-time OBD Data
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Real-time OBD Sensors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (_obdData.isEmpty)
                    const Text('No data - Connect to OBD adapter', style: TextStyle(color: Colors.grey))
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Key Sensors', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _buildSensorChips(ObdPidRegistry.dashboardPids),
                        ),
                        const SizedBox(height: 12),
                        ExpansionTile(
                          title: const Text('All Supported PIDs'),
                          subtitle: Text('${_supportedPids.isNotEmpty ? _supportedPids.length : ObdPidRegistry.allPids.length} sensors'),
                          children: [
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: (_supportedPids.isNotEmpty ? _supportedPids : ObdPidRegistry.allPids).length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final pid = (_supportedPids.isNotEmpty ? _supportedPids : ObdPidRegistry.allPids)[index];
                                final pidDef = ObdPidRegistry.pids[pid];
                                final value = _obdData[pid] ?? '--';
                                return ListTile(
                                  dense: true,
                                  title: Text(pidDef?.name ?? 'PID $pid'),
                                  subtitle: Text('PID $pid'),
                                  trailing: Text('$value ${pidDef?.unit ?? ''}'.trim()),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Trip Recording
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Trip Recording', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        _isRecording ? Icons.fiber_manual_record : Icons.stop_circle,
                        color: _isRecording ? Colors.red : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(_isRecording ? 'Recording...' : 'Not recording'),
                      const Spacer(),
                      _isRecording
                          ? ElevatedButton.icon(
                              icon: const Icon(Icons.stop),
                              label: const Text('Stop'),
                              onPressed: _stopTrip,
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            )
                          : ElevatedButton.icon(
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Start Trip'),
                              onPressed: _status == 'Connected' ? _startTrip : null,
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Diagnosis
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('AI Diagnosis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.analytics),
                        label: const Text('Diagnose'),
                        onPressed: _status == 'Connected' ? _diagnose : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_diagnosis.isNotEmpty) ...[
                    Text('Confidence: ${(_confidence * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: _confidence > 0.7 ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_diagnosis),
                    ),
                  ] else
                    const Text('No diagnosis yet. Connect and tap Diagnose.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSensorChips(List<String> pids) {
    return pids.map((pid) {
      final pidDef = ObdPidRegistry.pids[pid];
      final value = _obdData[pid] ?? '--';
      return Chip(
        avatar: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(pid, style: const TextStyle(fontSize: 10, color: Colors.white)),
        ),
        label: Text('${pidDef?.name ?? pid}: $value ${pidDef?.unit ?? ''}'),
      );
    }).toList();
  }

  Widget _buildMapTab() {
    return _currentPosition == null
        ? const Center(child: CircularProgressIndicator())
        : GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              zoom: 15,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (controller) => _mapController = controller,
          );
  }

  Widget _buildTripsTab() {
    return FutureBuilder<List<TripLog>>(
      future: _tripLogger.loadAllTrips(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final trips = snapshot.data ?? [];

        if (trips.isEmpty) {
          return const Center(child: Text('No trips recorded yet'));
        }

        return FutureBuilder<List<RouteScore>>(
          future: RouteAnalyzerService().analyzeRoutes(trips),
          builder: (context, routeSnapshot) {
            final routes = routeSnapshot.data ?? [];

            return FutureBuilder<List<RouteRecommendation>>(
              future: RouteAnalyzerService().recommendRoutes(routes),
              builder: (context, recSnapshot) {
                final recommendations = recSnapshot.data ?? [];

                return ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    if (recommendations.isNotEmpty) ...[
                      const Text('Route Recommendations', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ...recommendations.map((rec) => Card(
                            child: ListTile(
                              leading: const Icon(Icons.recommend, color: Colors.green),
                              title: Text(rec.routeName),
                              subtitle: Text(
                                '${rec.recommendation}\n'
                                'Damage: ${rec.damageScore.toStringAsFixed(1)} | '
                                'Distance: ${(rec.distance / 1000).toStringAsFixed(1)} km | '
                                'Time: ${rec.estimatedTime.inMinutes} min',
                              ),
                              isThreeLine: true,
                              trailing: rec.warnings.isEmpty
                                  ? const Icon(Icons.check_circle, color: Colors.green)
                                  : const Icon(Icons.warning, color: Colors.orange),
                            ),
                          )),
                      const Divider(height: 32),
                    ],
                    if (routes.isNotEmpty) ...[
                      const Text('Route Analysis', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ...routes.map((route) => Card(
                            child: ListTile(
                              leading: const Icon(Icons.route, color: Colors.blue),
                              title: Text(route.routeName),
                              subtitle: Text(
                                'Trips: ${route.tripCount} | Avg Damage: ${route.averageDamage.toStringAsFixed(1)} | '
                                'Distance: ${(route.distance / 1000).toStringAsFixed(1)} km',
                              ),
                              trailing: route.averageDamage < 30
                                  ? const Icon(Icons.check_circle, color: Colors.green)
                                  : route.averageDamage < 60
                                      ? const Icon(Icons.warning, color: Colors.orange)
                                      : const Icon(Icons.error, color: Colors.red),
                            ),
                          )),
                      const Divider(height: 32),
                    ],
                    const Text('All Trips', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...trips.map((trip) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.trip_origin),
                            title: Text(
                              '${trip.startTime.day}/${trip.startTime.month}/${trip.startTime.year} '
                              '${trip.startTime.hour}:${trip.startTime.minute.toString().padLeft(2, '0')}',
                            ),
                            subtitle: Text(
                              'Distance: ${(trip.totalDistance / 1000).toStringAsFixed(2)} km | '
                              'Damage: ${trip.totalDamage.toStringAsFixed(1)} | '
                              'Points: ${trip.entries.length}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await _tripLogger.deleteTrip(trip.id);
                                setState(() {});
                              },
                            ),
                          ),
                        )),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zero-Touch Car Diagnostics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.map), text: 'Map'),
            Tab(icon: Icon(Icons.route), text: 'Trips'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(),
          _buildMapTab(),
          _buildTripsTab(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _obdUpdateTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
}
