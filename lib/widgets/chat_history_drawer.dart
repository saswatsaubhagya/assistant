import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ChatHistoryDrawer extends StatelessWidget {
  final String currentSessionId;
  final void Function(String sessionId) onSessionSelected;
  const ChatHistoryDrawer({
    super.key,
    required this.currentSessionId,
    required this.onSessionSelected,
  });

  Future<List<Map<String, dynamic>>> _getAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('chatHistory') ?? [];
    return history.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getAllSessions(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final sessions = snapshot.data!;
          if (sessions.isEmpty) {
            return const Center(child: Text('No past chats.'));
          }
          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              final sessionId = session['sessionId'] as String;
              final messages = session['messages'] as List;
              final preview = messages.isNotEmpty
                  ? (messages.last['text'] ?? '')
                  : 'No messages';
              return ListTile(
                title: Text('Session ${index + 1}'),
                subtitle: Text(
                  preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.pop(context); // close drawer
                  onSessionSelected(sessionId);
                },
                selected: sessionId == currentSessionId,
              );
            },
          );
        },
      ),
    );
  }
}
