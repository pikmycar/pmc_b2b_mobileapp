import 'package:equatable/equatable.dart';
import '../../../data/models/cust_request_trip_by_id.dart';

abstract class CustRequestTripByIdState extends Equatable {
  const CustRequestTripByIdState();

  @override
  List<Object?> get props => [];
}

class CustRequestTripByIdInitial extends CustRequestTripByIdState {
  const CustRequestTripByIdInitial();
}

class CustRequestTripByIdLoading extends CustRequestTripByIdState {
  const CustRequestTripByIdLoading();
}

class CustRequestTripByIdSuccess extends CustRequestTripByIdState {
  final CustRequestTripById tripDetails;

  const CustRequestTripByIdSuccess({required this.tripDetails});

  @override
  List<Object?> get props => [tripDetails];
}

class CustRequestTripByIdError extends CustRequestTripByIdState {
  final String message;

  const CustRequestTripByIdError({required this.message});

  @override
  List<Object?> get props => [message];
}
