import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:game_city_app/shared/layout_mine.dart';
import 'package:game_city_app/shared/widgets/widgets.dart';
import '../controllers/blocked_users_controller.dart';

class BlockedUsersView extends StatelessWidget {
  const BlockedUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    final BlockedUsersController controller = Get.put(BlockedUsersController());
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutMine(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: LoadingWidget());
        }

        if (controller.blockedUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.block,
                  size: 80,
                  color: colorScheme.primary.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'لا يوجد مستخدمين محظورين',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSecondary.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'عندما تقوم بحظر مستخدم، سيظهر هنا',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSecondary.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchBlockedUsers(),
          color: colorScheme.primary,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: controller.blockedUsers.length,
            itemBuilder: (context, index) {
              final user = controller.blockedUsers[index];
              return _buildBlockedUserCard(
                context,
                controller,
                user,
                colorScheme,
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildBlockedUserCard(
    BuildContext context,
    BlockedUsersController controller,
    dynamic user,
    ColorScheme colorScheme,
  ) {
    final displayName = user.firstName != null && user.firstName!.isNotEmpty
        ? '${user.firstName} ${user.lastName ?? ''}'
        : user.userName ?? 'مستخدم';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // صورة المستخدم
            SafeCachedAvatar(
              user: user,
              radius: 28,
              backgroundColor: colorScheme.primary.withOpacity(0.2),
            ),
            const SizedBox(width: 12),

            // اسم المستخدم
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (user.userName != null && user.firstName != null)
                    Text(
                      '@${user.userName}',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                ],
              ),
            ),

            // زر فك الحظر
            CustomButton(
              text: 'فك الحظر',
              type: ButtonType.primary,
              onPressed: () => _showUnblockDialog(context, controller, user),
              width: 110,
              height: 38,
            ),
          ],
        ),
      ),
    );
  }

  void _showUnblockDialog(
    BuildContext context,
    BlockedUsersController controller,
    dynamic user,
  ) {
    final displayName = user.firstName != null && user.firstName!.isNotEmpty
        ? '${user.firstName} ${user.lastName ?? ''}'
        : user.userName ?? 'هذا المستخدم';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('فك الحظر'),
        content: Text('هل أنت متأكد من فك حظر $displayName؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.unblockUser(user.id!);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('فك الحظر'),
          ),
        ],
      ),
    );
  }
}
