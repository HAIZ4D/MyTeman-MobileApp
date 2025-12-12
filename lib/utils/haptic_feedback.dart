import 'package:flutter/services.dart';

/// Haptic feedback utility for accessibility
/// Provides vibration feedback for different user interactions
class HapticHelper {
  /// Success feedback - light single vibration
  static Future<void> success() async {
    await HapticFeedback.lightImpact();
  }

  /// Error feedback - medium double vibration
  static Future<void> error() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
  }

  /// Warning feedback - medium single vibration
  static Future<void> warning() async {
    await HapticFeedback.mediumImpact();
  }

  /// Selection feedback - light tap
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  /// Navigation feedback - light impact
  static Future<void> navigation() async {
    await HapticFeedback.lightImpact();
  }

  /// Heavy feedback for important actions
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// Vibrate pattern - custom pattern for specific events
  static Future<void> pattern(List<Duration> pattern) async {
    for (int i = 0; i < pattern.length; i++) {
      if (i % 2 == 0) {
        await HapticFeedback.mediumImpact();
      }
      await Future.delayed(pattern[i]);
    }
  }
}
