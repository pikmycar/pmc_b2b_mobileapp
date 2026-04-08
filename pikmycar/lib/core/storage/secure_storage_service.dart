import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/auth_constants.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Write data
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Read data
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  // Delete data
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  // Clear all data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Auth specific helper methods
  Future<void> saveAuthToken(String token) async {
    await write(AuthConstants.authToken, token);
  }

  Future<String?> getAuthToken() async {
    return await read(AuthConstants.authToken);
  }

  Future<void> setLoggedIn(bool isLoggedIn) async {
    await write(AuthConstants.isLoggedIn, isLoggedIn.toString());
  }

  Future<bool> isLoggedIn() async {
    final value = await read(AuthConstants.isLoggedIn);
    return value == 'true';
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await write(AuthConstants.biometricEnabled, enabled.toString());
  }

  Future<bool> isBiometricEnabled() async {
    final value = await read(AuthConstants.biometricEnabled);
    return value == 'true';
  }
}
