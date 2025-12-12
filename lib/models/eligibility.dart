// FILE: lib/models/eligibility.dart

/// Eligibility check result model
class EligibilityResult {
  final bool eligible;
  final String status; // 'eligible', 'not_eligible', 'pending'
  final List<String> matchedRules;
  final List<String> failedRules;
  final List<String> missingFields;
  final Map<String, dynamic> usedData; // Redacted user data
  final Map<String, dynamic>? followUpQuestions;
  final DateTime timestamp;
  final String requestId;

  EligibilityResult({
    required this.eligible,
    required this.status,
    required this.matchedRules,
    required this.failedRules,
    required this.missingFields,
    required this.usedData,
    this.followUpQuestions,
    required this.timestamp,
    required this.requestId,
  });

  factory EligibilityResult.fromJson(Map<String, dynamic> json) {
    return EligibilityResult(
      eligible: json['eligible'] as bool,
      status: json['status'] as String,
      matchedRules: List<String>.from(json['matched_rules'] as List),
      failedRules: List<String>.from(json['failed_rules'] as List),
      missingFields: List<String>.from(json['missing_fields'] as List),
      usedData: json['used_data'] as Map<String, dynamic>,
      followUpQuestions: json['follow_up_questions'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      requestId: json['request_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eligible': eligible,
      'status': status,
      'matched_rules': matchedRules,
      'failed_rules': failedRules,
      'missing_fields': missingFields,
      'used_data': usedData,
      'follow_up_questions': followUpQuestions,
      'timestamp': timestamp.toIso8601String(),
      'request_id': requestId,
    };
  }

  EligibilityResult copyWith({
    bool? eligible,
    String? status,
    List<String>? matchedRules,
    List<String>? failedRules,
    List<String>? missingFields,
    Map<String, dynamic>? usedData,
    Map<String, dynamic>? followUpQuestions,
    DateTime? timestamp,
    String? requestId,
  }) {
    return EligibilityResult(
      eligible: eligible ?? this.eligible,
      status: status ?? this.status,
      matchedRules: matchedRules ?? this.matchedRules,
      failedRules: failedRules ?? this.failedRules,
      missingFields: missingFields ?? this.missingFields,
      usedData: usedData ?? this.usedData,
      followUpQuestions: followUpQuestions ?? this.followUpQuestions,
      timestamp: timestamp ?? this.timestamp,
      requestId: requestId ?? this.requestId,
    );
  }
}

/// Audit entry for eligibility check
class EligibilityAudit {
  final String auditId;
  final String uid;
  final String service; // e.g., 'peka_b40'
  final DateTime timestamp;
  final String consentMethod; // 'biometric_face', 'biometric_fingerprint', 'pin'
  final List<String> usedFields;
  final String result; // 'eligible', 'not_eligible', 'pending'
  final Map<String, dynamic> debug;

  EligibilityAudit({
    required this.auditId,
    required this.uid,
    required this.service,
    required this.timestamp,
    required this.consentMethod,
    required this.usedFields,
    required this.result,
    required this.debug,
  });

  factory EligibilityAudit.fromJson(Map<String, dynamic> json) {
    return EligibilityAudit(
      auditId: json['audit_id'] as String,
      uid: json['uid'] as String,
      service: json['service'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      consentMethod: json['consent_method'] as String,
      usedFields: List<String>.from(json['used_fields'] as List),
      result: json['result'] as String,
      debug: json['debug'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'audit_id': auditId,
      'uid': uid,
      'service': service,
      'timestamp': timestamp.toIso8601String(),
      'consent_method': consentMethod,
      'used_fields': usedFields,
      'result': result,
      'debug': debug,
    };
  }
}

/// Follow-up question for missing data
class FollowUpQuestion {
  final String field;
  final String question;
  final String questionMs;
  final String type; // 'number', 'yes_no', 'text'
  final String? hint;
  final String? hintMs;

  FollowUpQuestion({
    required this.field,
    required this.question,
    required this.questionMs,
    required this.type,
    this.hint,
    this.hintMs,
  });

  factory FollowUpQuestion.fromJson(String field, Map<String, dynamic> json) {
    return FollowUpQuestion(
      field: field,
      question: json['question'] as String,
      questionMs: json['question_ms'] as String,
      type: json['type'] as String,
      hint: json['hint'] as String?,
      hintMs: json['hint_ms'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field': field,
      'question': question,
      'question_ms': questionMs,
      'type': type,
      'hint': hint,
      'hint_ms': hintMs,
    };
  }
}
