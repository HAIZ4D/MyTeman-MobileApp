import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service.dart';
import '../models/application.dart';
import '../providers/app_state_provider.dart';
import '../widgets/voice_input_field.dart';
import '../widgets/document_upload_widget.dart';
import '../utils/haptic_feedback.dart';
import '../services/tts_service.dart';
import '../services/sync_queue.dart';
import '../services/biometric_service.dart';

/// Multi-step application form screen with voice input support
class ApplicationFormScreen extends ConsumerStatefulWidget {
  final Service service;

  const ApplicationFormScreen({
    super.key,
    required this.service,
  });

  @override
  ConsumerState<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends ConsumerState<ApplicationFormScreen> {
  final PageController _pageController = PageController();
  final Map<String, TextEditingController> _controllers = {};
  final TtsService _tts = TtsService();

  int _currentStep = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers for all required fields
    for (final field in widget.service.requiredFields) {
      _controllers[field] = TextEditingController();
    }
    _announceScreen();
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _announceScreen() async {
    final language = ref.read(languageProvider);
    final voiceMode = ref.read(voiceModeProvider);

    if (voiceMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      final announcement = language == 'ms'
          ? 'Borang permohonan ${widget.service.title}. Langkah 1 daripada ${widget.service.requiredFields.length}'
          : 'Application form for ${widget.service.titleEn}. Step 1 of ${widget.service.requiredFields.length}';
      await _tts.speak(announcement, language: language);
    }
  }

  void _nextStep() {
    if (_currentStep < widget.service.requiredFields.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      HapticHelper.navigation();
      _announceCurrentField();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      HapticHelper.navigation();
      _announceCurrentField();
    }
  }

  Future<void> _announceCurrentField() async {
    final language = ref.read(languageProvider);
    final voiceMode = ref.read(voiceModeProvider);

    if (voiceMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      final field = widget.service.requiredFields[_currentStep];
      final fieldLabel = _getFieldLabel(field, language);
      final announcement = language == 'ms'
          ? 'Langkah ${_currentStep + 1}. $fieldLabel'
          : 'Step ${_currentStep + 1}. $fieldLabel';
      await _tts.speak(announcement, language: language);
    }
  }

  String _getFieldLabel(String field, String language) {
    final labels = {
      'income_proof': {
        'en': 'Income Proof',
        'ms': 'Bukti Pendapatan',
      },
      'household_size': {
        'en': 'Household Size',
        'ms': 'Bilangan Ahli Keluarga',
      },
      'reason': {
        'en': 'Reason for Application',
        'ms': 'Sebab Permohonan',
      },
      'business_name': {
        'en': 'Business Name',
        'ms': 'Nama Perniagaan',
      },
      'business_type': {
        'en': 'Business Type',
        'ms': 'Jenis Perniagaan',
      },
      'address': {
        'en': 'Address',
        'ms': 'Alamat',
      },
      'owner_ic': {
        'en': 'Owner IC Number',
        'ms': 'Nombor IC Pemilik',
      },
      'academic_transcript': {
        'en': 'Academic Transcript',
        'ms': 'Transkrip Akademik',
      },
      'personal_statement': {
        'en': 'Personal Statement',
        'ms': 'Pernyataan Peribadi',
      },
      'reference_letter': {
        'en': 'Reference Letter',
        'ms': 'Surat Rujukan',
      },
    };

    return labels[field]?[language] ?? field;
  }

  String _getFieldHint(String field, String language) {
    final hints = {
      'income_proof': {
        'en': 'Enter your monthly income amount',
        'ms': 'Masukkan jumlah pendapatan bulanan',
      },
      'household_size': {
        'en': 'Enter number of people in household',
        'ms': 'Masukkan bilangan ahli keluarga',
      },
      'reason': {
        'en': 'Explain why you need this assistance',
        'ms': 'Terangkan sebab anda memerlukan bantuan ini',
      },
      'business_name': {
        'en': 'Enter your business name',
        'ms': 'Masukkan nama perniagaan anda',
      },
      'business_type': {
        'en': 'E.g., Restaurant, Retail, Services',
        'ms': 'Cth: Restoran, Runcit, Perkhidmatan',
      },
      'address': {
        'en': 'Enter your business address',
        'ms': 'Masukkan alamat perniagaan anda',
      },
      'owner_ic': {
        'en': 'Enter owner IC number',
        'ms': 'Masukkan nombor IC pemilik',
      },
      'academic_transcript': {
        'en': 'Upload your academic results',
        'ms': 'Muat naik keputusan akademik anda',
      },
      'personal_statement': {
        'en': 'Write about your achievements and goals',
        'ms': 'Tulis tentang pencapaian dan matlamat anda',
      },
      'reference_letter': {
        'en': 'Upload reference letter from teacher',
        'ms': 'Muat naik surat rujukan dari guru',
      },
    };

    return hints[field]?[language] ?? '';
  }

  bool _isFieldDocument(String field) {
    return field.contains('proof') ||
           field.contains('transcript') ||
           field.contains('letter') ||
           field.contains('document');
  }

  Future<void> _submitForm() async {
    final language = ref.read(languageProvider);
    final user = ref.read(currentUserProvider);

    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(language == 'ms'
                ? 'Sila log masuk terlebih dahulu'
                : 'Please login first'),
          ),
        );
      }
      return;
    }

    // Biometric authentication if enabled (now with fallback to confirmation)
    if (user.biometricEnabled) {
      final biometricService = BiometricService();
      final reason = BiometricService.getAuthenticationReason(
        language,
        serviceName: language == 'ms' ? widget.service.title : widget.service.titleEn,
      );

      // Announce authentication requirement
      if (ref.read(voiceModeProvider)) {
        final announcement = language == 'ms'
            ? 'Pengesahan identiti diperlukan'
            : 'Identity verification required';
        await _tts.speak(announcement, language: language);
      }

      final authenticated = await biometricService.authenticate(
        language: language,
        reason: reason,
      );

      if (!authenticated) {
        // If authentication fails, ask for confirmation instead of blocking
        await HapticHelper.selection();

        if (mounted) {
          final shouldContinue = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(language == 'ms'
                  ? 'Pengesahan Tidak Berjaya'
                  : 'Authentication Failed'),
              content: Text(language == 'ms'
                  ? 'Pengesahan identiti tidak berjaya. Adakah anda masih ingin menghantar permohonan ini?'
                  : 'Identity verification failed. Do you still want to submit this application?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(language == 'ms' ? 'Batal' : 'Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(language == 'ms' ? 'Teruskan' : 'Continue'),
                ),
              ],
            ),
          );

          if (shouldContinue != true) {
            if (ref.read(voiceModeProvider)) {
              await _tts.speak(
                language == 'ms' ? 'Permohonan dibatalkan' : 'Application cancelled',
                language: language,
              );
            }
            return;
          }
        } else {
          return;
        }
      } else {
        // Announce success
        if (ref.read(voiceModeProvider)) {
          await _tts.speak(
            language == 'ms' ? 'Pengesahan berjaya' : 'Authentication successful',
            language: language,
          );
        }
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    await HapticHelper.heavy();

    // Collect form data
    final filledData = <String, String>{};
    for (final entry in _controllers.entries) {
      filledData[entry.key] = entry.value.text;
    }

    // Create application
    final application = Application(
      appId: 'app_${DateTime.now().millisecondsSinceEpoch}',
      serviceId: widget.service.serviceId,
      uid: user.uid,
      status: 'draft',
      filledData: filledData,
      submittedAt: DateTime.now(),
      audit: [
        AuditEntry(
          timestamp: DateTime.now(),
          action: 'created',
          details: 'Application created via ISN app',
        )
      ],
    );

    // Save to offline queue
    final syncQueue = SyncQueue();
    try {
      await syncQueue.enqueue(application);

      // Try to sync immediately if online
      final isOnline = await syncQueue.isOnline();
      if (isOnline) {
        await syncQueue.attemptSyncAll();
      }

      setState(() {
        _isSubmitting = false;
      });

      await HapticHelper.success();

      if (mounted) {
        final queueSize = await syncQueue.getQueueSize();
        final message = isOnline
            ? (language == 'ms'
                ? 'Permohonan berjaya dihantar'
                : 'Application submitted successfully')
            : (language == 'ms'
                ? 'Permohonan disimpan. Akan disegerakkan apabila talian tersedia. ($queueSize dalam baris gilir)'
                : 'Application saved. Will sync when online. ($queueSize in queue)');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Return to previous screen
        Navigator.pop(context, application);
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      await HapticHelper.error();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(language == 'ms'
                ? 'Ralat menyimpan permohonan: $e'
                : 'Error saving application: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticHelper.selection();
            Navigator.pop(context);
          },
        ),
        actions: [
          // Save draft button
          TextButton.icon(
            onPressed: _isSubmitting ? null : _submitForm,
            icon: const Icon(Icons.save_outlined),
            label: Text(language == 'ms' ? 'Simpan' : 'Save'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentStep + 1) / widget.service.requiredFields.length,
            backgroundColor: Colors.grey[200],
            minHeight: 6,
          ),

          // Step counter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  language == 'ms'
                      ? widget.service.title
                      : (widget.service.titleEn ?? widget.service.title),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '${_currentStep + 1}/${widget.service.requiredFields.length}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          // Form fields
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.service.requiredFields.length,
              itemBuilder: (context, index) {
                final field = widget.service.requiredFields[index];
                final controller = _controllers[field]!;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getFieldLabel(field, language),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getFieldHint(field, language),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Check if field is document upload or text input
                      if (_isFieldDocument(field))
                        _buildDocumentUploadField(field, language)
                      else
                        VoiceInputField(
                          label: _getFieldHint(field, language),
                          controller: controller,
                          language: language,
                          maxLines: field == 'reason' || field == 'personal_statement' ? 5 : 1,
                          keyboardType: field == 'household_size' || field == 'income_proof'
                              ? TextInputType.number
                              : TextInputType.text,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _previousStep,
                      icon: const Icon(Icons.arrow_back),
                      label: Text(language == 'ms' ? 'Sebelum' : 'Previous'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _currentStep < widget.service.requiredFields.length - 1
                        ? _nextStep
                        : (_isSubmitting ? null : _submitForm),
                    icon: Icon(_currentStep < widget.service.requiredFields.length - 1
                        ? Icons.arrow_forward
                        : Icons.check),
                    label: Text(_currentStep < widget.service.requiredFields.length - 1
                        ? (language == 'ms' ? 'Seterusnya' : 'Next')
                        : (language == 'ms' ? 'Hantar' : 'Submit')),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadField(String field, String language) {
    return DocumentUploadWidget(
      fieldName: field,
      language: language,
      onFileSelected: (filePath) {
        // Store the file path in the controller
        if (filePath != null) {
          _controllers[field]?.text = filePath;
        } else {
          _controllers[field]?.text = '';
        }
      },
    );
  }
}
