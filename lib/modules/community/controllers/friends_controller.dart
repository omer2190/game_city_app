import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/social_repository.dart';

class FriendsController extends GetxController {
  final SocialRepository _socialRepository = SocialRepository();
  late final FirebaseDatabase _db;

  var friendsList = <UserModel>[].obs;
  var pendingRequests = <UserModel>[].obs;
  var searchResults = <UserModel>[].obs;

  var isFriendsLoading = false.obs;
  var isPendingLoading = false.obs;
  var isSearchLoading = false.obs;

  // Stores last message info keyed by chatRoomId
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
    fetchFriends();
    fetchPendingRequests();
  }

  void _setupChatListeners() {
    final activeRoomIds = friendsList
        .where((f) => f.chatRoomId != null)
        .map((f) => f.chatRoomId!)
        .toSet();

    _roomListeners.keys.toList().forEach((roomId) {
      if (!activeRoomIds.contains(roomId)) {
        _roomListeners[roomId]?.cancel();
        _roomListeners.remove(roomId);
      }
    });

    for (var friend in friendsList) {
      final roomId = friend.chatRoomId;
      if (roomId != null && !_roomListeners.containsKey(roomId)) {
        _listenToRoom(roomId);
      }
    }
  }

  void _listenToRoom(String roomId) {
    if (roomId.isEmpty) return;

    final roomRef = _db.ref('chats/$roomId/messages').limitToLast(1);

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

            _sortFriendsInternal();
          }
        } catch (e) {
          debugPrint('Error parsing message for room $roomId: $e');
        }
      }
    });
  }

  void _sortFriendsInternal() {
    if (friendsList.isEmpty) return;

    final List<UserModel> sorted = List.from(friendsList);
    sorted.sort((a, b) {
      final timeA = lastMessages[a.chatRoomId]?['timestamp'] ?? 0;
      final timeB = lastMessages[b.chatRoomId]?['timestamp'] ?? 0;
      return timeB.compareTo(timeA);
    });

    bool changed = false;
    if (sorted.length == friendsList.length) {
      for (int i = 0; i < sorted.length; i++) {
        if (sorted[i].id != friendsList[i].id) {
          changed = true;
          break;
        }
      }
    } else {
      changed = true;
    }

    if (changed) {
      friendsList.assignAll(sorted);
    }
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

  @override
  void onClose() {
    _roomListeners.values.forEach((s) => s.cancel());
    super.onClose();
  }
}
