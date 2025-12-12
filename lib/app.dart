import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/mydigitalid_login_screen.dart';
import 'screens/my_applications_screen.dart';
import 'widgets/adaptive_navigation.dart';
import 'theme/app_theme.dart';
import 'providers/app_state_provider.dart';

class IsnApp extends ConsumerWidget {
  const IsnApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final highContrastMode = ref.watch(highContrastModeProvider);
    final textScale = ref.watch(textScaleProvider);

    return MaterialApp(
      title: 'ISN Accessible Bridge',
      theme: highContrastMode ? AppTheme.highContrastTheme : AppTheme.lightTheme,
      home: currentUser == null ? const MyDigitalIDLoginScreen() : const AdaptiveNavigation(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/my-applications': (context) => const MyApplicationsScreen(),
      },
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: child!,
        );
      },
    );
  }
}
