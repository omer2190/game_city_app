import '../../core/network/api_client.dart';
import '../../core/values/api_constants.dart';
import '../../data/models/user_model.dart';

class SocialRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<UserModel>> getSuggestedFriends() async {
    final response = await _apiClient.get(ApiConstants.friendsSuggestions);
    final List<dynamic> body = response as List<dynamic>;
    return body.map((item) => UserModel.fromJson(item)).toList();
  }

  Future<List<UserModel>> getFriendsList() async {
    final response = await _apiClient.get(ApiConstants.friendsList);
    final List<dynamic> body = response as List<dynamic>;
    return body.map((item) => UserModel.fromJson(item)).toList();
  }

  Future<void> sendFriendRequest(String recipientId) async {
    await _apiClient.post(
      ApiConstants.friendRequest,
      body: {'friendId': recipientId},
    );
  }

  Future<void> acceptFriendRequest(String requestId) async {
    await _apiClient.post(
      ApiConstants.acceptFriendRequest,
      body: {'requestId': requestId},
    );
  }

  Future<List<UserModel>> getPendingRequests() async {
    final response = await _apiClient.get(ApiConstants.pendingRequests);
    final List<dynamic> body = response as List<dynamic>;
    return body.map((item) => UserModel.fromJson(item)).toList();
  }

  Future<List<UserModel>> searchUsers(String query) async {
    final response = await _apiClient.get(
      '${ApiConstants.baseUrl}/api/friends/search?query=$query',
    );
    final List<dynamic> body = response as List<dynamic>;
    return body.map((item) => UserModel.fromJson(item)).toList();
  }

  Future<UserModel> getUserProfile(String userId) async {
    final response = await _apiClient.get(
      '${ApiConstants.userProfile}/$userId',
    );
    // نمرر الاستجابة كاملة لأن UserModel.fromJson يعرف كيف يستخرج 'user' و 'socialMedia' و 'userInfos'
    return UserModel.fromJson(response);
  }

  Future<void> removeFriend(String targetId) async {
    await _apiClient.delete(
      '${ApiConstants.baseUrl}/api/friends/remove/$targetId',
    );
  }
}
