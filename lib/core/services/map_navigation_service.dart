import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../constants/app_constants.dart';

class DirectionRoute {
  final List<LatLng> polylinePoints;
  final String distanceText;
  final int distanceValue; // in meters
  final String durationText;
  final int durationValue; // in seconds

  DirectionRoute({
    required this.polylinePoints,
    required this.distanceText,
    required this.distanceValue,
    required this.durationText,
    required this.durationValue,
  });
}

class MapNavigationService {
  final Dio _dio = Dio();

  Future<DirectionRoute?> fetchDirections(LatLng origin, LatLng destination) async {
    try {
      final apiKey = AppConstants.googleMapsApiKey;
      if (apiKey.isEmpty || apiKey.contains("YOUR_API_KEY")) {
        debugPrint("[MapNavigationService] Google Maps API Key is invalid or placeholder. Using straight-line fallback.");
        return _fallbackRoute(origin, destination);
      }

      final url = "https://maps.googleapis.com/maps/api/directions/json"
          "?origin=${origin.latitude},${origin.longitude}"
          "&destination=${destination.latitude},${destination.longitude}"
          "&key=$apiKey";

      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data["status"] == "OK" && data["routes"] != null && (data["routes"] as List).isNotEmpty) {
          final route = data["routes"][0];
          final leg = route["legs"][0];
          final encodedPolyline = route["overview_polyline"]["points"];
          final points = decodePolyline(encodedPolyline);

          return DirectionRoute(
            polylinePoints: points,
            distanceText: leg["distance"]["text"] ?? "N/A",
            distanceValue: leg["distance"]["value"] ?? 0,
            durationText: leg["duration"]["text"] ?? "N/A",
            durationValue: leg["duration"]["value"] ?? 0,
          );
        } else {
          debugPrint("[MapNavigationService] Directions API error status: ${data["status"]}. Using fallback.");
        }
      }
    } catch (e) {
      debugPrint("[MapNavigationService] Error fetching directions: $e. Using fallback.");
    }
    return _fallbackRoute(origin, destination);
  }

  DirectionRoute _fallbackRoute(LatLng origin, LatLng destination) {
    final distMeters = distanceBetween(origin, destination);
    final distKm = distMeters / 1000;
    // Estimate 45 km/h average speed => 12.5 m/s
    final durationSeconds = (distMeters / 12.5).round();
    final durationMins = (durationSeconds / 60).round();

    return DirectionRoute(
      polylinePoints: [origin, destination],
      distanceText: "${distKm.toStringAsFixed(1)} km",
      distanceValue: distMeters.round(),
      durationText: "$durationMins mins",
      durationValue: durationSeconds,
    );
  }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  double calculateBearing(LatLng start, LatLng end) {
    double lat1 = start.latitude * pi / 180;
    double lon1 = start.longitude * pi / 180;
    double lat2 = end.latitude * pi / 180;
    double lon2 = end.longitude * pi / 180;

    double dLon = lon2 - lon1;

    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    double radians = atan2(y, x);

    double bearing = radians * 180 / pi;
    return (bearing + 360) % 360;
  }

  double distanceBetween(LatLng p1, LatLng p2) {
    double earthRadius = 6371000; // meters
    double dLat = (p2.latitude - p1.latitude) * pi / 180;
    double dLon = (p2.longitude - p1.longitude) * pi / 180;
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(p1.latitude * pi / 180) * cos(p2.latitude * pi / 180) *
            sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double distanceToSegment(LatLng p, LatLng a, LatLng b) {
    double latMean = (a.latitude + b.latitude) / 2.0 * pi / 180;
    double kLat = 111320.0;
    double kLng = 111320.0 * cos(latMean);

    double ax = a.longitude * kLng;
    double ay = a.latitude * kLat;
    double bx = b.longitude * kLng;
    double by = b.latitude * kLat;
    double px = p.longitude * kLng;
    double py = p.latitude * kLat;

    double dx = bx - ax;
    double dy = by - ay;

    double segmentLenSq = dx * dx + dy * dy;
    if (segmentLenSq == 0) {
      return sqrt((px - ax) * (px - ax) + (py - ay) * (py - ay));
    }

    double t = ((px - ax) * dx + (py - ay) * dy) / segmentLenSq;
    t = max(0.0, min(1.0, t));

    double projx = ax + t * dx;
    double projy = ay + t * dy;

    return sqrt((px - projx) * (px - projx) + (py - projy) * (py - projy));
  }

  double minDistanceToPolyline(LatLng p, List<LatLng> polyline) {
    if (polyline.isEmpty) return double.infinity;
    if (polyline.length == 1) return distanceBetween(p, polyline.first);

    double minDistance = double.infinity;
    for (int i = 0; i < polyline.length - 1; i++) {
      double dist = distanceToSegment(p, polyline[i], polyline[i + 1]);
      if (dist < minDistance) {
        minDistance = dist;
      }
    }
    return minDistance;
  }

  bool checkRouteDeviation(LatLng driverPos, List<LatLng> polylinePoints, double thresholdInMeters) {
    if (polylinePoints.isEmpty) return false;
    double minDistance = minDistanceToPolyline(driverPos, polylinePoints);
    return minDistance > thresholdInMeters;
  }
}
