import 'package:flutter/material.dart';
import 'package:game_city_app/shared/header.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../controllers/notifications_controller.dart';
import '../../../data/models/notification_model.dart';
import '../../../shared/layout_mine.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../routes/app_routes.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<NotificationsController>()) {
      Get.put(NotificationsController());
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutMine(
      body: Column(
        children: [
          Header(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => Get.back(),
            ),
            title: 'الإشعارات',
            trailing: Obx(
              () => controller.unreadCount > 0
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.secondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${controller.unreadCount} غير مقروء',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.notifications.isEmpty) {
                return const Center(child: LoadingWidget(message: 'جاري جلب الإشعارات...'));
              }

              if (controller.notifications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none_rounded, size: 80, color: Colors.white.withOpacity(0.2)),
                      const SizedBox(height: 16),
                      Text('لا توجد إشعارات حالياً', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16)),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchNotifications(),
                color: colorScheme.primary,
                child: ListView.builder(
                  itemCount: controller.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = controller.notifications[index];
                    return _NotificationItem(notification: notification);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationItem({required this.notification});

  void _navigateToTarget(BuildContext context) {
    final type = notification.type;
    final targetId = notification.data?['targetId'] as String?;

    switch (type) {
      case 'news':
      case 'comment':
      case 'new_like':
        if (targetId != null) {
          Get.toNamed(AppRoutes.newsDetails, arguments: {'newsId': targetId});
        } else {
          Get.toNamed(AppRoutes.news);
        }
        break;

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
        break;

      case 'friend_request':
        Get.toNamed(AppRoutes.profile);
        break;

      case 'friend_accept':
      case 'chat_message':
      case 'chat':
        Get.toNamed(AppRoutes.chatRoom);
        break;

      case 're_engagement':
      case 'broadcast':
      default:
        Get.toNamed(AppRoutes.home);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationsController>();
    final colorScheme = Theme.of(context).colorScheme;

    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case 'news':
        iconData = Icons.article_rounded;
        iconColor = Colors.amber;
        break;
      case 'comment':
        iconData = Icons.comment_rounded;
        iconColor = Colors.green;
        break;
      case 'new_like':
        iconData = Icons.favorite_rounded;
        iconColor = Colors.red;
        break;
      case 'new_game':
        iconData = Icons.new_releases_rounded;
        iconColor = Colors.purple;
        break;
      case 'wishlist_free':
        iconData = Icons.card_giftcard_rounded;
        iconColor = Colors.pink;
        break;
      case 'wishlist_discount':
        iconData = Icons.local_offer_rounded;
        iconColor = Colors.orange;
        break;
      case 'wishlist_released':
        iconData = Icons.rocket_launch_rounded;
        iconColor = Colors.cyan;
        break;
      case 'looking_for_players':
        iconData = Icons.sports_esports_rounded;
        iconColor = Colors.orange;
        break;
      case 'friend_request':
        iconData = Icons.person_add_rounded;
        iconColor = Colors.blue;
        break;
      case 'friend_accept':
        iconData = Icons.group_add_rounded;
        iconColor = Colors.teal;
        break;
      case 'chat_message':
      case 'chat':
        iconData = Icons.chat_rounded;
        iconColor = Colors.lightBlue;
        break;
      case 're_engagement':
        iconData = Icons.waving_hand_rounded;
        iconColor = Colors.yellow;
        break;
      case 'broadcast':
        iconData = Icons.campaign_rounded;
        iconColor = Colors.deepPurple;
        break;
      default:
        iconData = Icons.notifications_rounded;
        iconColor = colorScheme.primary;
    }

    return GestureDetector(
      onTap: () {
        if (!notification.isRead && notification.id != null) {
          controller.markAsRead(notification.id!);
        }
        _navigateToTarget(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.white.withOpacity(0.05)
              : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: notification.isRead
              ? null
              : Border.all(
                  color: colorScheme.primary.withOpacity(0.3),
                  width: 1.5,
                ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title ?? 'تنبيه',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: notification.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.createdAt != null
                        ? timeago.format(notification.createdAt!, locale: 'ar')
                        : '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
