// FILE: lib/services/eligibility_service.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/user.dart';
import '../models/eligibility.dart';

/// Eligibility Service - Rule engine for checking program eligibility
///
/// Loads rules from assets/eligibility_rules.json and evaluates them
/// against user data from MyDigitalID.
class EligibilityService {
  Map<String, dynamic>? _rules;
  bool _rulesLoaded = false;

  /// Load eligibility rules from JSON
  Future<void> loadRules() async {
    if (_rulesLoaded) return;

    try {
      final String jsonString =
          await rootBundle.loadString('assets/eligibility_rules.json');
      _rules = jsonDecode(jsonString) as Map<String, dynamic>;
      _rulesLoaded = true;
      print('EligibilityService: Rules loaded successfully');
    } catch (e) {
      print('EligibilityService: Error loading rules: $e');
      rethrow;
    }
  }

  /// Check eligibility for Peka B40
  Future<EligibilityResult> checkPekaB40Eligibility(
    User user, {
    Map<String, dynamic>? additionalAnswers,
  }) async {
    await loadRules();

    final requestId = 'eligibility_${DateTime.now().millisecondsSinceEpoch}';
    final timestamp = DateTime.now();

    if (_rules == null || !_rules!.containsKey('peka_b40')) {
      throw Exception('Peka B40 rules not found');
    }

    final pekaB40Rules = _rules!['peka_b40'] as Map<String, dynamic>;
    final conditions = pekaB40Rules['conditions'] as List;
    final missingFieldsQuestions =
        pekaB40Rules['missing_fields_questions'] as Map<String, dynamic>;

    // Prepare user data (combine MyDigitalID + additional answers)
    final userData = _prepareUserData(user, additionalAnswers);

    // Evaluate conditions
    final evaluationResult = _evaluateConditions(
      conditions,
      userData,
      missingFieldsQuestions,
    );

    // Determine final status
    String status;
    bool eligible;

    if (evaluationResult['missing_fields'].isNotEmpty) {
      status = 'pending';
      eligible = false;
    } else if (evaluationResult['failed_rules'].isNotEmpty) {
      status = 'not_eligible';
      eligible = false;
    } else {
      status = 'eligible';
      eligible = true;
    }

    return EligibilityResult(
      eligible: eligible,
      status: status,
      matchedRules: List<String>.from(evaluationResult['matched_rules']),
      failedRules: List<String>.from(evaluationResult['failed_rules']),
      missingFields: List<String>.from(evaluationResult['missing_fields']),
      usedData: _redactSensitiveData(userData),
      followUpQuestions: evaluationResult['follow_up_questions'],
      timestamp: timestamp,
      requestId: requestId,
    );
  }

  /// Prepare user data for evaluation
  Map<String, dynamic> _prepareUserData(
    User user,
    Map<String, dynamic>? additionalAnswers,
  ) {
    final data = <String, dynamic>{
      'citizenship': user.citizenship,
      'age': user.age,
      'household_income': user.householdIncome,
      'existing_aids': user.existingAids ?? [],
      'household_size': user.householdSize,
    };

    // Merge additional answers (from follow-up questions)
    if (additionalAnswers != null) {
      data.addAll(additionalAnswers);
    }

    return data;
  }

  /// Evaluate all conditions
  Map<String, dynamic> _evaluateConditions(
    List conditions,
    Map<String, dynamic> userData,
    Map<String, dynamic> missingFieldsQuestions,
  ) {
    final List<String> matchedRules = [];
    final List<String> failedRules = [];
    final List<String> missingFields = [];
    final Map<String, dynamic> followUpQuestions = {};

    for (final condition in conditions) {
      final conditionMap = condition as Map<String, dynamic>;

      if (conditionMap.containsKey('any')) {
        // Handle "any" (OR) conditions
        final anyResult = _evaluateAnyCondition(
          conditionMap['any'] as List,
          userData,
        );

        if (anyResult['matched']) {
          matchedRules.add('Any of: ${anyResult['description']}');
        } else if (anyResult['has_missing']) {
          // Collect missing fields from "any" conditions
          for (final field in anyResult['missing_fields']) {
            if (!missingFields.contains(field)) {
              missingFields.add(field);
              if (missingFieldsQuestions.containsKey(field)) {
                followUpQuestions[field] = missingFieldsQuestions[field];
              }
            }
          }
        } else {
          failedRules.add('Required: Any of ${anyResult['description']}');
        }
      } else {
        // Handle single condition
        final result = _evaluateSingleCondition(conditionMap, userData);

        if (result == null) {
          // Missing field
          final field = conditionMap['field'] as String;
          if (!missingFields.contains(field)) {
            missingFields.add(field);
            if (missingFieldsQuestions.containsKey(field)) {
              followUpQuestions[field] = missingFieldsQuestions[field];
            }
          }
        } else if (result) {
          matchedRules.add(_getConditionDescription(conditionMap));
        } else {
          failedRules.add(_getConditionErrorMessage(conditionMap));
        }
      }
    }

    return {
      'matched_rules': matchedRules,
      'failed_rules': failedRules,
      'missing_fields': missingFields,
      'follow_up_questions': followUpQuestions,
    };
  }

