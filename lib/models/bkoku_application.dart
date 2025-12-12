// FILE: lib/models/bkoku_application.dart

import 'application.dart' as app_model;

/// BKOKU (Financial Assistance for OKU Students) Application Model
///
/// This model represents a complete application for BKOKU financial assistance.
/// It includes user data, supporting documents, submission status, and audit trail.
///
/// PRIVACY NOTE: Never log raw IC numbers or personal documents to console in production.
/// Always redact sensitive fields in logs and ensure HTTPS for all transmissions.

class BkokuApplication {
  final String applicationId;
  final String uid;
  final String userName;
  final String icNumber; // Redacted in logs
  final String okuId;
  final String okuStatus;
  final String institution;
  final String enrollmentNo;
  final String bankAccountNo; // Redacted in logs
  final String bankName;
  final Map<String, dynamic> filledData;
  final List<BkokuDocument> attachments;
  final ApplicationStatus status;
  final DateTime createdAt;
  final DateTime? submittedAt;
  final List<AuditEntry> audit;
  final String? consentId;
  final String? bundleId; // For offline sync
  final int attemptCount;

  BkokuApplication({
    required this.applicationId,
    required this.uid,
    required this.userName,
    required this.icNumber,
    required this.okuId,
    required this.okuStatus,
    required this.institution,
    required this.enrollmentNo,
    required this.bankAccountNo,
    required this.bankName,
    required this.filledData,
    required this.attachments,
    required this.status,
    required this.createdAt,
    this.submittedAt,
    required this.audit,
    this.consentId,
    this.bundleId,
    this.attemptCount = 0,
  });

