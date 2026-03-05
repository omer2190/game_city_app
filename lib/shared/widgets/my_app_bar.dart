import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:game_city_app/modules/auth/controllers/auth_controller.dart';
import 'package:game_city_app/routes/app_routes.dart';
import 'package:get/get.dart';

import '../../modules/notifications/controllers/notifications_controller.dart';

AppBar myAppBar(BuildContext context) {
  final theme = Theme.of(context);
  final AuthController authController = Get.find<AuthController>();
  final notificationsController = Get.find<NotificationsController>();
  return AppBar(
    elevation: 0,
    toolbarHeight: 0,
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.toNamed('/profile'),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: theme.colorScheme.primary,
                    backgroundImage:
                        authController.userModel.value?.userImage != null &&
                            authController
                                .userModel
                                .value!
                                .userImage!
                                .isNotEmpty
                        ? CachedNetworkImageProvider(
                            authController.userModel.value!.userImage![0],
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Obx(() {
                  final hour = DateTime.now().hour;
                  final greeting = (hour >= 5 && hour < 12)
                      ? 'صباح الخير'
                      : 'مساء الخير';
                  final name =
                      authController.userModel.value?.firstName ?? 'ضيف';
                  return Text(
                    '$greeting يا $name',
                    style: theme.textTheme.titleMedium,
                  );
                }),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.toNamed(AppRoutes.notifications),
                  icon: Stack(
                    children: [
                      Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        // size: 26,
                      ),
                      Obx(
                        () => notificationsController.unreadCount > 0
                            ? Positioned(
                                right: 0,
                                top: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 10,
                                    minHeight: 10,
                                  ),
                                  child: Text(
                                    '${notificationsController.unreadCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Get.toNamed('/messages');
                  },
                  icon: Icon(Icons.message_outlined),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
