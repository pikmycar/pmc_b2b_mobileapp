import 'package:equatable/equatable.dart';

abstract class SupportPickMeRequestEvent extends Equatable {
  const SupportPickMeRequestEvent();

  @override
  List<Object?> get props => [];
}

class FetchSupportPickMeRequestEvent extends SupportPickMeRequestEvent {
  final String ticketId;
  final String supportDriverId;
  final String pickupLocation;
  final double pickupLatitude;
  final double pickupLongitude;
  final String pickupGoogleMapsAddress;
  final String dropLocation;
  final double dropLatitude;
  final double dropLongitude;
  final String dropGoogleMapsAddress;
  final String notes;
  final bool sameVendorOnly;

  const FetchSupportPickMeRequestEvent({
    required this.ticketId,
    required this.supportDriverId,
    required this.pickupLocation,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.pickupGoogleMapsAddress,
    required this.dropLocation,
    required this.dropLatitude,
    required this.dropLongitude,
    required this.dropGoogleMapsAddress,
    required this.notes,
    required this.sameVendorOnly,
  });

  @override
  List<Object?> get props => [
        ticketId,
        supportDriverId,
        pickupLocation,
        pickupLatitude,
        pickupLongitude,
        pickupGoogleMapsAddress,
        dropLocation,
        dropLatitude,
        dropLongitude,
        dropGoogleMapsAddress,
        notes,
        sameVendorOnly,
      ];
}

class AcceptSupportPickMeRequestEvent extends SupportPickMeRequestEvent {
  final String tripId;

  const AcceptSupportPickMeRequestEvent({required this.tripId});

  @override
  List<Object?> get props => [tripId];
}

class DeclineSupportPickMeRequestEvent extends SupportPickMeRequestEvent {
  final String tripId;

  const DeclineSupportPickMeRequestEvent({required this.tripId});

  @override
  List<Object?> get props => [tripId];
}

class CompleteSupportPickMeRequestEvent extends SupportPickMeRequestEvent {
  final String tripId;

  const CompleteSupportPickMeRequestEvent({required this.tripId});

  @override
  List<Object?> get props => [tripId];
}
