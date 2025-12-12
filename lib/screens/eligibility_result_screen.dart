// FILE: lib/screens/eligibility_result_screen.dart

import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/eligibility.dart';
import '../services/eligibility_service.dart';

/// Eligibility Result Screen
///
/// Shows the final eligibility status with:
/// - Eligibility card (Eligible / Not Eligible)
/// - Matched/Failed rules
/// - Used data (redacted)
/// - Next steps CTA
class EligibilityResultScreen extends StatelessWidget {
  final User user;
  final EligibilityResult result;

  const EligibilityResultScreen({
    super.key,
    required this.user,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final lang = user.preferredLanguage;
    final eligibilityService = EligibilityService();
    final nextSteps = eligibilityService.getNextSteps(result.status, lang);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          lang == 'ms' ? 'Keputusan Kelayakan' : 'Eligibility Result',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            _buildStatusCard(context, lang, nextSteps),
            const SizedBox(height: 24),

            // Matched Rules
            if (result.matchedRules.isNotEmpty) ...[
              _buildSectionHeader(
                context,
                lang == 'ms' ? 'Kriteria Dipenuhi' : 'Criteria Met',
                Icons.check_circle,
                Colors.green,
              ),
              const SizedBox(height: 12),
              ...result.matchedRules.map((rule) => _buildRuleItem(
                    context,
                    rule,
                    Colors.green,
                    Icons.check_circle_outline,
                  )),
              const SizedBox(height: 24),
            ],

            // Failed Rules
            if (result.failedRules.isNotEmpty) ...[
              _buildSectionHeader(
                context,
                lang == 'ms' ? 'Kriteria Tidak Dipenuhi' : 'Criteria Not Met',
                Icons.cancel,
                Colors.red,
              ),
              const SizedBox(height: 12),
              ...result.failedRules.map((rule) => _buildRuleItem(
                    context,
                    rule,
                    Colors.red,
                    Icons.cancel_outlined,
                  )),
              const SizedBox(height: 24),
            ],

            // Data Used
            _buildSectionHeader(
              context,
              lang == 'ms' ? 'Data Digunakan' : 'Data Used',
              Icons.info_outline,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildDataUsedCard(context, lang),
            const SizedBox(height: 24),

            // Next Steps
            if (nextSteps != null) ...[
              _buildNextStepsSection(context, lang, nextSteps),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    String lang,
    Map<String, dynamic>? nextSteps,
  ) {
    final bool isEligible = result.eligible;
    final MaterialColor statusColor = isEligible ? Colors.green : Colors.red;
    final IconData statusIcon = isEligible ? Icons.check_circle : Icons.cancel;

    String title = '';
    String message = '';

    if (nextSteps != null) {
      title = lang == 'ms' ? nextSteps['title_ms'] : nextSteps['title'];
      message = lang == 'ms' ? nextSteps['message_ms'] : nextSteps['message'];
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              statusColor[50]!,
              statusColor[100]!,
            ],
          ),
        ),
        child: Column(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                statusIcon,
                size: 48,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: statusColor[900]!,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: statusColor[800]!,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    MaterialColor color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color[900]!,
          ),
        ),
      ],
    );
  }

  Widget _buildRuleItem(
    BuildContext context,
    String rule,
    MaterialColor color,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color[50]!,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color[700]!),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              rule,
              style: TextStyle(
                fontSize: 13,
                color: color[900]!,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataUsedCard(BuildContext context, String lang) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDataRow(
              lang == 'ms' ? 'Kewarganegaraan' : 'Citizenship',
              result.usedData['citizenship']?.toString() ?? '-',
            ),
            _buildDataRow(
              lang == 'ms' ? 'Umur' : 'Age',
              result.usedData['age']?.toString() ?? '-',
            ),
            _buildDataRow(
              lang == 'ms' ? 'Pendapatan Isi Rumah' : 'Household Income',
              result.usedData['household_income'] != null
                  ? 'RM ${result.usedData['household_income']}'
                  : (lang == 'ms' ? 'Tidak diberikan' : 'Not provided'),
            ),
            _buildDataRow(
              lang == 'ms' ? 'Bantuan Sedia Ada' : 'Existing Aids',
              result.usedData['existing_aids'] is List
                  ? (result.usedData['existing_aids'] as List).join(', ')
                  : (lang == 'ms' ? 'Tiada' : 'None'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepsSection(
    BuildContext context,
    String lang,
    Map<String, dynamic> nextSteps,
  ) {
    final actions = nextSteps['actions'] as List?;

    if (actions == null || actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          context,
          lang == 'ms' ? 'Langkah Seterusnya' : 'Next Steps',
          Icons.arrow_forward,
          Colors.purple,
        ),
        const SizedBox(height: 12),
        ...actions.map((action) {
          final label = lang == 'ms' ? action['label_ms'] : action['label'];
          final route = action['route'];
          final url = action['url'];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ElevatedButton.icon(
              onPressed: () {
                if (route != null) {
                  // Navigate to route
                  Navigator.pushNamed(context, route);
                } else if (url != null) {
                  // Open URL (would need url_launcher package)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Open: $url')),
                  );
                }
              },
              icon: Icon(
                route != null ? Icons.arrow_forward : Icons.open_in_new,
              ),
              label: Text(label),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
