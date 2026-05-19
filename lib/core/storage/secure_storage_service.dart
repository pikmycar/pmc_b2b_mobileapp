import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/auth_constants.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ===============================
  // 🔹 BASIC METHODS
  // ===============================

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // ===============================
  // 🔹 AUTH TOKENS
  // ===============================

  Future<void> saveToken(String token) async {
    await write(AuthConstants.authToken, token);
  }

  Future<String?> getToken() async {
    return await read(AuthConstants.authToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await write(AuthConstants.refreshToken, token);
  }

  Future<String?> getRefreshToken() async {
    return await read(AuthConstants.refreshToken);
  }

  // ===============================
  // 🔹 DRIVER METADATA
  // ===============================

  Future<void> saveRole(String role) async {
    await write(AuthConstants.userRole, role);
  }

  Future<String?> getRole() async {
    return await read(AuthConstants.userRole);
  }

  Future<void> saveDriverId(String id) async {
    await write(AuthConstants.driverId, id);
  }

  Future<String?> getDriverId() async {
    return await read(AuthConstants.driverId);
  }

  Future<void> saveUserName(String name) async {
    await write(AuthConstants.userName, name);
  }

  Future<String?> getUserName() async {
    return await read(AuthConstants.userName);
  }

  Future<void> setLoggedIn(bool isLoggedIn) async {
    await write(AuthConstants.isLoggedIn, isLoggedIn.toString());
  }

  Future<bool> isLoggedIn() async {
    final value = await read(AuthConstants.isLoggedIn);
    return value == 'true';
  }

  // ===============================
  // 🔹 FULL LOGOUT
  // ===============================

  Future<void> logout() async {
    await clearAll();
    await setLoggedIn(false);
  }

  // Legacy support for refactoring
  Future<void> saveAuthToken(String token) => saveToken(token);
  Future<String?> getAuthToken() => getToken();
  Future<void> setUserRole(String role) => saveRole(role);
  Future<String?> getUserRole() => getRole();
  Future<void> savePin(String pin) => write(AuthConstants.userPin, pin);
  Future<String?> getPin() => read(AuthConstants.userPin);
  Future<bool> isBiometricEnabled() async {
    final value = await read(AuthConstants.biometricEnabled);
    return value == 'true';
  }
  Future<void> setBiometricEnabled(bool enabled) => write(AuthConstants.biometricEnabled, enabled.toString());
}