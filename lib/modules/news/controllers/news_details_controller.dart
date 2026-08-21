import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import '../../../data/models/comments.dart';
import '../../../data/models/news_model.dart';
import '../../../data/repositories/news_repository.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/views/login_view.dart';

/// A single comment with its nested replies (thread).
class CommentNode {
  final Comments comment;
  final List<CommentNode> replies;
  CommentNode(this.comment, this.replies);
}

class NewsDetailsController extends GetxController {
  final NewsRepository _newsRepository = NewsRepository();
  final AuthController _authController = Get.find<AuthController>();

  var isLiked = false.obs;
  var likesCount = 0.obs;
  var comments = <Comments>[].obs;
  var isLoadingComments = true.obs;
  var replyingTo = RxnString();
  var replyingToName = RxnString();

  void initDetails(News news) {
    isLiked.value = false;
    likesCount.value = 0;
    fetchLikesData(news.id!);
    fetchComments(news.id!);
  }

  void fetchLikesData(String newsId) async {
    try {
      final data = await _newsRepository.getLikesData(newsId);
      likesCount.value = data['likes'];
      isLiked.value = data['userLiked'];
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void toggleLike(String newsId) async {
    if (!_authController.isLoggedIn.value) {
      Get.to(() => LoginView());
      return;
    }
    try {
      final response = await _newsRepository.toggleLike(newsId);
      // Update both based on the new response format
      likesCount.value =
          int.tryParse(
            response['likes']?.toString() ?? likesCount.value.toString(),
          ) ??
          likesCount.value;
      isLiked.value = response['userLiked'] ?? !isLiked.value;
      fetchLikesData(newsId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to like');
    }
  }

  void fetchComments(String newsId) async {
    try {
      isLoadingComments(true);
      comments.value = await _newsRepository.getComments(newsId);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoadingComments(false);
    }
  }

  /// Builds comment threads: top-level comments with their nested replies.
  /// Top-level comments are ordered by number of replies (descending).
  List<CommentNode> get commentThreads {
    final all = comments.toList();
    final byParent = <String?, List<Comments>>{};
    for (final c in all) {
      byParent.putIfAbsent(c.parentComment, () => []).add(c);
    }
    // Sort replies within each group by creation time (oldest first).
    byParent.forEach((_, list) {
      list.sort(
        (a, b) =>
            (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0)),
      );
    });

    CommentNode buildNode(Comments c) {
      final replies = (byParent[c.id] ?? []).map(buildNode).toList();
      return CommentNode(c, replies);
    }

    int countReplies(Comments c) {
      var count = 0;
      for (final r in byParent[c.id] ?? []) {
        count += 1 + countReplies(r);
      }
      return count;
    }

    final topLevel = (byParent[null] ?? []).toList();
    // Order top-level comments by number of replies (descending).
    topLevel.sort((a, b) {
      final aCount = countReplies(a);
      final bCount = countReplies(b);
      if (aCount != bCount) return bCount.compareTo(aCount);
      return (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0));
    });

    return topLevel.map(buildNode).toList();
  }

  void setReplyingTo(Comments comment) {
    replyingTo.value = comment.id;
    replyingToName.value =
        "${comment.userId?.firstName ?? 'مستخدم'} ${comment.userId?.lastName ?? ''}";
  }

  void clearReplyingTo() {
    replyingTo.value = null;
    replyingToName.value = null;
  }

  void addComment(String newsId, String content) async {
    if (!_authController.isLoggedIn.value) {
      Get.to(() => LoginView());
      return;
    }
    if (content.isEmpty) return;

    try {
      final parentId = replyingTo.value;
      await _newsRepository.addComment(
        newsId,
        content,
        parentComment: parentId,
      );
      clearReplyingTo();
      fetchComments(newsId); // Refresh comments
      Get.snackbar(
        'Success',
        parentId == null ? 'Comment added' : 'Reply added',
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to add comment');
    }
  }

  void deleteComment(String newsId, String commentId) async {
    if (!_authController.isLoggedIn.value) {
      Get.to(() => LoginView());
      return;
    }
    try {
      await _newsRepository.deleteComment(commentId);
      fetchComments(newsId);
      Get.snackbar('نجاح', 'تم حذف التعليق بنجاح');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل حذف التعليق');
    }
  }

  void updateComment(String newsId, String commentId, String content) async {
    if (!_authController.isLoggedIn.value) {
      Get.to(() => LoginView());
      return;
    }
    try {
      if (content.isEmpty) return;
      await _newsRepository.updateComment(commentId, content);
      fetchComments(newsId);
      Get.snackbar('نجاح', 'تم تحديث التعليق بنجاح');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحديث التعليق: $e');
    }
  }

  bool isMyComment(String? commentUserId) {
    if (!_authController.isLoggedIn.value) return false;
    return _authController.userModel.value?.id == commentUserId;
  }
}
