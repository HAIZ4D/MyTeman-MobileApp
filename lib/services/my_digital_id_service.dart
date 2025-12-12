// FILE: lib/services/my_digital_id_service.dart

import 'package:local_auth/local_auth.dart';
import '../models/user.dart';

/// MyDigitalID Service for biometric authentication and data retrieval
class MyDigitalIDService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Authenticate using biometrics
  Future<bool> authenticateBiometric({
    required String reason,
  }) async {
    try {
      // Check if biometric auth is available
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        print('Biometric authentication not available - simulating success for demo');
        // For demo purposes, simulate successful authentication
        await Future.delayed(const Duration(milliseconds: 800));
        return true; // ✅ Allow demo to continue even without biometric
      }

      // Authenticate
      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow PIN/Pattern as fallback
        ),
      );

      return authenticated;
    } catch (e) {
      print('Biometric authentication error: $e');
      // For demo purposes, return true on error so flow continues
      await Future.delayed(const Duration(milliseconds: 800));
      return true; // ✅ Allow demo to continue on error
    }
  }

  /// Get user data from MyDigitalID (simulated)
  Future<Map<String, dynamic>?> getUserData(User user) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock MyDigitalID data
    return {
      'name': user.name,
      'ic_number': user.icNumber,
      'address': user.address,
      'phone': '+60123456789',
      'email': '${user.name.toLowerCase().replaceAll(' ', '.')}@example.com',
      'dob': user.dob,
      'verified': true,
    };
  }

  /// Check if MyDigitalID is linked
  bool isLinked(User user) {
    return user.mydigitalidLinked;
  }
}
