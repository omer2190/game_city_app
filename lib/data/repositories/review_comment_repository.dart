import '../../core/network/api_client.dart';
import '../../core/values/api_constants.dart';
import '../models/review_comment_model.dart';

class ReviewCommentRepository {
  final ApiClient _apiClient = ApiClient();

  /// إنشاء تقييم جديد للعبة
  /// [gameId] - معرف اللعبة
  /// [rating] - التقييم من 1 إلى 5
  /// [content] - تعليق اختياري
  Future<Map<String, dynamic>> createReview({
    required String gameId,
    required int rating,
    String? content,
  }) async {
    final body = <String, dynamic>{'gameId': gameId, 'rating': rating};
    if (content != null && content.isNotEmpty) {
      body['content'] = content;
    }
    final response = await _apiClient.post(
      ApiConstants.reviewComments,
      body: body,
    );
    return response as Map<String, dynamic>;
  }

  /// جلب جميع تقييمات لعبة معينة
  Future<ReviewCommentsResponse> getGameReviews(
    String gameId, {
    int page = 1,
    int limit = 20,
  }) async {
    final uri = Uri.parse(ApiConstants.gameReviews(gameId)).replace(
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
    );
    final response = await _apiClient.get(uri.toString());
    if (response is Map<String, dynamic> && response['success'] == true) {
      return ReviewCommentsResponse.fromJson(response);
    }
    return ReviewCommentsResponse(
      reviewComments: [],
      page: 1,
      totalPages: 1,
      total: 0,
    );
  }

  /// جلب تقييم المستخدم الحالي للعبة معينة
  /// يرجع null إذا لم يقيم المستخدم اللعبة بعد
  Future<ReviewComment?> getUserReview(String gameId) async {
    try {
      final response = await _apiClient.get(ApiConstants.userReview(gameId));
      if (response is Map<String, dynamic> && response['success'] == true) {
        if (response['reviewComment'] == null) return null;
        return ReviewComment.fromJson(response['reviewComment']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// تحديث تقييم (تغيير النجوم و/أو التعليق)
  Future<Map<String, dynamic>> updateReview(
    String reviewId, {
    int? rating,
    String? content,
  }) async {
    final body = <String, dynamic>{};
    if (rating != null) body['rating'] = rating;
    if (content != null) body['content'] = content;
    final response = await _apiClient.put(
      ApiConstants.reviewById(reviewId),
      body: body,
    );
    return response as Map<String, dynamic>;
  }

  /// حذف تقييم
  Future<Map<String, dynamic>> deleteReview(String reviewId) async {
    final response = await _apiClient.delete(ApiConstants.reviewById(reviewId));
    return response as Map<String, dynamic>;
  }
}
