# Zero-Touch Car Diagnostics v1.31.0

## What's New

🎉 **Major Architecture Refactor**
- Removed Flipper Zero backend (~15,000 lines of C++)
- Streamlined to pure Flutter + native OBD plugins
- Focus: ELM327 Bluetooth + USB Serial (1260 modules)

## Features

✅ **AI-Powered Diagnostics**
- Google Gemini 2.5 Pro integration (free tier)
- Configurable API key in Settings
- Comprehensive vehicle health analysis

✅ **Comprehensive OBD-II Support**
- 50+ generic PIDs with auto-discovery
- Real-time monitoring dashboard
- ELM327 Bluetooth Classic support
- USB Serial adapter support (CH340/CP210x/FTDI)

✅ **Advanced Trip Features**
- GPS map with real-time tracking
- Automatic trip logging with sensor fusion
- Phone accelerometer & gyroscope integration
- Damage scoring algorithm
- Route analysis and recommendations

✅ **Reliability Improvements**
- Bluetooth keep-alive (no more timeouts)
- Activity tracking and reconnection
- Persistent settings storage

## Installation

1. Download `ZTCD_v1.31.0.apk`
2. Enable "Install from Unknown Sources" in Android settings
3. Install the APK
4. Open app → Settings → Configure Gemini API key
5. (Optional) Add Google Maps API key for full map features

## Requirements

- **Android**: 6.0+ (API 23+)
- **Hardware**: ELM327 Bluetooth or USB Serial OBD-II adapter
- **API Keys**: 
  - Gemini API (free): https://aistudio.google.com/app/apikey
  - Google Maps (optional): https://console.cloud.google.com/

## Documentation

- [README.md](README.md) - Full feature list and setup guide
- [OBD_INTEGRATION.md](OBD_INTEGRATION.md) - ELM327 integration details
- [CHANGES.md](CHANGES.md) - Detailed changelog

## Known Issues

- iOS Bluetooth Classic not supported (Apple limitation)
- Some vehicle-specific PIDs not yet implemented
- Background GPS tracking requires location permission

## Support

Report issues: https://github.com/mark/zero_touch_car_diagnostics_vs2/issues

---

**Full Changelog**: https://github.com/mark/zero_touch_car_diagnostics_vs2/commits/v1.31.0
