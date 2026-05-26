import 'package:equatable/equatable.dart';

abstract class CustRequestsTripEvent extends Equatable {
  const CustRequestsTripEvent();

  @override
  List<Object?> get props => [];
}

class FetchCustRequestsTripEvent extends CustRequestsTripEvent {
  const FetchCustRequestsTripEvent();
}

class AcceptCustRequestsTripEvent extends CustRequestsTripEvent {
  final String tripId;

  const AcceptCustRequestsTripEvent({required this.tripId});

  @override
  List<Object?> get props => [tripId];
}

class DeclineCustRequestsTripEvent extends CustRequestsTripEvent {
  final String tripId;

  const DeclineCustRequestsTripEvent({required this.tripId});

  @override
  List<Object?> get props => [tripId];
}

class CompleteCustRequestsTripEvent extends CustRequestsTripEvent {
  final String tripId;

  const CompleteCustRequestsTripEvent({required this.tripId});

  @override
  List<Object?> get props => [tripId];
}
