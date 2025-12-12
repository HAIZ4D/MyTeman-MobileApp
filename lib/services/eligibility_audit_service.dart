// FILE: lib/services/eligibility_audit_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/eligibility.dart';
import '../config.dart' as config;

/// Audit service for eligibility checks
///
/// Records consent and eligibility results to Firestore for compliance
/// and audit trail purposes.
class EligibilityAuditService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Record eligibility check audit
  Future<void> recordEligibilityAudit(
    String uid,
    String service,
    String consentMethod,
    List<String> usedFields,
    EligibilityResult result,
  ) async {
    if (!config.AppConfig.useFirebase) {
      print('EligibilityAudit: Firebase disabled, skipping audit');
      return;
    }

    try {
      final audit = EligibilityAudit(
        auditId: result.requestId,
        uid: uid,
        service: service,
        timestamp: result.timestamp,
        consentMethod: consentMethod,
        usedFields: usedFields,
        result: result.status,
        debug: {
          'matched_rules': result.matchedRules,
          'failed_rules': result.failedRules,
          'missing_fields': result.missingFields,
        },
      );

      await _firestore
          .collection('eligibility_audit')
          .doc(audit.auditId)
          .set(audit.toJson());

      print('EligibilityAudit: Recorded audit ${audit.auditId}');
    } catch (e) {
      print('EligibilityAudit: Error recording audit: $e');
      // Don't rethrow - audit failure shouldn't block user flow
    }
  }

  /// Get eligibility audit history for user
  Future<List<EligibilityAudit>> getAuditHistory(String uid) async {
    if (!config.AppConfig.useFirebase) {
      return [];
    }

    try {
      final snapshot = await _firestore
          .collection('eligibility_audit')
          .where('uid', isEqualTo: uid)
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => EligibilityAudit.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('EligibilityAudit: Error fetching history: $e');
      return [];
    }
  }

  /// Record consent for MyDigitalID access
  Future<void> recordConsent({
    required String uid,
    required String service,
    required String consentMethod,
    required List<String> fieldsAccessed,
    required bool granted,
  }) async {
    if (!config.AppConfig.useFirebase) {
      print('EligibilityAudit: Firebase disabled, skipping consent record');
      return;
    }

    try {
      final consentId = 'consent_${uid}_${DateTime.now().millisecondsSinceEpoch}';

      await _firestore.collection('eligibility_consents').doc(consentId).set({
        'consent_id': consentId,
        'uid': uid,
        'service': service,
        'timestamp': DateTime.now().toIso8601String(),
        'consent_method': consentMethod,
        'fields_accessed': fieldsAccessed,
        'granted': granted,
      });

      print('EligibilityAudit: Recorded consent $consentId');
    } catch (e) {
      print('EligibilityAudit: Error recording consent: $e');
    }
  }
}
