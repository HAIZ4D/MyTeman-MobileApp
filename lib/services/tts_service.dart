import 'package:flutter_tts/flutter_tts.dart';

/// Text-to-Speech service for voice accessibility
class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  /// Initialize TTS with default settings
  Future<void> initialize({String language = 'en-US'}) async {
    if (_isInitialized) return;

    await _flutterTts.setLanguage(language);
    await _flutterTts.setSpeechRate(0.5); // Normal speed
    await _flutterTts.setVolume(1.0); // Max volume
    await _flutterTts.setPitch(1.0); // Normal pitch

    // Set language-specific settings
    if (language.startsWith('ms')) {
      await _flutterTts.setLanguage('ms-MY'); // Malay
    } else {
      await _flutterTts.setLanguage('en-US'); // English
    }

    _isInitialized = true;
  }

  /// Speak text
  Future<void> speak(String text, {String? language}) async {
    if (!_isInitialized) {
      await initialize(language: language ?? 'en-US');
    }

    // Change language if specified
    if (language != null) {
      if (language == 'ms') {
        await _flutterTts.setLanguage('ms-MY');
      } else {
        await _flutterTts.setLanguage('en-US');
      }
    }

    await _flutterTts.speak(text);
  }

  /// Stop speaking
  Future<void> stop() async {
    await _flutterTts.stop();
  }

  /// Pause speaking
  Future<void> pause() async {
    await _flutterTts.pause();
  }

  /// Get available voices
  Future<List<dynamic>> getVoices() async {
    return await _flutterTts.getVoices ?? [];
  }

  /// Check if speaking
  Future<bool> get isSpeaking async {
    final status = await _flutterTts.awaitSpeakCompletion(true);
    return status == 1;
  }

  /// Set speech rate (0.0 - 1.0)
  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate);
  }

  /// Set volume (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    await _flutterTts.setVolume(volume);
  }

  /// Set pitch (0.5 - 2.0)
  Future<void> setPitch(double pitch) async {
    await _flutterTts.setPitch(pitch);
  }

  /// Dispose TTS resources
  void dispose() {
    _flutterTts.stop();
  }
}
