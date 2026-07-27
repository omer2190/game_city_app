import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/block_repository.dart';

class BlockedUsersController extends GetxController {
  final BlockRepository _blockRepository = BlockRepository();

  var blockedUsers = <UserModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBlockedUsers();
  }

  /// جلب قائمة المحظورين
  Future<void> fetchBlockedUsers() async {
    try {
      isLoading.value = true;
      final users = await _blockRepository.getBlockedUsers();
      blockedUsers.value = users
          .map((u) => UserModel.fromJson(u as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching blocked users: $e');
      }
      Get.snackbar('خطأ', 'فشل جلب قائمة المحظورين: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// فك حظر مستخدم
  Future<void> unblockUser(String targetId) async {
    try {
      isLoading.value = true;
      await _blockRepository.unblockUser(targetId);
      // إزالة المستخدم من القائمة محلياً
      blockedUsers.removeWhere((u) => u.id == targetId);
      Get.snackbar('نجاح', 'تم فك حظر المستخدم بنجاح.');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error unblocking user: $e');
      }
      Get.snackbar('خطأ', 'فشل فك حظر المستخدم: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// حظر مستخدم (تُستخدم من صفحات أخرى)
  Future<void> blockUser(String targetId) async {
    try {
      await _blockRepository.blockUser(targetId);
      Get.snackbar('نجاح', 'تم حظر المستخدم بنجاح.');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error blocking user: $e');
      }
      Get.snackbar('خطأ', 'فشل حظر المستخدم: $e');
    }
  }

  /// التحقق من حالة الحظر
  Future<bool> checkBlockStatus(String targetId) async {
    try {
      return await _blockRepository.checkBlockStatus(targetId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking block status: $e');
      }
      return false;
    }
  }
}
