import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'services/connectivity_monitor.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Sign in anonymously for Firestore access
  await FirebaseAuth.instance.signInAnonymously();
  print('Firebase: Signed in anonymously');

  // Start connectivity monitoring for automatic offline sync
  ConnectivityMonitor().startMonitoring();

  runApp(
    const ProviderScope(
      child: IsnApp(),
    ),
  );
}
