import 'package:equatable/equatable.dart';

abstract class UpdateProfileEvent extends Equatable {
  const UpdateProfileEvent();

  @override
  List<Object?> get props => [];
}

class SubmitUpdateProfileEvent extends UpdateProfileEvent {
  final String? name;
  final String? email;
  final String? phone;

  const SubmitUpdateProfileEvent({
    this.name,
    this.email,
    this.phone,
  });

  @override
  List<Object?> get props => [name, email, phone];
}
