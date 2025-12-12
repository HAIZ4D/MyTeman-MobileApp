// Configuration for the ISN app
// Toggle between Firebase and local JSON for prototyping

class AppConfig {
  // Set to false for local JSON demo (offline-first development)
  // Set to true when Firebase is configured
  static const bool useFirebase = false;

  // Debug mode shows additional information
  static const bool debugMode = true;

  // Default language
  static const String defaultLanguage = 'ms';

  // Biometric authentication timeout (seconds)
  static const int biometricTimeout = 30;
}
