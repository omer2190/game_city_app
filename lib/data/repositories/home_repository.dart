import '../../core/network/api_client.dart';
import '../../core/values/api_constants.dart';
import '../models/home_dashboard_model.dart';

class HomeRepository {
  final ApiClient _apiClient = ApiClient();

  Future<HomeDashboardModel?> getHomeDashboard() async {
    try {
      final response = await _apiClient.get(ApiConstants.homeDashboard);
      if (response['success'] == true) {
        return HomeDashboardModel.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
