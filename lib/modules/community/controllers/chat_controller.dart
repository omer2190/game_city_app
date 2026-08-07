import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../data/repositories/chat_repository.dart';

const _kDbBase =
    'https://gaming-city-94354-default-rtdb.europe-west1.firebasedatabase.app';

/// Group chat room controller - uses Firebase REST API (all platforms).
class ChatController extends GetxController {
  final String roomId;
  ChatController({required this.roomId});

  final ChatRepository _chatRepository = ChatRepository();
  final http.Client _http = http.Client();
  final _messages = <Map<String, dynamic>>[].obs;

  List<Map<String, dynamic>> get messages => _messages;

  Timer? _pollTimer;

  @override
  void onInit() {
    super.onInit();
    _fetchMessages();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _fetchMessages(),
    );
  }

  Future<String?> _getIdToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) return await user.getIdToken();
    } catch (_) {}
    return null;
  }

  Future<void> _fetchMessages() async {
    try {
      final token = await _getIdToken();
      final uri = Uri.parse(
        '$_kDbBase/chats/group_$roomId/messages.json'
        '${token != null ? '?auth=$token' : ''}',
      );
      final res = await _http.get(uri);
      if (res.statusCode != 200) return;

      final dynamic body = jsonDecode(res.body);
      if (body == null || body is! Map) {
        _messages.clear();
        return;
      }

      final data = body as Map<String, dynamic>;
      final loaded = <Map<String, dynamic>>[];
      data.forEach((key, value) {
        if (value is Map) {
          final msg = Map<String, dynamic>.from(value);
          msg['id'] = key.toString();
          loaded.add(msg);
        }
      });
      loaded.sort((a, b) {
        final timeA = int.tryParse(a['createdAt']?.toString() ?? '0') ?? 0;
        final timeB = int.tryParse(b['createdAt']?.toString() ?? '0') ?? 0;
        return timeA.compareTo(timeB);
      });
      final last50 = loaded.length > 50
          ? loaded.sublist(loaded.length - 50)
          : loaded;
      _messages.assignAll(last50);
    } catch (e) {
      debugPrint('Group chat REST fetch error: $e');
    }
  }

  Future<void> updateMessage(String messageId, String newContent) async {
    try {
      final token = await _getIdToken();
      final uri = Uri.parse(
        '$_kDbBase/chats/group_$roomId/messages/$messageId.json'
        '${token != null ? '?auth=$token' : ''}',
      );
      await _http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': newContent, 'isEdited': true}),
      );
    } catch (e) {
      debugPrint('Failed to update message: $e');
      rethrow;
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      final token = await _getIdToken();
      final uri = Uri.parse(
        '$_kDbBase/chats/group_$roomId/messages/$messageId.json'
        '${token != null ? '?auth=$token' : ''}',
      );
      await _http.delete(uri);
    } catch (e) {
      debugPrint('Failed to delete message: $e');
      rethrow;
    }
  }

  Future<void> sendMessage(String content) async {
    try {
      await _chatRepository.sendRoomMessage(roomId, content);
    } catch (e) {
      debugPrint('Failed to send room message: $e');
      rethrow;
    }
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    _http.close();
    super.onClose();
  }
}
