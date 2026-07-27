import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/social_repository.dart';
import '../../../data/repositories/block_repository.dart';

class UserProfileController extends GetxController {
  final SocialRepository _socialRepository = SocialRepository();
  final BlockRepository _blockRepository = BlockRepository();

  var user = Rxn<UserModel>();
  var isLoading = false.obs;
  var isSendingRequest = false.obs;
  var requestSent = false.obs;
  var isBlocked = false.obs;
  var isBlocking = false.obs;

  Future<void> loadUserProfile(String userId) async {
    try {
      isLoading(true);
      requestSent(false); // Reset
      final fetchedUser = await _socialRepository.getUserProfile(userId);
      user.value = fetchedUser;
      // التحقق من حالة الحظر
      await _checkBlockStatus(userId);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحميل ملف تعريف المستخدم: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> _checkBlockStatus(String targetId) async {
    try {
      final blocked = await _blockRepository.checkBlockStatus(targetId);
      isBlocked.value = blocked;
    } catch (e) {
      isBlocked.value = false;
    }
  }

  Future<void> toggleBlockUser() async {
    if (user.value?.id == null) return;
    try {
      isBlocking(true);
      if (isBlocked.value) {
        await _blockRepository.unblockUser(user.value!.id!);
        isBlocked.value = false;
        Get.snackbar('نجاح', 'تم فك حظر المستخدم بنجاح.');
      } else {
        await _blockRepository.blockUser(user.value!.id!);
        isBlocked.value = true;
        Get.snackbar('نجاح', 'تم حظر المستخدم بنجاح.');
      }
    } catch (e) {
      print('Error toggling block status: $e');
      Get.snackbar('خطأ', 'فشل العملية: $e');
    } finally {
      isBlocking(false);
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
