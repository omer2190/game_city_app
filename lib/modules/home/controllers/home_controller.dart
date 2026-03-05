import 'package:get/get.dart';
import '../../notifications/controllers/notifications_controller.dart';

class HomeController extends GetxController {
  var currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Pre-initialize notifications controller to keep track of count
    Get.put(NotificationsController());
  }

  void changePage(int index) {
    currentIndex.value = index;
  }
}
