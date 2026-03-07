import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/notification_repository.dart';

class NotificationsController extends GetxController {
  final NotificationRepository _repository = NotificationRepository();

  var notifications = <NotificationModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading(true);
      final list = await _repository.getNotifications();
      notifications.assignAll(list);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل جلب الإشعارات: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final success = await _repository.markAsRead(id);
      if (success) {
        final index = notifications.indexWhere((n) => n.id == id);
        if (index != -1) {
          // Update local state without re-fetching
          final updated = NotificationModel(
            id: notifications[index].id,
            userId: notifications[index].userId,
            title: notifications[index].title,
            body: notifications[index].body,
            type: notifications[index].type,
            data: notifications[index].data,
            isRead: true,
            createdAt: notifications[index].createdAt,
          );
          notifications[index] = updated;
        }
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}
