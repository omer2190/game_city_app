import 'package:get/get.dart';
import '../../../data/models/game_model.dart';
import '../../../data/repositories/games_repository.dart';

class GameComingSoonController extends GetxController {
  final GamesRepository _gamesRepository = GamesRepository();
  final RxList<Game> games = <Game>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchComingSoon();
  }

  Future<void> fetchComingSoon() async {
    try {
      isLoading.value = true;
      final result = await _gamesRepository.getComingSoonGames();
      games.value = result;
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحميل الألعاب القادمة: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
