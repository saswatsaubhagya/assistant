import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isTyping;
  const ChatMessageBubble({
    super.key,
    required this.message,
    this.isTyping = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: message.isUser
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!message.isUser)
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 4.0),
            child: CircleAvatar(
              backgroundColor: Colors.deepPurple.shade100,
              child: const Icon(Icons.smart_toy, color: Colors.deepPurple),
            ),
          ),
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: message.isUser ? const Color(0xFF8E2DE2) : Colors.white,
              gradient: message.isUser
                  ? const LinearGradient(
                      colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(message.isUser ? 18 : 4),
                bottomRight: Radius.circular(message.isUser ? 4 : 18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: isTyping
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [_TypingIndicator()],
                  )
                : Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
        if (message.isUser)
          Padding(
            padding: const EdgeInsets.only(right: 8.0, left: 4.0),
            child: CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
      ],
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _dot1, _dot2, _dot3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _dot1 = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeInOut),
      ),
    );
    _dot2 = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.5, curve: Curves.easeInOut),
      ),
    );
    _dot3 = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.7, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => Transform.translate(
              offset: Offset(0, _dot1.value),
              child: _dot(),
            ),
          ),
          const SizedBox(width: 4),
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => Transform.translate(
              offset: Offset(0, _dot2.value),
              child: _dot(),
            ),
          ),
          const SizedBox(width: 4),
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => Transform.translate(
              offset: Offset(0, _dot3.value),
              child: _dot(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot() => Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(color: Colors.deepPurple, shape: BoxShape.circle),
  );
}
