import 'package:flutter/material.dart';
import 'package:game_city_app/data/models/notification_model.dart';
import 'package:game_city_app/modules/notifications/controllers/notifications_controller.dart';
import 'package:game_city_app/routes/app_routes.dart';
import 'package:game_city_app/core/values/app_breakpoints.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

/// A popup panel that displays recent notifications in a styled dropdown.
/// Used on desktop/tablet screens instead of navigating to a full page.
class NotificationsPopup extends StatelessWidget {
  final NotificationsController controller;

  const NotificationsPopup({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.5)
                : colorScheme.primary.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ──────────────────────────────────────────────
          _buildHeader(context, colorScheme, isDark),
          // ── Divider ─────────────────────────────────────────────
          Divider(
            height: 1,
            thickness: 1,
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : colorScheme.primary.withOpacity(0.08),
          ),
          // ── Notifications list ─────────────────────────────────
          Flexible(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.notifications.isEmpty) {
                return const SizedBox(
                  height: 160,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                );
              }

              if (controller.notifications.isEmpty) {
                return SizedBox(
                  height: 180,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          size: 48,
                          color: isDark
                              ? Colors.white.withOpacity(0.2)
                              : colorScheme.primary.withOpacity(0.25),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'لا توجد إشعارات',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withOpacity(0.5)
                                : colorScheme.primary.withOpacity(0.5),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: controller.notifications.length.clamp(0, 8),
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  indent: 60,
                  endIndent: 16,
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : colorScheme.primary.withOpacity(0.05),
                ),
                itemBuilder: (_, i) {
                  return _NotificationTile(
                    notification: controller.notifications[i],
                    controller: controller,
                  );
                },
              );
            }),
          ),
          // ── View all button ────────────────────────────────────
          Divider(
            height: 1,
            thickness: 1,
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : colorScheme.primary.withOpacity(0.08),
          ),
          _buildViewAllButton(context, colorScheme, isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.primary.withOpacity(0.12)
                  : colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              size: 20,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'الإشعارات',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: isDark ? Colors.white : colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          Obx(() {
            final unread = controller.unreadCount;
            if (unread == 0) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$unread جديد',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildViewAllButton(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        Get.toNamed(AppRoutes.notifications);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.03)
              : colorScheme.primary.withOpacity(0.04),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'عرض جميع الإشعارات',
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Single notification tile inside the popup.
class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final NotificationsController controller;

  const _NotificationTile({
    required this.notification,
    required this.controller,
  });

  (IconData, Color) _iconForType(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final type = notification.type;
    switch (type) {
      case 'news':
        return (Icons.article_rounded, Colors.amber);
      case 'comment':
        return (Icons.comment_rounded, Colors.green);
      case 'new_like':
        return (Icons.favorite_rounded, Colors.red);
      case 'new_game':
        return (Icons.new_releases_rounded, Colors.purple);
      case 'wishlist_free':
        return (Icons.card_giftcard_rounded, Colors.pink);
      case 'wishlist_discount':
        return (Icons.local_offer_rounded, Colors.orange);
      case 'wishlist_released':
        return (Icons.rocket_launch_rounded, Colors.cyan);
      case 'looking_for_players':
        return (Icons.sports_esports_rounded, Colors.orange);
      case 'friend_request':
        return (Icons.person_add_rounded, Colors.blue);
      case 'friend_accept':
        return (Icons.group_add_rounded, Colors.teal);
      case 'chat_message':
      case 'chat':
        return (Icons.chat_rounded, Colors.lightBlue);
      case 're_engagement':
        return (Icons.waving_hand_rounded, Colors.yellow);
      case 'broadcast':
        return (Icons.campaign_rounded, Colors.deepPurple);
      default:
        return (Icons.notifications_rounded, c.primary);
    }
  }

  void _navigateToTarget() {
    final targetId = notification.data?['targetId'] as String?;
    switch (notification.type) {
      case 'news':
      case 'comment':
      case 'new_like':
        if (targetId != null) {
          Get.toNamed(AppRoutes.newsDetails, arguments: {'newsId': targetId});
        } else {
          Get.toNamed(AppRoutes.news);
        }
      case 'new_game':
      case 'wishlist_free':
      case 'wishlist_discount':
      case 'wishlist_released':
      case 'looking_for_players':
        if (targetId != null) {
          Get.toNamed(AppRoutes.gameDetails, arguments: {'gameId': targetId});
        } else {
          Get.toNamed(AppRoutes.game);
        }
      case 'friend_request':
        Get.toNamed(AppRoutes.profile);
      case 'friend_accept':
      case 'chat_message':
      case 'chat':
        Get.toNamed(AppRoutes.chatRoom);
      case 're_engagement':
      case 'broadcast':
      default:
        Get.toNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final (iconData, iconColor) = _iconForType(context);
    final timeStr = notification.createdAt != null
        ? timeago.format(notification.createdAt!, locale: 'ar')
        : '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (!notification.isRead && notification.id != null) {
            controller.markAsRead(notification.id!);
          }
          Navigator.of(context).pop();
          _navigateToTarget();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Icon ──────────────────────────────────────────
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(iconData, color: iconColor, size: 20),
                    if (!notification.isRead)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: iconColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.cardColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // ── Content ───────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title ?? 'تنبيه',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                              fontSize: 14,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? Colors.white.withOpacity(0.4)
                                : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notification.body ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: isDark
                            ? Colors.white.withOpacity(0.6)
                            : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows the notification popup anchored below the [renderBox] widget.
/// Automatically detects screen size: on desktop shows popup, on mobile navigates.
void showNotificationsPopup(
  BuildContext context, {
  required RenderBox renderBox,
  required NotificationsController controller,
}) {
  // On mobile, navigate to the full page for a better UX.
  final screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth < AppBreakpoints.tabletBreakpoint) {
    Get.toNamed(AppRoutes.notifications);
    return;
  }

  final offset = renderBox.localToGlobal(Offset.zero);
  final size = renderBox.size;

  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.25),
    builder: (dialogContext) {
      return Stack(
        children: [
          // Invisible barrier to close on tap outside
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(dialogContext).pop(),
              child: Container(color: Colors.transparent),
            ),
          ),
          // The notification popup positioned below the icon
          Positioned(
            top: offset.dy + size.height + 6,
            right: screenWidth - offset.dx - size.width - 350,
            child: Material(
              elevation: 0,
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              child: NotificationsPopup(controller: controller),
            ),
          ),
        ],
      );
    },
  );
}
