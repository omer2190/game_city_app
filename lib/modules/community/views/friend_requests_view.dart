import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:game_city_app/shared/header.dart';
import 'package:game_city_app/shared/layout_mine.dart';
import 'package:get/get.dart';
import '../controllers/friends_controller.dart';
import '../../../data/models/user_model.dart';

class FriendRequestsView extends StatelessWidget {
  const FriendRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final FriendsController controller = Get.find<FriendsController>();

    return LayoutMine(
      body: Column(
        children: [
          Header(
            title: 'طلبات الصداقة',
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: colorScheme.onBackground),
              onPressed: () => Get.back(),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isPendingLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: colorScheme.primary),
                );
              }

              if (controller.pendingRequests.isEmpty) {
                return Center(
                  child: Text(
                    'لا توجد طلبات معلقة',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: controller.pendingRequests.length,
                itemBuilder: (context, index) {
                  final user = controller.pendingRequests[index];
                  return _buildRequestTile(context, user, controller);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestTile(
    BuildContext context,
    UserModel user,
    FriendsController controller,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage:
                (user.userImage != null && user.userImage!.isNotEmpty)
                ? CachedNetworkImageProvider(user.userImage!.first)
                : null,
            child: (user.userImage == null || user.userImage!.isEmpty)
                ? const Icon(Icons.person)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              user.userName ?? '',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () => controller.acceptRequest(user.id ?? ''),
            icon: const Icon(Icons.check_circle, color: Colors.greenAccent),
          ),
          IconButton(
            onPressed: () => controller.removeOrRejectFriend(user.id ?? ''),
            icon: const Icon(Icons.cancel, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }
}
