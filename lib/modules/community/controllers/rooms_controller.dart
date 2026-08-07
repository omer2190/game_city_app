import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../data/repositories/chat_repository.dart';

const _kDbBase =
    'https://gaming-city-94354-default-rtdb.europe-west1.firebasedatabase.app';

class RoomsController extends GetxController {
  final ChatRepository _chatRepository = ChatRepository();
  final http.Client _http = http.Client();

  var rooms = <dynamic>[].obs;
  var isLoading = false.obs;
  var lastMessages = <String, Map<String, dynamic>>{}.obs;

  final Map<String, Timer> _roomTimers = {};
  bool _sortScheduled = false;

  @override
  void onInit() {
    super.onInit();
    fetchRooms();
  }

  Future<String?> _getIdToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final t = await user.getIdToken();
        debugPrint('🔵 Rooms: Auth token ${t != null ? "GOT" : "NULL"}');
        return t;
      }
      debugPrint('🔴 Rooms: no currentUser');
    } catch (e) {
      debugPrint('🔴 Rooms: Auth token error: $e');
    }
    return null;
  }

  Future<void> fetchRooms() async {
    try {
      isLoading.value = true;
      final res = await _chatRepository.getChatRooms();
      rooms.assignAll(res);
      _setupRoomListeners();
      _sortRoomsInternal();
    } catch (e) {
      debugPrint('Failed to fetch rooms: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _setupRoomListeners() {
    final activeRoomIds = rooms
        .map((r) => (r['_id'] ?? r['id'])?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();

    _roomTimers.keys.toList().forEach((roomId) {
      if (!activeRoomIds.contains(roomId)) {
        _roomTimers[roomId]?.cancel();
        _roomTimers.remove(roomId);
      }
    });

    for (var room in rooms) {
      final roomId = (room['_id'] ?? room['id'])?.toString() ?? '';
      if (roomId.isNotEmpty && !_roomTimers.containsKey(roomId)) {
        _pollRoom(roomId);
      }
    }
  }

  void _pollRoom(String roomId) {
    Future<void> fetch() async {
      try {
        debugPrint('🔵 Rooms: polling room $roomId');
        final token = await _getIdToken();
        final uri = Uri.parse(
          '$_kDbBase/chats/group_$roomId/messages.json'
          '${token != null ? '?auth=$token' : ''}',
        );
        final res = await _http.get(uri);
        debugPrint('🔵 Rooms: room $roomId status=${res.statusCode}');
        if (res.statusCode != 200) return;

        final dynamic body = jsonDecode(res.body);
        if (body == null || body is! Map) return;

        final data = body as Map<String, dynamic>;
        if (data.isNotEmpty) {
          final entries = data.entries.toList();
          entries.sort((a, b) {
            final va = a.value is Map ? a.value as Map : <dynamic, dynamic>{};
            final vb = b.value is Map ? b.value as Map : <dynamic, dynamic>{};
            final ta =
                int.tryParse(
                  (va['createdAt'] ?? va['timestamp'] ?? '0').toString(),
                ) ??
                0;
            final tb =
                int.tryParse(
                  (vb['createdAt'] ?? vb['timestamp'] ?? '0').toString(),
                ) ??
                0;
            return ta.compareTo(tb);
          });
          final lastMsgMap = Map<String, dynamic>.from(
            entries.last.value as Map,
          );
          final String content =
              (lastMsgMap['text'] ?? lastMsgMap['content'])?.toString() ?? '';
          final String senderId = lastMsgMap['senderId']?.toString() ?? '';
          final String senderName = lastMsgMap['name']?.toString() ?? 'Unknown';
          final int timestamp = lastMsgMap['createdAt'] is int
              ? lastMsgMap['createdAt']
              : (lastMsgMap['timestamp'] is int
                    ? lastMsgMap['timestamp']
                    : int.tryParse(
                            (lastMsgMap['createdAt'] ??
                                    lastMsgMap['timestamp'] ??
                                    '0')
                                .toString(),
                          ) ??
                          0);

          lastMessages[roomId] = {
            'text': content,
            'senderId': senderId,
            'senderName': senderName,
            'timestamp': timestamp,
            'read': lastMsgMap['read'] == true,
          };
          lastMessages.refresh();
          debugPrint('🟢 Rooms: room $roomId lastMsg="$content"');
          _sortRoomsInternal();
        }
      } catch (e) {
        debugPrint('Error polling room $roomId: $e');
      }
    }

    fetch();
    _roomTimers[roomId] = Timer.periodic(
      const Duration(seconds: 2),
      (_) => fetch(),
    );
  }

  void _sortRoomsInternal() {
    if (_sortScheduled) return;
    _sortScheduled = true;
    scheduleMicrotask(() {
      _sortScheduled = false;
      _doSort();
    });
  }

  void _doSort() {
    if (rooms.isEmpty) return;

    final List<dynamic> sorted = List.from(rooms);
    sorted.sort((a, b) {
      final idA = (a['_id'] ?? a['id'])?.toString() ?? '';
      final idB = (b['_id'] ?? b['id'])?.toString() ?? '';
      final timeA = lastMessages[idA]?['timestamp'] ?? 0;
      final timeB = lastMessages[idB]?['timestamp'] ?? 0;
      return timeB.compareTo(timeA);
    });

    debugPrint('🟢 Rooms: re-sorted');
    rooms.assignAll(sorted);
  }

  Future<bool> joinRoom(String roomId) async {
    try {
      final res = await _chatRepository.joinRoom(roomId);
      return res['success'] == true;
    } catch (e) {
      Get.snackbar('خطأ', e.toString());
      return false;
    }
  }

  void leaveRoom(String roomId) async {
    try {
      await _chatRepository.joinRoom(roomId);
      fetchRooms();
    } catch (e) {
      Get.snackbar('خطأ', e.toString());
    }
  }

  @override
  void onClose() {
    _roomTimers.values.forEach((t) => t.cancel());
    _http.close();
    super.onClose();
  }
}
