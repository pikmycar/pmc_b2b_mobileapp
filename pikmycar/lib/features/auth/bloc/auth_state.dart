import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String role;
  final bool isFirstLogin; // To trigger biometric dialog if true

  const AuthAuthenticated({required this.role, this.isFirstLogin = false});

  @override
  List<Object?> get props => [role, isFirstLogin];
}

class AuthOtpRequired extends AuthState {
  final String message;

  const AuthOtpRequired(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
