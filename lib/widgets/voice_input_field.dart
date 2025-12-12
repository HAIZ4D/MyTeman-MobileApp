import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/tts_service.dart';
import '../utils/haptic_feedback.dart';

/// Voice input field widget with STT support
class VoiceInputField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final String language;
  final Function(String)? onChanged;
  final bool enabled;
  final int? maxLines;
  final TextInputType? keyboardType;

  const VoiceInputField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.language = 'en',
    this.onChanged,
    this.enabled = true,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  State<VoiceInputField> createState() => _VoiceInputFieldState();
}

class _VoiceInputFieldState extends State<VoiceInputField> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final TtsService _tts = TtsService();
  bool _isListening = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (error) {
        setState(() => _isListening = false);
        HapticHelper.error();
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
    );
    setState(() {});
  }

  Future<void> _startListening() async {
    if (!_speechAvailable) return;

    await HapticHelper.selection();

    // Announce that listening has started
    final announcement = widget.language == 'ms'
        ? 'Sedang mendengar'
        : 'Listening';
    await _tts.speak(announcement, language: widget.language);

    await _speech.listen(
      onResult: (result) {
        setState(() {
          widget.controller.text = result.recognizedWords;
          widget.onChanged?.call(result.recognizedWords);
        });
      },
      localeId: widget.language == 'ms' ? 'ms_MY' : 'en_US',
    );

    setState(() => _isListening = true);
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    await HapticHelper.success();
    setState(() => _isListening = false);
  }

  Future<void> _speakLabel() async {
    final text = widget.hint ?? widget.label;
    await _tts.speak(text, language: widget.language);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        border: const OutlineInputBorder(),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TTS button - reads the label/hint
            IconButton(
              icon: const Icon(Icons.volume_up, size: 20),
              onPressed: widget.enabled ? _speakLabel : null,
              tooltip: widget.language == 'ms'
                  ? 'Dengar arahan'
                  : 'Hear instructions',
              color: Theme.of(context).colorScheme.primary,
            ),
            // Voice input button
            if (_speechAvailable)
              IconButton(
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  size: 24,
                ),
                onPressed: widget.enabled
                    ? (_isListening ? _stopListening : _startListening)
                    : null,
                tooltip: widget.language == 'ms'
                    ? (_isListening ? 'Berhenti' : 'Gunakan suara')
                    : (_isListening ? 'Stop' : 'Use voice'),
                color: _isListening
                    ? Colors.red
                    : Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
      onChanged: widget.onChanged,
    );
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }
}
