import 'package:equatable/equatable.dart';

abstract class GetTripMainDriverStatusEvent extends Equatable {
  const GetTripMainDriverStatusEvent();

  @override
  List<Object?> get props => [];
}

class FetchTripMainDriverStatusEvent extends GetTripMainDriverStatusEvent {
  final String ticketId;

  const FetchTripMainDriverStatusEvent({required this.ticketId});

  @override
  List<Object?> get props => [ticketId];
}
