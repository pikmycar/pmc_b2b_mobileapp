import 'package:equatable/equatable.dart';
import '../../../data/models/get_profile.dart'; // Ensure compatibility with existing model

abstract class GetProfileState extends Equatable {
  const GetProfileState();
  
  @override
  List<Object?> get props => [];
}

class GetProfileInitial extends GetProfileState {
  const GetProfileInitial();
}

class GetProfileLoading extends GetProfileState {
  const GetProfileLoading();
}

class GetProfileSuccess extends GetProfileState {
  final GetProfileDetails profileDetails;

  const GetProfileSuccess({required this.profileDetails});

  @override
  List<Object?> get props => [profileDetails];
}

class GetProfileError extends GetProfileState {
  final String message;

  const GetProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}
