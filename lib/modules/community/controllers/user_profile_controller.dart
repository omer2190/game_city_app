import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/social_repository.dart';

class UserProfileController extends GetxController {
  final SocialRepository _socialRepository = SocialRepository();

  var user = Rxn<UserModel>();
  var isLoading = false.obs;
  var isSendingRequest = false.obs;
  var requestSent = false.obs;

  Future<void> loadUserProfile(String userId) async {
    try {
      isLoading(true);
      requestSent(false); // Reset
      final fetchedUser = await _socialRepository.getUserProfile(userId);
      user.value = fetchedUser;
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحميل ملف تعريف المستخدم: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> sendFriendRequest() async {
    if (user.value?.id == null) return;
    try {
      isSendingRequest(true);
      await _socialRepository.sendFriendRequest(user.value!.id!);
      Get.snackbar('نجاح', 'تم إرسال طلب الصداقة بنجاح');
      requestSent(true);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل إرسال طلب الصداقة: $e');
    } finally {
      isSendingRequest(false);
    }
  }

  Future<void> removeFriend() async {
    if (user.value?.id == null) return;
    try {
      isLoading(true);
      await _socialRepository.removeFriend(user.value!.id!);
      Get.snackbar('نجاح', 'تم حذف الصديق بنجاح');
      // Refresh user profile to update UI
      await loadUserProfile(user.value!.id!);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل حذف الصديق: $e');
    } finally {
      isLoading(false);
    }
  }
}
