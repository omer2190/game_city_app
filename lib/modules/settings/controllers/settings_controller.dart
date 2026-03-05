import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsController extends GetxController {
  final box = GetStorage();
  final RxBool notificationsEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Load saved setting, default to true
    notificationsEnabled.value = box.read('notifications_enabled') ?? true;
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
