import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/chat_repository.dart';

class ChatController extends GetxController {
  final String roomId;
  ChatController({required this.roomId});

  final ChatRepository _chatRepository = ChatRepository();
  final _messages = <Map<String, dynamic>>[].obs;
  StreamSubscription<DatabaseEvent>? _sub;

  List<Map<String, dynamic>> get messages => _messages;

  @override
  void onInit() {
    super.onInit();
    _listenMessages();
  }

  void _listenMessages() {
    debugPrint('Listening to messages for room: $roomId');
    final ref = FirebaseDatabase.instance.ref('chats/group_$roomId/messages');

    _sub = ref.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> data =
            event.snapshot.value as Map<dynamic, dynamic>;
        final List<Map<String, dynamic>> loadedMessages = [];

        data.forEach((key, value) {
          if (value is Map) {
            final msg = Map<String, dynamic>.from(value);
            msg['id'] = key.toString(); // Store the message ID for edit/delete
            loadedMessages.add(msg);
          }
        });

        // Sort by timestamp
        loadedMessages.sort((a, b) {
          final timeA = int.tryParse(a['createdAt']?.toString() ?? '0') ?? 0;
          final timeB = int.tryParse(b['createdAt']?.toString() ?? '0') ?? 0;
          return timeA.compareTo(timeB);
        });

        _messages.assignAll(loadedMessages);
      } else {
        _messages.clear();
      }
    });
  }

  Future<void> updateMessage(String messageId, String newContent) async {
    try {
      final ref = FirebaseDatabase.instance.ref(
        'chats/group_$roomId/messages/$messageId',
      );
      await ref.update({'text': newContent, 'isEdited': true});
    } catch (e) {
      debugPrint('Failed to update message: $e');
      rethrow;
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      final ref = FirebaseDatabase.instance.ref(
        'chats/group_$roomId/messages/$messageId',
      );
      await ref.remove();
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
    _sub?.cancel();
    super.onClose();
  }
}