  factory BkokuApplication.fromJson(Map<String, dynamic> json) {
    return BkokuApplication(
      applicationId: json['application_id'] as String,
      uid: json['uid'] as String,
      userName: json['user_name'] as String,
      icNumber: json['ic_number'] as String,
      okuId: json['oku_id'] as String,
      okuStatus: json['oku_status'] as String,
      institution: json['institution'] as String,
      enrollmentNo: json['enrollment_no'] as String,
      bankAccountNo: json['bank_account_no'] as String,
      bankName: json['bank_name'] as String,
      filledData: Map<String, dynamic>.from(json['filled_data'] as Map),
      attachments: (json['attachments'] as List)
          .map((e) => BkokuDocument.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: ApplicationStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => ApplicationStatus.draft,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : null,
      audit: (json['audit'] as List)
          .map((e) => AuditEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      consentId: json['consent_id'] as String?,
      bundleId: json['bundle_id'] as String?,
      attemptCount: json['attempt_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'application_id': applicationId,
      'uid': uid,
      'user_name': userName,
      'ic_number': icNumber,
      'oku_id': okuId,
      'oku_status': okuStatus,
      'institution': institution,
      'enrollment_no': enrollmentNo,
      'bank_account_no': bankAccountNo,
      'bank_name': bankName,
      'filled_data': filledData,
      'attachments': attachments.map((e) => e.toJson()).toList(),
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'submitted_at': submittedAt?.toIso8601String(),
      'audit': audit.map((e) => e.toJson()).toList(),
      'consent_id': consentId,
      'bundle_id': bundleId,
      'attempt_count': attemptCount,
    };
  }

  /// Create a redacted version for logging (removes sensitive fields)
  Map<String, dynamic> toRedactedJson() {
    return {
      'application_id': applicationId,
      'uid': uid,
      'user_name': userName,
      'ic_number': 'REDACTED',
      'oku_id': okuId,
      'oku_status': okuStatus,
      'institution': institution,
      'enrollment_no': enrollmentNo,
      'bank_account_no': 'REDACTED',
      'bank_name': bankName,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'submitted_at': submittedAt?.toIso8601String(),
      'attachment_count': attachments.length,
      'consent_id': consentId,
      'bundle_id': bundleId,
      'attempt_count': attemptCount,
    };
  }

  /// Convert to general Application model for offline queue and My Applications screen
  app_model.Application toGeneralApplication() {
    return app_model.Application(
      appId: 'app_$applicationId',
      serviceId: 'bkoku_application_2025',
      uid: uid,
      status: 'submitted',
      filledData: {
        'institution': institution,
        'enrollment_no': enrollmentNo,
        'oku_id': okuId,
        'bank_name': bankName,
        'documents_count': attachments.length,
        'bkoku_app_id': applicationId,
        'user_name': userName,
      },
      submittedAt: submittedAt ?? DateTime.now(),
      audit: [
        app_model.AuditEntry(
          timestamp: DateTime.now(),
          action: 'submitted',
          details: 'BKOKU application submitted via voice interface',
        ),
      ],
    );
  }

  BkokuApplication copyWith({
    String? applicationId,
    String? uid,
    String? userName,
    String? icNumber,
    String? okuId,
    String? okuStatus,
    String? institution,
    String? enrollmentNo,
    String? bankAccountNo,
    String? bankName,
    Map<String, dynamic>? filledData,
    List<BkokuDocument>? attachments,
    ApplicationStatus? status,
    DateTime? createdAt,
    DateTime? submittedAt,
    List<AuditEntry>? audit,
    String? consentId,
    String? bundleId,
    int? attemptCount,
  }) {
    return BkokuApplication(
      applicationId: applicationId ?? this.applicationId,
      uid: uid ?? this.uid,
      userName: userName ?? this.userName,
      icNumber: icNumber ?? this.icNumber,
      okuId: okuId ?? this.okuId,
      okuStatus: okuStatus ?? this.okuStatus,
      institution: institution ?? this.institution,
      enrollmentNo: enrollmentNo ?? this.enrollmentNo,
      bankAccountNo: bankAccountNo ?? this.bankAccountNo,
      bankName: bankName ?? this.bankName,
      filledData: filledData ?? this.filledData,
      attachments: attachments ?? this.attachments,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      submittedAt: submittedAt ?? this.submittedAt,
      audit: audit ?? this.audit,
      consentId: consentId ?? this.consentId,
      bundleId: bundleId ?? this.bundleId,
      attemptCount: attemptCount ?? this.attemptCount,
    );
  }
}

/// Document attached to BKOKU application
class BkokuDocument {
  final String documentId;
  final String name;
  final String type; // disability_cert, matriculation, transcript, bank_statement
  final String path; // Local file path or Storage URL
  final int sizeBytes;
  final String? base64Data; // For offline storage
  final bool compressed;
  final DateTime uploadedAt;

  BkokuDocument({
    required this.documentId,
    required this.name,
    required this.type,
    required this.path,
    required this.sizeBytes,
    this.base64Data,
    this.compressed = false,
    required this.uploadedAt,
  });

  factory BkokuDocument.fromJson(Map<String, dynamic> json) {
    return BkokuDocument(
      documentId: json['document_id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      path: json['path'] as String,
      sizeBytes: json['size_bytes'] as int,
      base64Data: json['base64_data'] as String?,
      compressed: json['compressed'] as bool? ?? false,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'document_id': documentId,
      'name': name,
      'type': type,
      'path': path,
      'size_bytes': sizeBytes,
      'base64_data': base64Data,
      'compressed': compressed,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }
}

/// Application status enum
enum ApplicationStatus {
  draft,
  queued, // Waiting for network
  syncing, // Upload in progress
  submitted, // Successfully submitted
  failed, // Failed to submit
  processing, // Being processed by backend
  approved,
  rejected,
}

/// Audit entry for tracking application lifecycle
class AuditEntry {
  final DateTime timestamp;
  final String action;
  final String details;
  final Map<String, dynamic>? metadata;

  AuditEntry({
    required this.timestamp,
    required this.action,
    required this.details,
    this.metadata,
  });

  factory AuditEntry.fromJson(Map<String, dynamic> json) {
    return AuditEntry(
      timestamp: DateTime.parse(json['timestamp'] as String),
      action: json['action'] as String,
      details: json['details'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'action': action,
      'details': details,
      'metadata': metadata,
    };
  }
}

/// Consent record for MyDigitalID access
class ConsentRecord {
  final String consentId;
  final String uid;
  final DateTime timestamp;
  final String method; // biometric_face, biometric_fingerprint, pin
  final List<String> fieldsRequested;
  final List<String> documentsRequested;
  final bool granted;
  final String consentText;

  ConsentRecord({
    required this.consentId,
    required this.uid,
    required this.timestamp,
    required this.method,
    required this.fieldsRequested,
    required this.documentsRequested,
    required this.granted,
    required this.consentText,
  });

  factory ConsentRecord.fromJson(Map<String, dynamic> json) {
    return ConsentRecord(
      consentId: json['consent_id'] as String,
      uid: json['uid'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      method: json['method'] as String,
      fieldsRequested: List<String>.from(json['fields_requested'] as List),
      documentsRequested: List<String>.from(json['documents_requested'] as List),
      granted: json['granted'] as bool,
      consentText: json['consent_text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'consent_id': consentId,
      'uid': uid,
      'timestamp': timestamp.toIso8601String(),
      'method': method,
      'fields_requested': fieldsRequested,
      'documents_requested': documentsRequested,
      'granted': granted,
      'consent_text': consentText,
    };
  }
}
