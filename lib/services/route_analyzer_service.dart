import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'trip_logging_service.dart';

class RouteScore {
  final String routeName;
  final double totalDamage;
  final double averageDamage;
  final double distance;
  final Duration averageTime;
  final int tripCount;
  final List<String> commonIssues;

  RouteScore({
    required this.routeName,
    required this.totalDamage,
    required this.averageDamage,
    required this.distance,
    required this.averageTime,
    required this.tripCount,
    required this.commonIssues,
  });
}

class RouteRecommendation {
  final String routeName;
  final double damageScore;
  final Duration estimatedTime;
  final double distance;
  final String recommendation;
  final List<String> warnings;

  RouteRecommendation({
    required this.routeName,
    required this.damageScore,
    required this.estimatedTime,
    required this.distance,
    required this.recommendation,
    required this.warnings,
  });
}

class RouteAnalyzerService {
  static const double _routeMatchingRadius = 100.0; // meters

  /// Analyze historical trips to identify common routes
  Future<List<RouteScore>> analyzeRoutes(List<TripLog> trips) async {
    if (trips.isEmpty) return [];

    final routeGroups = <String, List<TripLog>>{};

    // Group trips by similar start/end points
    for (final trip in trips) {
      if (trip.entries.isEmpty) continue;

      final startPoint = trip.entries.first;
      final endPoint = trip.entries.last;

      if (startPoint.latitude == null || endPoint.latitude == null) continue;

      final routeKey = _findMatchingRoute(
        routeGroups.keys.toList(),
        startPoint.latitude!,
        startPoint.longitude!,
        endPoint.latitude!,
        endPoint.longitude!,
      );

      if (routeKey != null) {
        routeGroups[routeKey]!.add(trip);
      } else {
        final newKey = '${startPoint.latitude!.toStringAsFixed(4)},${startPoint.longitude!.toStringAsFixed(4)}_'
            '${endPoint.latitude!.toStringAsFixed(4)},${endPoint.longitude!.toStringAsFixed(4)}';
        routeGroups[newKey] = [trip];
      }
    }

    // Calculate statistics for each route
    final routeScores = <RouteScore>[];
    var routeIndex = 1;

    for (final entry in routeGroups.entries) {
      final routeTrips = entry.value;
      if (routeTrips.isEmpty) continue;

      final totalDamage = routeTrips.fold<double>(0, (sum, trip) => sum + trip.totalDamage);
      final totalDistance = routeTrips.fold<double>(0, (sum, trip) => sum + trip.totalDistance);
      final totalDuration = routeTrips.fold<Duration>(
        Duration.zero,
        (sum, trip) => sum + (trip.endTime?.difference(trip.startTime) ?? Duration.zero),
      );

      final avgDamage = totalDamage / routeTrips.length;
      final avgDistance = totalDistance / routeTrips.length;
      final avgTime = Duration(milliseconds: totalDuration.inMilliseconds ~/ routeTrips.length);

      final commonIssues = _identifyCommonIssues(routeTrips);

      routeScores.add(RouteScore(
        routeName: 'Route $routeIndex',
        totalDamage: totalDamage,
        averageDamage: avgDamage,
        distance: avgDistance,
        averageTime: avgTime,
        tripCount: routeTrips.length,
        commonIssues: commonIssues,
      ));

      routeIndex++;
    }

    // Sort by trip count (most traveled routes first)
    routeScores.sort((a, b) => b.tripCount.compareTo(a.tripCount));

    return routeScores;
  }

