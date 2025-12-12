// FILE: lib/screens/bkoku_application_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/bkoku_application.dart';
import '../services/bkoku_service.dart';
import '../services/my_digital_id_service.dart';
import '../services/voice_service_enhanced.dart';
import '../services/sync_queue.dart';
import '../providers/voice_clinic_providers.dart';
import '../config/bkoku_config.dart';

/// BKOKU Application Screen - Voice-First OKU Student Financial Aid
///
/// Flow:
/// 1. Welcome & explain process
/// 2. Request MyDigitalID consent
/// 3. Authenticate with biometric
/// 4. Auto-fill from MyDigitalID vault
/// 5. Review and confirm
/// 6. Submit application
class BkokuApplicationScreen extends ConsumerStatefulWidget {
  final User user;

  const BkokuApplicationScreen({super.key, required this.user});

  @override
  ConsumerState<BkokuApplicationScreen> createState() =>
      _BkokuApplicationScreenState();
}

class _BkokuApplicationScreenState
    extends ConsumerState<BkokuApplicationScreen> {
  final BkokuService _bkokuService = BkokuService();
  late VoiceServiceEnhanced _voiceService;
  late MyDigitalIDService _myDigitalIDService;

  BkokuApplication? _application;
  bool _isInitialized = false;
  bool _consentGiven = false;
  bool _isSubmitting = false;
  String? _consentId;

  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    _voiceService = ref.read(voiceServiceProvider);
    _myDigitalIDService = ref.read(myDigitalIDServiceProvider);

    await _voiceService.initialize();

    setState(() {
      _isInitialized = true;
    });

    await _startFlow();
  }

  Future<void> _startFlow() async {
    final lang = widget.user.preferredLanguage;

    // Welcome message
    final welcomeMsg = _bkokuService.getTtsMessage('welcome', lang);
    _addMessage(welcomeMsg, isUser: false);
    await _voiceService.speakAndWait(welcomeMsg);

    await Future.delayed(const Duration(milliseconds: 500));

    // Consent request
    final consentMsg = _bkokuService.getTtsMessage('consent_request', lang);
    _addMessage(consentMsg, isUser: false);
    await _voiceService.speakAndWait(consentMsg);

    // Show consent dialog
    await Future.delayed(const Duration(milliseconds: 300));
    _showConsentDialog();
  }

  void _addMessage(String text, {required bool isUser}) {
    setState(() {
      _messages.add({
        'text': text,
        'isUser': isUser,
        'timestamp': DateTime.now(),
      });
    });

    // Auto-scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showConsentDialog() {
    final lang = widget.user.preferredLanguage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(lang == 'ms' ? 'Kebenaran MyDigitalID' : 'MyDigitalID Consent'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lang == 'ms'
                    ? 'Untuk memudahkan permohonan BKOKU, kami perlukan akses kepada:'
                    : 'To facilitate your BKOKU application, we need access to:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...BkokuConfig.REQUIRED_FIELDS.map((field) => Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            size: 16, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getFieldLabel(field, lang),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 12),
              Text(
                lang == 'ms' ? 'Dan dokumen sokongan:' : 'And supporting documents:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...BkokuConfig.REQUIRED_DOCUMENTS.map((doc) => Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.description,
                            size: 16, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _bkokuService.getDocumentLabel(doc, lang),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  BkokuConfig.CONSENT_TEXT[lang]!,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Exit screen
            },
            child: Text(lang == 'ms' ? 'Tidak Setuju' : 'Disagree'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _handleConsentGiven();
            },
            icon: const Icon(Icons.fingerprint),
            label: Text(lang == 'ms' ? 'Setuju & Sahkan' : 'Agree & Authenticate'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleConsentGiven() async {
    final lang = widget.user.preferredLanguage;

    setState(() {
      _consentGiven = true;
    });

    _addMessage(
      lang == 'ms' ? 'Saya setuju' : 'I agree',
      isUser: true,
    );

    // Authenticate with biometric
    final authMsg = lang == 'ms'
        ? 'Sila sahkan identiti anda...'
        : 'Please authenticate...';
    _addMessage(authMsg, isUser: false);
    await _voiceService.speakAndWait(authMsg);

    final authenticated = await _myDigitalIDService.authenticateBiometric(
      reason: lang == 'ms'
          ? 'Sahkan identiti untuk permohonan BKOKU'
          : 'Authenticate for BKOKU application',
    );

    if (!authenticated) {
      final errorMsg = lang == 'ms'
          ? 'Pengesahan gagal. Sila cuba lagi.'
          : 'Authentication failed. Please try again.';
      _addMessage(errorMsg, isUser: false);
      await _voiceService.speakAndWait(errorMsg);
      return;
    }

    // Record consent
    _consentId = _bkokuService.generateConsentId(widget.user.uid);
    final consent = ConsentRecord(
      consentId: _consentId!,
      uid: widget.user.uid,
      timestamp: DateTime.now(),
      method: 'biometric',
      fieldsRequested: BkokuConfig.REQUIRED_FIELDS,
      documentsRequested: BkokuConfig.REQUIRED_DOCUMENTS,
      granted: true,
      consentText: BkokuConfig.CONSENT_TEXT[lang]!,
    );

    await _bkokuService.recordConsent(consent);

    // Build application from vault
    await _buildAndShowApplication();
  }

  Future<void> _buildAndShowApplication() async {
    final lang = widget.user.preferredLanguage;

    try {
      // Build application
      final app = _bkokuService.buildApplicationFromVault(widget.user);

      setState(() {
        _application = app;
      });

      // Auto-fill complete message
      final autofillMsg = _bkokuService.getTtsMessage('autofill_complete', lang);
      _addMessage(autofillMsg, isUser: false);
      await _voiceService.speakAndWait(autofillMsg);

      await Future.delayed(const Duration(milliseconds: 500));

      // Ask for submission confirmation
      final confirmMsg = _bkokuService.getTtsMessage('submit_confirm', lang);
      _addMessage(confirmMsg, isUser: false);
      await _voiceService.speakAndWait(confirmMsg);
    } catch (e) {
      final errorMsg = lang == 'ms'
          ? 'Ralat membina permohonan: $e'
          : 'Error building application: $e';
      _addMessage(errorMsg, isUser: false);
      await _voiceService.speakAndWait(errorMsg);
    }
  }

  Future<void> _submitApplication() async {
    if (_application == null || _consentId == null) return;

    final lang = widget.user.preferredLanguage;

    setState(() {
      _isSubmitting = true;
    });

    _addMessage(
      lang == 'ms' ? 'Ya, hantar sekarang' : 'Yes, submit now',
      isUser: true,
    );

    try {
      // Initialize sync queue
      final syncQueue = SyncQueue();

      // Check connectivity first
      final isOnline = await syncQueue.isOnline();

      if (isOnline) {
        // ONLINE: Submit directly to Firestore
        final syncingMsg = _bkokuService.getTtsMessage('syncing', lang);
        _addMessage(syncingMsg, isUser: false);
        await _voiceService.speakAndWait(syncingMsg);

        await _bkokuService.submitApplication(_application!, _consentId!);

        final successMsg = _bkokuService.getTtsMessage('submitted', lang);
        _addMessage(successMsg, isUser: false);
        await _voiceService.speakAndWait(successMsg);

        // Show success snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                lang == 'ms'
                    ? '✅ Permohonan BKOKU berjaya dihantar!'
                    : '✅ BKOKU application submitted successfully!',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        // OFFLINE: Save to queue
        final offlineMsg = lang == 'ms'
            ? 'Tiada sambungan internet. Permohonan akan disimpan dan dihantar apabila sambungan kembali.'
            : 'No internet connection. Application will be saved and submitted when connection is restored.';
        _addMessage(offlineMsg, isUser: false);
        await _voiceService.speakAndWait(offlineMsg);

        // Create general application for queue
        final generalApp = _application!.toGeneralApplication();

        // Add to offline queue
        await syncQueue.enqueue(generalApp);

        print('BKOKU: Application saved to offline queue: ${generalApp.appId}');

        final queuedMsg = lang == 'ms'
            ? 'Permohonan telah disimpan. Akan dihantar secara automatik apabila ada internet.'
            : 'Application saved. Will be submitted automatically when internet is available.';
        _addMessage(queuedMsg, isUser: false);
        await _voiceService.speakAndWait(queuedMsg);

        // Show offline snackbar with icon
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.offline_bolt, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      lang == 'ms'
                          ? '📱 Disimpan secara offline. Akan dihantar automatik bila ada internet.'
                          : '📱 Saved offline. Will sync automatically when online.',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      }

      setState(() {
        _isSubmitting = false;
      });

      // Navigate back after success
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      final errorMsg = lang == 'ms'
          ? 'Ralat menghantar permohonan: $e'
          : 'Error submitting application: $e';
      _addMessage(errorMsg, isUser: false);
      await _voiceService.speakAndWait(errorMsg);

      setState(() {
        _isSubmitting = false;
      });

      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $errorMsg'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  String _getFieldLabel(String field, String lang) {
    final labels = {
      'name': {'ms': 'Nama Penuh', 'en': 'Full Name'},
      'ic_number': {'ms': 'No. Kad Pengenalan', 'en': 'IC Number'},
      'dob': {'ms': 'Tarikh Lahir', 'en': 'Date of Birth'},
      'oku_id': {'ms': 'No. Kad OKU', 'en': 'OKU Card Number'},
      'oku_status': {'ms': 'Status OKU', 'en': 'OKU Status'},
      'institution': {'ms': 'Nama Universiti', 'en': 'University Name'},
      'enrollment_no': {'ms': 'No. Matrikulasi', 'en': 'Enrollment Number'},
      'bank_account_no': {'ms': 'No. Akaun Bank', 'en': 'Bank Account Number'},
      'bank_name': {'ms': 'Nama Bank', 'en': 'Bank Name'},
    };

    return labels[field]?[lang] ?? field;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.user.preferredLanguage;

    return Scaffold(
      appBar: AppBar(
        title: Text(lang == 'ms' ? 'Permohonan BKOKU' : 'BKOKU Application'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Messages
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _MessageBubble(
                        text: message['text'],
                        isUser: message['isUser'],
                      );
                    },
                  ),
                ),

                // Application preview (if built)
                if (_application != null) ...[
                  const Divider(),
                  _ApplicationPreview(
                    application: _application!,
                    language: lang,
                  ),
                ],

                // Submit button
                if (_application != null && !_isSubmitting)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submitApplication,
                        icon: const Icon(Icons.send),
                        label: Text(
                          lang == 'ms' ? 'Hantar Permohonan' : 'Submit Application',
                          style: const TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ),

                if (_isSubmitting)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const _MessageBubble({
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}

class _ApplicationPreview extends StatelessWidget {
  final BkokuApplication application;
  final String language;

  const _ApplicationPreview({
    required this.application,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.green[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                language == 'ms' ? 'Maklumat Lengkap' : 'Information Complete',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.school,
            label: language == 'ms' ? 'Universiti' : 'University',
            value: application.institution,
          ),
          _InfoRow(
            icon: Icons.badge,
            label: language == 'ms' ? 'No. Matrikulasi' : 'Enrollment No.',
            value: application.enrollmentNo,
          ),
          _InfoRow(
            icon: Icons.account_balance,
            label: language == 'ms' ? 'Bank' : 'Bank',
            value: application.bankName,
          ),
          _InfoRow(
            icon: Icons.description,
            label: language == 'ms' ? 'Dokumen' : 'Documents',
            value: '${application.attachments.length} ${language == 'ms' ? 'fail' : 'files'}',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
