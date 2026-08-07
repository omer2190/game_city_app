import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../data/models/user_model.dart';
import '../../../data/repositories/social_repository.dart';

const _kDbBase =
    'https://gaming-city-94354-default-rtdb.europe-west1.firebasedatabase.app';

class FriendsController extends GetxController {
  final SocialRepository _socialRepository = SocialRepository();
  final http.Client _http = http.Client();

  var friendsList = <UserModel>[].obs;
  var pendingRequests = <UserModel>[].obs;
  var searchResults = <UserModel>[].obs;

  var isFriendsLoading = false.obs;
  var isPendingLoading = false.obs;
  var isSearchLoading = false.obs;

  var lastMessages = <String, Map<String, dynamic>>{}.obs;

  final Map<String, Timer> _roomTimers = {};
  bool _sortScheduled = false;

  @override
  void onInit() {
    super.onInit();
    fetchFriends();
    fetchPendingRequests();
  }

  Future<String?> _getIdToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final t = await user.getIdToken();
        debugPrint('🔵 Friends: Auth token ${t != null ? "GOT" : "NULL"}');
        return t;
      }
      debugPrint('🔴 Friends: no currentUser');
    } catch (e) {
      debugPrint('🔴 Friends: Auth token error: $e');
    }
    return null;
  }

  void _setupChatListeners() {
    final activeRoomIds = friendsList
        .where((f) => f.chatRoomId != null)
        .map((f) => f.chatRoomId!)
        .toSet();

    _roomTimers.keys.toList().forEach((roomId) {
      if (!activeRoomIds.contains(roomId)) {
        _roomTimers[roomId]?.cancel();
        _roomTimers.remove(roomId);
      }
    });

    for (var friend in friendsList) {
      final roomId = friend.chatRoomId;
      if (roomId != null && !_roomTimers.containsKey(roomId)) {
        _pollRoom(roomId);
      }
    }
  }

  void _pollRoom(String roomId) {
    if (roomId.isEmpty) return;

    Future<void> fetch() async {
      try {
        debugPrint('🔵 Friends: polling room $roomId');
        final token = await _getIdToken();
        final uri = Uri.parse(
          '$_kDbBase/chats/$roomId/messages.json'
          '${token != null ? '?auth=$token' : ''}',
        );
        final res = await _http.get(uri);
        debugPrint('🔵 Friends: room $roomId status=${res.statusCode}');
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
            'timestamp': timestamp,
            'read': lastMsgMap['read'] == true,
          };
          lastMessages.refresh();
          debugPrint(
            '🟢 Friends: room $roomId lastMsg="$content" ts=$timestamp',
          );
          _sortFriendsInternal();
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

  void _sortFriendsInternal() {
    // Debounce: if already scheduled for this frame, skip.
    if (_sortScheduled) return;
    _sortScheduled = true;

    scheduleMicrotask(() {
      _sortScheduled = false;
      _doSort();
    });
  }

  void _doSort() {
    if (friendsList.isEmpty) return;

    final List<UserModel> sorted = List.from(friendsList);
    sorted.sort((a, b) {
      final timeA = lastMessages[a.chatRoomId]?['timestamp'] ?? 0;
      final timeB = lastMessages[b.chatRoomId]?['timestamp'] ?? 0;
      return timeB.compareTo(timeA);
    });

    debugPrint(
      '🟢 Friends: re-sorted, top=${sorted.isNotEmpty ? sorted.first.userName : "none"}',
    );
    friendsList.assignAll(sorted);
  }

  Future<void> fetchFriends() async {
    try {
      isFriendsLoading(true);
      final list = await _socialRepository.getFriendsList();
      final Map<String, UserModel> uniqueMap = {};
      for (var u in list) {
        if (u.id != null) uniqueMap[u.id!] = u;
      }
      friendsList.assignAll(uniqueMap.values.toList());
      _setupChatListeners();
      _sortFriendsInternal();
    } catch (e) {
      debugPrint('Error fetching friends: $e');
    } finally {
      isFriendsLoading(false);
    }
  }

  Future<void> fetchPendingRequests() async {
    try {
      isPendingLoading(true);
      final list = await _socialRepository.getPendingRequests();
      final Map<String, UserModel> uniqueMap = {};
      for (var u in list) {
        if (u.id != null) uniqueMap[u.id!] = u;
      }
      pendingRequests.assignAll(uniqueMap.values.toList());
    } catch (e) {
      debugPrint('Error fetching pending: $e');
    } finally {
      isPendingLoading(false);
    }
  }

  void search(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }
    try {
      isSearchLoading(true);
      final list = await _socialRepository.searchUsers(query);
      final Map<String, UserModel> uniqueMap = {};
      for (var u in list) {
        if (u.id != null) uniqueMap[u.id!] = u;
      }
      searchResults.assignAll(uniqueMap.values.toList());
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      isSearchLoading(false);
    }
  }

  void acceptRequest(String senderId) async {
    try {
      await _socialRepository.acceptFriendRequest(senderId);
      fetchFriends();
      fetchPendingRequests();
    } catch (e) {
      Get.snackbar('خطأ', e.toString());
    }
  }

  void removeOrRejectFriend(String targetId) async {
    try {
      await _socialRepository.removeFriend(targetId);
      fetchFriends();
      fetchPendingRequests();
    } catch (e) {
      Get.snackbar('خطأ', e.toString());
    }
  }

  void sendFriendRequest(String targetId) async {
    try {
      await _socialRepository.sendFriendRequest(targetId);
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
