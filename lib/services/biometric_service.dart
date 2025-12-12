import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

/// Biometric authentication service for secure application submissions
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Check if biometric authentication is available on device
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } catch (e) {
      print('BiometricService: Error checking availability: $e');
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      print('BiometricService: Error getting available biometrics: $e');
      return [];
    }
  }

  /// Authenticate user with biometric or device credentials
  /// Returns true if authentication successful, false otherwise
  /// Now includes fallback to device PIN/pattern/password
  Future<bool> authenticate({
    required String language,
    required String reason,
  }) async {
    try {
      final bool isAvailable = await isBiometricAvailable();

      if (!isAvailable) {
        print('BiometricService: Biometric not available on this device - will use device credentials');
        // If biometric not available, still try to authenticate with device credentials
        // This allows PIN/pattern/password authentication
      }

      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow device credentials (PIN/pattern/password)
          useErrorDialogs: true,
        ),
        authMessages: <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: language == 'ms'
                ? 'Pengesahan Identiti'
                : 'Identity Verification',
            cancelButton: language == 'ms' ? 'Batal' : 'Cancel',
            biometricHint: language == 'ms'
                ? 'Sahkan identiti anda menggunakan biometrik atau PIN peranti'
                : 'Verify your identity using biometric or device PIN',
            biometricNotRecognized: language == 'ms'
                ? 'Tidak dikenali. Sila cuba lagi.'
                : 'Not recognized. Please try again.',
            biometricSuccess: language == 'ms'
                ? 'Berjaya'
                : 'Success',
            deviceCredentialsRequiredTitle: language == 'ms'
                ? 'Pengesahan Diperlukan'
                : 'Authentication Required',
            deviceCredentialsSetupDescription: language == 'ms'
                ? 'Sila gunakan PIN, corak atau kata laluan peranti anda'
                : 'Please use your device PIN, pattern or password',
            goToSettingsButton: language == 'ms' ? 'Tetapan' : 'Settings',
            goToSettingsDescription: language == 'ms'
                ? 'Sila sediakan keselamatan peranti di tetapan'
                : 'Please setup device security in settings',
          ),
          IOSAuthMessages(
            cancelButton: language == 'ms' ? 'Batal' : 'Cancel',
            goToSettingsButton: language == 'ms' ? 'Tetapan' : 'Settings',
            goToSettingsDescription: language == 'ms'
                ? 'Sila sediakan keselamatan peranti di tetapan'
                : 'Please setup device security in settings',
            lockOut: language == 'ms'
                ? 'Terlalu banyak cubaan. Sila cuba lagi kemudian.'
                : 'Too many attempts. Please try again later.',
          ),
        ],
      );

      if (didAuthenticate) {
        print('BiometricService: Authentication successful');
      } else {
        print('BiometricService: Authentication cancelled or failed');
      }

      return didAuthenticate;
    } catch (e) {
      print('BiometricService: Error during authentication: $e');
      // If there's an error, return false instead of crashing
      return false;
    }
  }

  /// Get biometric type name for display
  String getBiometricTypeName(BiometricType type, String language) {
    switch (type) {
      case BiometricType.face:
        return language == 'ms' ? 'Imbasan Wajah' : 'Face ID';
      case BiometricType.fingerprint:
        return language == 'ms' ? 'Cap Jari' : 'Fingerprint';
      case BiometricType.iris:
        return language == 'ms' ? 'Imbasan Iris' : 'Iris Scan';
      case BiometricType.strong:
        return language == 'ms' ? 'Biometrik Kuat' : 'Strong Biometric';
      case BiometricType.weak:
        return language == 'ms' ? 'Biometrik Lemah' : 'Weak Biometric';
    }
  }

  /// Get user-friendly authentication reason
  static String getAuthenticationReason(String language, {String? serviceName}) {
    if (serviceName != null) {
      return language == 'ms'
          ? 'Sahkan identiti anda untuk menghantar permohonan $serviceName'
          : 'Verify your identity to submit $serviceName application';
    }

    return language == 'ms'
        ? 'Sahkan identiti anda untuk menghantar permohonan'
        : 'Verify your identity to submit application';
  }
}
