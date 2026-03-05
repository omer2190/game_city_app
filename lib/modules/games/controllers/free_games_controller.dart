import 'package:game_city_app/data/models/game_model.dart';
import 'package:get/get.dart';
import '../../../data/repositories/games_repository.dart';

class FreeGamesController extends GetxController {
  final GamesRepository _gamesRepository = GamesRepository();
  var isLoading = true.obs;
  var freeGames = <Game>[].obs;
  var searchQuery = ''.obs;
  var selectedPlatform = ''.obs;

  @override
  void onInit() {
    fetchFreeGames();
    super.onInit();
  }

  void fetchFreeGames() async {
    try {
      isLoading(true);
      final response = await _gamesRepository.getGames(
        type: 'free',
        search: searchQuery.value,
        platform: selectedPlatform.value,
        limit: 100,
      );
      if (response['items'] != null) {
        final List<dynamic> items = response['items'];
        freeGames.assignAll(items.map((item) => Game.fromJson(item)).toList());
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load free games: $e');
    } finally {
      isLoading(false);
    }
  }

  void setSearchAndPlatform(String query, String platform) {
    searchQuery.value = query;
    selectedPlatform.value = platform;
    fetchFreeGames();
  }

  void setSearch(String query) {
    searchQuery.value = query;
    fetchFreeGames();
  }

  List<Game> get filteredFreeGames {
    return freeGames;
  }
}
