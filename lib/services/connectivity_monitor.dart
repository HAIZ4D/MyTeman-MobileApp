import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'sync_queue.dart';

/// Global connectivity monitor that automatically syncs queue when online
class ConnectivityMonitor {
  static final ConnectivityMonitor _instance = ConnectivityMonitor._internal();
  factory ConnectivityMonitor() => _instance;
  ConnectivityMonitor._internal();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final SyncQueue _syncQueue = SyncQueue();
  bool _wasOffline = false;

  /// Start monitoring connectivity changes
  void startMonitoring() {
    print('ConnectivityMonitor: Starting connectivity monitoring...');

    _subscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        final isOnline = results.contains(ConnectivityResult.mobile) ||
            results.contains(ConnectivityResult.wifi) ||
            results.contains(ConnectivityResult.ethernet) ||
            results.contains(ConnectivityResult.vpn);

        print('ConnectivityMonitor: Connectivity changed - isOnline: $isOnline, results: $results');

        // If we were offline and now online, trigger sync
        if (_wasOffline && isOnline) {
          print('ConnectivityMonitor: Device back online! Triggering auto-sync...');
          await _autoSync();
        }

        _wasOffline = !isOnline;
      },
      onError: (error) {
        print('ConnectivityMonitor: Error monitoring connectivity: $error');
      },
    );
  }

  /// Stop monitoring connectivity changes
  void stopMonitoring() {
    print('ConnectivityMonitor: Stopping connectivity monitoring...');
    _subscription?.cancel();
    _subscription = null;
  }

  /// Automatically sync pending applications
  Future<void> _autoSync() async {
    try {
      final queueSize = await _syncQueue.getQueueSize();

      if (queueSize == 0) {
        print('ConnectivityMonitor: No applications in queue to sync');
        return;
      }

      print('ConnectivityMonitor: Found $queueSize applications in queue. Starting sync...');

      final result = await _syncQueue.attemptSyncAll();

      if (result.success) {
        print('ConnectivityMonitor: Auto-sync successful! ${result.successCount} applications synced');
      } else {
        print('ConnectivityMonitor: Auto-sync completed with errors. Success: ${result.successCount}, Failed: ${result.failedCount}');
      }
    } catch (e) {
      print('ConnectivityMonitor: Error during auto-sync: $e');
    }
  }

  /// Manually check and sync if online
  Future<void> checkAndSync() async {
    final isOnline = await _syncQueue.isOnline();
    if (isOnline) {
      await _autoSync();
    } else {
      print('ConnectivityMonitor: Device is offline, cannot sync');
    }
  }
}
