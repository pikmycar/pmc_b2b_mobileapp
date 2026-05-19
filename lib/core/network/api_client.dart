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
        connectTimeout: Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          "Content-Type": "application/json",
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storageService.getToken();
          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {

          // 🔒 Prevent infinite loop
          if (e.requestOptions.path.contains(AppConstants.refreshEndpoint)) {
            return handler.next(e);
          }

          if (e.response?.statusCode == 401) {
            final refreshToken = await storageService.getRefreshToken();

            if (refreshToken != null) {
              try {
                final refreshDio = Dio(
                  BaseOptions(
                    baseUrl: AppConstants.baseUrl,
                    connectTimeout: Duration(milliseconds: AppConstants.connectTimeout),
                    receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
                    headers: {"Content-Type": "application/json"},
                  ),
                );

                final response = await refreshDio.post(
                  AppConstants.refreshEndpoint,
                  data: {"refresh_token": refreshToken},
                );

                if (response.statusCode == 200 || response.statusCode == 201) {
                  final data = response.data['data'] ?? response.data;

                  final newAccessToken = data['access_token'] ?? data['token'];
                  final newRefreshToken = data['refresh_token'];

                  if (newAccessToken != null) {
                    await storageService.saveToken(newAccessToken);
                  }

                  if (newRefreshToken != null) {
                    await storageService.saveRefreshToken(newRefreshToken);
                  }

                  final opts = e.requestOptions;

                  final retryResponse = await dio.request(
                    opts.path,
                    data: opts.data,
                    queryParameters: opts.queryParameters,
                    options: Options(
                      method: opts.method,
                      headers: {
                        ...opts.headers,
                        "Authorization": "Bearer $newAccessToken",
                      },
                    ),
                  );

                  return handler.resolve(retryResponse);
                }
              } catch (_) {
                await storageService.logout();
              }
            } else {
              await storageService.logout();
            }
          }

          return handler.next(e);
        },
      ),
    );

    // Optional debug logs
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    );
  }
}