  String? _findMatchingRoute(
    List<String> existingRoutes,
    double startLat,
    double startLon,
    double endLat,
    double endLon,
  ) {
    for (final routeKey in existingRoutes) {
      final parts = routeKey.split('_');
      if (parts.length != 2) continue;

      final startParts = parts[0].split(',');
      final endParts = parts[1].split(',');

      if (startParts.length != 2 || endParts.length != 2) continue;

      final existingStartLat = double.tryParse(startParts[0]);
      final existingStartLon = double.tryParse(startParts[1]);
      final existingEndLat = double.tryParse(endParts[0]);
      final existingEndLon = double.tryParse(endParts[1]);

      if (existingStartLat == null || existingStartLon == null || existingEndLat == null || existingEndLon == null) {
        continue;
      }

      final startDistance = Geolocator.distanceBetween(startLat, startLon, existingStartLat, existingStartLon);
      final endDistance = Geolocator.distanceBetween(endLat, endLon, existingEndLat, existingEndLon);

      if (startDistance < _routeMatchingRadius && endDistance < _routeMatchingRadius) {
        return routeKey;
      }
    }

    return null;
  }

  List<String> _identifyCommonIssues(List<TripLog> trips) {
    final issues = <String>[];
    var harshBrakingCount = 0;
    var highRpmCount = 0;
    var overheatingCount = 0;
    var totalEntries = 0;

    for (final trip in trips) {
      for (final entry in trip.entries) {
        totalEntries++;

        // Check for harsh braking/acceleration
        if (entry.accelerometer != null && entry.accelerometer!.magnitude > 15) {
          harshBrakingCount++;
        }

        // Check for high RPM
        if (entry.obdData.containsKey('0C')) {
          final rpm = int.tryParse(entry.obdData['0C'] ?? '0') ?? 0;
          if (rpm > 4000) highRpmCount++;
        }

        // Check for overheating
        if (entry.obdData.containsKey('05')) {
          final temp = int.tryParse(entry.obdData['05'] ?? '0') ?? 0;
          if (temp > 100) overheatingCount++;
        }
      }
    }

    if (totalEntries == 0) return issues;

    final harshBrakingPercent = (harshBrakingCount / totalEntries) * 100;
    final highRpmPercent = (highRpmCount / totalEntries) * 100;
    final overheatingPercent = (overheatingCount / totalEntries) * 100;

    if (harshBrakingPercent > 10) {
      issues.add('Frequent harsh braking/acceleration');
    }
    if (highRpmPercent > 15) {
      issues.add('High RPM driving');
    }
    if (overheatingPercent > 5) {
      issues.add('Engine overheating incidents');
    }

    return issues;
  }

  /// Recommend the best route based on damage and time
  Future<List<RouteRecommendation>> recommendRoutes(
    List<RouteScore> routes, {
    double damageWeight = 0.6,
    double timeWeight = 0.4,
  }) async {
    if (routes.isEmpty) return [];

    final recommendations = <RouteRecommendation>[];

    for (final route in routes) {
      // Normalize damage and time scores (0-100)
      final maxDamage = routes.map((r) => r.averageDamage).reduce(max);
      final maxTime = routes.map((r) => r.averageTime.inSeconds).reduce(max);

      final normalizedDamage = maxDamage > 0 ? (route.averageDamage / maxDamage) * 100 : 0;
      final normalizedTime = maxTime > 0 ? (route.averageTime.inSeconds / maxTime) * 100 : 0;

      // Calculate weighted score (lower is better)
      final score = (normalizedDamage * damageWeight) + (normalizedTime * timeWeight);

      final warnings = <String>[];
      if (route.averageDamage > 50) {
        warnings.add('High vehicle wear on this route');
      }
      if (route.commonIssues.isNotEmpty) {
        warnings.addAll(route.commonIssues);
      }

      String recommendation;
      if (score < 40) {
        recommendation = 'Recommended - Low wear, good time';
      } else if (score < 70) {
        recommendation = 'Acceptable - Moderate wear';
      } else {
        recommendation = 'Consider alternatives - High wear or longer time';
      }

      recommendations.add(RouteRecommendation(
        routeName: route.routeName,
        damageScore: route.averageDamage,
        estimatedTime: route.averageTime,
        distance: route.distance,
        recommendation: recommendation,
        warnings: warnings,
      ));
    }

    // Sort by score (best routes first)
    recommendations.sort((a, b) => a.damageScore.compareTo(b.damageScore));

    return recommendations;
  }
}
