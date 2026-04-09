import 'package:get/get.dart';
import '../../modules/auth/controllers/auth_controller.dart';
import '../../modules/wishlist/controllers/wishlist_controller.dart';
import '../../modules/notifications/controllers/notifications_controller.dart';
import '../services/notification_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
    Get.put(WishlistController(), permanent: true);
    Get.put(NotificationsController(), permanent: true);
    Get.lazyPut(() => NotificationService());
  }
}
