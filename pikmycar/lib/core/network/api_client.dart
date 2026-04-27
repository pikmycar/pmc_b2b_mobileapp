import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage_service.dart';

class ApiClient {
  late Dio dio;
  final SecureStorageService storageService;

  ApiClient(this.storageService) {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          "Content-Type": "application/json",
        },
      ),
    );

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 🔥 Attach token automatically
        final token = await storageService.getToken();
        if (token != null) {
          options.headers["Authorization"] = "Bearer $token";
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // 🔥 Handle 401 automatically (Refresh Token Flow)
        if (e.response?.statusCode == 401) {
          final refreshToken = await storageService.getRefreshToken();
          
          if (refreshToken != null) {
            try {
              // We use a clean Dio instance for the refresh call to avoid infinite loops
              final refreshDio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
              final response = await refreshDio.post(
                AppConstants.refreshEndpoint,
                data: {"refresh_token": refreshToken},
              );

              if (response.statusCode == 200 || response.statusCode == 201) {
                final data = response.data['data'] ?? response.data;
                final newAccessToken = data['access_token'] ?? data['token'];
                final newRefreshToken = data['refresh_token'];

                // Save tokens
                await storageService.saveToken(newAccessToken);
                if (newRefreshToken != null) {
                  await storageService.saveRefreshToken(newRefreshToken);
                }

                // Retry original request
                final opts = e.requestOptions;
                opts.headers["Authorization"] = "Bearer $newAccessToken";
                
                final retryResponse = await dio.fetch(opts);
                return handler.resolve(retryResponse);
              }
            } catch (refreshError) {
              // Refresh failed, logout
              await storageService.logout();
              // TODO: Trigger navigation to login if possible via a stream or event
            }
          } else {
            // No refresh token, logout
            await storageService.logout();
          }
        }
        return handler.next(e);
      },
    ));
  }
}
