import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final String mobile;
  final String password;

  const LoginEvent({required this.mobile, required this.password});

  @override
  List<Object?> get props => [mobile, password];
}

class LogoutRequested extends AuthEvent {}

class PinCreated extends AuthEvent {
  final String pin;
  const PinCreated(this.pin);

  @override
  List<Object?> get props => [pin];
}
