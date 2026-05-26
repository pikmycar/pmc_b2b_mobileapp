import 'package:equatable/equatable.dart';

abstract class CustRequestTripByIdEvent extends Equatable {
  const CustRequestTripByIdEvent();

  @override
  List<Object?> get props => [];
}

class FetchCustRequestTripByIdEvent extends CustRequestTripByIdEvent {
  final String tripId;

  const FetchCustRequestTripByIdEvent({required this.tripId});

  @override
  List<Object?> get props => [tripId];
}
