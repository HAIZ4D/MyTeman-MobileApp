// FILE: lib/screens/eligibility_voice_check_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/eligibility.dart';
import '../services/eligibility_service.dart';
import '../services/eligibility_audit_service.dart';
import '../services/my_digital_id_service.dart';
import '../services/voice_service_enhanced.dart';
import '../providers/voice_clinic_providers.dart';
import '../widgets/eligibility_consent_modal.dart';
import '../widgets/eligibility_followup_question.dart';
import 'eligibility_loading_screen.dart';
import 'eligibility_result_screen.dart';

/// Voice-First Peka B40 Eligibility Check Screen
///
/// Flow:
/// 1. Welcome & explain process (TTS)
/// 2. Request MyDigitalID consent
/// 3. Authenticate with biometric
/// 4. Auto-check eligibility from MyDigitalID
/// 5. Ask follow-up questions if needed
/// 6. Show result
class EligibilityVoiceCheckScreen extends ConsumerStatefulWidget {
  final User user;

  const EligibilityVoiceCheckScreen({super.key, required this.user});

  @override
  ConsumerState<EligibilityVoiceCheckScreen> createState() =>
      _EligibilityVoiceCheckScreenState();
}

class _EligibilityVoiceCheckScreenState
    extends ConsumerState<EligibilityVoiceCheckScreen> {
  final EligibilityService _eligibilityService = EligibilityService();
  final EligibilityAuditService _auditService = EligibilityAuditService();
  late final MyDigitalIDService _myDigitalIDService;
  VoiceServiceEnhanced? _voiceService;

  bool _consentGiven = false;
  bool _isChecking = false;
  bool _flowStarted = false;
  EligibilityResult? _result;
  final List<FollowUpQuestion> _pendingQuestions = [];
  int _currentQuestionIndex = 0;
  final Map<String, dynamic> _answers = {};
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _myDigitalIDService = MyDigitalIDService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_flowStarted) {
      _flowStarted = true;
      _voiceService = ref.read(voiceServiceProvider);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeAndStartFlow();
      });
    }
  }

  Future<void> _initializeAndStartFlow() async {
    if (_voiceService == null) return;

    final lang = widget.user.preferredLanguage;
    final languageCode = lang == 'ms' ? 'ms-MY' : 'en-US';

    // Initialize voice service first
    final initialized = await _voiceService!.initialize(language: languageCode);

    if (!initialized) {
      print('Voice service failed to initialize');
      // Continue without voice
    }

    // Start the flow
    await _startFlow();
  }

  Future<void> _startFlow() async {
    if (_voiceService == null || !mounted) return;

    final lang = widget.user.preferredLanguage;

    // Welcome message
    final welcomeMsg = lang == 'ms'
        ? 'Selamat datang ke semakan kelayakan Peka B40. Saya akan semak kelayakan anda menggunakan maklumat MyDigitalID.'
        : 'Welcome to Peka B40 eligibility check. I will check your eligibility using MyDigitalID information.';

    _addMessage(welcomeMsg, isUser: false);

    // Show consent modal immediately after welcome message
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _showConsentModal();

    // Speak welcome and consent message in background while modal is visible
    _voiceService!.speakAndWait(welcomeMsg).then((_) async {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 500));

      final consentMsg = lang == 'ms'
          ? 'Saya perlukan kebenaran untuk akses maklumat MyDigitalID anda. Sila klik butang untuk bersetuju.'
          : 'I need permission to access your MyDigitalID information. Please click the button to consent.';

      if (!mounted) return;
      _addMessage(consentMsg, isUser: false);
      await _voiceService!.speakAndWait(consentMsg);
    });
  }

  void _showConsentModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EligibilityConsentModal(
        language: widget.user.preferredLanguage,
        fields: const [
          'citizenship',
          'age',
          'household_income',
          'existing_aids',
        ],
        onConsent: () {
          Navigator.pop(context);
          _handleConsentGiven();
        },
        onDecline: () {
          Navigator.pop(context);
          _handleConsentDeclined();
        },
      ),
    );
  }

  Future<void> _handleConsentGiven() async {
    if (_voiceService == null) return;

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

    // Speak auth message and show biometric prompt in parallel
    _voiceService!.speakAndWait(authMsg);

    final authenticated = await _myDigitalIDService.authenticateBiometric(
      reason: lang == 'ms'
          ? 'Sahkan identiti untuk semakan kelayakan Peka B40'
          : 'Authenticate for Peka B40 eligibility check',
    );

    if (!authenticated) {
      final errorMsg = lang == 'ms'
          ? 'Pengesahan gagal. Sila cuba lagi.'
          : 'Authentication failed. Please try again.';
      _addMessage(errorMsg, isUser: false);
      await _voiceService!.speakAndWait(errorMsg);
      return;
    }

    // Record consent (don't await - run in background)
    _auditService.recordConsent(
      uid: widget.user.uid,
      service: 'peka_b40',
      consentMethod: 'biometric',
      fieldsAccessed: const [
        'citizenship',
        'age',
        'household_income',
        'existing_aids',
      ],
      granted: true,
    );

    // Check eligibility immediately
    await _checkEligibility();
  }

  Future<void> _handleConsentDeclined() async {
    if (_voiceService == null) return;

    final lang = widget.user.preferredLanguage;

    final declineMsg = lang == 'ms'
        ? 'Anda telah menolak kebenaran. Semakan kelayakan tidak dapat diteruskan.'
        : 'You have declined consent. Eligibility check cannot proceed.';

    _addMessage(declineMsg, isUser: false);
    await _voiceService!.speakAndWait(declineMsg);

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _checkEligibility() async {
    if (_voiceService == null) return;

    final lang = widget.user.preferredLanguage;

    setState(() {
      _isChecking = true;
    });

    final checkingMsg = lang == 'ms'
        ? 'Menyemak...'
        : 'Checking...';
    _addMessage(checkingMsg, isUser: false);

    // Speak checking message without waiting (in background)
    _voiceService!.speakAndWait(checkingMsg);

    try {
      final result = await _eligibilityService.checkPekaB40Eligibility(
        widget.user,
        additionalAnswers: _answers,
      );

      setState(() {
        _result = result;
        _isChecking = false;
      });

      // Record audit in background (don't await)
      _auditService.recordEligibilityAudit(
        widget.user.uid,
        'peka_b40',
        'biometric',
        const [
          'citizenship',
          'age',
          'household_income',
          'existing_aids',
        ],
        result,
      );

      // Handle result
      if (result.status == 'pending') {
        // Need follow-up questions
        final questions = _eligibilityService.getFollowUpQuestions(
          result,
          lang,
        );
        setState(() {
          _pendingQuestions.addAll(questions);
        });

        final pendingMsg = lang == 'ms'
            ? 'Saya perlukan beberapa maklumat tambahan.'
            : 'I need some additional information.';
        _addMessage(pendingMsg, isUser: false);
        await _voiceService!.speakAndWait(pendingMsg);
      } else {
        // Show final result
        await _announceResult(result);
      }
    } catch (e) {
      setState(() {
        _isChecking = false;
      });

      final errorMsg = lang == 'ms'
          ? 'Ralat: $e'
          : 'Error: $e';
      _addMessage(errorMsg, isUser: false);
      await _voiceService!.speakAndWait(errorMsg);
    }
  }

  Future<void> _announceResult(EligibilityResult result) async {
    if (_voiceService == null || !mounted) return;

    final lang = widget.user.preferredLanguage;

    // Short announcement message
    String resultMsg;
    if (result.eligible) {
      resultMsg = lang == 'ms'
          ? 'Ya, anda layak.'
          : 'Yes, you are eligible.';
    } else {
      resultMsg = lang == 'ms'
          ? 'Maaf, anda tidak layak.'
          : 'Sorry, you are not eligible.';
    }

    // Add message to UI and speak it
    _addMessage(resultMsg, isUser: false);
    await _voiceService!.speakAndWait(resultMsg);

    // Wait a moment before navigating
    await Future.delayed(const Duration(milliseconds: 500));

    // Navigate to loading screen
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EligibilityLoadingScreen(
          language: lang,
          result: result,
          user: widget.user,
        ),
      ),
    );
  }

  void _handleFollowUpAnswer(String answer) async {
    if (_voiceService == null) return;

    final currentQuestion = _pendingQuestions[_currentQuestionIndex];
    final lang = widget.user.preferredLanguage;

    // Parse answer
    final parsedAnswer = _eligibilityService.parseAnswer(
      currentQuestion.field,
      currentQuestion.type,
      answer,
    );

    setState(() {
      _answers[currentQuestion.field] = parsedAnswer;
    });

    _addMessage(answer, isUser: true);

    // Confirm answer
    final confirmMsg = lang == 'ms'
        ? 'Saya terima: $answer. Terima kasih.'
        : 'I heard: $answer. Thank you.';
    _addMessage(confirmMsg, isUser: false);
    await _voiceService!.speakAndWait(confirmMsg);

    // Move to next question or re-check
    if (_currentQuestionIndex < _pendingQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      // Re-check eligibility with answers
      await _checkEligibility();
    }
  }

  void _addMessage(String text, {required bool isUser}) {
    if (!mounted) return;
    setState(() {
      _messages.add({
        'text': text,
        'isUser': isUser,
        'timestamp': DateTime.now(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.user.preferredLanguage;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          lang == 'ms'
              ? 'Semakan Kelayakan Peka B40'
              : 'Peka B40 Eligibility Check',
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length +
                  (_pendingQuestions.isNotEmpty &&
                          _result?.status == 'pending'
                      ? 1
                      : 0),
              itemBuilder: (context, index) {
                if (index < _messages.length) {
                  final message = _messages[index];
                  return _MessageBubble(
                    text: message['text'],
                    isUser: message['isUser'],
                  );
                } else {
                  // Show follow-up question
                  return EligibilityFollowUpQuestion(
                    question: _pendingQuestions[_currentQuestionIndex],
                    language: lang,
                    onAnswer: _handleFollowUpAnswer,
                  );
                }
              },
            ),
          ),

          // Loading indicator
          if (_isChecking)
            Container(
              padding: const EdgeInsets.all(16),
              child: const CircularProgressIndicator(),
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
        decoration: BoxDecoration(
          color: isUser ? Colors.blue.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(text),
      ),
    );
  }
}
