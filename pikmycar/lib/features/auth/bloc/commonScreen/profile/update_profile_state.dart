import 'package:equatable/equatable.dart';
import '../../../data/models/update_profile.dart';

abstract class UpdateProfileState extends Equatable {
  const UpdateProfileState();

  @override
  List<Object?> get props => [];
}

class UpdateProfileInitial extends UpdateProfileState {
  const UpdateProfileInitial();
}

class UpdateProfileLoading extends UpdateProfileState {
  const UpdateProfileLoading();
}

class UpdateProfileSuccess extends UpdateProfileState {
  final UpdateProfileResponse response;

  const UpdateProfileSuccess({required this.response});

  @override
  List<Object?> get props => [response];
}

class UpdateProfileError extends UpdateProfileState {
  final String message;

  const UpdateProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}
