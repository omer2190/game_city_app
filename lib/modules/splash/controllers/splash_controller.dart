import 'package:flutter/material.dart';
import 'package:game_city_app/core/services/notification_service.dart';
import 'package:game_city_app/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:game_city_app/core/services/storage_service.dart';

class SplashController extends GetxController {
  SplashController();

  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Send FCM token to server if user is logged in
      await _sendFCMTokenToAPI();

      await Future.delayed(const Duration(seconds: 1));

      final token = box.read('token');
      if (token != null) {
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  Future<void> _sendFCMTokenToAPI() async {
    final token = box.read('token');
    if (token == null) return;

    try {
      if (!Get.isRegistered<NotificationService>()) {
        debugPrint('NotificationService not registered yet. Skipping token send.');
        return;
      }
      final fcmToken = await NotificationService.to.getToken();
      if (fcmToken != null) {
        box.write('fcm_token', fcmToken);
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }
}
