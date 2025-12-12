// FILE: lib/screens/voice_clinic_search_flow_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user.dart';
import '../models/clinic.dart';
import '../models/appointment.dart';
import '../models/application.dart';
import '../providers/voice_clinic_providers.dart';
import '../services/voice_service_enhanced.dart';
import '../services/enhanced_clinic_service.dart';
import '../services/appointment_service.dart';
import '../services/application_service.dart';
import '../services/my_digital_id_service.dart';

/// Voice-first Clinic Search with Conversational Flow
class VoiceClinicSearchFlowScreen extends ConsumerStatefulWidget {
  final User user;

  const VoiceClinicSearchFlowScreen({super.key, required this.user});

  @override
  ConsumerState<VoiceClinicSearchFlowScreen> createState() =>
      _VoiceClinicSearchFlowScreenState();
}

class _VoiceClinicSearchFlowScreenState
    extends ConsumerState<VoiceClinicSearchFlowScreen> {
  late VoiceServiceEnhanced _voiceService;
  late EnhancedClinicService _clinicService;
  late AppointmentService _appointmentService;
  late ApplicationService _applicationService;
  late MyDigitalIDService _myDigitalIDService;

  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    _voiceService = ref.read(voiceServiceProvider);
    _clinicService = ref.read(clinicServiceProvider);
    _appointmentService = ref.read(appointmentServiceProvider);
    _applicationService = ref.read(applicationServiceProvider);
    _myDigitalIDService = ref.read(myDigitalIDServiceProvider);

    // Set voice callbacks
    _voiceService.onListeningStateChange = (isListening) {
      ref.read(voiceListeningProvider.notifier).state = isListening;
    };

    _voiceService.onSpeakingStateChange = (isSpeaking) {
      ref.read(voiceSpeakingProvider.notifier).state = isSpeaking;
    };

    _voiceService.onTranscript = (transcript) {
      ref.read(currentTranscriptProvider.notifier).state = transcript;
    };

    // Initialize voice service
    final language = widget.user.preferredLanguage == 'ms' ? 'ms-MY' : 'en-US';
    final initialized = await _voiceService.initialize(language: language);

    if (initialized) {
      setState(() => _isInitialized = true);
      _startConversation();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.user.preferredLanguage == 'ms'
                ? 'Ralat: Perkhidmatan suara tidak tersedia'
                : 'Error: Voice service not available'),
          ),
        );
      }
    }
  }

  Future<void> _startConversation() async {
    final lang = widget.user.preferredLanguage;
    final greeting = lang == 'ms'
        ? 'Selamat datang ${widget.user.name}. Saya di sini untuk membantu anda mencari klinik PEKA B40. Di kawasan mana anda tinggal?'
        : 'Welcome ${widget.user.name}. I\'m here to help you find PEKA B40 clinics. Which area do you live in?';

    _addMessage(greeting, isUser: false);
    await _voiceService.speakAndWait(greeting);

    ref.read(conversationStateProvider.notifier).state =
        ConversationState.askingLocation;
  }

  void _addMessage(String text, {required bool isUser}) {
    final messages = ref.read(conversationMessagesProvider);
    ref.read(conversationMessagesProvider.notifier).state = [
      ...messages,
      {
        'text': text,
        'isUser': isUser,
        'timestamp': DateTime.now(),
      }
    ];

    // Auto-scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleUserInput(String transcript) async {
    _addMessage(transcript, isUser: true);

    final currentState = ref.read(conversationStateProvider);
    final lang = widget.user.preferredLanguage;

    switch (currentState) {
      case ConversationState.askingLocation:
        await _handleLocationInput(transcript);
        break;

      case ConversationState.askingAction:
        await _handleActionInput(transcript);
        break;

      case ConversationState.collectingAppointmentDetails:
        await _handleAppointmentDetailsInput(transcript);
        break;

      default:
        final intent = _voiceService.detectIntent(transcript);
        if (intent == 'search_clinic') {
          await _handleLocationInput(transcript);
        }
    }
  }

  Future<void> _handleLocationInput(String transcript) async {
    final lang = widget.user.preferredLanguage;
    final location = _voiceService.extractLocation(transcript);

    if (location['state'] == null && location['city'] == null) {
      final response = lang == 'ms'
          ? 'Maaf, saya tidak faham lokasi anda. Boleh sebut nama negeri atau bandar?'
          : 'Sorry, I didn\'t understand your location. Can you mention the state or city name?';

      _addMessage(response, isUser: false);
      await _voiceService.speakAndWait(response);
      return;
    }

    ref.read(conversationStateProvider.notifier).state =
        ConversationState.searchingClinic;

    final searchingMsg = lang == 'ms'
        ? 'Baik, saya sedang mencari klinik...'
        : 'Okay, searching for clinics...';

    _addMessage(searchingMsg, isUser: false);
    await _voiceService.speakAndWait(searchingMsg);

    // Search clinics
    final clinics = await _clinicService.searchByLocation(
      state: location['state'],
      city: location['city'],
    );

    if (clinics.isEmpty) {
      final notFoundMsg = lang == 'ms'
          ? 'Maaf, kawasan anda terlalu jauh dari klinik demo yang tersedia. Klinik demo hanya ada di Melaka, Johor, dan Negeri Sembilan.'
          : 'Sorry, your area is too far from the demo clinics. Demo clinics are only available in Melaka, Johor, and Negeri Sembilan.';

      _addMessage(notFoundMsg, isUser: false);
      await _voiceService.speakAndWait(notFoundMsg);

      ref.read(conversationStateProvider.notifier).state =
          ConversationState.completed;
      return;
    }

    // Show clinic results
    final clinic = clinics.first;
    ref.read(selectedClinicProvider.notifier).state = clinic;
    ref.read(clinicSearchResultsProvider.notifier).state = clinics;

    final clinicInfo = _clinicService.formatClinicForVoice(clinic, lang);
    _addMessage(clinicInfo, isUser: false);
    await _voiceService.speakAndWait(clinicInfo);

    // Ask for action - wait for previous speech to complete
    final actionPrompt = lang == 'ms'
        ? 'Adakah anda ingin saya hubungi klinik, tunjukkan arah, atau buat temujanji?'
        : 'Do you want me to call the clinic, get directions, or book an appointment?';

    _addMessage(actionPrompt, isUser: false);
    await _voiceService.speakAndWait(actionPrompt);

    ref.read(conversationStateProvider.notifier).state =
        ConversationState.askingAction;
  }

  Future<void> _handleActionInput(String transcript) async {
    final intent = _voiceService.detectIntent(transcript);
    final lang = widget.user.preferredLanguage;
    final clinic = ref.read(selectedClinicProvider);

    if (clinic == null) return;

    switch (intent) {
      case 'direction':
        await _handleDirectionRequest(clinic);
        break;

      case 'call_clinic':
        await _handleCallRequest(clinic);
        break;

      case 'book_appointment':
        await _startAppointmentBooking(clinic);
        break;

      case 'done':
        final thankYouMsg = lang == 'ms'
            ? 'Baik, terima kasih kerana menggunakan perkhidmatan kami.'
            : 'Okay, thank you for using our service.';

        _addMessage(thankYouMsg, isUser: false);
        await _voiceService.speakAndWait(thankYouMsg);

        ref.read(conversationStateProvider.notifier).state =
            ConversationState.completed;
        break;

      default:
        final clarify = lang == 'ms'
            ? 'Maaf, saya tidak faham. Boleh sebut "arah", "hubungi", "buat temujanji", atau "selesai".'
            : 'Sorry, I didn\'t understand. Can you say "direction", "call", "book appointment", or "done"?';

        _addMessage(clarify, isUser: false);
        await _voiceService.speakAndWait(clarify);
    }
  }

  Future<void> _handleDirectionRequest(Clinic clinic) async {
    final lang = widget.user.preferredLanguage;
    final response = lang == 'ms'
        ? 'Baik, saya akan buka Google Maps untuk navigasi.'
        : 'Okay, I will open Google Maps for navigation.';

    _addMessage(response, isUser: false);
    await _voiceService.speakAndWait(response);

    // Open Google Maps
    final uri = Uri.parse(clinic.locationUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }

    // Ask if user wants to do something else
    await Future.delayed(const Duration(milliseconds: 500));
    final followUpPrompt = lang == 'ms'
        ? 'Adakah anda ingin hubungi klinik atau buat temujanji?'
        : 'Would you like to call the clinic or book an appointment?';

    _addMessage(followUpPrompt, isUser: false);
    await _voiceService.speakAndWait(followUpPrompt);

    ref.read(conversationStateProvider.notifier).state =
        ConversationState.askingAction;
  }

  Future<void> _handleCallRequest(Clinic clinic) async {
    final lang = widget.user.preferredLanguage;
    final response = lang == 'ms'
        ? 'Nombor telefon klinik ialah ${clinic.formattedContact}. Saya akan buka aplikasi telefon.'
        : 'The clinic phone number is ${clinic.formattedContact}. I will open the phone app.';

    _addMessage(response, isUser: false);
    await _voiceService.speakAndWait(response);

    // Open phone dialer
    final uri = Uri.parse('tel:${clinic.contactNo}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }

    // Ask if user wants to do something else
    await Future.delayed(const Duration(milliseconds: 500));
    final followUpPrompt = lang == 'ms'
        ? 'Adakah anda ingin tunjukkan arah atau buat temujanji?'
        : 'Would you like to get directions or book an appointment?';

    _addMessage(followUpPrompt, isUser: false);
    await _voiceService.speakAndWait(followUpPrompt);

    ref.read(conversationStateProvider.notifier).state =
        ConversationState.askingAction;
  }

  Future<void> _startAppointmentBooking(Clinic clinic) async {
    final lang = widget.user.preferredLanguage;

    ref.read(conversationStateProvider.notifier).state =
        ConversationState.bookingAppointment;

    final prompt = lang == 'ms'
        ? 'Baik, mari kita buat temujanji. Beritahu saya tarikh, masa, dan tujuan lawatan.'
        : 'Okay, let\'s book an appointment. Tell me the date, time, and purpose of visit.';

    _addMessage(prompt, isUser: false);
    await _voiceService.speakAndWait(prompt);

    ref.read(conversationStateProvider.notifier).state =
        ConversationState.collectingAppointmentDetails;
  }

  Future<void> _handleAppointmentDetailsInput(String transcript) async {
    final lang = widget.user.preferredLanguage;

    // Store appointment details
    ref.read(appointmentDraftProvider.notifier).state = {
      'raw_transcript': transcript,
      'purpose': transcript,
    };

    // Ask for MyDigitalID authentication
    final authPrompt = lang == 'ms'
        ? 'Benarkan saya gunakan maklumat MyDigitalID anda untuk temujanji supaya anda tidak perlu isi borang manual.'
        : 'Allow me to use your MyDigitalID information for the appointment so you don\'t need to fill forms manually.';

    _addMessage(authPrompt, isUser: false);
    await _voiceService.speakAndWait(authPrompt);

    ref.read(conversationStateProvider.notifier).state =
        ConversationState.authenticating;

    // Trigger biometric auth
    await _authenticateAndSubmit();
  }

  Future<void> _authenticateAndSubmit() async {
    final lang = widget.user.preferredLanguage;
    final clinic = ref.read(selectedClinicProvider);

    if (clinic == null) return;

    ref.read(conversationStateProvider.notifier).state =
        ConversationState.submitting;

    // Authenticate
    final reason = lang == 'ms'
        ? 'Sahkan identiti untuk buat temujanji'
        : 'Authenticate to book appointment';

    final authenticated = await _myDigitalIDService.authenticateBiometric(
      reason: reason,
    );

    if (!authenticated) {
      final errorMsg = lang == 'ms'
          ? 'Pengesahan gagal. Temujanji dibatalkan.'
          : 'Authentication failed. Appointment cancelled.';

      _addMessage(errorMsg, isUser: false);
      await _voiceService.speakAndWait(errorMsg);

      ref.read(conversationStateProvider.notifier).state =
          ConversationState.completed;
      return;
    }

    // Authentication successful - provide feedback
    final authSuccessMsg = lang == 'ms'
        ? 'Pengesahan berjaya. Sedang memproses temujanji anda...'
        : 'Authentication successful. Processing your appointment...';

    _addMessage(authSuccessMsg, isUser: false);
    await _voiceService.speakAndWait(authSuccessMsg);

    // Get MyDigitalID data
    final userData = await _myDigitalIDService.getUserData(widget.user);

    // Create appointment
    final draft = ref.read(appointmentDraftProvider);
    final appointment = Appointment(
      appointmentId: _appointmentService.generateAppointmentId(),
      clinicId: clinic.id,
      clinicName: clinic.name,
      userId: widget.user.uid,
      userName: widget.user.name,
      userIc: widget.user.icNumber,
      date: DateTime.now().add(const Duration(days: 7)), // Default 1 week
      time: '10:00 AM', // Default time
      purpose: draft['purpose'] ?? 'Health Screening',
      status: AppointmentStatus.pending,
      createdAt: DateTime.now(),
      metadata: userData,
    );

    try {
      print('Creating appointment with ID: ${appointment.appointmentId}');
      print('Appointment data: ${appointment.toJson()}');

      // Create appointment
      await _appointmentService.createAppointment(appointment);
      print('Appointment created successfully!');

      // Create application record for "My Applications"
      final application = Application(
        appId: 'app_${appointment.appointmentId}',
        serviceId: 'peka_b40_clinic_search',
        uid: widget.user.uid,
        status: 'submitted',
        filledData: {
          'clinic_name': clinic.name,
          'clinic_address': clinic.address,
          'appointment_date': appointment.date.toIso8601String(),
          'appointment_time': appointment.time,
          'purpose': appointment.purpose,
          'appointment_id': appointment.appointmentId,
        },
        submittedAt: DateTime.now(),
        audit: [
          AuditEntry(
            timestamp: DateTime.now(),
            action: 'submitted',
            details: 'PEKA B40 clinic appointment booked via voice interface',
          ),
        ],
      );

      await _applicationService.createApplication(application);
      print('Application record created successfully!');

      // Success message
      final successMsg = lang == 'ms'
          ? 'Temujanji anda telah berjaya dibuat! ID temujanji: ${appointment.appointmentId}. Klinik akan menghubungi anda untuk pengesahan.'
          : 'Your appointment has been successfully created! Appointment ID: ${appointment.appointmentId}. The clinic will contact you for confirmation.';

      _addMessage(successMsg, isUser: false);
      await _voiceService.speakAndWait(successMsg);
    } catch (e, stackTrace) {
      // Error creating appointment - log details
      print('ERROR creating appointment: $e');
      print('Stack trace: $stackTrace');

      final errorMsg = lang == 'ms'
          ? 'Maaf, terdapat masalah semasa membuat temujanji. Ralat: $e'
          : 'Sorry, there was a problem creating your appointment. Error: $e';

      _addMessage(errorMsg, isUser: false);
      await _voiceService.speakAndWait(errorMsg);
    }

    ref.read(conversationStateProvider.notifier).state =
        ConversationState.completed;
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(conversationMessagesProvider);
    final isListening = ref.watch(voiceListeningProvider);
    final isSpeaking = ref.watch(voiceSpeakingProvider);
    final currentTranscript = ref.watch(currentTranscriptProvider);
    final selectedClinic = ref.watch(selectedClinicProvider);
    final lang = widget.user.preferredLanguage;

    return Scaffold(
      appBar: AppBar(
        title: Text(lang == 'ms' ? 'Cari Klinik PEKA B40' : 'Find PEKA B40 Clinic'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Conversation messages
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return _buildMessageBubble(
                        message['text'] as String,
                        message['isUser'] as bool,
                      );
                    },
                  ),
                ),

                // Selected clinic card
                if (selectedClinic != null) _buildClinicCard(selectedClinic),

                // Voice input area
                _buildVoiceInputArea(
                  isListening: isListening,
                  isSpeaking: isSpeaking,
                  currentTranscript: currentTranscript,
                ),
              ],
            ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildClinicCard(Clinic clinic) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              clinic.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(clinic.fullAddress),
            const SizedBox(height: 4),
            Text('Tel: ${clinic.formattedContact}'),
            if (clinic.operatingHours != null) ...[
              const SizedBox(height: 4),
              Text(clinic.operatingHours!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceInputArea({
    required bool isListening,
    required bool isSpeaking,
    required String currentTranscript,
  }) {
    final lang = widget.user.preferredLanguage;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Current transcript
          if (isListening && currentTranscript.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(currentTranscript),
            ),

          // Status indicator
          if (isSpeaking)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    lang == 'ms' ? 'Bercakap...' : 'Speaking...',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          // Microphone button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSpeaking)
                ElevatedButton.icon(
                  onPressed: () => _voiceService.stopSpeaking(),
                  icon: const Icon(Icons.stop),
                  label: Text(lang == 'ms' ? 'Henti' : 'Stop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  if (isListening) {
                    _voiceService.stopListening();
                  } else {
                    _voiceService.startListening(
                      onResult: _handleUserInput,
                    );
                  }
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isListening ? Colors.red : Theme.of(context).colorScheme.primary,
                    boxShadow: [
                      BoxShadow(
                        color: (isListening ? Colors.red : Theme.of(context).colorScheme.primary)
                            .withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: isListening ? 10 : 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    isListening ? Icons.mic : Icons.mic_none,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isListening
                ? (lang == 'ms' ? 'Sedang mendengar...' : 'Listening...')
                : (lang == 'ms' ? 'Tekan untuk bercakap' : 'Tap to speak'),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
