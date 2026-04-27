class AppConstants {
  static const String baseUrl = "https://api.pikmycar.com/api/v1";

  static const String loginEndpoint = "/driver/auth/login";
  static const String refreshEndpoint = "/auth/refresh-token";

  // Scalability & Performance
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
