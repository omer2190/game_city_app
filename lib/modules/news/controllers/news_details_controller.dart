import 'package:get/get.dart';
import '../../../data/models/news_model.dart';
import '../../../data/repositories/news_repository.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/views/login_view.dart';

class NewsDetailsController extends GetxController {
  final NewsRepository _newsRepository = NewsRepository();
  final AuthController _authController = Get.find<AuthController>();

  var isLiked = false.obs;
  var likesCount = 0.obs;
  var comments = <dynamic>[].obs;
  var isLoadingComments = true.obs;

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
      print(e);
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
      print(e);
    } finally {
      isLoadingComments(false);
    }
  }

  void addComment(String newsId, String content) async {
    if (!_authController.isLoggedIn.value) {
      Get.to(() => LoginView());
      return;
    }
    if (content.isEmpty) return;

    try {
      await _newsRepository.addComment(newsId, content);
      fetchComments(newsId); // Refresh comments
      Get.snackbar('Success', 'Comment added');
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
