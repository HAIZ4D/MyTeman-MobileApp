import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../models/user.dart';
import '../models/service.dart';
import '../services/gemini_service.dart';

/// Intelligent Voice Assistant Screen powered by Gemini AI
/// Provides natural, context-aware conversations for government services
class VoiceAssistantScreen extends ConsumerStatefulWidget {
  final User user;
  final Service service;

  const VoiceAssistantScreen({
    super.key,
    required this.user,
    required this.service,
  });

  @override
  ConsumerState<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends ConsumerState<VoiceAssistantScreen> {
  final GeminiService _gemini = GeminiService();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  final List<ChatMessage> _messages = [];
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isSpeaking = false;
  String _currentTranscript = '';
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize Speech-to-Text
      await _speech.initialize(
        onError: (error) => print('Speech error: $error'),
        onStatus: (status) => print('Speech status: $status'),
      );

      // Initialize Text-to-Speech
      await _tts.setLanguage(widget.user.preferredLanguage == 'ms' ? 'ms-MY' : 'en-US');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      // Set TTS callbacks
      _tts.setStartHandler(() {
        setState(() => _isSpeaking = true);
      });
      _tts.setCompletionHandler(() {
        setState(() => _isSpeaking = false);
      });
      _tts.setErrorHandler((msg) {
        setState(() => _isSpeaking = false);
      });

      // Start Gemini conversation
      await _gemini.startConversation(
        service: widget.service,
        user: widget.user,
        language: widget.user.preferredLanguage,
      );

      setState(() => _initialized = true);

      // Send initial greeting
      await _sendInitialGreeting();
    } catch (e) {
      print('Initialization error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing voice assistant: $e')),
        );
      }
    }
  }

  Future<void> _sendInitialGreeting() async {
    final language = widget.user.preferredLanguage;

    final aiResponse = await _gemini.sendMessage(
      language == 'ms' ? 'Mulakan perbualan dengan salam' : 'Start conversation with greeting'
    );

    _addMessage(aiResponse, isUser: false);
    await _speak(aiResponse);
  }

  void _addMessage(String text, {required bool isUser}) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: isUser,
        timestamp: DateTime.now(),
      ));
    });

    // Auto-scroll to bottom
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

  Future<void> _speak(String text) async {
    if (_isSpeaking) {
      await _tts.stop();
    }
    await _tts.speak(text);
  }

  Future<void> _startListening() async {
    if (!_speech.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not available')),
      );
      return;
    }

    if (_isSpeaking) {
      await _tts.stop();
    }

    setState(() {
      _isListening = true;
      _currentTranscript = '';
    });

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _currentTranscript = result.recognizedWords;
        });

        if (result.finalResult) {
          _processUserInput(_currentTranscript);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      localeId: widget.user.preferredLanguage == 'ms' ? 'ms_MY' : 'en_US',
    );
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _processUserInput(String userInput) async {
    if (userInput.trim().isEmpty) return;

    setState(() {
      _isListening = false;
      _isProcessing = true;
    });

    // Add user message
    _addMessage(userInput, isUser: true);

    try {
      // Get AI response from Gemini
      final aiResponse = await _gemini.sendMessage(userInput);

      // Add AI message
      _addMessage(aiResponse, isUser: false);

      // Speak the response
      await _speak(aiResponse);
    } catch (e) {
      final errorMsg = widget.user.preferredLanguage == 'ms'
          ? 'Maaf, terdapat ralat. Sila cuba lagi.'
          : 'Sorry, there was an error. Please try again.';
      _addMessage(errorMsg, isUser: false);
      await _speak(errorMsg);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final language = widget.user.preferredLanguage;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service.getTitle(language)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_gemini.hasActiveConversation)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: language == 'ms' ? 'Mula semula' : 'Restart',
              onPressed: () async {
                setState(() => _messages.clear());
                await _sendInitialGreeting();
              },
            ),
        ],
      ),
      body: !_initialized
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Service info banner
                _buildServiceBanner(),

                // Chat messages
                Expanded(
                  child: _messages.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            return _buildMessageBubble(_messages[index]);
                          },
                        ),
                ),

                // Voice input area
                _buildVoiceInputArea(),
              ],
            ),
    );
  }

  Widget _buildServiceBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getServiceIcon(widget.service.icon),
            size: 32,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.service.getTitle(widget.user.preferredLanguage),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.service.getDescription(widget.user.preferredLanguage),
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final language = widget.user.preferredLanguage;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mic_none,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            language == 'ms'
                ? 'Tekan butang mikrofon untuk bercakap'
                : 'Tap the microphone button to speak',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isUser
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: message.isUser
                    ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)
                    : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceInputArea() {
    final language = widget.user.preferredLanguage;

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
          // Current transcript display
          if (_isListening && _currentTranscript.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _currentTranscript,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontSize: 16,
                ),
              ),
            ),

          // Status indicator
          if (_isProcessing || _isSpeaking)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isProcessing
                        ? (language == 'ms' ? 'Memproses...' : 'Processing...')
                        : (language == 'ms' ? 'Bercakap...' : 'Speaking...'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          // Voice button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Stop speaking button
              if (_isSpeaking)
                ElevatedButton.icon(
                  onPressed: () async {
                    await _tts.stop();
                  },
                  icon: const Icon(Icons.stop),
                  label: Text(language == 'ms' ? 'Henti' : 'Stop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),

              const SizedBox(width: 16),

              // Main microphone button
              GestureDetector(
                onTap: _isListening ? _stopListening : _startListening,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isListening
                        ? Colors.red
                        : Theme.of(context).colorScheme.primary,
                    boxShadow: [
                      BoxShadow(
                        color: (_isListening ? Colors.red : Theme.of(context).colorScheme.primary)
                            .withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: _isListening ? 10 : 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Instruction text
          Text(
            _isListening
                ? (language == 'ms' ? 'Sedang mendengar...' : 'Listening...')
                : (language == 'ms'
                    ? 'Tekan untuk bercakap'
                    : 'Tap to speak'),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getServiceIcon(String? iconName) {
    switch (iconName) {
      case 'local_hospital':
        return Icons.local_hospital;
      case 'verified_user':
        return Icons.verified_user;
      case 'school':
        return Icons.school;
      default:
        return Icons.description;
    }
  }

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  void dispose() {
    _gemini.endConversation();
    _speech.stop();
    _tts.stop();
    _scrollController.dispose();
    super.dispose();
  }
}

/// Chat message model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
