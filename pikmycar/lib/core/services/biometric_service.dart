import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  // Check if biometrics is supported by the device
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException {
      return false;
    }
  }

  // Check if there are any biometrics enrolled
  Future<bool> hasEnrolledBiometrics() async {
    try {
      final List<BiometricType> availableBiometrics =
          await _auth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  // Trigger Biometric Authentication
  Future<bool> authenticate() async {
    try {
      // Using core authenticate call for maximum compatibility
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Please authenticate to log in',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return didAuthenticate;
    } on PlatformException {
      // Handle edge cases here, do not crash
      return false;
    }
  }
}
