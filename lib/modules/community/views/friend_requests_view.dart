import 'package:flutter/material.dart';
import 'package:game_city_app/core/values/app_breakpoints.dart';
import 'package:game_city_app/shared/header.dart';
import 'package:game_city_app/shared/layout_mine.dart';
import 'package:game_city_app/shared/widgets/safe_cached_avatar.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import 'user_profile_view.dart';
import '../controllers/friends_controller.dart';

class FriendRequestsView extends StatelessWidget {
  const FriendRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    final FriendsController controller = Get.find<FriendsController>();
    final isDesktop = context.isDesktop;

    return LayoutMine(
      body: Column(
        children: [
          Header(
            title: 'طلبات الصداقة',
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isPendingLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.pendingRequests.isEmpty) {
                return _buildEmptyState(context, isDesktop);
              }

              if (isDesktop) {
                return _buildDesktopList(context, controller);
              }
              return _buildMobileList(context, controller);
            }),
          ),
        ],
      ),
    );
  }

  // ──────────────────────── Desktop Layout ────────────────────────────

  Widget _buildDesktopList(BuildContext context, FriendsController ctrl) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          itemCount: ctrl.pendingRequests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (_, i) =>
              _buildDesktopCard(context, ctrl.pendingRequests[i], ctrl),
        ),
      ),
    );
  }

  Widget _buildDesktopCard(
    BuildContext context,
    UserModel user,
    FriendsController ctrl,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.onSurface.withOpacity(0.06)),
      ),
      color: cs.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // ── Avatar ──────────────────────────────────────────────
            GestureDetector(
              onTap: () {
                if (Get.width > AppBreakpoints.mobileBreakpoint) {
                  Get.dialog(
                    UserProfileView(
                      userId: user.id ?? '',
                      heroTag: 'avatar_${user.id}',
                    ),
                  );
                } else {
                  Get.to(() => UserProfileView(userId: user.id!));
                }
              },
              child: SafeCachedAvatar(
                imageUrl: user.userImage?.isNotEmpty == true
                    ? user.userImage!.first
                    : null,
                fallbackName: user.userName,
                radius: 32,
                borderColor: cs.primary.withOpacity(0.15),
                borderWidth: 2,
              ),
            ),
            const SizedBox(width: 20),
            // ── Info ────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.userName ?? 'مستخدم',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (user.userProfile?.bio != null &&
                      user.userProfile!.bio!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      user.userProfile!.bio!,
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            // ── Actions ─────────────────────────────────────────────
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () => ctrl.acceptRequest(user.id ?? ''),
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('قبول'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _confirmReject(context, user, ctrl),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('رفض'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────── Mobile Layout ─────────────────────────────

  Widget _buildMobileList(BuildContext context, FriendsController ctrl) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: ctrl.pendingRequests.length,
      itemBuilder: (_, i) {
        final user = ctrl.pendingRequests[i];
        return _buildMobileCard(context, user, ctrl);
      },
    );
  }

  Widget _buildMobileCard(
    BuildContext context,
    UserModel user,
    FriendsController ctrl,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (Get.width > AppBreakpoints.mobileBreakpoint) {
                Get.dialog(
                  UserProfileView(
                    userId: user.id ?? '',
                    heroTag: 'avatar_${user.id}',
                  ),
                );
              } else {
                Get.to(() => UserProfileView(userId: user.id!));
              }
            },
            child: SafeCachedAvatar(
              imageUrl: user.userImage?.isNotEmpty == true
                  ? user.userImage!.first
                  : null,
              fallbackName: user.userName,
              radius: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user.userName ?? '',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (user.userProfile?.bio != null &&
                    user.userProfile!.bio!.isNotEmpty)
                  Text(
                    user.userProfile!.bio!,
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          _ActionButton(
            icon: Icons.check_circle_outline,
            color: Colors.greenAccent,
            tooltip: 'قبول',
            onTap: () => ctrl.acceptRequest(user.id ?? ''),
          ),
          const SizedBox(width: 4),
          _ActionButton(
            icon: Icons.highlight_remove_rounded,
            color: Colors.redAccent,
            tooltip: 'رفض',
            onTap: () => _confirmReject(context, user, ctrl),
          ),
        ],
      ),
    );
  }

  // ──────────────────────── Shared Helpers ────────────────────────────

  Widget _buildEmptyState(BuildContext context, bool isDesktop) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_add_disabled_rounded,
              size: isDesktop ? 88 : 64,
              color: cs.onSurface.withOpacity(0.1),
            ),
            const SizedBox(height: 20),
            Text(
              'لا توجد طلبات صداقة معلقة',
              style: TextStyle(
                color: cs.onSurface.withOpacity(0.4),
                fontSize: isDesktop ? 18 : 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'عندما يرسل لك شخص طلب صداقة، سيظهر هنا',
              style: TextStyle(
                color: cs.onSurface.withOpacity(0.25),
                fontSize: isDesktop ? 14 : 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReject(
    BuildContext context,
    UserModel user,
    FriendsController controller,
  ) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('رفض طلب الصداقة'),
        content: Text(
          'هل أنت متأكد من رفض طلب الصداقة من ${user.userName ?? "هذا المستخدم"}؟',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              controller.removeOrRejectFriend(user.id ?? '');
              Get.back();
            },
            child: const Text('رفض', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// Compact icon-button wrapper for mobile action buttons.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: color, size: 22),
        padding: EdgeInsets.zero,
        tooltip: tooltip,
        style: IconButton.styleFrom(
          backgroundColor: color.withOpacity(0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
