import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../widgets/chat_message_bubble.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'landing_screen.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../widgets/chat_history_drawer.dart';
import '../widgets/chat_input_row.dart';

class ChatPage extends StatefulWidget {
  final String sessionId;
  const ChatPage({super.key, required this.sessionId});

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  final _messages = <ChatMessage>[];
  final _controller = TextEditingController();
  bool _isTyping = false;

  // Speech to text variables
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _loadSessionMessages();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      _controller.text = _lastWords;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });
  }

  Future<void> _loadSessionMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('chatHistory') ?? [];
    final session = history
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .firstWhere(
          (s) => s['sessionId'] == widget.sessionId,
          orElse: () => {},
        );
    if (session.isNotEmpty && session['messages'] != null) {
      setState(() {
        _messages.clear();
        _messages.addAll(
          (session['messages'] as List).map(
            (m) => ChatMessage.fromJson(Map<String, dynamic>.from(m)),
          ),
        );
      });
    }
  }

  Future<void> _saveSessionMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('chatHistory') ?? [];
    // Remove any previous session with this sessionId
    final filtered = history.where((e) {
      final s = jsonDecode(e) as Map<String, dynamic>;
      return s['sessionId'] != widget.sessionId;
    }).toList();
    final sessionData = {
      'sessionId': widget.sessionId,
      'messages': _messages.map((m) => m.toJson()).toList(),
    };
    filtered.add(jsonEncode(sessionData));
    await prefs.setStringList('chatHistory', filtered);
  }

  Future<void> sendMessage(String message) async {
    setState(() {
      _messages.insert(0, ChatMessage(text: message, isUser: true));
      _isTyping = true;
    });
    await _saveSessionMessages();
    try {
      final reply = await ChatService.sendMessage(message, widget.sessionId);
      setState(() {
        _messages.insert(0, ChatMessage(text: reply, isUser: false));
        _isTyping = false;
      });
      await _saveSessionMessages();
    } catch (e) {
      setState(() {
        _messages.insert(0, ChatMessage(text: 'Error: $e', isUser: false));
        _isTyping = false;
      });
      await _saveSessionMessages();
    }
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: ChatHistoryDrawer(
        currentSessionId: widget.sessionId,
        onSessionSelected: (sessionId) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => ChatPage(sessionId: sessionId)),
          );
        },
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: const Text(
            'My Agent',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.add_comment, color: Colors.white),
              tooltip: 'New Chat',
              onPressed: () async {
                await _saveSessionMessages();
                final newSessionId = const Uuid().v4();
                if (!context.mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatPage(sessionId: newSessionId),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: 'Logout',
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LandingScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
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
        child: SafeArea(
          child: Center(
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                width: 500,
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.all(8),
                        itemCount: _messages.length + (_isTyping ? 1 : 0),
                        itemBuilder: (_, index) {
                          if (_isTyping && index == 0) {
                            return ChatMessageBubble(
                              message: ChatMessage(text: '', isUser: false),
                              isTyping: true,
                            );
                          }
                          final msgIndex = index - (_isTyping ? 1 : 0);
                          return ChatMessageBubble(
                            message: _messages[msgIndex],
                          );
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    ChatInputRow(
                      controller: _controller,
                      speechEnabled: _speechEnabled,
                      isListening: _speechToText.isListening,
                      onMicPressed: () {
                        if (_speechToText.isNotListening) {
                          _startListening();
                        } else {
                          _stopListening();
                        }
                      },
                      onSendPressed: () {
                        final text = _controller.text.trim();
                        if (text.isNotEmpty) {
                          _controller.clear();
                          sendMessage(text);
                        }
                      },
                      onSubmitted: sendMessage,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
