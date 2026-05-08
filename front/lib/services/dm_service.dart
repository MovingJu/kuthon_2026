import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class DmMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime createdAt;

  DmMessage({required this.id, required this.senderId, required this.text, required this.createdAt});

  factory DmMessage.fromJson(Map<String, dynamic> j) => DmMessage(
    id: j['id'] as String,
    senderId: j['sender_id'] as String,
    text: j['text'] as String,
    createdAt: DateTime.parse(j['created_at'] as String).toLocal(),
  );
}

class DmService {
  DmService._();

  static String get _base => dotenv.env['CHAT_BASE_URL'] ?? 'http://10.0.2.2:8001';

  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    return {'Authorization': 'Bearer ${token ?? ''}', 'Content-Type': 'application/json'};
  }

  static Future<List<DmMessage>> fetchMessages(String otherUserId, {DateTime? after}) async {
    final headers = await _headers();
    final query = after != null ? '?after=${Uri.encodeComponent(after.toUtc().toIso8601String())}' : '';
    final res = await http.get(Uri.parse('$_base/chats/$otherUserId/messages$query'), headers: headers);
    if (res.statusCode != 200) return [];
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    return (data['messages'] as List).map((e) => DmMessage.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<DmMessage?> sendMessage(String otherUserId, String text) async {
    final headers = await _headers();
    final res = await http.post(
      Uri.parse('$_base/chats/$otherUserId/messages'),
      headers: headers,
      body: jsonEncode({'text': text}),
    );
    if (res.statusCode != 201) return null;
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    return DmMessage.fromJson(data['message'] as Map<String, dynamic>);
  }

  static Future<List<Map<String, String>>> fetchChatList() async {
    final headers = await _headers();
    final res = await http.get(Uri.parse('$_base/chats'), headers: headers);
    debugPrint('[DmService] GET /chats status=${res.statusCode} body=${res.body}');
    if (res.statusCode != 200) return [];
    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    return (data['chats'] as List).map((e) {
      final m = e as Map<String, dynamic>;
      return {
        'other_user_id': m['other_user_id'] as String,
        'other_user_name': m['other_user_name'] as String,
        'last_message': m['last_message'] as String? ?? '',
        'unread_count': m['unread_count'].toString(),
      };
    }).toList();
  }
}
