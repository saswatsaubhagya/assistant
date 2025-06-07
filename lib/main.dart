import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/chat_page.dart';
import 'screens/landing_screen.dart';
import 'screens/new_chat_screen.dart';

void main() => runApp(const ChatApp());

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  Future<bool> _hasCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('webhookUrl') &&
        prefs.containsKey('username') &&
        prefs.containsKey('password');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Agent',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
      ),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: _hasCredentials(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return snapshot.data! ? const NewChatScreen() : const LandingScreen();
        },
      ),
    );
  }
}
