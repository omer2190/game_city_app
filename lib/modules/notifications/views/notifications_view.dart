import 'package:flutter/material.dart';
import 'package:game_city_app/shared/header.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../controllers/notifications_controller.dart';
import '../../../data/models/notification_model.dart';
import '../../../shared/layout_mine.dart';
import '../../../shared/widgets/widgets.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    if (!Get.isRegistered<NotificationsController>()) {
      Get.put(NotificationsController());
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutMine(
      body: Column(
        children: [
          // Header
          Header(
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Get.back(),
            ),
            title: 'الإشعارات',
            trailing: Obx(
              () => controller.unreadCount > 0
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.secondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${controller.unreadCount} غير مقروء',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),

          // Padding(
          //   padding: const EdgeInsets.fromLTRB(16, 60, 16, 20),
          //   child: Row(
          //     children: [
          //       Container(
          //         decoration: BoxDecoration(
          //           color: Colors.white.withOpacity(0.1),
          //           borderRadius: BorderRadius.circular(12),
          //         ),
          //         child: IconButton(
          //           icon: const Icon(
          //             Icons.arrow_back_ios_new_rounded,
          //             color: Colors.white,
          //             size: 20,
          //           ),
          //           onPressed: () => Get.back(),
          //         ),
          //       ),
          //       const SizedBox(width: 16),
          //       const Text(
          //         'الإشعارات',
          //         style: TextStyle(
          //           color: Colors.white,
          //           fontSize: 24,
          //           fontWeight: FontWeight.bold,
          //         ),
          //       ),
          //       const Spacer(),
          //       Obx(
          //         () => controller.unreadCount > 0
          //             ? Container(
          //                 padding: const EdgeInsets.symmetric(
          //                   horizontal: 10,
          //                   vertical: 4,
          //                 ),
          //                 decoration: BoxDecoration(
          //                   color: colorScheme.secondary,
          //                   borderRadius: BorderRadius.circular(20),
          //                 ),
          //                 child: Text(
          //                   '${controller.unreadCount} غير مقروء',
          //                   style: const TextStyle(
          //                     color: Colors.white,
          //                     fontSize: 12,
          //                     fontWeight: FontWeight.bold,
          //                   ),
          //                 ),
          //               )
          //             : const SizedBox.shrink(),
          //       ),
          //     ],
          //   ),
          // ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.notifications.isEmpty) {
                return const Center(
                  child: LoadingWidget(message: 'جاري جلب الإشعارات...'),
                );
              }

              if (controller.notifications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 80,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد إشعارات حالياً',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchNotifications(),
                color: colorScheme.primary,
                child: ListView.builder(
                  // padding: const EdgeInsets.symmetric(
                  //   horizontal: 16,
                  //   vertical: 10,
                  // ),
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

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationsController>();
    final colorScheme = Theme.of(context).colorScheme;

    // Icon and color based on type
    IconData iconData = Icons.notifications_rounded;
    Color iconColor = colorScheme.primary;

    switch (notification.type) {
      case 'match_found':
        iconData = Icons.sports_esports_rounded;
        iconColor = Colors.orange;
        break;
      case 'friend_request':
        iconData = Icons.person_add_rounded;
        iconColor = Colors.blue;
        break;
      case 'comment':
        iconData = Icons.comment_rounded;
        iconColor = Colors.green;
        break;
    }

    return GestureDetector(
      onTap: () {
        if (!notification.isRead && notification.id != null) {
          controller.markAsRead(notification.id!);
        }
        // Handle navigation based on type here if needed
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
