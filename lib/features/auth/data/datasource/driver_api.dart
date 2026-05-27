import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/app_constants.dart';

class DriverApi {
  final ApiClient apiClient;

  DriverApi(this.apiClient);

Future<Response> updateAvailability({
  required bool isOnline,
  required bool isAvailable,
  required double lat,   // ✅ make required
  required double lng,   // ✅ make required
  String? address,
}) async {
  final Map<String, dynamic> payload = {
    "isOnline": isOnline,
    "isAvailable": isAvailable,
    "latitude": lat,      // ✅ always sent
    "longitude": lng,     // ✅ always sent
  };

  if (address != null && address.isNotEmpty) {
    payload["address"] = address;
  }

  try {
    print("🟡 UPDATE AVAILABILITY API");
    print("➡️ Payload: $payload");

    final response = await apiClient.dio.put(
      AppConstants.availabilityEndpoint,
      data: payload,
    );

    print("✅ Response: ${response.data}");
    return response;
  } on DioException catch (e) {
    print("❌ ERROR: ${e.response?.data}");
    rethrow;
  }
}Future<Response> updateLocation({
  String? tripId,
  required double lat,
  required double lng,
  double? speed,
  double? heading,
  required DateTime timestamp,
}) async {
  final payload = {
    "latitude": lat,
    "longitude": lng,
    "timestamp": timestamp.toIso8601String(),
  };

  if (tripId != null && tripId.isNotEmpty) {
    payload["tripId"] = tripId;
  }

  if (speed != null) {
    payload["speed"] = speed;
  }

  if (heading != null) {
    payload["heading"] = heading;
  }

  try {
    print("🟡 UPDATE LOCATION API");
    print("➡️ Payload: $payload");

    final response = await apiClient.dio.post(
      AppConstants.locationEndpoint,
      data: payload,
    );

    print("✅ Response Status: ${response.statusCode}");
    print("📦 Response Data: ${response.data}");

    return response;
  } on DioException catch (e) {
    print("❌ ERROR (Location): ${e.message}");
    print("❌ Response: ${e.response?.data}");
    rethrow;
  }
}

  Future<Response> getPendingRequests() async {
    try {
      print("========== PENDING API ==========");
      print("ONLINE DRIVER FETCHING REQUESTS");
      final response = await apiClient.dio.get(AppConstants.pendingRequestsEndpoint);
      print("STATUS CODE => ${response.statusCode}");
      print("RESPONSE => ${response.data}");
      return response;
    } on DioException catch (e) {
      print("STATUS CODE => ${e.response?.statusCode}");
      print("RESPONSE => ${e.response?.data}");
      rethrow;
    }
  }

  Future<Response> getMainDriverTicketDetails(String requestId) async {
    try {
      print("========== MAIN DRIVER TICKET DETAILS ==========");
      print("REQUEST ID => $requestId");
      final response = await apiClient.dio.get("${AppConstants.ticketDetailsEndpoint}/$requestId/ticket-details");
      print("STATUS CODE => ${response.statusCode}");
      print("RESPONSE => ${response.data}");
      return response;
    } on DioException catch (e) {
      print("STATUS CODE => ${e.response?.statusCode}");
      print("RESPONSE => ${e.response?.data}");
      rethrow;
    }
  }

  Future<Response> acceptRequest(String requestId) async {
    try {
      final response = await apiClient.dio.post("${AppConstants.acceptRequestEndpoint}/$requestId/accept");
      print("========== ACCEPT API ==========");
      print("REQUEST ID => $requestId");
      print("TRIP ACCEPTED");
      print("RESPONSE => ${response.data}");
      return response;
    } on DioException catch (e) {
      print("========== ACCEPT ERROR ==========");
      print("ERROR => $e");
      print("RESPONSE => ${e.response?.data}");
      print("==================================");
      rethrow;
    }
  }

  Future<Response> rejectRequest(String requestId) async {
    try {
      final response = await apiClient.dio.post(
        "${AppConstants.rejectRequestEndpoint}/$requestId/reject",
        data: {"reject_reason": "Busy"},
      );
      print("========== REJECT API ==========");
      print("REQUEST ID => $requestId");
      print("TRIP REJECTED");
      return response;
    } on DioException catch (e) {
      print("STATUS CODE => ${e.response?.statusCode}");
      print("RESPONSE => ${e.response?.data}");
      rethrow;
    }
  }

  Future<Response> updateTicketDetails(String ticketId, String status) async {
    final body = {
      "ticketId": ticketId,
      "status": status,
    };
    try {
      final response = await apiClient.dio.post(
        AppConstants.updateTicketEndpoint,
        data: body,
      );
      print("========== UPDATE TICKET ==========");
      print("TICKET ID => $ticketId");
      print("STATUS => $status");
      print("BODY => $body");
      print("RESPONSE => ${response.data}");
      return response;
    } on DioException catch (e) {
      print("========== UPDATE TICKET ERROR ==========");
      print("TICKET ID => $ticketId");
      print("STATUS => $status");
      print("BODY => $body");
      print("ERROR => $e");
      print("RESPONSE => ${e.response?.data}");
      rethrow;
    }
  }
}