import 'package:get/get.dart';
import '../../modules/auth/controllers/auth_controller.dart';
import '../../modules/wishlist/controllers/wishlist_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
    Get.put(WishlistController(), permanent: true);
  }
}
