import '../../core/network/api_client.dart';
import '../../core/values/api_constants.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<NotificationModel>> getNotifications() async {
    final response = await _apiClient.get(ApiConstants.notifications);
    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> list = response['data'];
      return list.map((json) => NotificationModel.fromJson(json)).toList();
    }
    return [];
  }

  Future<bool> markAsRead(String id) async {
    final response = await _apiClient.put(
      '${ApiConstants.notifications}/$id/read',
    );
    return response['success'] == true;
  }
}
