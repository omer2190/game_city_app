import 'package:flutter/foundation.dart';
import 'package:game_city_app/data/repositories/auth_repository.dart';
import 'package:get/get.dart';
import 'package:game_city_app/core/services/storage_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsController extends GetxController {
  final box = GetStorage();
  final RxBool notificationsEnabled = true.obs;
  final RxString appVersion = ''.obs;
  final RxBool isRequestingPermission = false.obs;
  final AuthRepository _authRepository = AuthRepository();

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

  // bool _isStandalone() {
  //   if (!kIsWeb) return false;
  //   return web_support.isStandalone();
  // }

  // void _showIOSInstructions() {
  //   Get.dialog(
  //     AlertDialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //       title: const Text(
  //         'تفعيل الإشعارات على آيفون',
  //         textAlign: TextAlign.center,
  //         style: TextStyle(fontWeight: FontWeight.bold),
  //       ),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           const Text(
  //             'لتتمكن من استلام الإشعارات على جهاز الآيفون، يجب إضافة التطبيق للشاشة الرئيسية أولاً:',
  //             textAlign: TextAlign.center,
  //           ),
  //           const SizedBox(height: 20),
  //           _buildStep(1, 'اضغط على زر المشاركة (Share) في أسفل المتصفح.'),
  //           const SizedBox(height: 10),
  //           _buildStep(
  //             2,
  //             'اختر "إضافة إلى الشاشة الرئيسية" (Add to Home Screen).',
  //           ),
  //           const SizedBox(height: 10),
  //           _buildStep(
  //             3,
  //             'افتح التطبيق من الأيقونة الجديدة على شاشتك واطلب الإذن مجدداً.',
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Get.back(),
  //           child: const Text('حسنًا، فهمت'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildStep(int number, String text) {
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       CircleAvatar(
  //         radius: 12,
  //         backgroundColor: Get.theme.colorScheme.primary,
  //         child: Text(
  //           '$number',
  //           style: const TextStyle(fontSize: 12, color: Colors.white),
  //         ),
  //       ),
  //       const SizedBox(width: 10),
  //       Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
  //     ],
  //   );
  // }

  Future<void> requestNotificationPermission() async {
    try {
      await FirebaseMessaging.instance.requestPermission(provisional: true);

      // For apple platforms, make sure the APNS token is available before making any FCM plugin API calls
      final apnsToken = await FirebaseMessaging.instance.getToken();
      if (apnsToken != null) {
        print("///////////////////////////////////////////////////////////");
        print('APNS Token: $apnsToken');
      }

      // // 2. Get and update FCM token
      // await Get.find<AuthController>().updateFcmToken();
      if (apnsToken != null) {
        await _authRepository.updateUser({'fcmToken': apnsToken});
      }

      // 3. Mark as enabled in settings
      notificationsEnabled.value = true;
      box.write('notifications_enabled', true);

      Get.snackbar('نجاح', 'تم تفعيل الإشعارات بنجاح');
    } catch (e) {
      if (kDebugMode) {
        print('Error enabling notifications: $e');
      }

      String message = e.toString();
      // if (message.contains('NotAllowedError') ||
      //     message.contains('Permission denied')) {
      //   message = 'تم رفض الإذن. يرجى تفعيل الإشعارات من إعدادات المتصفح';
      // }

      Get.snackbar('تنبيه', message);
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
