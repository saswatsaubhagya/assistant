import 'package:flutter/material.dart';
import 'chat_page.dart';
import 'package:uuid/uuid.dart';

class NewChatScreen extends StatelessWidget {
  const NewChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8E2DE2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
            ),
            onPressed: () {
              final sessionId = const Uuid().v4();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatPage(sessionId: sessionId),
                ),
              );
            },
            child: const Text(
              'New Chat',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
