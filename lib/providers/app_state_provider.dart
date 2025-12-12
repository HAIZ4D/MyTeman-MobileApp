import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/service.dart';
import '../services/mygov_service.dart';

/// App state management using Riverpod

// MyGOV service provider
final myGovServiceProvider = Provider<MyGovService>((ref) => MyGovService());

// Services list provider
final servicesProvider = FutureProvider<List<Service>>((ref) async {
  final service = ref.read(myGovServiceProvider);
  return service.getAllServices();
});

// Current selected user provider
final currentUserProvider = StateProvider<User?>((ref) => null);

// High contrast mode provider
final highContrastModeProvider = StateProvider<bool>((ref) => false);

// Text scale provider
final textScaleProvider = StateProvider<double>((ref) => 1.0);

// Voice mode provider
final voiceModeProvider = StateProvider<bool>((ref) => false);

// Rural/offline mode provider
final ruralModeProvider = StateProvider<bool>((ref) => false);

// Language provider ('ms' for Malay, 'en' for English)
final languageProvider = StateProvider<String>((ref) => 'en');

// Bottom navigation index provider
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
