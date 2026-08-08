import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:game_city_app/modules/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';

import '../../core/values/app_breakpoints.dart';
import '../../core/values/app_dimensions.dart';
import '../../modules/notifications/controllers/notifications_controller.dart';
import 'notifications_popup.dart';

AppBar myAppBar(BuildContext context) {
  final theme = Theme.of(context);
  final isDesktop = context.isDesktop;
  final fontSize = AppDimensions.scaledFontSize(context, 14);

  final AuthController authController = Get.isRegistered<AuthController>()
      ? Get.find<AuthController>()
      : Get.put(AuthController());

  final notificationsController = Get.isRegistered<NotificationsController>()
      ? Get.find<NotificationsController>()
      : Get.put(NotificationsController());

  return AppBar(
    elevation: 0,
    toolbarHeight: 0,
    bottom: PreferredSize(
      preferredSize: Size.fromHeight(isDesktop ? 80 : 70),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 32 : 24,
              vertical: isDesktop ? 12 : 8,
            ),
            child: Row(
              children: [
                if (Get.width < 600) ...[
                  GestureDetector(
                    onTap: () => Get.toNamed('/profile'),
                    child: CircleAvatar(
                      radius: isDesktop ? 24 : 20,
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: fontSize,
                      ),
                    );
                  }),
                ],
                const Spacer(),
                _NotificationIconButton(controller: notificationsController),
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

/// A standalone [IconButton] for notifications that holds its own [GlobalKey]
/// so the popup can be positioned accurately relative to the button.
class _NotificationIconButton extends StatefulWidget {
  final NotificationsController controller;
  const _NotificationIconButton({required this.controller});

  @override
  State<_NotificationIconButton> createState() =>
      _NotificationIconButtonState();
}

class _NotificationIconButtonState extends State<_NotificationIconButton> {
  final GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: _key,
      onPressed: () {
        final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          showNotificationsPopup(
            context,
            renderBox: renderBox,
            controller: widget.controller,
          );
        }
      },
      icon: Stack(
        children: [
          const Icon(Icons.notifications_outlined, color: Colors.white),
          Obx(
            () => widget.controller.unreadCount > 0
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
                        '${widget.controller.unreadCount}',
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
    );
  }
}
