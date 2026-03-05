import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
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
    print('Listening to messages for room: $roomId');
    final ref = FirebaseDatabase.instance.ref('chats/group_$roomId/messages');
    _sub = ref.onChildAdded.listen((event) {
      final val = event.snapshot.value;
      if (val is Map) {
        final msg = Map<String, dynamic>.from(val);
        _messages.add(msg);
      }
    });
  }

  Future<void> sendMessage(String content) async {
    try {
      await _chatRepository.sendRoomMessage(roomId, content);
    } catch (e) {
      print('Failed to send room message: $e');
      rethrow;
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
