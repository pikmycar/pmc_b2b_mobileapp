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
  // 🔹 AUTH TOKEN
  // ===============================

  Future<void> saveAuthToken(String token) async {
    await write(AuthConstants.authToken, token);
  }

  Future<String?> getAuthToken() async {
    return await read(AuthConstants.authToken);
  }

  Future<void> removeAuthToken() async {
    await delete(AuthConstants.authToken);
  }

  // ===============================
  // 🔹 LOGIN STATUS
  // ===============================

  Future<void> setLoggedIn(bool isLoggedIn) async {
    await write(AuthConstants.isLoggedIn, isLoggedIn.toString());
  }

  Future<bool> isLoggedIn() async {
    final value = await read(AuthConstants.isLoggedIn);
    return value == 'true';
  }

  // ===============================
  // 🔹 BIOMETRIC
  // ===============================

  Future<void> setBiometricEnabled(bool enabled) async {
    await write(AuthConstants.biometricEnabled, enabled.toString());
  }

  Future<bool> isBiometricEnabled() async {
    final value = await read(AuthConstants.biometricEnabled);
    return value == 'true';
  }

  Future<void> removeBiometric() async {
    await delete(AuthConstants.biometricEnabled);
  }

  // ===============================
  // 🔹 PIN (NEW 🔥)
  // ===============================

  Future<void> savePin(String pin) async {
    await write(AuthConstants.userPin, pin);
  }

  Future<String?> getPin() async {
    return await read(AuthConstants.userPin);
  }

  Future<void> removePin() async {
    await delete(AuthConstants.userPin);
  }

  // ===============================
  // 🔹 FULL LOGOUT (IMPORTANT 🔥)
  // ===============================

  Future<void> logout() async {
    await removeAuthToken();
    await removePin();
    await removeBiometric();
    await setLoggedIn(false);
  }
}