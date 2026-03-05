import 'package:game_city_app/data/models/game_model.dart';
import 'package:get/get.dart';
import '../../../data/repositories/games_repository.dart';

class DiscountedGamesController extends GetxController {
  final GamesRepository _gamesRepository = GamesRepository();
  var isLoading = true.obs;
  var games = <Game>[].obs;
  var searchQuery = ''.obs;
  var selectedPlatform = ''.obs;

  @override
  void onInit() {
    fetchGames();
    super.onInit();
  }

  void fetchGames() async {
    try {
      isLoading(true);
      final response = await _gamesRepository.getGames(
        type: 'discounted',
        search: searchQuery.value,
        platform: selectedPlatform.value,
        limit: 100,
      );
      if (response['items'] != null) {
        final List<dynamic> items = response['items'];
        games.assignAll(items.map((item) => Game.fromJson(item)).toList());
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load discounted games: $e');
    } finally {
      isLoading(false);
    }
  }

  void setSearchAndPlatform(String query, String platform) {
    searchQuery.value = query;
    selectedPlatform.value = platform;
    fetchGames();
  }

  void setSearch(String query) {
    searchQuery.value = query;
    fetchGames();
  }
}
