import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  static Future<String> sendMessage(String message, String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final webhookUrl = prefs.getString('webhookUrl') ?? '';
    final username = prefs.getString('username') ?? '';
    final password = prefs.getString('password') ?? '';
    final basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';
    final response = await http.post(
      Uri.parse(webhookUrl),
      headers: {'Content-Type': 'application/json', 'Authorization': basicAuth},
      body: jsonEncode({'message': message, 'sessionId': sessionId}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['output'] ?? 'No reply';
    } else {
      throw Exception('Failed to get response');
    }
  }
}
