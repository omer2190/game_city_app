import 'package:get/get.dart';
import '../../../core/services/version_service.dart';
import '../../notifications/controllers/notifications_controller.dart';

class HomeController extends GetxController {
  var currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Pre-initialize notifications controller to keep track of count
    Get.put(NotificationsController());
  }

  @override
  void onReady() {
    super.onReady();
    // Check if update dialog was dismissed during navigation
    if (Get.isRegistered<VersionService>()) {
      Get.find<VersionService>().checkAndShowIfNeeded();
    }
  }

  void changePage(int index) {
    currentIndex.value = index;
  }
}
