class AppConstants {
  AppConstants._();

  // =========================
  // APP MODE
  // =========================
  // Set to true for 100% offline static UI mockup testing / demo purposes.
  // Set to false to connect directly to the live backend APIs and WebSockets.
  static const bool isMockMode = false; 

  // =========================
  // BASE URLS
  // =========================

  static const String baseUrl = "https://pmcapi.pikmycar.com/api";

  // Secure WebSocket
  static const String wsBaseUrl =
      "wss://pmcapi.pikmycar.com";
  // Google Maps
  static const String googleMapsApiKey =
      "AIzaSyDxV3x0-Ra1FsFY2m2wPPwEbGAPNDbSSEQ";

  // =========================
  // AUTH ENDPOINTS
  // =========================

  static const String loginEndpoint =
      "$baseUrl/Auth/login";

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
      "$baseUrl/drivers/location/update";

  /// Usage: "$profileEndpoint?id={driverId}"
  static const String profileEndpoint =
      "$baseUrl/Master/get-driver";

  /// Usage: "$updateProfileEndpoint/{driverId}"
  static const String updateProfileEndpoint =
      "$baseUrl/Master/update-driver";

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
      "$baseUrl/SupportDriverFlow/get-assigned-tickets";

  static const String fetchTicketByIdEndpoint =
      "$baseUrl/SupportDriverFlow/get-ticket-details";

  static const String updateTicketEndpoint =
      "$baseUrl/web/tickets/update";

  // =========================
  // MAIN DRIVER ENDPOINTS
  // =========================

  static const String sendMainDriverRequestEndpoint =
      "$baseUrl/SupportDriverFlow/request-main-driver";

  static const String getTripMainDriverStatusEndpoint =
      "$baseUrl/SupportDriverFlow/get-main-driver-status";

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