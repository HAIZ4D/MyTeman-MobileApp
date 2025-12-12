import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/application.dart';

/// Service for managing applications in Firestore
class ApplicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new application record in Firestore
  Future<void> createApplication(Application application) async {
    try {
      print('Creating application with ID: ${application.appId}');
      print('Application data: ${application.toJson()}');

      await _firestore
          .collection('applications')
          .doc(application.appId)
          .set(application.toJson());

      print('Application created successfully!');
    } catch (e, stackTrace) {
      print('ERROR creating application: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get all applications for a specific user
  Future<List<Application>> getApplicationsByUser(String uid) async {
    try {
      print('Fetching applications for user: $uid');

      final querySnapshot = await _firestore
          .collection('applications')
          .where('uid', isEqualTo: uid)
          .orderBy('submitted_at', descending: true)
          .get();

      print('Found ${querySnapshot.docs.length} applications');

      return querySnapshot.docs
          .map((doc) => Application.fromJson(doc.data()))
          .toList();
    } catch (e, stackTrace) {
      print('ERROR fetching applications: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  /// Get a specific application by ID
  Future<Application?> getApplicationById(String appId) async {
    try {
      final doc = await _firestore
          .collection('applications')
          .doc(appId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return Application.fromJson(doc.data()!);
    } catch (e) {
      print('ERROR fetching application: $e');
      return null;
    }
  }

  /// Update an existing application
  Future<void> updateApplication(Application application) async {
    try {
      await _firestore
          .collection('applications')
          .doc(application.appId)
          .update(application.toJson());

      print('Application updated successfully!');
    } catch (e) {
      print('ERROR updating application: $e');
      rethrow;
    }
  }

  /// Stream of applications for a user (real-time updates)
  Stream<List<Application>> streamApplicationsByUser(String uid) {
    return _firestore
        .collection('applications')
        .where('uid', isEqualTo: uid)
        .orderBy('submitted_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Application.fromJson(doc.data()))
          .toList();
    });
  }
}
