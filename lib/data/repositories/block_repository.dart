import '../../core/network/api_client.dart';
import '../../core/values/api_constants.dart';

class BlockRepository {
  final ApiClient _apiClient = ApiClient();

  /// حظر مستخدم
  Future<Map<String, dynamic>> blockUser(String targetId) async {
    return await _apiClient.post(
      ApiConstants.blockUser,
      body: {'targetId': targetId},
    );
  }

  /// فك حظر مستخدم
  Future<Map<String, dynamic>> unblockUser(String targetId) async {
    return await _apiClient.post(
      ApiConstants.unblockUser,
      body: {'targetId': targetId},
    );
  }

  /// جلب قائمة المحظورين
  Future<List<dynamic>> getBlockedUsers() async {
    final response = await _apiClient.get(ApiConstants.getBlockedUsers);
    return response['blockedUsers'] ?? [];
  }

  /// التحقق من حالة الحظر
  Future<bool> checkBlockStatus(String targetId) async {
    final response = await _apiClient.get(
      ApiConstants.checkBlockStatus(targetId),
    );
    return response['isBlocked'] == true;
  }
}
