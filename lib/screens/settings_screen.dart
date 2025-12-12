import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_state_provider.dart';
import '../config.dart';

/// Settings screen for app preferences and accessibility
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final highContrast = ref.watch(highContrastModeProvider);
    final textScale = ref.watch(textScaleProvider);
    final voiceMode = ref.watch(voiceModeProvider);
    final ruralMode = ref.watch(ruralModeProvider);
    final language = ref.watch(languageProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            language == 'ms' ? 'Tetapan' : 'Settings',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),

          // Accessibility Section
          Text(
            language == 'ms' ? 'Kebolehcapaian' : 'Accessibility',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(language == 'ms' ? 'Mod Kontras Tinggi' : 'High Contrast Mode'),
                  subtitle: Text(
                    language == 'ms'
                        ? 'Warna hitam dan kuning untuk penglihatan lebih baik'
                        : 'Black and yellow colors for better visibility',
                  ),
                  secondary: const Icon(Icons.contrast),
                  value: highContrast,
                  onChanged: (value) {
                    ref.read(highContrastModeProvider.notifier).state = value;
                    // Show snackbar to inform user they need to restart
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          language == 'ms'
                              ? 'Mod kontras tinggi ${value ? 'diaktifkan' : 'dilumpuhkan'}'
                              : 'High contrast mode ${value ? 'enabled' : 'disabled'}',
                        ),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.text_fields),
                  title: Text(language == 'ms' ? 'Saiz Teks' : 'Text Size'),
                  subtitle: Text(
                    textScale == 1.0
                        ? (language == 'ms' ? 'Biasa' : 'Normal')
                        : textScale == 1.5
                            ? (language == 'ms' ? 'Besar' : 'Large')
                            : (language == 'ms' ? 'Sangat Besar' : 'Extra Large'),
                  ),
                  trailing: SegmentedButton<double>(
                    segments: const [
                      ButtonSegment(value: 1.0, label: Text('A')),
                      ButtonSegment(value: 1.5, label: Text('A+')),
                      ButtonSegment(value: 2.0, label: Text('A++')),
                    ],
                    selected: {textScale},
                    onSelectionChanged: (Set<double> selected) {
                      ref.read(textScaleProvider.notifier).state = selected.first;
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.mic),
                  title: Text(language == 'ms' ? 'Mod Suara' : 'Voice Mode'),
                  subtitle: Text(
                    language == 'ms'
                        ? 'Sentiasa aktif - Butang suara sentiasa tersedia'
                        : 'Always active - Voice button always available',
                  ),
                  trailing: Chip(
                    label: Text(
                      language == 'ms' ? 'Aktif' : 'Active',
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.green.shade100,
                    labelStyle: TextStyle(color: Colors.green.shade900),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.cloud_sync),
                  title: Text(language == 'ms' ? 'Mod Luar Talian' : 'Offline Mode'),
                  subtitle: Text(
                    language == 'ms'
                        ? 'Auto sync - Data disimpan dan segerak secara automatik'
                        : 'Auto sync - Data saved and synced automatically',
                  ),
                  trailing: Chip(
                    label: Text(
                      language == 'ms' ? 'Auto' : 'Auto',
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.blue.shade100,
                    labelStyle: TextStyle(color: Colors.blue.shade900),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // App Settings
          Text(
            language == 'ms' ? 'Tetapan Aplikasi' : 'App Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(language == 'ms' ? 'Bahasa' : 'Language'),
                  subtitle: Text(language == 'ms' ? 'Bahasa Melayu' : 'English'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showLanguageDialog(context, ref, language);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text(language == 'ms' ? 'Notifikasi' : 'Notifications'),
                  subtitle: Text(language == 'ms' ? 'Urus keutamaan notifikasi' : 'Manage notification preferences'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Notification settings
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: Text(language == 'ms' ? 'Keselamatan & Privasi' : 'Security & Privacy'),
                  subtitle: Text(language == 'ms' ? 'Urus tetapan keselamatan' : 'Manage security settings'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Security settings
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // About Section
          Text(
            language == 'ms' ? 'Tentang' : 'About',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(language == 'ms' ? 'Versi Aplikasi' : 'App Version'),
                  subtitle: const Text('1.0.0 (Build 1)'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: Text(language == 'ms' ? 'Terma & Syarat' : 'Terms & Conditions'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: Text(language == 'ms' ? 'Dasar Privasi' : 'Privacy Policy'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: Text(language == 'ms' ? 'Bantuan & Sokongan' : 'Help & Support'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Debug info (for demo purposes)
          if (user != null)
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bug_report, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          language == 'ms' ? 'Mod Debug (Demo)' : 'Debug Mode (Demo)',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'User ID: ${user.uid}\n'
                      'Firebase Mode: ${AppConfig.useFirebase}\n'
                      'High Contrast: $highContrast\n'
                      'Text Scale: $textScale\n'
                      'Voice Mode: $voiceMode\n'
                      'Rural Mode: $ruralMode',
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref, String currentLanguage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(currentLanguage == 'ms' ? 'Pilih Bahasa' : 'Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('English'),
                value: 'en',
                groupValue: currentLanguage,
                onChanged: (String? value) {
                  if (value != null) {
                    ref.read(languageProvider.notifier).state = value;
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Language changed to English'),
                      ),
                    );
                  }
                },
              ),
              RadioListTile<String>(
                title: const Text('Bahasa Melayu'),
                value: 'ms',
                groupValue: currentLanguage,
                onChanged: (String? value) {
                  if (value != null) {
                    ref.read(languageProvider.notifier).state = value;
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bahasa ditukar kepada Bahasa Melayu'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(currentLanguage == 'ms' ? 'Batal' : 'Cancel'),
            ),
          ],
        );
      },
    );
  }
}
