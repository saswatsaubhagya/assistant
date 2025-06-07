import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ChatHistoryDrawer extends StatefulWidget {
  final String currentSessionId;
  final void Function(String sessionId) onSessionSelected;
  const ChatHistoryDrawer({
    super.key,
    required this.currentSessionId,
    required this.onSessionSelected,
  });

  @override
  State<ChatHistoryDrawer> createState() => _ChatHistoryDrawerState();
}

class _ChatHistoryDrawerState extends State<ChatHistoryDrawer> {
  late Future<List<Map<String, dynamic>>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = _getAllSessions();
  }

  Future<List<Map<String, dynamic>>> _getAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('chatHistory') ?? [];
    return history.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  Future<void> _deleteSession(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('chatHistory') ?? [];
    final filtered = history.where((e) {
      final s = jsonDecode(e) as Map<String, dynamic>;
      return s['sessionId'] != sessionId;
    }).toList();
    await prefs.setStringList('chatHistory', filtered);
    setState(() {
      _sessionsFuture = _getAllSessions();
    });
  }

  Future<void> _deleteAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chatHistory');
    setState(() {
      _sessionsFuture = _getAllSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _sessionsFuture,
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
                        widget.onSessionSelected(sessionId);
                      },
                      selected: sessionId == widget.currentSessionId,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Delete this session',
                        onPressed: () => _deleteSession(sessionId),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Delete All History'),
                onPressed: _deleteAllSessions,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
