/// Vehicle data model for OBD2 telemetry
class VehicleData {
  // Engine data
  double? engineRpm;
  double? engineLoad;
  double? coolantTemp;
  double? intakeTemp;
  double? engineTiming;

  // Fuel data
  double? fuelPressure;
  double? fuelTrim1;
  double? fuelTrim2;
  double? shortTermTrim1;
  double? shortTermTrim2;

  // Vehicle motion
  double? vehicleSpeed;
  double? throttlePosition;

  // Emissions
  double? o2Voltage1;
  double? o2Voltage2;
  String? fuelSystemStatus;

  // System status
  bool? checkEngineLightActive;
  int? totalMilDistance;
  int? runTimeSinceStart;

  // Protocol info
  String? supportedProtocol;
  List<String>? activeDTCs;
  List<String>? pendingDTCs;

  VehicleData({
    this.engineRpm,
    this.engineLoad,
    this.coolantTemp,
    this.intakeTemp,
    this.engineTiming,
    this.fuelPressure,
    this.fuelTrim1,
    this.fuelTrim2,
    this.shortTermTrim1,
    this.shortTermTrim2,
    this.vehicleSpeed,
    this.throttlePosition,
    this.o2Voltage1,
    this.o2Voltage2,
    this.fuelSystemStatus,
    this.checkEngineLightActive,
    this.totalMilDistance,
    this.runTimeSinceStart,
    this.supportedProtocol,
    this.activeDTCs,
    this.pendingDTCs,
  });

  /// Convert to JSON for API transmission
  Map<String, dynamic> toJson() {
    return {
      'engine': {
        'rpm': engineRpm,
        'load': engineLoad,
        'coolantTemp': coolantTemp,
        'intakeTemp': intakeTemp,
        'timing': engineTiming,
      },
      'fuel': {
        'pressure': fuelPressure,
        'trim1': fuelTrim1,
        'trim2': fuelTrim2,
        'shortTerm1': shortTermTrim1,
        'shortTerm2': shortTermTrim2,
      },
      'motion': {
        'speed': vehicleSpeed,
        'throttle': throttlePosition,
      },
      'emissions': {
        'o2_1': o2Voltage1,
        'o2_2': o2Voltage2,
        'fuelSystem': fuelSystemStatus,
      },
      'system': {
        'checkEngineLightActive': checkEngineLightActive,
        'totalMilDistance': totalMilDistance,
        'runTimeSinceStart': runTimeSinceStart,
      },
      'protocol': {
        'supported': supportedProtocol,
        'activeDTCs': activeDTCs,
        'pendingDTCs': pendingDTCs,
      },
    };
  }

  /// Get health score (0-100)
  int getHealthScore() {
    int score = 100;

    // Engine health
    if (engineRpm != null && engineRpm! > 7000) score -= 5;
    if (engineLoad != null && engineLoad! > 80) score -= 10;
    if (coolantTemp != null && coolantTemp! > 100) score -= 15;

    // Fuel system
    if (fuelTrim1 != null && fuelTrim1!.abs() > 15) score -= 5;
    if (fuelTrim2 != null && fuelTrim2!.abs() > 15) score -= 5;

    // Check Engine Light
    if (checkEngineLightActive == true) score -= 20;

    // DTCs
    if (activeDTCs != null && activeDTCs!.isNotEmpty) score -= 10;

    return score.clamp(0, 100);
  }

  /// Get alert list
  List<String> getAlerts() {
    final alerts = <String>[];

    if (checkEngineLightActive == true) {
      alerts.add('⚠️ Check Engine Light Active');
    }

    if (engineRpm != null && engineRpm! > 6500) {
      alerts.add('⚠️ High Engine RPM (${engineRpm!.toStringAsFixed(0)})');
    }

    if (coolantTemp != null && coolantTemp! > 95) {
      alerts.add('⚠️ High Coolant Temperature (${coolantTemp!.toStringAsFixed(1)}°C)');
    }

    if (activeDTCs != null && activeDTCs!.isNotEmpty) {
      alerts.add('⚠️ Active Fault Codes: ${activeDTCs!.length}');
    }

    if (fuelTrim1 != null && fuelTrim1!.abs() > 20) {
      alerts.add('⚠️ High Fuel Trim (Bank 1)');
    }

    if (throttlePosition != null && throttlePosition! > 90) {
      alerts.add('⚠️ Wide Open Throttle');
    }

    return alerts;
  }

  @override
  String toString() {
    return '''
VehicleData(
  RPM: $engineRpm, Load: $engineLoad%, Temp: $coolantTemp°C,
  Speed: $vehicleSpeed km/h, Throttle: $throttlePosition%,
  Health: ${getHealthScore()}/100
)''';
  }
}

/// Vehicle health diagnostic
class VehicleHealthDiagnostic {
  final VehicleData data;
  final DateTime timestamp;

  VehicleHealthDiagnostic({
    required this.data,
    required this.timestamp,
  });

  /// Generate health report
  String getHealthReport() {
    final score = data.getHealthScore();
    final alerts = data.getAlerts();

    String status;
    if (score >= 90) {
      status = '🟢 Excellent - Vehicle is in great condition';
    } else if (score >= 70) {
      status = '🟡 Good - Minor issues detected';
    } else if (score >= 50) {
      status = '🟠 Fair - Attention needed';
    } else {
      status = '🔴 Poor - Immediate service recommended';
    }

    final buffer = StringBuffer();
    buffer.writeln('VEHICLE HEALTH REPORT');
    buffer.writeln('─' * 40);
    buffer.writeln('Health Score: $score/100');
    buffer.writeln('Status: $status');
    buffer.writeln('Timestamp: ${timestamp.toLocal()}');
    buffer.writeln('');

    if (alerts.isNotEmpty) {
      buffer.writeln('ALERTS:');
      for (final alert in alerts) {
        buffer.writeln('  $alert');
      }
    } else {
      buffer.writeln('✅ No alerts detected');
    }

    buffer.writeln('');
    buffer.writeln('ENGINE:');
    buffer.writeln('  RPM: ${data.engineRpm?.toStringAsFixed(0) ?? 'N/A'}');
    buffer.writeln('  Load: ${data.engineLoad?.toStringAsFixed(1) ?? 'N/A'}%');
    buffer.writeln('  Coolant: ${data.coolantTemp?.toStringAsFixed(1) ?? 'N/A'}°C');
    buffer.writeln('  Timing: ${data.engineTiming?.toStringAsFixed(1) ?? 'N/A'}°');

    buffer.writeln('');
    buffer.writeln('VEHICLE:');
    buffer.writeln('  Speed: ${data.vehicleSpeed?.toStringAsFixed(0) ?? 'N/A'} km/h');
    buffer.writeln('  Throttle: ${data.throttlePosition?.toStringAsFixed(1) ?? 'N/A'}%');

    return buffer.toString();
  }
}
