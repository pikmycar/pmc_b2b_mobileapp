import '../datasource/auth_api.dart';
import '../models/login_response.dart';

class AuthRepository {
  final AuthApi api;

  AuthRepository(this.api);

  Future<LoginResponse> login(String mobile, String password) async {
    final response = await api.login(mobile, password);
    return LoginResponse.fromJson(response.data);
  }

  Future<bool> validateToken(String token) async {
    // Implement token validation API call if exists
    return true; 
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await api.refreshToken(refreshToken);
    return response.data['data'] ?? response.data;
  }
}
