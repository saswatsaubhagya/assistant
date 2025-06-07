import 'package:flutter/material.dart';

class ChatInputRow extends StatelessWidget {
  final TextEditingController controller;
  final bool speechEnabled;
  final bool isListening;
  final VoidCallback onMicPressed;
  final VoidCallback onSendPressed;
  final ValueChanged<String> onSubmitted;

  const ChatInputRow({
    super.key,
    required this.controller,
    required this.speechEnabled,
    required this.isListening,
    required this.onMicPressed,
    required this.onSendPressed,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: onSubmitted,
              minLines: 1,
              maxLines: 5,
              keyboardType: TextInputType.multiline,
              scrollPadding: const EdgeInsets.all(20),
              decoration: const InputDecoration(
                hintText: 'Send a message...',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              isListening ? Icons.mic : Icons.mic_off,
              color: Colors.deepPurple,
            ),
            onPressed: speechEnabled ? onMicPressed : null,
          ),
          const SizedBox(width: 6),
          Material(
            color: const Color(0xFF8E2DE2),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onSendPressed,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.send, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
