import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/models/message_model.dart';
import '../../auth/controllers/auth_controller.dart';

class ChatController extends GetxController {
  final ChatRepository _chatRepository = ChatRepository();
  final AuthController _authController = Get.find<AuthController>();
  late final FirebaseDatabase _db;

  var messages = <MessageModel>[].obs;
  var isLoading = false.obs;

  StreamSubscription? _messageSubscription;

  @override
  void onInit() {
    super.onInit();
    _db = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://gaming-city-94354-default-rtdb.europe-west1.firebasedatabase.app/',
    );
  }

  void listenToMessages(String chatRoomId) {
    if (chatRoomId.isEmpty) return;

    isLoading(true);
    _messageSubscription?.cancel();

    try {
      // Path corrected based on Firebase structure: chats/ROOM_ID/messages
      final chatRef = _db.ref('chats/$chatRoomId/messages').limitToLast(50);

      _messageSubscription = chatRef.onValue.listen(
        (event) {
          if (event.snapshot.value != null) {
            try {
              final Map<dynamic, dynamic> data =
                  event.snapshot.value as Map<dynamic, dynamic>;
              final List<MessageModel> loadedMessages = [];

              data.forEach((key, value) {
                if (value is Map) {
                  loadedMessages.add(
                    MessageModel.fromMap(key.toString(), value),
                  );
                }
              });

              // Sort by timestamp
              loadedMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

              messages.assignAll(loadedMessages);

              // Mark individual messages as read if they are sent to me
              markMessagesAsRead(chatRoomId);
            } catch (e) {
              print('Error parsing message data: $e');
            }
          } else {
            messages.clear();
          }
          isLoading(false);
        },
        onError: (error) {
          print('Chat Subscription Error: $error');
          isLoading(false);
        },
      );
    } catch (e) {
      print('Error setting up chat: $e');
      isLoading(false);
    }
  }

  Future<void> sendChatMessage(
    String recipientId,
    String content, {
    String type = 'text',
  }) async {
    try {
      await _chatRepository.sendMessage(recipientId, content, type: type);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل إرسال الرسالة: $e');
    }
  }

  void markMessagesAsRead(String chatRoomId) {
    if (messages.isEmpty) return;

    final currentUserId = _authController.userModel.value?.id;
    if (currentUserId == null) return;

    for (var message in messages) {
      // If the message is NOT sent by me and it's NOT read, mark it as read
      if (message.senderId != currentUserId && !message.read) {
        _db
            .ref('chats/$chatRoomId/messages/${message.id}')
            .update({'read': true})
            .catchError(
              (e) => print('Error marking message $message.id as read: $e'),
            );
      }
    }
  }

  @override
  void onClose() {
    _messageSubscription?.cancel();
    super.onClose();
  }
}
