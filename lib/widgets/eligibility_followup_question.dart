// FILE: lib/widgets/eligibility_followup_question.dart

import 'package:flutter/material.dart';
import '../models/eligibility.dart';

/// Widget for asking follow-up questions via voice or text
class EligibilityFollowUpQuestion extends StatefulWidget {
  final FollowUpQuestion question;
  final String language;
  final Function(String answer) onAnswer;
  final VoidCallback? onSkip;

  const EligibilityFollowUpQuestion({
    super.key,
    required this.question,
    required this.language,
    required this.onAnswer,
    this.onSkip,
  });

  @override
  State<EligibilityFollowUpQuestion> createState() =>
      _EligibilityFollowUpQuestionState();
}

class _EligibilityFollowUpQuestionState
    extends State<EligibilityFollowUpQuestion> {
  final TextEditingController _controller = TextEditingController();
  bool _isListening = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questionText = widget.language == 'ms'
        ? widget.question.questionMs
        : widget.question.question;
    final hintText = widget.language == 'ms'
        ? widget.question.hintMs
        : widget.question.hint;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question icon and text
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.help_outline,
                    color: Colors.purple.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        questionText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (hintText != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          hintText,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Input method based on question type
            if (widget.question.type == 'yes_no')
              _buildYesNoButtons()
            else if (widget.question.type == 'number')
              _buildNumberInput()
            else
              _buildTextInput(),

            const SizedBox(height: 12),

            // Voice input button
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isListening = true;
                      });
                      // Trigger voice listening
                      // This would integrate with VoiceServiceEnhanced
                    },
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: _isListening ? Colors.red : null,
                    ),
                    label: Text(
                      widget.language == 'ms'
                          ? (_isListening ? 'Mendengar...' : 'Jawab dengan Suara')
                          : (_isListening ? 'Listening...' : 'Answer by Voice'),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (widget.onSkip != null) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: widget.onSkip,
                    child: Text(widget.language == 'ms' ? 'Langkau' : 'Skip'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYesNoButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => widget.onAnswer(
              widget.language == 'ms' ? 'ya' : 'yes',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              widget.language == 'ms' ? 'Ya' : 'Yes',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => widget.onAnswer(
              widget.language == 'ms' ? 'tidak' : 'no',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              widget.language == 'ms' ? 'Tidak' : 'No',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: widget.language == 'ms'
                  ? 'Masukkan jumlah (cth: 1500)'
                  : 'Enter amount (e.g., 1500)',
              border: const OutlineInputBorder(),
              prefixText: 'RM ',
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              widget.onAnswer(_controller.text);
            }
          },
          child: const Icon(Icons.check),
        ),
      ],
    );
  }

  Widget _buildTextInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: widget.language == 'ms'
                  ? 'Taip jawapan anda'
                  : 'Type your answer',
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              widget.onAnswer(_controller.text);
            }
          },
          child: const Icon(Icons.check),
        ),
      ],
    );
  }
}
