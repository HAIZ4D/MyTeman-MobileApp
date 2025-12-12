// FILE: lib/widgets/eligibility_consent_modal.dart

import 'package:flutter/material.dart';

/// Consent modal for MyDigitalID access
///
/// Shows which fields will be accessed and requests biometric authentication
class EligibilityConsentModal extends StatelessWidget {
  final String language;
  final List<String> fields;
  final VoidCallback onConsent;
  final VoidCallback onDecline;

  const EligibilityConsentModal({
    super.key,
    required this.language,
    required this.fields,
    required this.onConsent,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fingerprint,
                  size: 32,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              language == 'ms'
                  ? 'MyDigitalID Consent'
                  : 'MyDigitalID Consent',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Explanation
            Text(
              language == 'ms'
                  ? 'Untuk semakan kelayakan Peka B40, kami perlukan akses kepada maklumat berikut dari MyDigitalID anda:'
                  : 'To check your Peka B40 eligibility, we need access to the following information from your MyDigitalID:',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),

            // Fields list
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: fields.map((field) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.green.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getFieldLabel(field, language),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Privacy note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock, size: 16, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      language == 'ms'
                          ? 'Maklumat anda selamat dan tidak akan dikongsi dengan pihak ketiga.'
                          : 'Your information is secure and will not be shared with third parties.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      language == 'ms' ? 'Tidak Setuju' : 'Decline',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onConsent,
                    icon: const Icon(Icons.fingerprint),
                    label: Text(
                      language == 'ms' ? 'Setuju & Sahkan' : 'Agree & Authenticate',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getFieldLabel(String field, String lang) {
    final labels = {
      'citizenship': {
        'ms': 'Kewarganegaraan',
        'en': 'Citizenship',
      },
      'age': {
        'ms': 'Umur',
        'en': 'Age',
      },
      'household_income': {
        'ms': 'Pendapatan Isi Rumah',
        'en': 'Household Income',
      },
      'existing_aids': {
        'ms': 'Bantuan Sedia Ada (STR, dll)',
        'en': 'Existing Aids (STR, etc)',
      },
      'household_size': {
        'ms': 'Bilangan Ahli Keluarga',
        'en': 'Household Size',
      },
    };

    return labels[field]?[lang] ?? field;
  }
}