  /// Evaluate "any" (OR) condition
  Map<String, dynamic> _evaluateAnyCondition(
    List anyConditions,
    Map<String, dynamic> userData,
  ) {
    bool anyMatched = false;
    bool hasMissing = false;
    final List<String> missingFields = [];
    final List<String> descriptions = [];

    for (final condition in anyConditions) {
      final conditionMap = condition as Map<String, dynamic>;
      final result = _evaluateSingleCondition(conditionMap, userData);

      descriptions.add(conditionMap['description'] as String? ?? 'Unknown');

      if (result == null) {
        hasMissing = true;
        final field = conditionMap['field'] as String;
        if (!missingFields.contains(field)) {
          missingFields.add(field);
        }
      } else if (result) {
        anyMatched = true;
        break; // One match is enough for "any"
      }
    }

    return {
      'matched': anyMatched,
      'has_missing': hasMissing && !anyMatched,
      'missing_fields': missingFields,
      'description': descriptions.join(' OR '),
    };
  }

  /// Evaluate a single condition
  /// Returns:
  /// - true if condition passes
  /// - false if condition fails
  /// - null if required data is missing
  bool? _evaluateSingleCondition(
    Map<String, dynamic> condition,
    Map<String, dynamic> userData,
  ) {
    final field = condition['field'] as String;
    final value = userData[field];

    // Check if field exists
    if (value == null) {
      return null; // Missing data
    }

    // Handle "contains" operator for arrays
    if (condition.containsKey('contains')) {
      if (value is List) {
        final containsValue = condition['contains'];
        return value.contains(containsValue);
      }
      return false;
    }

    // Handle comparison operators
    final op = condition['op'] as String?;
    final expectedValue = condition['value'];

    if (op == null) {
      return false;
    }

    switch (op) {
      case '==':
        return value == expectedValue;
      case '!=':
        return value != expectedValue;
      case '>':
        if (value is num && expectedValue is num) {
          return value > expectedValue;
        }
        return false;
      case '>=':
        if (value is num && expectedValue is num) {
          return value >= expectedValue;
        }
        return false;
      case '<':
        if (value is num && expectedValue is num) {
          return value < expectedValue;
        }
        return false;
      case '<=':
        if (value is num && expectedValue is num) {
          return value <= expectedValue;
        }
        return false;
      default:
        return false;
    }
  }

  /// Get condition description for matched rules
  String _getConditionDescription(Map<String, dynamic> condition) {
    if (condition.containsKey('description')) {
      return condition['description'] as String;
    }

    final field = condition['field'] as String;
    final op = condition['op'] as String?;
    final value = condition['value'];

    if (op != null) {
      return '$field $op $value';
    } else if (condition.containsKey('contains')) {
      return '$field contains ${condition['contains']}';
    }

    return 'Unknown condition';
  }

  /// Get error message for failed rules
  String _getConditionErrorMessage(Map<String, dynamic> condition) {
    return condition['error_message'] as String? ?? 'Condition not met';
  }

  /// Redact sensitive data before storing in result
  Map<String, dynamic> _redactSensitiveData(Map<String, dynamic> data) {
    final redacted = Map<String, dynamic>.from(data);

    // Redact or remove sensitive fields
    // (For now, we're using non-sensitive fields only)

    return redacted;
  }

  /// Get follow-up questions for missing fields
  List<FollowUpQuestion> getFollowUpQuestions(
    EligibilityResult result,
    String language,
  ) {
    if (result.followUpQuestions == null ||
        result.followUpQuestions!.isEmpty) {
      return [];
    }

    final questions = <FollowUpQuestion>[];

    for (final entry in result.followUpQuestions!.entries) {
      final field = entry.key;
      final questionData = entry.value as Map<String, dynamic>;

      questions.add(FollowUpQuestion.fromJson(field, questionData));
    }

    return questions;
  }

  /// Parse answer to follow-up question
  dynamic parseAnswer(String field, String type, String answer) {
    final lowerAnswer = answer.toLowerCase().trim();

    switch (type) {
      case 'number':
        // Extract number from answer
        final match = RegExp(r'\d+').firstMatch(answer);
        if (match != null) {
          return int.tryParse(match.group(0)!) ?? 0;
        }
        return 0;

      case 'yes_no':
        // Parse yes/no (both English and Malay)
        if (lowerAnswer.contains('ya') ||
            lowerAnswer.contains('yes') ||
            lowerAnswer.contains('ada')) {
          return ['STR']; // Assume STR if yes
        } else {
          return [];
        }

      case 'text':
        return answer;

      default:
        return answer;
    }
  }

  /// Get next steps based on eligibility status
  Map<String, dynamic>? getNextSteps(String status, String language) {
    if (_rules == null) return null;

    final pekaB40Rules = _rules!['peka_b40'] as Map<String, dynamic>;
    final nextSteps = pekaB40Rules['next_steps'] as Map<String, dynamic>;

    return nextSteps[status] as Map<String, dynamic>?;
  }
}
