class AuthRepository {
  // Mock login API call
  Future<Map<String, dynamic>> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Simple mock logic
    if (username.isNotEmpty && password.isNotEmpty) {
      return {
        'success': true,
        'message': 'OTP sent to registered mobile number',
      };
    } else {
      throw Exception('Invalid credentials');
    }
  }

  // Mock OTP verification API call
  Future<Map<String, dynamic>> verifyOtp(String otp) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Simple mock logic
    if (otp == '123456') {
      return {
        'success': true,
        'token': 'mock_jwt_token_\${DateTime.now().millisecondsSinceEpoch}',
        'role': 'support_driver', // or 'main_driver'
      };
    } else {
      throw Exception('Invalid OTP');
    }
  }

  // Mock token validation call
  Future<bool> validateToken(String token) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock validation logic: check if token is not "expired"
    // In real app, this would be an API call or JWT decoding check
    if (token.startsWith('mock_jwt_token_')) {
      final timestampStr = token.replaceFirst('mock_jwt_token_', '');
      final timestamp = int.tryParse(timestampStr) ?? 0;
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      
      // Mock expiry: 24 hours (in ms)
      const expiryDuration = 24 * 60 * 60 * 1000;
      return (currentTime - timestamp) < expiryDuration;
    }
    return false;
  }
}
