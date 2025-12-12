import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/application.dart';

/// Offline sync queue for storing applications locally and syncing to backend
class SyncQueue {
  static const String _queueKey = 'sync_queue';
  static const String _syncStatusKey = 'last_sync_time';

  /// Add application to sync queue
  Future<void> enqueue(Application application) async {
    final prefs = await SharedPreferences.getInstance();

    // Get current queue
    final queueJson = prefs.getString(_queueKey);
    List<Map<String, dynamic>> queue = [];

    if (queueJson != null) {
      final decoded = jsonDecode(queueJson) as List;
      queue = decoded.map((e) => e as Map<String, dynamic>).toList();
    }

    // Add new application to queue
    queue.add(application.toJson());

    // Save updated queue
    await prefs.setString(_queueKey, jsonEncode(queue));

    print('SyncQueue: Added application ${application.appId} to queue. Queue size: ${queue.length}');
  }

  /// Get all pending applications in queue
  Future<List<Application>> getPendingApplications() async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = prefs.getString(_queueKey);

    if (queueJson == null) {
      return [];
    }

    try {
      final decoded = jsonDecode(queueJson) as List;
      return decoded
          .map((e) => Application.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('SyncQueue: Error loading queue: $e');
      return [];
    }
  }

  /// Remove application from queue (after successful sync)
  Future<void> dequeue(String appId) async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = prefs.getString(_queueKey);

    if (queueJson == null) return;

    try {
      final decoded = jsonDecode(queueJson) as List;
      final queue = decoded.map((e) => e as Map<String, dynamic>).toList();

      // Remove the application with matching appId
      queue.removeWhere((app) => app['appId'] == appId);

      // Save updated queue
      await prefs.setString(_queueKey, jsonEncode(queue));

      print('SyncQueue: Removed application $appId from queue. Remaining: ${queue.length}');
    } catch (e) {
      print('SyncQueue: Error removing from queue: $e');
    }
  }

  /// Clear all applications from queue
  Future<void> clearQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_queueKey);
    print('SyncQueue: Queue cleared');
  }

  /// Get queue size
  Future<int> getQueueSize() async {
    final applications = await getPendingApplications();
    return applications.length;
  }

  /// Attempt to sync all pending applications
  Future<SyncResult> attemptSyncAll() async {
    final applications = await getPendingApplications();

    if (applications.isEmpty) {
      return SyncResult(
        success: true,
        totalAttempted: 0,
        successCount: 0,
        failedCount: 0,
        message: 'No applications to sync',
      );
    }

    int successCount = 0;
    int failedCount = 0;
    List<String> failedIds = [];

    for (final app in applications) {
      try {
        // Simulate API call (replace with actual API call)
        await Future.delayed(const Duration(milliseconds: 500));

        // Assume success for now
        final success = await _syncToBackend(app);

        if (success) {
          await dequeue(app.appId);
          successCount++;
        } else {
          failedCount++;
          failedIds.add(app.appId);
        }
      } catch (e) {
        print('SyncQueue: Error syncing ${app.appId}: $e');
        failedCount++;
        failedIds.add(app.appId);
      }
    }

    // Update last sync time
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_syncStatusKey, DateTime.now().toIso8601String());

    return SyncResult(
      success: failedCount == 0,
      totalAttempted: applications.length,
      successCount: successCount,
      failedCount: failedCount,
      failedIds: failedIds,
      message: failedCount == 0
          ? 'All applications synced successfully'
          : '$successCount synced, $failedCount failed',
    );
  }

  /// Sync application to Firestore backend
  Future<bool> _syncToBackend(Application application) async {
    try {
      print('SyncQueue: Syncing ${application.appId} to Firestore...');

      // Update status to 'submitted' when syncing
      final updatedApp = Application(
        appId: application.appId,
        serviceId: application.serviceId,
        uid: application.uid,
        status: 'submitted', // Change from 'draft' to 'submitted'
        filledData: application.filledData,
        submittedAt: application.submittedAt,
        audit: application.audit,
      );

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('applications')
          .doc(application.appId)
          .set(updatedApp.toJson());

      print('SyncQueue: Successfully synced ${application.appId} to Firestore');
      return true;
    } catch (e) {
      print('SyncQueue: Error syncing ${application.appId} to Firestore: $e');
      return false;
    }
  }

  /// Get last sync time
  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeStr = prefs.getString(_syncStatusKey);

    if (timeStr == null) return null;

    try {
      return DateTime.parse(timeStr);
    } catch (e) {
      return null;
    }
  }

  /// Check if device is online using connectivity check
  Future<bool> isOnline() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();

      // Check if connected to any network
      final isConnected = connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.ethernet) ||
          connectivityResult.contains(ConnectivityResult.vpn);

      print('SyncQueue: Connectivity check - isOnline: $isConnected, result: $connectivityResult');

      return isConnected;
    } catch (e) {
      print('SyncQueue: Error checking connectivity: $e');
      return false;
    }
  }
}

/// Result of sync operation
class SyncResult {
  final bool success;
  final int totalAttempted;
  final int successCount;
  final int failedCount;
  final List<String> failedIds;
  final String message;

  SyncResult({
    required this.success,
    required this.totalAttempted,
    required this.successCount,
    required this.failedCount,
    this.failedIds = const [],
    required this.message,
  });
}
