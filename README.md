# Zero Touch Car Diagnostics

Multiplatform Flutter app that connects to ELM327 (Bluetooth Classic or USB serial), samples OBD-II telemetry, and sends structured data to Gemini for automated diagnosis. this app is a multi-platform app that uses the sensor data from a cars OBD2 via a ELM327 Bluetooth module or USB serial cable connected to a mobile device (android/IOS) to automate the diagnosis process of a vehicle by sending the data to Gemini 2.5 and prompting it to diagnose the problem and return a on-screen answer.  The output diagnosis must be within 95-99% accuracy. this app is a ongoing work-in-progress.

## Features

- Bluetooth Classic and USB serial transport for ELM327
- ELM327 init and basic PID sampling (RPM, speed, coolant)
- Gemini client with strict JSON response schema
- Simple UI: connect, sample, diagnose

## Prerequisites

- Flutter SDK (3.10+)
- Android device with Bluetooth or USB-OTG
- API key for Gemini Generative Language API

## Setup

1. Install dependencies:

```bash
flutter pub get
```

1. Android permissions are declared in `android/app/src/main/AndroidManifest.xml` (Bluetooth + USB host). On Android 12+, the app requests `BLUETOOTH_CONNECT` and `BLUETOOTH_SCAN` at runtime.
2. Provide your Gemini API key via Dart define:

```bash
flutter run \
  --dart-define=GEMINI_API_KEY=YOUR_API_KEY \
  --dart-define=GEMINI_MODEL=gemini-1.5-pro
```

1. Pair your ELM327 adapter (Bluetooth) or connect via USB; then open the app and tap `Connect`, followed by `Diagnose`.

## Notes on Accuracy

No model can guarantee 95–99% accuracy universally. We enforce structured outputs and include telemetry evidence; add more PIDs and cross-checks to improve reliability.

## Next Steps

- Expand PID coverage and sampling cadence
- Device selection UI and connection status
- Confidence calibration and multi-pass verification
- Offline simulation mode for development
