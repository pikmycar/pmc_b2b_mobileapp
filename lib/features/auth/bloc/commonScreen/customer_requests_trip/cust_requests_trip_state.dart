import 'package:equatable/equatable.dart';
import '../../../data/models/cust_requests_trip.dart';

abstract class CustRequestsTripState extends Equatable {
  const CustRequestsTripState();

  @override
  List<Object?> get props => [];
}

class CustRequestsTripInitial extends CustRequestsTripState {
  const CustRequestsTripInitial();
}

class CustRequestsTripLoading extends CustRequestsTripState {
  const CustRequestsTripLoading();
}

class CustRequestsTripSuccess extends CustRequestsTripState {
  final CustRequestTrip tripData;

  const CustRequestsTripSuccess({required this.tripData});

  @override
  List<Object?> get props => [tripData];
}

class CustRequestsTripAccepted extends CustRequestsTripState {
  final String tripId;

  const CustRequestsTripAccepted({required this.tripId});

  @override
  List<Object?> get props => [tripId];
}

class CustRequestsTripDeclined extends CustRequestsTripState {
  final String tripId;

  const CustRequestsTripDeclined({required this.tripId});

  @override
  List<Object?> get props => [tripId];
}

class CustRequestsTripCompleted extends CustRequestsTripState {
  final String tripId;

  const CustRequestsTripCompleted({required this.tripId});

  @override
  List<Object?> get props => [tripId];
}

class CustRequestsTripError extends CustRequestsTripState {
  final String message;

  const CustRequestsTripError({required this.message});

  @override
  List<Object?> get props => [message];
}
