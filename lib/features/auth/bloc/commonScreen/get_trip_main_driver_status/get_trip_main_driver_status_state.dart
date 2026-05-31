import 'package:equatable/equatable.dart';
import '../../../data/models/getTrip_mainDriver_status.dart';

abstract class GetTripMainDriverStatusState extends Equatable {
  const GetTripMainDriverStatusState();

  @override
  List<Object?> get props => [];
}

class GetTripMainDriverStatusInitial extends GetTripMainDriverStatusState {
  const GetTripMainDriverStatusInitial();
}

class GetTripMainDriverStatusLoading extends GetTripMainDriverStatusState {
  const GetTripMainDriverStatusLoading();
}

class GetTripMainDriverStatusSearching extends GetTripMainDriverStatusState {
  final GetTripMainDriverStatus statusDetails;

  const GetTripMainDriverStatusSearching({required this.statusDetails});

  @override
  List<Object?> get props => [statusDetails];
}

class GetTripMainDriverStatusAssigned extends GetTripMainDriverStatusState {
  final GetTripMainDriverStatus statusDetails;

  const GetTripMainDriverStatusAssigned({required this.statusDetails});

  @override
  List<Object?> get props => [statusDetails];
}

class GetTripMainDriverStatusError extends GetTripMainDriverStatusState {
  final String message;

  const GetTripMainDriverStatusError({required this.message});

  @override
  List<Object?> get props => [message];
}
