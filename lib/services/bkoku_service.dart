// FILE: lib/services/bkoku_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/bkoku_application.dart';
import '../models/application.dart' as app_model;
import '../config/bkoku_config.dart';

/// BKOKU Service - Handles BKOKU application creation and submission
///
/// This service builds BKOKU applications from MyDigitalID vault data
/// and submits them to Firestore for processing.
class BkokuService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Build a BKOKU application from user's MyDigitalID vault
  BkokuApplication buildApplicationFromVault(User user) {
    // Validate user has OKU status
    if (user.okuStatus != true) {
      throw Exception('User is not registered as OKU');
    }

    // Validate required fields
    if (user.okuId == null || user.okuId!.isEmpty) {
      throw Exception('OKU ID not found in MyDigitalID');
    }
    if (user.institution == null || user.institution!.isEmpty) {
      throw Exception('Institution information not found');
    }
    if (user.enrollmentNo == null || user.enrollmentNo!.isEmpty) {
      throw Exception('Enrollment number not found');
    }
    if (user.bankAccountNo == null || user.bankAccountNo!.isEmpty) {
      throw Exception('Bank account information not found');
    }

    // Generate application ID
    final String applicationId = 'bkoku_${DateTime.now().millisecondsSinceEpoch}';

    // Convert stored documents to BKOKU documents
    final List<BkokuDocument> attachments = [];
    if (user.storedDocuments != null) {
      for (final doc in user.storedDocuments!) {
        attachments.add(BkokuDocument(
          documentId: 'doc_${DateTime.now().millisecondsSinceEpoch}_${attachments.length}',
          name: doc.name,
          type: doc.type,
          path: doc.path,
          sizeBytes: 0, // Will be calculated from actual file
          base64Data: doc.base64Data,
          compressed: false,
          uploadedAt: DateTime.now(),
        ));
      }
    }

    // Build filled data from user info
    final Map<String, dynamic> filledData = {
      'full_name': user.name,
      'ic_number': user.icNumber,
      'dob': user.dob,
      'address': user.address,
      'oku_id': user.okuId!,
      'oku_status': user.okuStatus! ? 'Active' : 'Inactive',
      'institution': user.institution!,
      'enrollment_no': user.enrollmentNo!,
      'bank_account_no': user.bankAccountNo!,
      'bank_name': user.bankName!,
      'preferred_language': user.preferredLanguage,
      'application_year': '2025',
      'semester': '1',
    };

    // Create initial audit entry
    final List<AuditEntry> audit = [
      AuditEntry(
        timestamp: DateTime.now(),
        action: 'created',
        details: 'BKOKU application created from MyDigitalID vault',
        metadata: {
          'auto_filled': true,
          'fields_count': filledData.length,
          'documents_count': attachments.length,
        },
      ),
    ];

    // Build BKOKU application
    return BkokuApplication(
      applicationId: applicationId,
      uid: user.uid,
      userName: user.name,
      icNumber: user.icNumber,
      okuId: user.okuId!,
      okuStatus: user.okuStatus! ? 'Active' : 'Inactive',
      institution: user.institution!,
      enrollmentNo: user.enrollmentNo!,
      bankAccountNo: user.bankAccountNo!,
      bankName: user.bankName!,
      filledData: filledData,
      attachments: attachments,
      status: ApplicationStatus.draft,
      createdAt: DateTime.now(),
      audit: audit,
    );
  }

  /// Submit BKOKU application to Firestore
  Future<void> submitApplication(BkokuApplication bkokuApp, String consentId) async {
    try {
      print('Submitting BKOKU application: ${bkokuApp.toRedactedJson()}');

      // Update application with consent and submission info
      final updatedApp = bkokuApp.copyWith(
        status: ApplicationStatus.submitted,
        submittedAt: DateTime.now(),
        consentId: consentId,
        audit: [
          ...bkokuApp.audit,
          AuditEntry(
            timestamp: DateTime.now(),
            action: 'submitted',
            details: 'BKOKU application submitted to system',
            metadata: {
              'consent_id': consentId,
              'submission_method': 'online',
            },
          ),
        ],
      );

      // Create general application record for "My Applications" screen
      final app_model.Application generalApp = app_model.Application(
        appId: 'app_${bkokuApp.applicationId}',
        serviceId: 'bkoku_application_2025',
        uid: bkokuApp.uid,
        status: 'submitted',
        filledData: {
          'institution': bkokuApp.institution,
          'enrollment_no': bkokuApp.enrollmentNo,
          'oku_id': bkokuApp.okuId,
          'bank_name': bkokuApp.bankName,
          'documents_count': bkokuApp.attachments.length,
          'bkoku_app_id': bkokuApp.applicationId,
        },
        submittedAt: DateTime.now(),
        audit: [
          app_model.AuditEntry(
            timestamp: DateTime.now(),
            action: 'submitted',
            details: 'BKOKU application submitted via voice interface',
          ),
        ],
      );

      // Submit to Firestore in batch
      final batch = _firestore.batch();

      // Add BKOKU application
      batch.set(
        _firestore.collection('bkoku_applications').doc(bkokuApp.applicationId),
        updatedApp.toJson(),
      );

      // Add general application
      batch.set(
        _firestore.collection('applications').doc(generalApp.appId),
        generalApp.toJson(),
      );

      await batch.commit();

      print('BKOKU application submitted successfully!');
    } catch (e, stackTrace) {
      print('ERROR submitting BKOKU application: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get BKOKU application by ID
  Future<BkokuApplication?> getApplicationById(String applicationId) async {
    try {
      final doc = await _firestore
          .collection('bkoku_applications')
          .doc(applicationId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return BkokuApplication.fromJson(doc.data()!);
    } catch (e) {
      print('ERROR fetching BKOKU application: $e');
      return null;
    }
  }

  /// Get all BKOKU applications for a user
  Future<List<BkokuApplication>> getApplicationsByUser(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection('bkoku_applications')
          .where('uid', isEqualTo: uid)
          .orderBy('created_at', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => BkokuApplication.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('ERROR fetching user BKOKU applications: $e');
      return [];
    }
  }

  /// Generate consent ID
  String generateConsentId(String uid) {
    return 'consent_${uid}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Record consent in Firestore
  Future<void> recordConsent(ConsentRecord consent) async {
    try {
      await _firestore
          .collection('bkoku_consents')
          .doc(consent.consentId)
          .set(consent.toJson());

      print('Consent recorded: ${consent.consentId}');
    } catch (e) {
      print('ERROR recording consent: $e');
      rethrow;
    }
  }

  /// Get TTS message by key
  String getTtsMessage(String key, String language) {
    return BkokuConfig.TTS_MESSAGES[key]?[language] ?? '';
  }

  /// Get document label
  String getDocumentLabel(String type, String language) {
    return BkokuConfig.DOCUMENT_LABELS[type]?[language] ?? type;
  }
}
