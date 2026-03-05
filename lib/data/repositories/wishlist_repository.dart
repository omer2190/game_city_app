import '../../core/network/api_client.dart';
import '../../core/values/api_constants.dart';
import '../models/wishlist_model.dart';

class WishlistRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<WishlistEntry>> getMyWishlist() async {
    final response = await _apiClient.get(ApiConstants.myWishlist);
    if (response is List) {
      return response.map((item) => WishlistEntry.fromJson(item)).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> toggleWishlist(String gameId) async {
    final response = await _apiClient.post(
      ApiConstants.toggleWishlist,
      body: {'gameId': gameId},
    );
    return response as Map<String, dynamic>;
  }
}
