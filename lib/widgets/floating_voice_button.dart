import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../services/tts_service.dart';
import '../utils/haptic_feedback.dart';

/// Floating voice button for global voice commands
class FloatingVoiceButton extends StatefulWidget {
  final String language;
  final Function(String) onCommand;

  const FloatingVoiceButton({
    super.key,
    required this.language,
    required this.onCommand,
  });

  @override
  State<FloatingVoiceButton> createState() => _FloatingVoiceButtonState();
}

class _FloatingVoiceButtonState extends State<FloatingVoiceButton>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final TtsService _tts = TtsService();
  bool _isListening = false;
  bool _speechAvailable = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeSpeech() async {
    try {
      // Request microphone permission
      final status = await Permission.microphone.request();
      debugPrint('FloatingVoiceButton - Microphone permission: $status');

      if (status.isGranted) {
        _speechAvailable = await _speech.initialize(
          onError: (error) {
            debugPrint('FloatingVoiceButton - Speech error: $error');
            setState(() => _isListening = false);
            HapticHelper.error();
          },
          onStatus: (status) {
            debugPrint('FloatingVoiceButton - Speech status: $status');
            if (status == 'done' || status == 'notListening') {
              setState(() => _isListening = false);
            }
          },
        );
        debugPrint('FloatingVoiceButton - Speech initialized: $_speechAvailable');
      } else {
        debugPrint('FloatingVoiceButton - Microphone permission denied');
        _speechAvailable = false;
      }
      setState(() {});
    } catch (e) {
      debugPrint('FloatingVoiceButton - Initialization error: $e');
      // Even if initialization fails, show the button for debugging
      setState(() {
        _speechAvailable = true; // Allow button to show for debugging
      });
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    if (!_speechAvailable) {
      _showError();
      return;
    }

    await HapticHelper.heavy();

    // Short and clear audio feedback
    final announcement = widget.language == 'ms'
        ? 'Mendengar'
        : 'Hearing';
    await _tts.speak(announcement, language: widget.language);

    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          final command = result.recognizedWords;
          widget.onCommand(command);
          _stopListening();
        }
      },
      localeId: widget.language == 'ms' ? 'ms_MY' : 'en_US',
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.confirmation,
      ),
    );

    setState(() => _isListening = true);
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    await HapticHelper.selection();
    setState(() => _isListening = false);
  }

  void _showError() {
    final message = widget.language == 'ms'
        ? 'Pengenalan suara tidak tersedia'
        : 'Speech recognition not available';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Always show the button, even if speech is initializing
    // This ensures visibility for debugging
    return _isListening
        ? AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            child: FloatingActionButton.large(
              onPressed: _toggleListening,
              backgroundColor: Colors.red,
              child: const Icon(Icons.mic, size: 40, color: Colors.white),
            ),
          )
        : FloatingActionButton(
            onPressed: _speechAvailable ? _toggleListening : () {
              _showError();
              HapticHelper.error();
            },
            backgroundColor: _speechAvailable
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
            child: Icon(
              _speechAvailable ? Icons.mic_none : Icons.mic_off,
              color: Colors.white,
            ),
          );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _speech.stop();
    super.dispose();
  }
}
