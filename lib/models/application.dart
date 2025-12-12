class Application {
  final String appId;
  final String serviceId;
  final String uid;
  final String status;
  final Map<String, dynamic> filledData;
  final DateTime submittedAt;
  final List<AuditEntry> audit;

  Application({
    required this.appId,
    required this.serviceId,
    required this.uid,
    required this.status,
    required this.filledData,
    required this.submittedAt,
    required this.audit,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      appId: json['appId'] as String,
      serviceId: json['serviceId'] as String,
      uid: json['uid'] as String,
      status: json['status'] as String,
      filledData: Map<String, dynamic>.from(json['filled_data'] as Map),
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      audit: (json['audit'] as List)
          .map((e) => AuditEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appId': appId,
      'serviceId': serviceId,
      'uid': uid,
      'status': status,
      'filled_data': filledData,
      'submitted_at': submittedAt.toIso8601String(),
      'audit': audit.map((e) => e.toJson()).toList(),
    };
  }

  Application copyWith({
    String? appId,
    String? serviceId,
    String? uid,
    String? status,
    Map<String, dynamic>? filledData,
    DateTime? submittedAt,
    List<AuditEntry>? audit,
  }) {
    return Application(
      appId: appId ?? this.appId,
      serviceId: serviceId ?? this.serviceId,
      uid: uid ?? this.uid,
      status: status ?? this.status,
      filledData: filledData ?? this.filledData,
      submittedAt: submittedAt ?? this.submittedAt,
      audit: audit ?? this.audit,
    );
  }
}

class AuditEntry {
  final DateTime timestamp;
  final String action;
  final String details;

  AuditEntry({
    required this.timestamp,
    required this.action,
    required this.details,
  });

  factory AuditEntry.fromJson(Map<String, dynamic> json) {
    return AuditEntry(
      timestamp: DateTime.parse(json['timestamp'] as String),
      action: json['action'] as String,
      details: json['details'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'action': action,
      'details': details,
    };
  }
}
