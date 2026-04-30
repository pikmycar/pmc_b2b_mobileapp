class AppConstants {
  static const String baseUrl = "https://api.pikmycar.com/api/v1";

  // Auth
  static const String loginEndpoint = "/driver/auth/login";
  static const String refreshEndpoint = "/auth/refresh-token";

  // Driver
  static const String availabilityEndpoint = "/driver/availability";
  static const String locationEndpoint = "/driver/location";
    static const String profileEndpoint = "/driver/profile"; // ✅ ADD THIS
static const String ratingsEndpoint = "/driver/ratings";

  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}