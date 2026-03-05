import 'package:get/get.dart';
import '../../../data/models/wishlist_model.dart';
import '../../../data/repositories/wishlist_repository.dart';

class WishlistController extends GetxController {
  final WishlistRepository _repository = WishlistRepository();

  var isLoading = false.obs;
  var wishlist = <WishlistEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchWishlist();
  }

  Future<void> fetchWishlist() async {
    isLoading.value = true;
    try {
      final items = await _repository.getMyWishlist();
      wishlist.assignAll(items);
    } catch (e) {
      // Get.snackbar('Error', 'Failed to fetch wishlist');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleWishlist(String gameId) async {
    try {
      final response = await _repository.toggleWishlist(gameId);
      if (response['success'] == true) {
        // Optimistically update the list if we know the game details
        // or just refresh. Let's refresh for now to be sure we have
        // the correct list structure.
        fetchWishlist();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update wishlist');
    }
  }

  bool isInWishlist(String gameId) {
    return wishlist.any((element) => element.game.id == gameId);
  }
}
