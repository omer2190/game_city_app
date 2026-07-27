import 'user_model.dart';
import 'game_model.dart';

class ReviewComment {
  final String? id;
  final UserModel? userId;
  final Game? gameId;
  final int? rating;
  final String? content;
  final String? createdAt;
  final String? updatedAt;

  ReviewComment({
    this.id,
    this.userId,
    this.gameId,
    this.rating,
    this.content,
    this.createdAt,
    this.updatedAt,
  });

  factory ReviewComment.fromJson(Map<String, dynamic> json) {
    return ReviewComment(
      id: json['_id'],
      userId: json['userId'] != null
          ? (json['userId'] is Map<String, dynamic>
                ? UserModel.fromJson(json['userId'])
                : null)
          : null,
      gameId: json['gameId'] != null
          ? (json['gameId'] is Map<String, dynamic>
                ? Game.fromJson(json['gameId'])
                : null)
          : null,
      rating: json['rating'],
      content: json['content'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'userId': userId?.id,
    'gameId': gameId?.id,
    'rating': rating,
    'content': content,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

class ReviewCommentsResponse {
  final List<ReviewComment> reviewComments;
  final int page;
  final int totalPages;
  final int total;

  ReviewCommentsResponse({
    required this.reviewComments,
    required this.page,
    required this.totalPages,
    required this.total,
  });

  factory ReviewCommentsResponse.fromJson(Map<String, dynamic> json) {
    return ReviewCommentsResponse(
      reviewComments: json['reviewComments'] != null
          ? (json['reviewComments'] as List)
                .map((c) => ReviewComment.fromJson(c))
                .toList()
          : [],
      page: json['page'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      total: json['total'] ?? 0,
    );
  }
}
