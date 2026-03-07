import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/social_repository.dart';

class SuggestedFriendsController extends GetxController {
  final SocialRepository _socialRepository = SocialRepository();
  var suggestions = <UserModel>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    fetchSuggestions();
    super.onInit();
  }

  Future<void> fetchSuggestions() async {
    try {
      isLoading(true);
      final list = await _socialRepository.getSuggestedFriends();
      debugPrint(list.toString());
      suggestions.assignAll(list);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load suggestions: $e');
    } finally {
      isLoading(false);
    }
  }

  void sendFriendRequest(String userId) async {
    debugPrint(userId);
    try {
      await _socialRepository.sendFriendRequest(userId);
      Get.snackbar('نجاح', 'تم إرسال طلب الصداقة');
    } catch (e) {
      Get.snackbar('خطأ', e.toString());
    }
  }
}
