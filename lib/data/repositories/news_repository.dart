import '../../core/network/api_client.dart';
import '../../core/values/api_constants.dart';
import '../../data/models/news_model.dart';
import '../models/comments.dart';

class NewsRepository {
  final ApiClient _apiClient = ApiClient();

  Future<NewsResponse> getNews({
    int page = 1,
    String? newsType,
    String? search,
  }) async {
    String url = '${ApiConstants.news}?page=$page';
    if (newsType != null && newsType.isNotEmpty) {
      url += '&newsType=$newsType';
    }
    if (search != null && search.isNotEmpty) {
      url += '&search=$search';
    }
    final response = await _apiClient.get(url);
    // Ensure response is handled correctly depending on what get returns
    if (response is Map<String, dynamic>) {
      return NewsResponse.fromJson(response);
    }
    throw Exception('Invalid response format');
  }

  Future<Map<String, dynamic>> toggleLike(String newsId) async {
    return await _apiClient.post(
      '${ApiConstants.baseUrl}/api/likes/togglelike',
      body: {'newsId': newsId},
    );
  }

  Future<Map<String, dynamic>> getLikesData(String newsId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.baseUrl}/api/likes/count?newsId=$newsId',
      );
      return {
        'likes': int.tryParse(response['likes']?.toString() ?? '0') ?? 0,
        'userLiked': response['userLiked'] ?? false,
      };
    } catch (e) {
      return {'likes': 0, 'userLiked': false};
    }
  }

  Future<Map<String, dynamic>> addComment(String newsId, String content) async {
    return await _apiClient.post(
      '${ApiConstants.baseUrl}/api/comments/',
      body: {'newsId': newsId, 'content': content},
    );
  }

  Future<Map<String, dynamic>> updateComment(
    String commentId,
    String content,
  ) async {
    // try post if put is failing with 401 on some backends
    return await _apiClient.post(
      '${ApiConstants.baseUrl}/api/comments/$commentId',
      body: {'content': content},
    );
  }

  Future<Map<String, dynamic>> deleteComment(String commentId) async {
    // try post if delete is failing with 401 on some backends
    return await _apiClient.post(
      '${ApiConstants.baseUrl}/api/comments/$commentId/delete',
      body: {},
    );
  }

  Future<List<Comments>> getComments(String newsId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.baseUrl}/api/comments/news/$newsId',
      );
      if (response['comments'] == null) return [];
      return (response['comments'] as List<dynamic>)
          .map((c) => Comments.fromJson(c))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
