# OBD2 ELM327 Integration (Android + iOS notes)

This workspace includes a minimal cross-platform integration for talking to ELM327-style OBD-II Bluetooth adapters and using a remote LLM (Hugging Face Inference API) to parse responses into a diagnosis.

What I added

- `lib/services/obd/obd_service.dart` — Dart MethodChannel wrapper for native OBD calls
- `lib/services/llm/llm_service.dart` — Simple LLM client using Hugging Face Inference API
- `lib/pages/obd_page.dart` — Example UI page to connect, read PIDs and parse with LLM
- `android/.../ObdPlugin.kt` — Kotlin native plugin implementing RFCOMM for ELM327
- `ios/Runner/ObdPlugin.swift` — iOS Swift stub (CoreBluetooth implementation required)
- `pubspec.yaml` — added `http` dependency

Android notes

- Permissions were added to `android/app/src/main/AndroidManifest.xml` for Bluetooth and location.
- The Kotlin plugin uses classic Bluetooth RFCOMM (00001101-0000-1000-8000-00805F9B34FB) to connect to ELM327 devices by MAC address.
- `MainActivity.kt` registers the plugin automatically.

Usage (Flutter)

1. Install dependencies:

```bash
flutter pub get
```

1. Add the `ObdPage` to your app (example):

- In `lib/main.dart` import `lib/pages/obd_page.dart` and navigate to `ObdPage()`.

1. Enter the ELM327 Bluetooth MAC, connect, read PIDs (e.g. `010C` for RPM), and provide a Hugging Face API key to parse the raw output.

- `lib/services/llm/llm_service.dart` now calls a local Ollama REST endpoint. Defaults:
  - `baseUrl`: `http://10.0.2.2:11434` (Android emulator -> host mapping)
- `model`: `dolphin-mixtral-3.7b`

 To use your local model:

 1. Ensure Ollama is running on your host and the model `dolphin-mixtral-3.7b` is available in your Ollama installation (you mentioned `/home/kal/snap/ollama/current/.ollama/`).
 2. For Android emulator, keep the default `http://10.0.2.2:11434` host. For a physical device, set `baseUrl` to `http://<host-ip>:11434` in the app.
 3. On the app UI, set the `LLM Endpoint (host)` and `LLM Model` fields and tap `Parse Raw with LLM (Ollama)`.

 Notes: Ollama's REST API path used is `/api/generate`. If your Ollama setup exposes a different path or requires extra headers, update `lib/services/llm/llm_service.dart` accordingly.

Ping / connection health

- The app now sends a lightweight OBD request (`0100`) as a health check. Health is shown on the UI and a periodic ping runs every 10s while connected. You can also manually tap `Ping`.

Remote Gemini usage

- If you are away from home and want to use Google Gemini models (e.g., `gemini-2.5` or `gemini-3`), set the `LLM Model` field to the desired `gemini-*` model and provide a `Remote API Key` and `LLM Endpoint (host)` that points to your remote inference endpoint (for example a proxy or cloud endpoint that exposes Gemini).
- The app will send the same structured prompt to the remote endpoint and expects a JSON/text response. The remote endpoint and API key are required for `gemini-*` models.

Device discovery & pairing (Android)

- The app now includes a Discover button next to the `ELM327 Bluetooth MAC` field which opens a dialog listing paired devices and scanned devices. You can select a device to fill the MAC field or tap `Pair` to initiate pairing.
- Discovery uses Bluetooth classic discovery; ensure the app has runtime permissions for `BLUETOOTH_SCAN`, `BLUETOOTH_CONNECT`, and `ACCESS_FINE_LOCATION` on modern Android versions.
- The app requests runtime permissions using the `permission_handler` package before scanning or connecting. It asks for `ACCESS_FINE_LOCATION`, `BLUETOOTH_SCAN`, and `BLUETOOTH_CONNECT` (where supported). Ensure users accept these permissions.
- Note: some permissions (e.g., `bluetoothConnect`/`bluetoothScan`) require Android SDK 31+ and runtime handling; test on target Android versions.

Next steps I can do for you

- Implement a production-ready iOS CoreBluetooth flow (if using BLE adapter).
- Add device discovery and pairing UI (Android) instead of requiring MAC address input.
- Improve raw OBD parsing locally (no LLM) and add caching and retry logic.
- Integrate a local LLM (on-device) instead of remote API.

iOS

- The Swift plugin is a stub. To support iOS you must implement CoreBluetooth scanning/connection for your adapter (BLE vs Classic depends on adapter). Most ELM327 adapters are Bluetooth Classic which iOS does not support for third-party apps unless MFi or specific access — many ELM327 adapters will not work on iOS via classic RFCOMM. Consider using a BLE-capable OBD adapter or a Wi-Fi adapter for iOS.

Security & Privacy

- Do not hardcode API keys. Store and retrieve keys from secure storage (e.g., `flutter_secure_storage`) before calling the LLM.

Next steps I can do for you

- Implement a production-ready iOS CoreBluetooth flow (if using BLE adapter).
- Add device discovery and pairing UI (Android) instead of requiring MAC address input.
- Improve raw OBD parsing locally (no LLM) and add caching and retry logic.
- Integrate a local LLM (on-device) instead of remote API.

If you want, I can implement any of the next steps — tell me which one to prioritize.
