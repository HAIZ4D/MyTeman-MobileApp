import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_state_provider.dart';
import '../screens/user_selection_screen.dart';
import '../screens/my_applications_screen.dart';
import '../widgets/service_card.dart';
import '../models/user.dart';

/// Home screen with dashboard and quick actions
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final servicesAsync = ref.watch(servicesProvider);
    final language = ref.watch(languageProvider);

    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              language == 'ms' ? 'Tiada pengguna dipilih' : 'No user selected',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const UserSelectionScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_back),
              label: Text(language == 'ms' ? 'Pilih Pengguna' : 'Select User'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(servicesProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome banner
            _WelcomeBanner(user: user),
            const SizedBox(height: 24),

            // MyDigitalID status
            _MyDigitalIDStatus(user: user),
            const SizedBox(height: 24),

            // Quick actions
            Text(
              language == 'ms' ? 'Tindakan Pantas' : 'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _QuickActions(language: language),
            const SizedBox(height: 24),

            // Featured services
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  language == 'ms' ? 'Perkhidmatan Popular' : 'Popular Services',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    ref.read(bottomNavIndexProvider.notifier).state = 1;
                  },
                  child: Text(
                    language == 'ms' ? 'Lihat Semua' : 'View All',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            servicesAsync.when(
              data: (services) {
                return Column(
                  children: services.take(3).map((service) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ServiceCard(
                        service: service,
                        language: language,
                        onTap: () {
                          // TODO: Navigate to service details
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Opening ${service.getTitle(language)}'),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error: $error'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeBanner extends ConsumerWidget {
  final User user;

  const _WelcomeBanner({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final greeting = language == 'ms'
        ? 'Selamat datang, ${user.name}'
        : 'Welcome, ${user.name}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            language == 'ms'
                ? 'Apa yang boleh kami bantu hari ini?'
                : 'How can we help you today?',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _MyDigitalIDStatus extends ConsumerWidget {
  final User user;

  const _MyDigitalIDStatus({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: user.mydigitalidLinked ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                user.mydigitalidLinked ? Icons.verified_user : Icons.warning,
                color: user.mydigitalidLinked ? Colors.green : Colors.orange,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MyDigitalID',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.mydigitalidLinked
                        ? (language == 'ms' ? 'Terhubung' : 'Connected')
                        : (language == 'ms' ? 'Tidak Terhubung' : 'Not Connected'),
                    style: TextStyle(
                      color: user.mydigitalidLinked ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (!user.mydigitalidLinked)
              TextButton(
                onPressed: () {},
                child: Text(language == 'ms' ? 'Hubungkan' : 'Connect'),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends ConsumerWidget {
  final String language;

  const _QuickActions({required this.language});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    final actions = [
      {
        'icon': Icons.add_circle_outline,
        'label': language == 'ms' ? 'Mohon Perkhidmatan' : 'Apply for Service',
        'color': Colors.blue,
        'onTap': () {
          // Navigate to Services tab
          ref.read(bottomNavIndexProvider.notifier).state = 1;
        },
      },
      {
        'icon': Icons.history,
        'label': language == 'ms' ? 'Permohonan Saya' : 'My Applications',
        'color': Colors.green,
        'onTap': () {
          // Navigate to My Applications screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MyApplicationsScreen(),
            ),
          );
        },
      },
    ];

    return Row(
      children: actions.map((action) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: _QuickActionCard(
              icon: action['icon'] as IconData,
              label: action['label'] as String,
              color: action['color'] as Color,
              onTap: action['onTap'] as VoidCallback,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
