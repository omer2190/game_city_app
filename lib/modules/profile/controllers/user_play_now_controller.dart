import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../auth/controllers/auth_controller.dart';

class UserPlayNowController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final AuthController _authController = Get.find<AuthController>();
  var playNowList = <String>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize from current user data
    if (_authController.userModel.value?.playNow != null) {
      _updatePlayNowList(_authController.userModel.value!.playNow!);
    }

    // Listen for changes in AuthController to keep in sync
    ever(_authController.userModel, (user) {
      if (user?.playNow != null) {
        _updatePlayNowList(user!.playNow!);
      }
    });
  }

  void _updatePlayNowList(List<dynamic> list) {
    if (list.isEmpty) {
      playNowList.clear();
      return;
    }

    final List<String> ids = list
        .map((item) {
          if (item is String) return item;
          if (item is Map<String, dynamic>) {
            return (item['_id'] ?? item['id'])?.toString() ?? '';
          }
          return '';
        })
        .where((id) => id.isNotEmpty)
        .toList();

    playNowList.assignAll(ids);
  }

  void addGame(String gameId) async {
    try {
      isLoading(true);
      final response = await _authRepository.addGameToPlayNow(gameId);
      if (response['playNow'] != null) {
        playNowList.assignAll(List<String>.from(response['playNow']));
        Get.snackbar('نجاح', 'تمت إضافة اللعبة إلى قائمتك');
      }
    } catch (e) {
      Get.snackbar('خطأ', e.toString());
    } finally {
      isLoading(false);
    }
  }

  void removeGame(String gameId) async {
    try {
      isLoading(true);
      final response = await _authRepository.removeGameFromPlayNow(gameId);
      if (response['playNow'] != null) {
        playNowList.assignAll(List<String>.from(response['playNow']));
        Get.snackbar('نجاح', 'تمت إزالة اللعبة من قائمتك');
      }
    } catch (e) {
      Get.snackbar('خطأ', e.toString());
    } finally {
      isLoading(false);
    }
  }

  bool isPlaying(String gameId) {
    return playNowList.contains(gameId);
  }
}
