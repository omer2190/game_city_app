import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../data/models/message_model.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../auth/controllers/auth_controller.dart';

/// Firebase Realtime Database REST endpoint.
const _kDbBase =
    'https://gaming-city-94354-default-rtdb.europe-west1.firebasedatabase.app';

// ─────────────────────────────────────────────────────────────────────────────
// ChatController — uses Firebase REST API (works on ALL platforms incl. Windows)
// ─────────────────────────────────────────────────────────────────────────────
class ChatController extends GetxController {
  final ChatRepository _chatRepository = ChatRepository();
  final AuthController _authController = Get.find<AuthController>();
  final http.Client _http = http.Client();

  var messages = <MessageModel>[].obs;
  var isLoading = false.obs;

  String? _currentRoomId;
  Timer? _pollTimer;

  // ── Auth Token ──────────────────────────────────────────────────────────

  Future<String?> _getIdToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final t = await user.getIdToken();
        debugPrint(
          '🔵 Firebase Auth token: ${t != null ? "GOT (len=${t.length})" : "NULL"}',
        );
        return t;
      }
      debugPrint('🔴 Firebase Auth: no currentUser');
    } catch (e) {
      debugPrint('🔴 Firebase Auth token error: $e');
    }
    return null;
  }

  // ── Polling-based "listen" (replaces real-time subscription) ─────────────

  void listenToMessages(String chatRoomId) {
    if (chatRoomId.isEmpty) {
      debugPrint('🔴 ChatController: empty chatRoomId, skipping listen');
      return;
    }

    debugPrint('🟢 ChatController: listening to roomId=$chatRoomId');
    _pollTimer?.cancel();
    _currentRoomId = chatRoomId;
    messages.clear();
    isLoading(true);

    // Immediate first fetch
    _fetchMessages();
    // Then poll every 3 seconds
    _pollTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _fetchMessages(),
    );
  }

  Future<void> _fetchMessages() async {
    if (_currentRoomId == null) return;
    try {
      final token = await _getIdToken();
      final uri = Uri.parse(
        '$_kDbBase/chats/$_currentRoomId/messages.json'
        '${token != null ? '?auth=$token' : ''}',
      );

      debugPrint('🔵 Chat REST: GET $uri');
      final res = await _http.get(uri);
      debugPrint(
        '🔵 Chat REST: status=${res.statusCode} bodyLen=${res.body.length}',
      );

      if (res.statusCode != 200) {
        debugPrint('🔴 Chat REST: non-200 status, body=${res.body}');
        isLoading(false);
        return;
      }

      final dynamic body = jsonDecode(res.body);
      if (body == null || body is! Map) {
        debugPrint('🔴 Chat REST: body is null or not Map, clearing messages');
        messages.clear();
        isLoading(false);
        return;
      }

      final data = body as Map<String, dynamic>;
      debugPrint('🟢 Chat REST: got ${data.length} messages');
      final loaded = <MessageModel>[];
      data.forEach((key, value) {
        if (value is Map) {
          loaded.add(MessageModel.fromMap(key, value));
        }
      });
      loaded.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      final last50 = loaded.length > 50
          ? loaded.sublist(loaded.length - 50)
          : loaded;
      messages.assignAll(last50);
      isLoading(false);

      // Mark messages as read for the current user
      markMessagesAsRead(_currentRoomId!);
    } catch (e) {
      debugPrint('🔴 Chat REST fetch error: $e');
      isLoading(false);
    }
  }

  // ── Send ────────────────────────────────────────────────────────────────

  Future<String?> sendChatMessage(
    String recipientId,
    String content, {
    String type = 'text',
    String? chatRoomId,
  }) async {
    try {
      final response = await _chatRepository.sendMessage(
        recipientId,
        content,
        type: type,
      );

      if (chatRoomId == null || chatRoomId.isEmpty) {
        final newRoomId =
            response['roomId']?.toString() ??
            response['chatRoomId']?.toString() ??
            response['room']?['_id']?.toString();
        if (newRoomId != null && newRoomId.isNotEmpty) {
          listenToMessages(newRoomId);
        }
      }
      return response['roomId']?.toString() ??
          response['chatRoomId']?.toString();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل إرسال الرسالة: $e');
      return null;
    }
  }

  // ── Update message via REST ─────────────────────────────────────────────

  Future<void> updateMessage(
    String chatRoomId,
    String messageId,
    String newContent,
  ) async {
    try {
      final token = await _getIdToken();
      final uri = Uri.parse(
        '$_kDbBase/chats/$chatRoomId/messages/$messageId.json'
        '${token != null ? '?auth=$token' : ''}',
      );
      await _http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': newContent,
          'content': newContent,
          'isEdited': true,
        }),
      );
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تعديل الرسالة: $e');
    }
  }

  // ── Delete message via REST ─────────────────────────────────────────────

  Future<void> deleteMessage(String chatRoomId, String messageId) async {
    try {
      final token = await _getIdToken();
      final uri = Uri.parse(
        '$_kDbBase/chats/$chatRoomId/messages/$messageId.json'
        '${token != null ? '?auth=$token' : ''}',
      );
      await _http.delete(uri);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل حذف الرسالة: $e');
    }
  }

  // ── Mark as read via REST ───────────────────────────────────────────────

  void markMessagesAsRead(String chatRoomId) {
    if (messages.isEmpty) return;
    final currentUserId = _authController.userModel.value?.id;
    if (currentUserId == null) return;

    for (var message in messages) {
      if (message.senderId != currentUserId && !message.read) {
        _getIdToken().then((token) {
          final uri = Uri.parse(
            '$_kDbBase/chats/$chatRoomId/messages/${message.id}.json'
            '${token != null ? '?auth=$token' : ''}',
          );
          // Fire-and-forget: mark as read
          _http.patch(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'read': true}),
          );
        });
      }
    }
  }

  /// Send a message to a group chat room (uses backend REST API, not Firebase directly).
  Future<void> sendRoomMessage(String roomId, String content) async {
    try {
      await _chatRepository.sendRoomMessage(roomId, content);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل إرسال الرسالة: $e');
    }
  }

  // ── Lifecycle ───────────────────────────────────────────────────────────

  @override
  void onClose() {
    _pollTimer?.cancel();
    _http.close();
    super.onClose();
  }
}
