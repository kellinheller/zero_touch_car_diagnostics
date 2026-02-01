# Copilot Instructions for Zero-Touch Car Diagnostics

## Project Overview

This is a **comprehensive multi-platform Flutter app** for zero-touch automotive diagnostics combining OBD-II telemetry, phone sensors (accelerometer/gyroscope), GPS tracking, and AI-powered analysis via Google Gemini 2.5 Pro. The app features real-time dashboards, trip logging with damage scoring, and route recommendations based on vehicle wear analysis.

**Architecture:** Flutter frontend + OBD-II integration:
1. **ELM327 OBD-II integration** with 50+ generic PIDs (native platform channels)
2. **USB Serial (1260) support** for direct OBD-II communication
3. **Phone sensor fusion** (accelerometer, gyroscope, GPS)
4. **Trip logging and route analysis** with persistent storage

## Major Features

1. **Real-time OBD-II Monitoring**: 50+ PIDs including RPM, speed, coolant, throttle, fuel, MAF, timing
2. **GPS Map Integration**: Live Google Maps with route polyline tracking
3. **Trip Logging**: Automatic recording with sensor fusion (OBD + accelerometer + gyroscope + GPS)
4. **Damage Scoring**: Real-time vehicle wear calculation based on harsh driving, high RPM, overheating
5. **Route Analysis**: Historical trip grouping and recommendations for lowest-damage routes
6. **AI Diagnostics**: Gemini 2.5 Pro with configurable API key in settings
7. **Persistent Storage**: Trip logs saved as JSON files

## Critical Architecture Patterns

### OBD-II Communication Stack

**Layered abstraction** with comprehensive PID support:
- [lib/services/obd_connection.dart](lib/services/obd_connection.dart) - Abstract interface (`connect()`, `write()`, `lines` stream)
- [lib/services/elm327_protocol.dart](lib/services/elm327_protocol.dart) - ELM327 init (`ATZ`, `ATE0`) and PID queries
- [lib/services/obd_pid_registry.dart](lib/services/obd_pid_registry.dart) - **Complete registry of 50+ generic OBD-II PIDs** with parsers
- [lib/services/diagnostics_service.dart](lib/services/diagnostics_service.dart) - High-level sampling

**Three transport implementations:**
- [bluetooth_obd_connection.dart](lib/services/bluetooth_obd_connection.dart) - Bluetooth Classic RFCOMM with keep-alive
- [usb_obd_connection.dart](lib/services/usb_obd_connection.dart) - USB serial
- [simulation_obd_connection.dart](lib/services/simulation_obd_connection.dart) - Mock data for development

**Bluetooth Keep-Alive:** Prevents timeouts with:
- 10-second timer sending `0100` PID support query
- 30-second activity staleness detection
- Automatic reconnection handling

### Trip Logging & Sensor Fusion

[lib/services/trip_logging_service.dart](lib/services/trip_logging_service.dart) implements:
- **Sensor Streams**: Accelerometer, gyroscope (`sensors_plus`), GPS (`geolocator`)
- **Damage Calculation** real-time scoring:
   - Accelerometer >15 m/s² (harsh braking/acceleration) × 2
   - Gyroscope >2.0 rad/s (sharp turns) × 3
   - RPM >4000 rpm ÷ 500
   - Engine load >80% ÷ 10
   - Coolant >100°C ÷ 5
- **File Storage**: JSON in `{app_documents}/trips/{trip_id}.json`
- **Distance Tracking**: Cumulative via GPS coordinate deltas

### Route Analysis

[lib/services/route_analyzer_service.dart](lib/services/route_analyzer_service.dart):
- **Route Matching**: Groups trips by start/end coordinates (100m radius)
- **Statistics**: Average damage, time, distance per route
- **Recommendations**: Weighted scoring (60% damage + 40% time)
- **Issue Detection**: Harsh braking frequency, high RPM %, overheating incidents

### Main Dashboard

[lib/pages/main_dashboard_page.dart](lib/pages/main_dashboard_page.dart) - **3-tab interface**:
1. **Dashboard**: Connection controls, real-time OBD chips, trip toggle, diagnose button
2. **Map**: Google Maps with marker + route polyline during recording
3. **Trips**: Historical list with route analysis, damage scores, delete

**Periodic Updates:** 2-second timer queries dashboard PIDs, logs trip entries when recording.

### Settings & Persistence

[lib/services/settings_service.dart](lib/services/settings_service.dart) via `shared_preferences`:
- Keys: `gemini_api_key`, `gemini_model`, `use_gemini`
- Default model: `gemini-2.5-pro` (free tier)
- [Settings page](lib/pages/settings_page.dart) with Google AI Studio help link

### AI Integration (Gemini 2.5 Pro)

[lib/services/gemini_client.dart](lib/services/gemini_client.dart):
- **API Key**: User-configurable in settings (no hardcoding)
- **Model**: Selectable (default: `gemini-2.5-pro`)
- **Response**: Strict JSON with `diagnosis`, `confidence`, `probable_causes`, `recommended_actions`
- **Free Tier**: 1,500 requests/day

**Legacy Ollama Support:** [lib/services/llm/llm_service.dart](lib/services/llm/llm_service.dart) for local inference (not actively used).

### Native Platform Channels

