import 'package:equatable/equatable.dart';

abstract class TripEvent extends Equatable {
  const TripEvent();

  @override
  List<Object?> get props => [];
}

class GoOnline extends TripEvent {}

class GoOffline extends TripEvent {}

class SimulateRequest extends TripEvent {}

class AcceptRequest extends TripEvent {}

class DeclineRequest extends TripEvent {}

class MarkArrivedAtPickup extends TripEvent {}

class StartTripToCustomer extends TripEvent {}

class MarkDropComplete extends TripEvent {
  final String driverId;
  const MarkDropComplete(this.driverId);

  @override
  List<Object?> get props => [driverId];
}

class ResetToSearching extends TripEvent {}

class ReloadStoredTrip extends TripEvent {}

class UpdateLocation extends TripEvent {
  final double lat;
  final double lng;
  final double? heading;
  const UpdateLocation(this.lat, this.lng, [this.heading]);

  @override
  List<Object?> get props => [lat, lng, heading];
}

class FetchPendingRequests extends TripEvent {}

class NextTripStep extends TripEvent {}

class CancelActiveTrip extends TripEvent {}

class LogoutReset extends TripEvent {}

