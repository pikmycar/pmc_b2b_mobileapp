class LoginResponse {
  final String token;
  final String refreshToken;
  final String driverId;
  final String userName;
  final String role;
  final bool isDocumentVerified;

  LoginResponse({
    required this.token,
    required this.refreshToken,
    required this.driverId,
    required this.userName,
    required this.role,
    required this.isDocumentVerified,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Handling nested data if applicable, otherwise fallback to top-level
    final data = json['data'] ?? json;

    return LoginResponse(
      token: data['token'] ?? "",
      refreshToken: data['refresh_token'] ?? "",
      driverId: data['driver_id'] ?? "",
      userName: data['user_name'] ?? "",
      role: data['role'] ?? "",
      isDocumentVerified: data['is_document_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refresh_token': refreshToken,
      'driver_id': driverId,
      'user_name': userName,
      'role': role,
      'is_document_verified': isDocumentVerified,
    };
  }
}