#### Android OBD Plugin
[android/app/src/main/kotlin/com/example/zero_touch_car_diagnostics/ObdPlugin.kt](android/app/src/main/kotlin/com/example/zero_touch_car_diagnostics/ObdPlugin.kt):
- **Channel**: `zero_touch.obd`
- **Methods**: `connect`, `sendCommand`, `listPaired`, `scan`, `pair`
- **Protocol**: Bluetooth Classic RFCOMM (UUID `00001101-...`)
- **USB Serial**: Supports CH340/CP210x/FTDI chips (1260 modules)
- **Registration**: [MainActivity.kt](android/app/src/main/kotlin/com/example/zero_touch_car_diagnostics/MainActivity.kt)

## Development Workflows

### Running the App

```bash
# Development (simulation mode)
flutter pub get
flutter run

# With Gemini API key (optional - configure in-app)
flutter run --dart-define=GEMINI_API_KEY=your_key

# Add Google Maps API key to AndroidManifest.xml:
# <meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_KEY"/>
```

### Permissions (Android)

[android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml):
- **Bluetooth**: `BLUETOOTH`, `BLUETOOTH_ADMIN`, `BLUETOOTH_CONNECT`, `BLUETOOTH_SCAN`
- **Location**: `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `ACCESS_BACKGROUND_LOCATION`
- **Storage**: `WRITE_EXTERNAL_STORAGE`, `READ_EXTERNAL_STORAGE`
- **Network**: `INTERNET`

Runtime permissions via `permission_handler` and `geolocator`.

### Testing Without Hardware

Use `SimulationObdConnection` (default transport) for mock RPM/speed/coolant. No physical adapter needed.

## Project-Specific Conventions

### OBD-II PID Parsers

All PIDs in [ObdPidRegistry](lib/services/obd_pid_registry.dart) with parser functions:
```dart
ObdPid(
   pid: '0C',
   name: 'Engine RPM',
   unit: 'rpm',
   parser: (bytes) => '${((bytes[0] * 256 + bytes[1]) / 4).toInt()}',
)
```
**Formula convention:** Document SAE J1979 formulas in comments.

**Dashboard PIDs:** `dashboardPids` defines commonly monitored sensors:
- `0C` (RPM), `0D` (Speed), `05` (Coolant), `04` (Load), `11` (Throttle), `10` (MAF), `2F` (Fuel), `0F` (Intake)

### PID Response Parsing

ELM327 returns hex like `41 0C AA BB` for PID `010C`:
- Bytes 0-1: `41 0C` (mode+1, PID)
- Bytes 2+: Data (`AA BB`)
- Parser: `_extractDataBytes()` splits on `\s+`, filters 2-char hex

**Formula:** RPM = `((A*256)+B)/4`

### Damage Scoring Thresholds

[TripLoggingService._calculateDamageScore()](lib/services/trip_logging_service.dart):
- Accelerometer: >15 m/s² (harsh events)
- Gyroscope: >2.0 rad/s
- RPM: >4000 rpm
- Engine load: >80%
- Coolant: >100°C

**Weights:** Accel ×2, Gyro ×3, RPM ÷500, Load ÷10, Temp ÷5

### Transport Selection Pattern

[MainDashboardPage](lib/pages/main_dashboard_page.dart) dropdown:
```dart
if (_transport == 'Bluetooth') _conn = BluetoothObdConnection();
else if (_transport == 'USB') _conn = UsbObdConnection();
else _conn = SimulationObdConnection();
```
**Rule:** Always wrap transport in `Elm327Protocol` before `DiagnosticsService`.

### Native Method Channel Pattern

1. Define Dart `MethodChannel` in `lib/services/`
2. Implement Kotlin handler in `android/app/src/.../Plugin.kt`
3. Register in `MainActivity.configureFlutterEngine()`
4. For iOS: Add Swift in `ios/Runner/`

## Key Dependencies

**Core:**
- `flutter_bluetooth_serial`: Bluetooth Classic (Android only)
- `usb_serial`: USB OTG
- `google_generative_ai`: Gemini API
- `permission_handler`: Runtime permissions (Android 12+)

**New:**
- `google_maps_flutter`: Map display
- `geolocator`: GPS tracking
- `geocoding`: Address lookup (future)
- `sensors_plus`: Accelerometer/gyroscope
- `shared_preferences`: Settings storage
- `path_provider`: App documents directory
- `url_launcher`: Help links

## Common Pitfalls

1. **iOS Bluetooth**: Most ELM327 use Classic (iOS blocks). Consider BLE adapters or Wi-Fi OBD.
2. **Android 12+ permissions**: Request `BLUETOOTH_CONNECT`/`BLUETOOTH_SCAN` at runtime (SDK 31+).
3. **Emulator networking**: `http://10.0.2.2` → host. Physical devices need host IP.
4. **PID variability**: Adapters may add whitespace/prompts (`>`). Parser handles via `\s+` regex.
5. **Gemini limits**: Free tier = 1,500 requests/day. Cache diagnoses.
6. **GPS permissions**: Android 12+ requires runtime grants. Use `geolocator` requests.
7. **Background location**: For trip logging while backgrounded, request `ACCESS_BACKGROUND_LOCATION` (Android 10+).
8. **Google Maps key**: Must be in `AndroidManifest.xml` or map shows blank tiles.
9. **Trip file size**: Long trips = large JSON. Consider compression.
10. **Sensor calibration**: Phone baselines vary. Damage thresholds may need tuning.

## Integration Documentation

- [OBD_INTEGRATION.md](OBD_INTEGRATION.md) - ELM327 notes, Gemini setup
- [README.md](README.md) - Complete feature list, setup guide

## Next Steps

- iOS CoreBluetooth (BLE adapters)
- Offline LLM (on-device inference)
- Cloud sync for trip history
- Vehicle-specific PIDs (manufacturer modes)
- Predictive maintenance alerts
- Multi-language support
