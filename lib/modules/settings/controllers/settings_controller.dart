import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:game_city_app/core/services/storage_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/services/notification_service.dart';
import '../../auth/controllers/auth_controller.dart';
import 'non_web_support.dart'
    if (dart.library.html) 'web_support.dart'
    as web_support;

class SettingsController extends GetxController {
  final box = GetStorage();
  final RxBool notificationsEnabled = true.obs;
  final RxString appVersion = ''.obs;
  final RxBool isRequestingPermission = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load saved setting, default to true
    notificationsEnabled.value = box.read('notifications_enabled') ?? true;
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = packageInfo.version;
    } catch (e) {
      appVersion.value = '1.0.0';
    }
  }

  bool _isStandalone() {
    if (!kIsWeb) return false;
    return web_support.isStandalone();
  }

  void _showIOSInstructions() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'تفعيل الإشعارات على آيفون',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'لتتمكن من استلام الإشعارات على جهاز الآيفون، يجب إضافة التطبيق للشاشة الرئيسية أولاً:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildStep(1, 'اضغط على زر المشاركة (Share) في أسفل المتصفح.'),
            const SizedBox(height: 10),
            _buildStep(
              2,
              'اختر "إضافة إلى الشاشة الرئيسية" (Add to Home Screen).',
            ),
            const SizedBox(height: 10),
            _buildStep(
              3,
              'افتح التطبيق من الأيقونة الجديدة على شاشتك واطلب الإذن مجدداً.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('حسنًا، فهمت'),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: Get.theme.colorScheme.primary,
          child: Text(
            '$number',
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  Future<void> requestNotificationPermission() async {
    try {
      // Check if it's iOS Web and not in PWA mode
      if (kIsWeb &&
          defaultTargetPlatform == TargetPlatform.iOS &&
          !_isStandalone()) {
        _showIOSInstructions();
        return;
      }

      isRequestingPermission.value = true;
      // 1. Initialize notification service (this triggers the browser prompt)
      await NotificationService.to.init();

      // 2. Get and update FCM token
      await Get.find<AuthController>().updateFcmToken();

      // 3. Mark as enabled in settings
      notificationsEnabled.value = true;
      box.write('notifications_enabled', true);

      Get.snackbar(
        'نجاح',
        'تم تفعيل الإشعارات بنجاح',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error enabling notifications: $e');
      }

      String message = e.toString();
      // if (message.contains('NotAllowedError') ||
      //     message.contains('Permission denied')) {
      //   message = 'تم رفض الإذن. يرجى تفعيل الإشعارات من إعدادات المتصفح';
      // }

      Get.snackbar('تنبيه', message, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isRequestingPermission.value = false;
    }
  }

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
    box.write('notifications_enabled', value);

    if (value) {
      // Subscribe to topic or enable notifications
      FirebaseMessaging.instance.subscribeToTopic('all');
    } else {
      // Unsubscribe
      FirebaseMessaging.instance.unsubscribeFromTopic('all');
    }
  }

  Future<void> openPrivacyPolicy() async {
    const url = 'https://gmaingcity.com/privacy-policy';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Get.snackbar('خطأ', 'تعذر فتح رابط سياسة الخصوصية');
    }
  }
}
