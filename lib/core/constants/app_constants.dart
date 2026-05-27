class AppConstants {
  AppConstants._();

  // =========================
  // BASE URLS
  // =========================

  static const String baseUrl = "https://api.pikmycar.com/api/v1";

  // Secure WebSocket
  static const String wsBaseUrl =
      "wss://api.pikmycar.com";
  // Google Maps
  static const String googleMapsApiKey =
      "AIzaSyDxV3x0-Ra1FsFY2m2wPPwEbGAPNDbSSEQ";

  // =========================
  // AUTH ENDPOINTS
  // =========================

  static const String loginEndpoint =
      "$baseUrl/driver/auth/login";

  static const String refreshEndpoint =
      "$baseUrl/auth/refresh-token";

  // =========================
  // DRIVER ENDPOINTS
  // =========================

  static const String availabilityEndpoint =
      "$baseUrl/driver/availability";

  /// FIXED LOCATION ENDPOINT
  /// OLD => /driver/location/update
  /// NEW => /drivers/location/update
  static const String locationEndpoint =
      "$baseUrl/driver/location/update";

  static const String profileEndpoint =
      "$baseUrl/driver/profile";

  static const String ratingsEndpoint =
      "$baseUrl/driver/ratings";

  static const String earningsEndpoint =
      "$baseUrl/driver/earnings";

  // =========================
  // BANK ENDPOINTS
  // =========================

  static const String createBankEndpoint =
      "$baseUrl/driver/bank";

  static const String getBankEndpoint =
      "$baseUrl/driver/bank";

  // =========================
  // TICKET ENDPOINTS
  // =========================

  static const String fetchTicketsEndpoint =
      "$baseUrl/web/tickets/fetch";

  static const String fetchTicketByIdEndpoint =
      "$baseUrl/web/tickets/fetch-by-id";

  static const String updateTicketEndpoint =
      "$baseUrl/web/tickets/update";

  // =========================
  // MAIN DRIVER ENDPOINTS
  // =========================

  static const String sendMainDriverRequestEndpoint =
      "$baseUrl/driver/send-main-driver-request";

  static const String pendingRequestsEndpoint =
      "$baseUrl/main-driver-requests/pending";

  /// Usage:
  /// "$acceptRequestEndpoint/{id}/accept"
  static const String acceptRequestEndpoint =
      "$baseUrl/main-driver-requests";

  /// Usage:
  /// "$rejectRequestEndpoint/{id}/reject"
  static const String rejectRequestEndpoint =
      "$baseUrl/main-driver-requests";

  /// Usage:
  /// "$ticketDetailsEndpoint/{id}"
  static const String ticketDetailsEndpoint =
      "$baseUrl/main-driver-requests";

  // =========================
  // WEBSOCKET ENDPOINTS
  // =========================

  /// Usage:
  /// "$mainDriverWsEndpoint/{driverId}?token=$token"
  static const String mainDriverWsEndpoint =
      "$wsBaseUrl/api/v1/ws/main-driver";

  // =========================
  // TIMEOUTS
  // =========================

  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}