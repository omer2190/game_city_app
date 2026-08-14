import 'package:flutter/material.dart';
import 'package:game_city_app/data/models/user_model.dart';
import 'package:game_city_app/modules/auth/controllers/auth_controller.dart';
import 'package:game_city_app/modules/chat/views/chat_view.dart';
import 'package:game_city_app/modules/community/controllers/user_profile_controller.dart';
import 'package:get/get.dart';

class VisitorActionRow extends StatelessWidget {
  final UserProfileController controller;
  final UserModel user;
  final ColorScheme colorScheme;

  const VisitorActionRow({
    super.key,
    required this.controller,
    required this.user,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    if (auth.userModel.value?.id?.toString() == user.id?.toString()) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      if (controller.isSendingRequest.value || controller.isBlocking.value) {
        return const SizedBox(
          height: 28,
          width: 28,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        );
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _actionPill(
            label: user.isFriend == true
                ? 'صديق'
                : controller.requestSent.value
                ? 'تم الإرسال'
                : 'إضافة صديق',
            icon: user.isFriend == true
                ? Icons.check
                : controller.requestSent.value
                ? Icons.access_time_rounded
                : Icons.person_add,
            color: user.isFriend == true
                ? Colors.green
                : controller.requestSent.value
                ? Colors.grey
                : colorScheme.primary,
            onTap: user.isFriend == true
                ? () => _confirm(
                    'حذف الصديق',
                    'هل أنت متأكد من حذف هذا الصديق؟',
                    'حذف',
                    Colors.red,
                    () => controller.removeFriend(),
                  )
                : controller.requestSent.value
                ? null
                : () => controller.sendFriendRequest(),
          ),
          const SizedBox(width: 10),
          _actionPill(
            label: 'رسالة',
            icon: Icons.send_rounded,
            color: Colors.blue,
            onTap: () => Get.to(() => ChatView(recipient: user)),
          ),
          const SizedBox(width: 10),
          _actionPill(
            label: controller.isBlocked.value ? 'محظور' : 'حظر',
            icon: controller.isBlocked.value
                ? Icons.lock_open_rounded
                : Icons.block_flipped,
            color: controller.isBlocked.value
                ? Colors.orange
                : Colors.redAccent,
            onTap: () {
              if (controller.isBlocked.value) {
                _confirm(
                  'فك الحظر',
                  'هل أنت متأكد من فك حظر هذا المستخدم؟',
                  'فك الحظر',
                  Colors.orange,
                  () => controller.toggleBlockUser(),
                );
              } else {
                _confirm(
                  'حظر المستخدم',
                  'هل أنت متأكد من حظر هذا المستخدم؟',
                  'حظر',
                  Colors.red,
                  () => controller.toggleBlockUser(),
                );
              }
            },
          ),
        ],
      );
    });
  }

  Widget _actionPill({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirm(
    String title,
    String msg,
    String confirmLabel,
    Color confirmColor,
    VoidCallback onConfirm,
  ) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Get.theme.colorScheme.surface,
        title: Text(
          title,
          style: TextStyle(color: Get.theme.colorScheme.onSurface),
        ),
        content: Text(
          msg,
          style: TextStyle(
            color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          TextButton(
            onPressed: onConfirm,
            child: Text(confirmLabel, style: TextStyle(color: confirmColor)),
          ),
        ],
      ),
    );
  }
}
