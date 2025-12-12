// FILE: lib/services/voice_service_enhanced.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

/// Enhanced Voice Service for conversational clinic search
/// Handles STT/TTS with intent recognition
class VoiceServiceEnhanced {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isInitialized = false;
  bool _isListening = false;
  bool _isSpeaking = false;

  String _currentLanguage = 'ms-MY';
  Function(String)? onTranscript;
  Function(bool)? onListeningStateChange;
  Function(bool)? onSpeakingStateChange;

  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  bool get isInitialized => _isInitialized;

  /// Initialize voice service
  Future<bool> initialize({String language = 'ms-MY'}) async {
    if (_isInitialized) return true;

    try {
      // Initialize Speech-to-Text
      final available = await _speech.initialize(
        onError: (error) => debugPrint('Speech error: $error'),
        onStatus: (status) => debugPrint('Speech status: $status'),
      );

      if (!available) {
        debugPrint('Speech recognition not available');
        return false;
      }

      // Initialize Text-to-Speech
      await _tts.setLanguage(language);
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      // Set TTS callbacks
      _tts.setStartHandler(() {
        _isSpeaking = true;
        onSpeakingStateChange?.call(true);
      });

      _tts.setCompletionHandler(() {
        _isSpeaking = false;
        onSpeakingStateChange?.call(false);
      });

      _tts.setErrorHandler((msg) {
        debugPrint('TTS error: $msg');
        _isSpeaking = false;
        onSpeakingStateChange?.call(false);
      });

      _currentLanguage = language;
      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('Voice service initialization error: $e');
      return false;
    }
  }

  /// Start listening to user speech
  Future<void> startListening({
    required Function(String) onResult,
    Duration? listenFor,
    Duration? pauseFor,
  }) async {
    if (!_isInitialized || _isListening) return;

    if (_isSpeaking) {
      await stopSpeaking();
    }

    _isListening = true;
    onListeningStateChange?.call(true);

    await _speech.listen(
      onResult: (result) {
        if (result.recognizedWords.isNotEmpty) {
          onTranscript?.call(result.recognizedWords);

          if (result.finalResult) {
            onResult(result.recognizedWords);
            stopListening();
          }
        }
      },
      listenFor: listenFor ?? const Duration(seconds: 30),
      pauseFor: pauseFor ?? const Duration(seconds: 3),
      localeId: _currentLanguage,
    );
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (!_isListening) return;

    await _speech.stop();
    _isListening = false;
    onListeningStateChange?.call(false);
  }

  /// Speak text using TTS (doesn't wait for completion)
  Future<void> speak(String text) async {
    if (!_isInitialized) return;

    if (_isSpeaking) {
      await _tts.stop();
    }

    await _tts.speak(text);
  }

  /// Speak text and wait for completion
  Future<void> speakAndWait(String text) async {
    if (!_isInitialized) return;

    if (_isSpeaking) {
      await _tts.stop();
      await Future.delayed(const Duration(milliseconds: 100));
    }

    final completer = Completer<void>();

    // Set temporary completion handler
    void completionHandler() {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }

    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      onSpeakingStateChange?.call(false);
      completionHandler();
    });

    await _tts.speak(text);

    // Wait for completion or timeout after 30 seconds
    await completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        debugPrint('TTS timeout for text: $text');
      },
    );

    // Add small delay for natural pacing
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Stop speaking
  Future<void> stopSpeaking() async {
    if (_isSpeaking) {
      await _tts.stop();
      _isSpeaking = false;
      onSpeakingStateChange?.call(false);
    }
  }

  /// Change language
  Future<void> setLanguage(String language) async {
    _currentLanguage = language;
    await _tts.setLanguage(language);
  }

  /// Extract location/area from transcript
  Map<String, String?> extractLocation(String transcript) {
    final t = transcript.toLowerCase();

    // State patterns
    final statePatterns = {
      'melaka': ['melaka', 'malacca', 'semabok'],
      'johor': ['johor', 'muar', 'batu pahat'],
      'negeri sembilan': ['negeri sembilan', 'n9', 'port dickson', 'pd', 'seremban'],
      'selangor': ['selangor', 'shah alam', 'petaling jaya', 'pj'],
      'kuala lumpur': ['kuala lumpur', 'kl', 'klang'],
    };

    // City/area patterns
    final cityPatterns = {
      'semabok': 'melaka',
      'taman sinn': 'melaka',
      'muar': 'johor',
      'port dickson': 'negeri sembilan',
      'taman ria': 'negeri sembilan',
    };

    String? detectedState;
    String? detectedCity;

    // Check for state mentions
    for (final entry in statePatterns.entries) {
      for (final pattern in entry.value) {
        if (t.contains(pattern)) {
          detectedState = entry.key;
          break;
        }
      }
      if (detectedState != null) break;
    }

    // Check for city mentions
    for (final entry in cityPatterns.entries) {
      if (t.contains(entry.key)) {
        detectedCity = entry.key;
        detectedState ??= entry.value;
        break;
      }
    }

    return {
      'state': detectedState,
      'city': detectedCity,
    };
  }

  /// Detect user intent from transcript
  String detectIntent(String transcript) {
    final t = transcript.toLowerCase();

    // Direction/Navigation intent - Added "arah" and more Malay variations
    if (RegExp(r'direction|navigate|go there|tunjuk jalan|pergi sana|navigasi|map|arah|tunjukkan arah|tunjuk arah|directions|petunjuk').hasMatch(t)) {
      return 'direction';
    }

    // Book appointment intent - Added more variations with flexible spacing
    if (RegExp(r'book|appointment|temu\s*janji|buat\s+temu\s*janji|tempah|buat\s+booking|booking|janji').hasMatch(t)) {
      return 'book_appointment';
    }

    // Call clinic intent - Added more variations
    if (RegExp(r'call|phone|hubungi|telefon|panggil|hubungi klinik|call clinic').hasMatch(t)) {
      return 'call_clinic';
    }

    // Search clinic intent
    if (RegExp(r'find|search|cari|klinik|clinic').hasMatch(t)) {
      return 'search_clinic';
    }

    // Done/Exit intent - User wants to finish
    if (RegExp(r'done|finish|selesai|sudah|cukup|tidak|no thanks|tidak ada|taknak').hasMatch(t)) {
      return 'done';
    }

    return 'unknown';
  }

  /// Dispose resources
  void dispose() {
    _speech.stop();
    _tts.stop();
    _isInitialized = false;
  }
}
