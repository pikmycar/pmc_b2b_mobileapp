import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;

  const LoginRequested({required this.username, required this.password});

  @override
  List<Object> get props => [username, password];
}

class OtpVerified extends AuthEvent {
  final String otp;

  const OtpVerified({required this.otp});

  @override
  List<Object> get props => [otp];
}

class BiometricLoginRequested extends AuthEvent {}

class LogoutRequested extends AuthEvent {}
