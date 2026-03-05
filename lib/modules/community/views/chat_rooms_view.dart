import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../controllers/rooms_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import 'chat_room_view.dart';
import '../../../shared/widgets/widgets.dart';

class ChatRoomsView extends StatelessWidget {
  ChatRoomsView({super.key});
  final RoomsController controller = Get.put(RoomsController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(() {
      if (controller.isLoading.value) {
        return const LoadingWidget(message: 'جاري تحميل الغرف...');
      }

      final rooms = controller.rooms;
      if (rooms.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: colorScheme.onBackground.withOpacity(0.1),
              ),
              const SizedBox(height: 12),
              Text(
                'لا توجد غرف متاحة حالياً',
                style: TextStyle(
                  color: colorScheme.onBackground.withOpacity(0.3),
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchRooms(),
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemBuilder: (ctx, idx) {
            final room = rooms[idx] as Map<String, dynamic>;
            final roomId = (room['_id'] ?? room['id'])?.toString() ?? '';
            final authController = Get.find<AuthController>();

            return CustomCard(
              padding: const EdgeInsets.all(12),
              onTap: () async {
                if (roomId.isEmpty) return;
                final ok = await controller.joinRoom(roomId);
                if (ok) {
                  Get.to(
                    () => ChatRoomView(
                      roomId: roomId,
                      roomName: room['name'] ?? 'غرفة',
                    ),
                  );
                }
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.groups_rounded,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              room['name'] ?? 'غرفة المعجبين',
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Obx(() {
                              final lastMsg = controller.lastMessages[roomId];
                              if (lastMsg == null)
                                return const SizedBox.shrink();

                              final date = DateTime.fromMillisecondsSinceEpoch(
                                lastMsg['timestamp'] as int,
                              );
                              return Text(
                                timeago.format(date, locale: 'en_short'),
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 10,
                                ),
                              );
                            }),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Obx(() {
                          final lastMsg = controller.lastMessages[roomId];
                          if (lastMsg == null) {
                            return Text(
                              room['description'] ?? '',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          }

                          final senderId = lastMsg['senderId'];
                          final isMe =
                              senderId == authController.userModel.value?.id;
                          final senderName = isMe
                              ? 'أنت'
                              : (lastMsg['senderName'] ?? 'مشارك');

                          return Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '$senderName: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface.withOpacity(
                                      0.7,
                                    ),
                                    fontSize: 12,
                                  ),
                                ),
                                TextSpan(
                                  text: lastMsg['text'] ?? '',
                                  style: TextStyle(
                                    color: colorScheme.onSurface.withOpacity(
                                      0.5,
                                    ),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: colorScheme.onSurface.withOpacity(0.2),
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: rooms.length,
        ),
      );
    });
  }
}
