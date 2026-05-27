import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../../core/models/trip_models.dart';

abstract class TripState extends Equatable {
  final TripStatus status;
  final Trip? activeTrip;
  final String? error;
  final bool isLoading;
  final double? currentLatitude;
  final double? currentLongitude;
  final double? currentHeading;
  final List<LatLng> routePoints;
  final String? eta;
  final String? distanceRemaining;

  const TripState({
    this.status = TripStatus.offline,
    this.activeTrip,
    this.error,
    this.isLoading = false,
    this.currentLatitude,
    this.currentLongitude,
    this.currentHeading,
    this.routePoints = const [],
    this.eta,
    this.distanceRemaining,
  });

  @override
  List<Object?> get props => [
        status,
        activeTrip,
        error,
        isLoading,
        currentLatitude,
        currentLongitude,
        currentHeading,
        routePoints,
        eta,
        distanceRemaining,
      ];
}

class TripInitial extends TripState {
  const TripInitial() : super();
}

class TripUpdate extends TripState {
  const TripUpdate({
    required super.status,
    super.activeTrip,
    super.error,
    super.isLoading,
    super.currentLatitude,
    super.currentLongitude,
    super.currentHeading,
    super.routePoints = const [],
    super.eta,
    super.distanceRemaining,
  });
}
