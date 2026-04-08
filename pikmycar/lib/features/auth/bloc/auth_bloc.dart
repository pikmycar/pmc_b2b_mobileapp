import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../repository/auth_repository.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/services/biometric_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final SecureStorageService storageService;
  final BiometricService biometricService;

  AuthBloc({
    required this.authRepository,
    required this.storageService,
    required this.biometricService,
  }) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<OtpVerified>(_onOtpVerified);
    on<BiometricLoginRequested>(_onBiometricLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    final bool loggedIn = await storageService.isLoggedIn();
    if (!loggedIn) {
      emit(AuthUnauthenticated());
      return;
    }

    final String? token = await storageService.getAuthToken();
    if (token == null) {
      emit(AuthUnauthenticated());
      return;
    }

    // Validate token first
    final bool isTokenValid = await authRepository.validateToken(token);
    if (!isTokenValid) {
      await storageService.clearAll();
      emit(AuthUnauthenticated());
      return;
    }

    final bool bioEnabled = await storageService.isBiometricEnabled();
    final bool bioAvailable = await biometricService.isBiometricAvailable();

    if (bioEnabled && bioAvailable) {
      // Trigger biometric login flow
      add(BiometricLoginRequested());
    } else {
      // If biometric not enabled/available but already logged in with successful token validation,
      // navigate directly to dashboard (Auto-login)
      emit(const AuthAuthenticated(role: 'support_driver', isFirstLogin: false));
    }
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await authRepository.login(event.username, event.password);
      emit(AuthOtpRequired(response['message']));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onOtpVerified(OtpVerified event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await authRepository.verifyOtp(event.otp);
      
      final String token = response['token'];
      final String role = response['role'];
      
      await storageService.saveAuthToken(token);
      await storageService.setLoggedIn(true);
      
      emit(AuthAuthenticated(role: role, isFirstLogin: true));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onBiometricLoginRequested(BiometricLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    final bool bioAvailable = await biometricService.isBiometricAvailable();
    if (!bioAvailable) {
      emit(AuthUnauthenticated());
      return;
    }

    final bool authenticated = await biometricService.authenticate();
    if (authenticated) {
      // For mock purposes, we'll assume support_driver role
      emit(const AuthAuthenticated(role: 'support_driver'));
    } else {
      // Fallback to login screen
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await storageService.clearAll();
    emit(AuthUnauthenticated());
  }
}
