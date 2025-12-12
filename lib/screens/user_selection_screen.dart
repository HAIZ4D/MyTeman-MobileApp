import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../providers/app_state_provider.dart';

final usersProvider = FutureProvider<List<User>>((ref) async {
  final service = ref.read(myGovServiceProvider);
  return service.getAllUsers();
});

class UserSelectionScreen extends ConsumerWidget {
  const UserSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ISN Accessible Bridge'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: usersAsync.when(
        data: (users) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Demo Mode',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select a persona to demonstrate accessibility features:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return _UserCard(user: user);
                  },
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserCard extends ConsumerWidget {
  final User user;

  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // Set the current user in the provider
          ref.read(currentUserProvider.notifier).state = user;
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      user.name[0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user.address,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Accessibility Features:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (user.accessibility.voiceFirst)
                    _FeatureChip(
                      label: 'Voice-First',
                      icon: Icons.mic,
                      color: Colors.blue,
                    ),
                  if (user.accessibility.visuallyImpaired)
                    _FeatureChip(
                      label: 'Visually Impaired',
                      icon: Icons.visibility_off,
                      color: Colors.purple,
                    ),
                  if (user.accessibility.ruralMode)
                    _FeatureChip(
                      label: 'Rural/Offline',
                      icon: Icons.signal_wifi_off,
                      color: Colors.orange,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _FeatureChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: color.withValues(alpha: 0.1),
    );
  }
}
