import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/app_constants.dart';

class AuthApi {
  final ApiClient client;

  AuthApi(this.client);

  // 🔐 LOGIN
  Future<Response> login(String mobile, String password) async {
    try {
      print("🟡 API CALL: LOGIN");
      print("📤 Payload: {emailOrPhone: $mobile, password: $password}");

      final response = await client.dio.post(
        AppConstants.loginEndpoint,
        data: {
          "emailOrPhone": mobile,
          "password": password,
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

      print("🟢 SUCCESS RESPONSE: ${response.data}");
      return response;

    } on DioException catch (e) {
      String message = "Login failed";

      if (e.response != null) {
        final data = e.response?.data;

        print("🔴 STATUS CODE: ${e.response?.statusCode}");
        print("🔴 RESPONSE DATA: $data");

        if (data is Map) {
          if (data["message"] != null) {
            message = data["message"].toString();
          } else if (data["error"] != null) {
            message = data["error"].toString();
          }
          
          // Handle 422 Validation detail list
          if (data["detail"] != null && data["detail"] is List) {
            final details = data["detail"] as List;
            if (details.isNotEmpty) {
              final firstDetail = details.first;
              if (firstDetail is Map && firstDetail["message"] != null) {
                message = "${message}: ${firstDetail["message"]}";
              }
            }
          }
        } else {
          message = data.toString();
        }
      } else {
        print("🔴 DIO ERROR: ${e.message}");
        message = e.message ?? "Network error";
      }

      throw Exception(message);

    } catch (e) {
      print("🔥 UNEXPECTED ERROR: $e");
      throw Exception("Unexpected error: $e");
    }
  }

  // 🔄 REFRESH TOKEN
  Future<Response> refreshToken(String refreshToken) async {
    try {
      print("🟡 API CALL: REFRESH TOKEN");

      final response = await client.dio.post(
        AppConstants.refreshEndpoint,
        data: {
          "refresh_token": refreshToken,
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

      print("🟢 REFRESH SUCCESS: ${response.data}");
      return response;

    } on DioException catch (e) {
      String message = "Refresh token failed";

      if (e.response != null) {
        final data = e.response?.data;

        print("🔴 STATUS CODE: ${e.response?.statusCode}");
        print("🔴 RESPONSE DATA: $data");

        if (data is Map && data["message"] != null) {
          message = data["message"].toString();
        } else {
          message = data.toString();
        }
      } else {
        print("🔴 DIO ERROR: ${e.message}");
        message = e.message ?? "Network error";
      }

      throw Exception(message);

    } catch (e) {
      print("🔥 UNEXPECTED ERROR: $e");
      throw Exception("Unexpected error: $e");
    }
  }
}