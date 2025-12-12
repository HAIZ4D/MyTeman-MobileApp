import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_state_provider.dart';

/// Profile screen showing user information
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final language = ref.watch(languageProvider);

    if (user == null) {
      // This shouldn't happen as app.dart will show login screen when user is null
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
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      user.name[0],
                      style: TextStyle(
                        fontSize: 32,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
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
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            language == 'ms' ? 'Maklumat Peribadi' : 'Personal Information',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          // Personal information
          Card(
            child: Column(
              children: [
                _InfoTile(
                  icon: Icons.badge,
                  label: language == 'ms' ? 'No. Kad Pengenalan' : 'IC Number',
                  value: user.icNumber,
                ),
                const Divider(height: 1),
                _InfoTile(
                  icon: Icons.cake,
                  label: language == 'ms' ? 'Tarikh Lahir' : 'Date of Birth',
                  value: user.dob,
                ),
                const Divider(height: 1),
                _InfoTile(
                  icon: Icons.home,
                  label: language == 'ms' ? 'Alamat' : 'Address',
                  value: user.address,
                ),
                const Divider(height: 1),
                _InfoTile(
                  icon: Icons.language,
                  label: language == 'ms' ? 'Bahasa' : 'Language',
                  value: user.preferredLanguage == 'ms' ? 'Bahasa Melayu' : 'English',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            language == 'ms' ? 'MyDigitalID' : 'MyDigitalID',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          Card(
            child: Column(
              children: [
                _InfoTile(
                  icon: user.mydigitalidLinked ? Icons.verified_user : Icons.warning,
                  label: language == 'ms' ? 'Status' : 'Status',
                  value: user.mydigitalidLinked
                      ? (language == 'ms' ? 'Terhubung' : 'Connected')
                      : (language == 'ms' ? 'Tidak Terhubung' : 'Not Connected'),
                  valueColor: user.mydigitalidLinked ? Colors.green : Colors.orange,
                ),
                const Divider(height: 1),
                _InfoTile(
                  icon: Icons.fingerprint,
                  label: language == 'ms' ? 'Biometrik' : 'Biometric',
                  value: user.biometricEnabled
                      ? (language == 'ms' ? 'Diaktifkan' : 'Enabled')
                      : (language == 'ms' ? 'Dilumpuhkan' : 'Disabled'),
                  valueColor: user.biometricEnabled ? Colors.green : Colors.grey,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            language == 'ms' ? 'Tetapan Kebolehcapaian' : 'Accessibility Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          Card(
            child: Column(
              children: [
                _InfoTile(
                  icon: Icons.mic,
                  label: language == 'ms' ? 'Mod Suara' : 'Voice Mode',
                  value: user.accessibility.voiceFirst
                      ? (language == 'ms' ? 'Diaktifkan' : 'Enabled')
                      : (language == 'ms' ? 'Dilumpuhkan' : 'Disabled'),
                  valueColor: user.accessibility.voiceFirst ? Colors.blue : Colors.grey,
                ),
                const Divider(height: 1),
                _InfoTile(
                  icon: Icons.visibility_off,
                  label: language == 'ms' ? 'Mod Penglihatan' : 'Visually Impaired',
                  value: user.accessibility.visuallyImpaired
                      ? (language == 'ms' ? 'Diaktifkan' : 'Enabled')
                      : (language == 'ms' ? 'Dilumpuhkan' : 'Disabled'),
                  valueColor: user.accessibility.visuallyImpaired ? Colors.purple : Colors.grey,
                ),
                const Divider(height: 1),
                _InfoTile(
                  icon: Icons.signal_wifi_off,
                  label: language == 'ms' ? 'Mod Luar Bandar' : 'Rural Mode',
                  value: user.accessibility.ruralMode
                      ? (language == 'ms' ? 'Diaktifkan' : 'Enabled')
                      : (language == 'ms' ? 'Dilumpuhkan' : 'Disabled'),
                  valueColor: user.accessibility.ruralMode ? Colors.orange : Colors.grey,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Actions
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(language == 'ms' ? 'Log Keluar' : 'Logout'),
                    content: Text(
                      language == 'ms'
                          ? 'Adakah anda pasti mahu log keluar?'
                          : 'Are you sure you want to logout?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(language == 'ms' ? 'Batal' : 'Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Close the dialog first
                          Navigator.pop(context);
                          // Set user to null - app.dart will automatically show login screen
                          ref.read(currentUserProvider.notifier).state = null;
                        },
                        child: Text(language == 'ms' ? 'Log Keluar' : 'Logout'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout),
              label: Text(language == 'ms' ? 'Log Keluar' : 'Logout'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
