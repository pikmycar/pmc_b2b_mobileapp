import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../data/repository/auth_repository.dart';
import '../../../core/storage/secure_storage_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final SecureStorageService storage;

  AuthBloc({
    required this.authRepository,
    required this.storage,
  }) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginEvent>(_onLoginEvent);
    on<LogoutRequested>(_onLogoutRequested);
    on<PinCreated>(_onPinCreated);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    final bool loggedIn = await storage.isLoggedIn();
    if (!loggedIn) {
      emit(AuthUnauthenticated());
      return;
    }

    final String? token = await storage.getToken();
    final String? role = await storage.getRole();
    final String? pin = await storage.getPin();

    if (token != null && role != null) {
      if (pin == null || pin.isEmpty) {
        emit(AuthPinRequired(role));
      } else {
        emit(AuthAuthenticated(role));
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginEvent(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final res = await authRepository.login(event.mobile, event.password);

      // SAVE DATA
      await storage.saveToken(res.token);
      await storage.saveRefreshToken(res.refreshToken);
      await storage.saveDriverId(res.driverId);
      await storage.saveUserName(res.userName);
      await storage.saveRole(res.role);
      await storage.write("is_verified", res.isDocumentVerified.toString());
      await storage.setLoggedIn(true);

      // Check PIN after login
      final String? existingPin = await storage.getPin();
      if (existingPin == null || existingPin.isEmpty) {
        emit(AuthPinRequired(res.role));
      } else {
        emit(AuthAuthenticated(res.role));
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> _onPinCreated(PinCreated event, Emitter<AuthState> emit) async {
    try {
      await storage.savePin(event.pin);
      final role = await storage.getRole();
      emit(AuthAuthenticated(role ?? "main_driver"));
    } catch (e) {
      emit(AuthError("Failed to save PIN: $e"));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await storage.logout();
    emit(AuthUnauthenticated());
  }
}
