import 'package:equatable/equatable.dart';
import '../../../data/models/support_pickMe_request.dart';

abstract class SupportPickMeRequestState extends Equatable {
  const SupportPickMeRequestState();

  @override
  List<Object?> get props => [];
}

class SupportPickMeRequestInitial extends SupportPickMeRequestState {
  const SupportPickMeRequestInitial();
}

class SupportPickMeRequestLoading extends SupportPickMeRequestState {
  const SupportPickMeRequestLoading();
}

class SupportPickMeRequestSuccess extends SupportPickMeRequestState {
  final SupportPickmeRequest requestDetails;

  const SupportPickMeRequestSuccess({required this.requestDetails});

  @override
  List<Object?> get props => [requestDetails];
}

class SupportPickMeRequestAccepted extends SupportPickMeRequestState {
  const SupportPickMeRequestAccepted();
}

class SupportPickMeRequestDeclined extends SupportPickMeRequestState {
  const SupportPickMeRequestDeclined();
}

class SupportPickMeRequestCompleted extends SupportPickMeRequestState {
  const SupportPickMeRequestCompleted();
}

class SupportPickMeRequestError extends SupportPickMeRequestState {
  final String message;

  const SupportPickMeRequestError({required this.message});

  @override
  List<Object?> get props => [message];
}
