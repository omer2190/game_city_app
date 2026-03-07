import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/chat_repository.dart';

class RoomsController extends GetxController {
  final ChatRepository _chatRepository = ChatRepository();
  late final FirebaseDatabase _db;

  var rooms = <dynamic>[].obs;
  var isLoading = false.obs;

  // Stores last message info keyed by roomId
  var lastMessages = <String, Map<String, dynamic>>{}.obs;

  // Listeners for individual rooms
  final Map<String, StreamSubscription> _roomListeners = {};

  @override
  void onInit() {
    super.onInit();
    _db = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://gaming-city-94354-default-rtdb.europe-west1.firebasedatabase.app/',
    );
    fetchRooms();
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

    _roomListeners.keys.toList().forEach((roomId) {
      if (!activeRoomIds.contains(roomId)) {
        _roomListeners[roomId]?.cancel();
        _roomListeners.remove(roomId);
      }
    });

    for (var room in rooms) {
      final roomId = (room['_id'] ?? room['id'])?.toString() ?? '';
      if (roomId.isNotEmpty && !_roomListeners.containsKey(roomId)) {
        _listenToRoom(roomId);
      }
    }
  }

  void _listenToRoom(String roomId) {
    // Correct path: chats/ROOM_ID/messages
    final roomRef = _db.ref('chats/group_$roomId/messages').limitToLast(1);

    _roomListeners[roomId] = roomRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        try {
          final Map<dynamic, dynamic> data =
              event.snapshot.value as Map<dynamic, dynamic>;
          if (data.isNotEmpty) {
            final lastMsgMap = data.values.first as Map<dynamic, dynamic>;

            final String content =
                (lastMsgMap['text'] ?? lastMsgMap['content'])?.toString() ?? '';
            final String senderId = lastMsgMap['senderId']?.toString() ?? '';
            final String senderName =
                lastMsgMap['name']?.toString() ?? 'Unknown';
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

            _sortRoomsInternal();
          }
        } catch (e) {
          debugPrint('Error parsing message for room $roomId: $e');
        }
      }
    });
  }

  void _sortRoomsInternal() {
    if (rooms.isEmpty) return;

    final List<dynamic> sorted = List.from(rooms);
    sorted.sort((a, b) {
      final idA = (a['_id'] ?? a['id'])?.toString() ?? '';
      final idB = (b['_id'] ?? b['id'])?.toString() ?? '';

      final timeA = lastMessages[idA]?['timestamp'] ?? 0;
      final timeB = lastMessages[idB]?['timestamp'] ?? 0;
      return timeB.compareTo(timeA); // Newest first
    });

    // Minimal change check
    bool changed = false;
    if (sorted.length == rooms.length) {
      for (int i = 0; i < sorted.length; i++) {
        final idSorted = (sorted[i]['_id'] ?? sorted[i]['id'])?.toString();
        final idCurrent = (rooms[i]['_id'] ?? rooms[i]['id'])?.toString();
        if (idSorted != idCurrent) {
          changed = true;
          break;
        }
      }
    } else {
      changed = true;
    }

    if (changed) {
      rooms.assignAll(sorted);
    }
  }

  Future<bool> joinRoom(String roomId) async {
    try {
      final res = await _chatRepository.joinRoom(roomId);
      return res['success'] == true;
    } catch (e) {
      debugPrint('Failed to join room: $e');
      return false;
    }
  }

  @override
  void onClose() {
    _roomListeners.values.forEach((s) => s.cancel());
    super.onClose();
  }
}
