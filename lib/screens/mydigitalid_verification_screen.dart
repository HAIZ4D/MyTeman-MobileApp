import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';

/// MyDigitalID Verification Screen (Simulated for Demo)
/// Shows verification dialog with skip option for prototype demo
class MyDigitalIDVerificationScreen extends ConsumerStatefulWidget {
  final User user;
  final Function(bool verified, Map<String, dynamic>? data) onComplete;

  const MyDigitalIDVerificationScreen({
    super.key,
    required this.user,
    required this.onComplete,
  });

  @override
  ConsumerState<MyDigitalIDVerificationScreen> createState() =>
      _MyDigitalIDVerificationScreenState();
}

class _MyDigitalIDVerificationScreenState
    extends ConsumerState<MyDigitalIDVerificationScreen> {
  bool _isVerifying = false;

  Future<void> _simulateVerification() async {
    setState(() => _isVerifying = true);

    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate successful verification with mock data
    final mockData = {
      'ic_number': widget.user.icNumber,
      'name': widget.user.name,
      'dob': widget.user.dob,
      'address': widget.user.address,
      'household_income': 3500, // RM3,500 for demo (eligible for B40)
      'marital_status': 'Married',
      'employment_status': 'Employed',
      'verified_at': DateTime.now().toIso8601String(),
    };

    if (mounted) {
      setState(() => _isVerifying = false);
      widget.onComplete(true, mockData);
      Navigator.of(context).pop();
    }
  }

  void _skipVerification() {
    widget.onComplete(false, null);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final language = widget.user.preferredLanguage;

    return Scaffold(
      appBar: AppBar(
        title: Text(language == 'ms' ? 'Pengesahan MyDigitalID' : 'MyDigitalID Verification'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // MyDigitalID Logo/Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_circle,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                language == 'ms' ? 'Pengesahan MyDigitalID' : 'MyDigitalID Verification',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                language == 'ms'
                    ? 'Sahkan identiti anda menggunakan MyDigitalID untuk akses automatik kepada maklumat peribadi dan semakan kelayakan.'
                    : 'Verify your identity using MyDigitalID for automatic access to personal information and eligibility checking.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Demo notice
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        language == 'ms'
                            ? 'MOD DEMO: Pengesahan disimulasikan untuk tujuan demonstrasi.'
                            : 'DEMO MODE: Verification is simulated for demonstration purposes.',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // User info preview
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        language == 'ms' ? 'Maklumat Pengguna' : 'User Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        language == 'ms' ? 'Nama' : 'Name',
                        widget.user.name,
                      ),
                      _buildInfoRow(
                        language == 'ms' ? 'No. KP' : 'IC Number',
                        widget.user.icNumber,
                      ),
                      _buildInfoRow(
                        language == 'ms' ? 'Alamat' : 'Address',
                        widget.user.address,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Verify button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isVerifying ? null : _simulateVerification,
                  icon: _isVerifying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.verified_user),
                  label: Text(
                    _isVerifying
                        ? (language == 'ms' ? 'Mengesahkan...' : 'Verifying...')
                        : (language == 'ms' ? 'Sahkan dengan MyDigitalID' : 'Verify with MyDigitalID'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Skip button for demo
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _isVerifying ? null : _skipVerification,
                  icon: const Icon(Icons.skip_next),
                  label: Text(
                    language == 'ms' ? 'Langkau (Demo)' : 'Skip (Demo)',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // What will be verified
              ExpansionTile(
                title: Text(
                  language == 'ms' ? 'Apa yang akan disahkan?' : 'What will be verified?',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBulletPoint(
                          language == 'ms' ? 'Identiti peribadi' : 'Personal identity',
                        ),
                        _buildBulletPoint(
                          language == 'ms' ? 'Pendapatan isi rumah' : 'Household income',
                        ),
                        _buildBulletPoint(
                          language == 'ms' ? 'Status perkahwinan' : 'Marital status',
                        ),
                        _buildBulletPoint(
                          language == 'ms' ? 'Status pekerjaan' : 'Employment status',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          language == 'ms'
                              ? 'Maklumat ini digunakan untuk menentukan kelayakan program B40.'
                              : 'This information is used to determine B40 program eligibility.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 20, height: 1.2)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
