import '../../core/network/api_client.dart';
import '../../core/values/api_constants.dart';

class ChatRepository {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> sendMessage(
    String recipientId,
    String content, {
    String type = 'text',
  }) async {
    return await _apiClient.post(
      ApiConstants.chatSend,
      body: {'recipientId': recipientId, 'content': content, 'type': type},
    );
  }

  Future<List<dynamic>> getChatRooms() async {
    final response = await _apiClient.get(ApiConstants.chatRooms);
    return response['rooms'] ?? [];
  }

  // Note: ApiConstants for specific room actions need to be dynamic or constructed here
  // We didn't define dynamic paths in ApiConstants yet, so we construct them here using baseUrl

  Future<Map<String, dynamic>> joinRoom(String roomId) async {
    return await _apiClient.post(
      '${ApiConstants.baseUrl}/api/chat/rooms/$roomId/join',
    );
  }

  Future<Map<String, dynamic>> sendRoomMessage(
    String roomId,
    String content, {
    String type = 'text',
  }) async {
    return await _apiClient.post(
      '${ApiConstants.baseUrl}/api/chat/rooms/$roomId/send',
      body: {'content': content, 'type': type, "chatRoomId": roomId},
    );
  }
}
