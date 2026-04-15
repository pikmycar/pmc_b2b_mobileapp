import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trip_models.dart';

class TripStorageService {
  static const String _tripKey = 'active_trip_data';

  Future<void> saveTrip(Trip trip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tripKey, jsonEncode(trip.toJson()));
  }

  Future<Trip?> getTrip() async {
    final prefs = await SharedPreferences.getInstance();
    final tripData = prefs.getString(_tripKey);
    if (tripData == null) return null;
    try {
      return Trip.fromJson(jsonDecode(tripData));
    } catch (e) {
      return null;
    }
  }

  Future<void> clearTrip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tripKey);
  }
}
