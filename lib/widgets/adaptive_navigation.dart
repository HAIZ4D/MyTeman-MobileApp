import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_state_provider.dart';
import '../screens/home_screen.dart';
import '../screens/service_list_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/eligibility_voice_check_screen.dart';
import '../screens/voice_clinic_search_flow_screen.dart';
import '../screens/bkoku_application_screen.dart';
import 'floating_voice_button.dart';
import '../utils/haptic_feedback.dart';

/// Adaptive navigation that switches between bottom nav and drawer based on screen size
class AdaptiveNavigation extends ConsumerWidget {
  const AdaptiveNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Use 840dp breakpoint for better phone/tablet distinction
    // Modern phones typically have 360-480dp width
    // Tablets typically start at 600dp+ but we use 840dp to be safe
    final isTablet = screenWidth >= 840;

    if (isTablet) {
      return const _TabletLayout();
    } else {
      return const _MobileLayout();
    }
  }
}

/// Mobile layout with bottom navigation
class _MobileLayout extends ConsumerWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final user = ref.watch(currentUserProvider);
    final language = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
            tooltip: 'Notifications',
          ),
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  user.name[0],
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _getScreen(currentIndex),
      floatingActionButton: FloatingVoiceButton(
        language: language,
        onCommand: (command) => _handleVoiceCommand(command, ref, context),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          HapticHelper.navigation();
          ref.read(bottomNavIndexProvider.notifier).state = index;
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: language == 'ms' ? 'Utama' : 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.grid_view_outlined),
            selectedIcon: const Icon(Icons.grid_view),
            label: language == 'ms' ? 'Perkhidmatan' : 'Services',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: language == 'ms' ? 'Profil' : 'Profile',
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: language == 'ms' ? 'Tetapan' : 'Settings',
          ),
        ],
      ),
    );
  }

  void _handleVoiceCommand(String command, WidgetRef ref, BuildContext context) {
    final commandLower = command.toLowerCase();
    final language = ref.read(languageProvider);

    // Service-specific commands (check these first)
    if (commandLower.contains('eligibility') ||
        commandLower.contains('kelayakan') ||
        commandLower.contains('semak kelayakan') ||
        commandLower.contains('peka') ||
        commandLower.contains('b40')) {
      // Navigate to services and trigger eligibility check
      ref.read(bottomNavIndexProvider.notifier).state = 1;
      HapticHelper.success();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(language == 'ms'
              ? 'Membuka Semakan Kelayakan PEKA B40'
              : 'Opening PEKA B40 Eligibility Check'),
          duration: const Duration(seconds: 2),
        ),
      );
      // Navigate to eligibility check service after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        _navigateToService(context, ref, 'peka_b40_eligibility_check');
      });
    } else if (commandLower.contains('clinic') ||
               commandLower.contains('klinik') ||
               commandLower.contains('hospital') ||
               commandLower.contains('doctor') ||
               commandLower.contains('doktor')) {
      // Navigate to clinic search
      ref.read(bottomNavIndexProvider.notifier).state = 1;
      HapticHelper.success();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(language == 'ms'
              ? 'Membuka Carian Klinik PEKA B40'
              : 'Opening PEKA B40 Clinic Search'),
          duration: const Duration(seconds: 2),
        ),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        _navigateToService(context, ref, 'peka_b40_clinic_search');
      });
    } else if (commandLower.contains('bkoku') ||
               commandLower.contains('scholarship') ||
               commandLower.contains('biasiswa') ||
               commandLower.contains('oku') ||
               commandLower.contains('student') ||
               commandLower.contains('pelajar')) {
      // Navigate to BKOKU application
      ref.read(bottomNavIndexProvider.notifier).state = 1;
      HapticHelper.success();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(language == 'ms'
              ? 'Membuka Permohonan BKOKU'
              : 'Opening BKOKU Application'),
          duration: const Duration(seconds: 2),
        ),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        _navigateToService(context, ref, 'bkoku_application_2025');
      });
    }
    // Navigate to different screens based on voice command
    else if (commandLower.contains('home') || commandLower.contains('utama') || commandLower.contains('rumah')) {
      ref.read(bottomNavIndexProvider.notifier).state = 0;
      HapticHelper.success();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(language == 'ms' ? 'Pergi ke Utama' : 'Going to Home'),
          duration: const Duration(seconds: 1),
        ),
      );
    } else if (commandLower.contains('service') || commandLower.contains('perkhidmatan')) {
      ref.read(bottomNavIndexProvider.notifier).state = 1;
      HapticHelper.success();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(language == 'ms' ? 'Pergi ke Perkhidmatan' : 'Going to Services'),
          duration: const Duration(seconds: 1),
        ),
      );
    } else if (commandLower.contains('profile') || commandLower.contains('profil')) {
      ref.read(bottomNavIndexProvider.notifier).state = 2;
      HapticHelper.success();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(language == 'ms' ? 'Pergi ke Profil' : 'Going to Profile'),
          duration: const Duration(seconds: 1),
        ),
      );
    } else if (commandLower.contains('setting') || commandLower.contains('tetapan')) {
      ref.read(bottomNavIndexProvider.notifier).state = 3;
      HapticHelper.success();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(language == 'ms' ? 'Pergi ke Tetapan' : 'Going to Settings'),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      // Unknown command
      HapticHelper.error();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(language == 'ms'
              ? 'Arahan tidak difahami. Cuba cakap: Semakan Kelayakan, Klinik, BKOKU, atau Utama'
              : 'Command not understood. Try saying: Eligibility Check, Clinic, BKOKU, or Home'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _navigateToService(BuildContext context, WidgetRef ref, String serviceId) {
    // Import necessary files at the top of the file
    final language = ref.read(languageProvider);
    final user = ref.read(currentUserProvider);

    if (user == null) return;

    // Navigate to the specific service based on serviceId
    if (serviceId == 'peka_b40_eligibility_check') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            // Dynamically import the screen
            return _loadEligibilityScreen(user);
          },
        ),
      );
    } else if (serviceId == 'peka_b40_clinic_search') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return _loadClinicScreen(user, language);
          },
        ),
      );
    } else if (serviceId == 'bkoku_application_2025') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return _loadBkokuScreen(user, language);
          },
        ),
      );
    }
  }

  Widget _loadEligibilityScreen(dynamic user) {
    return EligibilityVoiceCheckScreen(user: user);
  }

  Widget _loadClinicScreen(dynamic user, String language) {
    return VoiceClinicSearchFlowScreen(user: user);
  }

  Widget _loadBkokuScreen(dynamic user, String language) {
    return BkokuApplicationScreen(user: user);
  }
}

/// Tablet layout with drawer navigation
class _TabletLayout extends ConsumerWidget {
  const _TabletLayout();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final user = ref.watch(currentUserProvider);
    final language = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
            tooltip: 'Notifications',
          ),
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                children: [
                  Text(user.name),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      user.name[0],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              ref.read(bottomNavIndexProvider.notifier).state = index;
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view),
                label: Text('Services'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: Text('Profile'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _getScreen(currentIndex),
          ),
        ],
      ),
    );
  }
}

/// Get screen widget based on index
Widget _getScreen(int index) {
  switch (index) {
    case 0:
      return const HomeScreen();
    case 1:
      return const ServiceListScreen();
    case 2:
      return const ProfileScreen();
    case 3:
      return const SettingsScreen();
    default:
      return const HomeScreen();
  }
}
