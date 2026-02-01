# Car Graphics & UI Implementation Guide

## 1. Car Status Widget

This widget displays a car's health and real-time status with visual indicators.

### Component Overview

```
┌─────────────────────────────────────┐
│  Vehicle Status Dashboard           │
├─────────────────────────────────────┤
│     🚗 [Car Graphic]                │
│    /   RPM: 2500                    │
│   /    Speed: 45 km/h               │
│  |     Temp: 85°C ✓                 │
│   \    Fuel: 75% ⚙                  │
│    \   Status: Running              │
│     🔋 Battery: Good                │
│                                     │
│  ⚠️ Minor Issues: None              │
└─────────────────────────────────────┘
```

### Data Flow
```
OBD Data (RPM, Speed, Coolant, etc.)
    ↓
DiagnosticsService
    ↓
CarStatusWidget
    ↓
Display with colors:
- Green: Normal
- Yellow: Warning
- Red: Critical
```

---

## 2. Gemini 2.5 Flash Configuration

### Issue & Solution

**Problem**: Generic Gemini API keys may have rate limiting or reduced capabilities.

**Solution**: Implement smart API key management with fallbacks.

### Configuration Approach

```dart
// lib/services/gemini_client.dart
class GeminiClient {
  // Available models
  static const String MODEL_2_5_FLASH = 'gemini-2.5-flash';
  static const String MODEL_2_0_FLASH = 'gemini-2.0-flash-exp';
  static const String MODEL_1_5_PRO = 'gemini-1.5-pro';
  
  // Try models in order
  static const List<String> FALLBACK_MODELS = [
    MODEL_2_5_FLASH,      // First choice
    MODEL_2_0_FLASH,      // Fallback
    MODEL_1_5_PRO,        // Last resort
  ];
}
```

### User Configuration Flow

```
Settings Page
    ↓
"Configure Gemini API Key"
    ↓
Enter API Key
    ↓
Test Connection
    ↓
Select Model (2.5 Flash recommended)
    ↓
Save & Verify
```

---

## 3. Recommended Implementation Order

### Step 1: Merge Repositories (5 min)
```bash
cd /home/mark
# Backup old repo
mv zero_touch_car_diagnostics zero_touch_car_diagnostics_old_backup
# Use vs2 as primary
mv zero_touch_car_diagnostics_vs2 zero_touch_car_diagnostics
cd zero_touch_car_diagnostics
```

### Step 2: Update Version (2 min)
Edit `pubspec.yaml`:
```yaml
version: 1.32.0+132
```

### Step 3: Create Car Graphics Widget (30 min)
Create `lib/widgets/car_status_widget.dart` with:
- Car SVG rendering
- Real-time indicator updates
- Color-coded status lights
- Smooth animations

### Step 4: Create Gauge Widget (20 min)
Create `lib/widgets/gauge_widget.dart`:
- Circular gauge for RPM
- Speed gauge
- Temperature indicator
- Animated needle movement

### Step 5: Update Dashboard (45 min)
Modify `lib/pages/main_dashboard_page.dart`:
- Import new widgets
- Add car graphics display area
- Integrate gauge widgets
- Add status indicators

### Step 6: Enhance Gemini Integration (20 min)
Update `lib/services/gemini_client.dart`:
- Add model fallback logic
- Implement API key validation
- Add error handling
- Cache responses

### Step 7: Build & Release (30 min)
```bash
flutter clean
flutter pub get
flutter build apk --release --build-name=1.32.0 --build-number=132
# Push to GitHub with tag v1.32.0
```

---

## 4. Code Snippets

### Car Status Widget Skeleton
```dart
// lib/widgets/car_status_widget.dart
import 'package:flutter/material.dart';

class CarStatusWidget extends StatefulWidget {
  final Map<String, dynamic> obdData;
  final bool isConnected;

  const CarStatusWidget({
    required this.obdData,
    required this.isConnected,
  });

  @override
  State<CarStatusWidget> createState() => _CarStatusWidgetState();
}

class _CarStatusWidgetState extends State<CarStatusWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue, width: 2),
      ),
      child: Column(
        children: [
          // Car ASCII/SVG display
          Text('🚗', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          
          // Status indicators
          _buildStatusRow('RPM', widget.obdData['rpm']?.toString() ?? 'N/A', Colors.green),
          _buildStatusRow('Speed', widget.obdData['speed']?.toString() ?? 'N/A', Colors.green),
          _buildStatusRow('Coolant', widget.obdData['coolant']?.toString() ?? 'N/A', Colors.orange),
          
          const SizedBox(height: 12),
          
          // Connection status
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.isConnected ? Icons.check_circle : Icons.error_circle,
                color: widget.isConnected ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                widget.isConnected ? 'Connected' : 'Disconnected',
                style: TextStyle(
                  color: widget.isConnected ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
```

