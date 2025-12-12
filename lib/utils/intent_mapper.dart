import 'dart:convert';
import 'package:flutter/services.dart';

class IntentMapper {
  List<Map<String, dynamic>>? _patterns;

  // Load intent patterns from JSON
  Future<void> _loadPatterns() async {
    if (_patterns != null) return;
    final String jsonString = await rootBundle.loadString('assets/intent_mapping.json');
    final data = json.decode(jsonString);
    _patterns = List<Map<String, dynamic>>.from(data['patterns']);
  }

  // Map user transcript to service intent
  Future<IntentResult> mapIntent(String transcript) async {
    await _loadPatterns();

    final t = transcript.toLowerCase().trim();

    for (final pattern in _patterns!) {
      final matchString = pattern['match'] as String;
      final regex = RegExp(matchString, caseSensitive: false);

      if (regex.hasMatch(t)) {
        // Extract numeric values (e.g., household size, income)
        final slots = _extractSlots(t);

        return IntentResult(
          serviceId: pattern['serviceId'] as String,
          confidence: 0.9,
          slots: slots,
          matchedPattern: matchString,
        );
      }
    }

    // No match found
    return IntentResult(
      serviceId: null,
      confidence: 0.0,
      slots: {},
      matchedPattern: null,
    );
  }

  // Extract numeric values and common keywords from transcript
  Map<String, dynamic> _extractSlots(String transcript) {
    final slots = <String, dynamic>{};

    // Extract numbers (for household size, income, etc.)
    final numberRegex = RegExp(r'\b(\d+)\b');
    final numberMatches = numberRegex.allMatches(transcript);

    if (numberMatches.isNotEmpty) {
      final numbers = numberMatches.map((m) => int.parse(m.group(1)!)).toList();

      // Heuristic: first number could be household size (typically < 20)
      // second number could be income
      if (numbers.isNotEmpty && numbers.first < 20) {
        slots['household_size'] = numbers.first;
      }

      if (numbers.length > 1) {
        slots['income'] = numbers[1];
      }
    }

    // Extract common reasons/keywords
    if (transcript.contains('sakit') || transcript.contains('sick')) {
      slots['reason'] = 'health issues';
    } else if (transcript.contains('kehilangan pekerjaan') || transcript.contains('lost job')) {
      slots['reason'] = 'job loss';
    } else if (transcript.contains('kecemasan') || transcript.contains('emergency')) {
      slots['reason'] = 'emergency';
    }

    return slots;
  }

  // Get all available patterns (for debugging)
  Future<List<Map<String, dynamic>>> getAllPatterns() async {
    await _loadPatterns();
    return _patterns!;
  }
}

class IntentResult {
  final String? serviceId;
  final double confidence;
  final Map<String, dynamic> slots;
  final String? matchedPattern;

  IntentResult({
    required this.serviceId,
    required this.confidence,
    required this.slots,
    required this.matchedPattern,
  });

  bool get isMatch => serviceId != null && confidence > 0.5;

  @override
  String toString() {
    return 'IntentResult(serviceId: $serviceId, confidence: $confidence, slots: $slots)';
  }
}