### Gauge Widget Skeleton
```dart
// lib/widgets/gauge_widget.dart
import 'package:flutter/material.dart';
import 'dart:math';

class GaugeWidget extends StatelessWidget {
  final String label;
  final double value;
  final double maxValue;
  final Color color;

  const GaugeWidget({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (value / maxValue).clamp(0.0, 1.0);

    return Column(
      children: [
        CustomPaint(
          size: const Size(120, 120),
          painter: GaugePainter(
            percentage: percentage,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          '${value.toStringAsFixed(0)} / ${maxValue.toStringAsFixed(0)}',
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class GaugePainter extends CustomPainter {
  final double percentage;
  final Color color;

  GaugePainter({required this.percentage, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Draw background circle
    canvas.drawCircle(center, radius, paint..color = Colors.grey[700]!);

    // Draw filled arc based on percentage
    final startAngle = -pi / 2;
    final sweepAngle = (2 * pi) * percentage;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint..color = color,
    );
  }

  @override
  bool shouldRepaint(GaugePainter oldDelegate) {
    return oldDelegate.percentage != percentage;
  }
}
```

---

## 5. Updated Settings Page Section

Add this to settings for Gemini configuration:

```dart
// Add to lib/pages/settings_page.dart

// ... inside build method ...

// Gemini API Configuration Section
ExpansionTile(
  title: const Text('Gemini AI Configuration'),
  subtitle: const Text('2.5 Flash (Recommended)'),
  children: [
    Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Get your free Gemini 2.5 Flash API key from Google AI Studio',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              _launchURL('https://aistudio.google.com/app/apikey');
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.open_in_new, size: 16),
                SizedBox(width: 8),
                Text('Open Google AI Studio'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedModel,
            items: const [
              DropdownMenuItem(
                value: 'gemini-2.5-flash',
                child: Text('Gemini 2.5 Flash (Recommended) ⭐'),
              ),
              DropdownMenuItem(
                value: 'gemini-2.0-flash-exp',
                child: Text('Gemini 2.0 Flash'),
              ),
              DropdownMenuItem(
                value: 'gemini-1.5-pro',
                child: Text('Gemini 1.5 Pro'),
              ),
            ],
            onChanged: (value) {
              setState(() => _selectedModel = value ?? 'gemini-2.5-flash');
            },
            decoration: const InputDecoration(
              labelText: 'Select Model',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    ),
  ],
),
```

---

## 6. Testing Checklist

- [ ] Car graphics display on dashboard
- [ ] Real-time gauge updates with OBD data
- [ ] Color indicators change based on values
- [ ] Gemini 2.5 Flash API key accepted
- [ ] Diagnosis works with configured key
- [ ] App doesn't crash without API key
- [ ] Settings page guides user to API setup
- [ ] APK builds without errors
- [ ] GPS map still works with new widgets
- [ ] Trip logging captures all data

---

## 7. Deployment

```bash
cd /home/mark/zero_touch_car_diagnostics

# Stage 1: Merge repos (if not done)
git status
git add -A
git commit -m "Phase 1: Merge repositories - v1.32.0 prep"

# Stage 2: Car graphics
git add lib/widgets/
git commit -m "feat: Add car graphics and status widget"

# Stage 3: Gemini enhancement
git add lib/services/gemini_client.dart
git commit -m "feat: Enhance Gemini 2.5 Flash integration with fallbacks"

# Stage 4: Build
flutter pub get
flutter build apk --release --build-name=1.32.0 --build-number=132

# Stage 5: Release
git tag -a v1.32.0 -m "v1.32.0 - Car Graphics UI + Gemini 2.5 Flash"
git push origin main --tags
# Upload APK to GitHub releases
```

---

**Ready to start implementing? Let me know which phase to begin with!**
