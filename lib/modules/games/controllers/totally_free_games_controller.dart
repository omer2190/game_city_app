import 'package:get/get.dart';
import '../../../data/models/game_model.dart';
import '../../../data/repositories/games_repository.dart';

class TotallyFreeGamesController extends GetxController {
  final GamesRepository _gamesRepository = GamesRepository();
  static const int _pageSize = 20;

  var isLoading = true.obs;
  var isLoadingMore = false.obs;
  var hasMore = true.obs;
  var currentPage = 1.obs;
  var games = <Game>[].obs;
  var searchQuery = ''.obs;
  var selectedPlatform = ''.obs;

  @override
  void onInit() {
    fetchGames();
    super.onInit();
  }

  void fetchGames({bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (isLoadingMore.value || isLoading.value || !hasMore.value) return;
      isLoadingMore(true);
    } else {
      isLoading(true);
      hasMore(true);
      currentPage.value = 1;
    }

    try {
      final pageToLoad = isLoadMore ? currentPage.value + 1 : 1;
      final response = await _gamesRepository.getGames(
        type: 'giveaway', // This is what getTotallyFreeGames used
        page: pageToLoad,
        search: searchQuery.value,
        platform: selectedPlatform.value,
        limit: _pageSize,
      );

      if (response['items'] != null) {
        final List<dynamic> items = response['items'];
        final loadedGames = items.map((item) => Game.fromJson(item)).toList();

        if (isLoadMore) {
          games.addAll(loadedGames);
        } else {
          games.assignAll(loadedGames);
        }

        currentPage.value = pageToLoad;
        hasMore(loadedGames.isNotEmpty);
      } else {
        if (!isLoadMore) {
          games.clear();
        }
        hasMore(false);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load free-to-play games: $e');
    } finally {
      isLoading(false);
      isLoadingMore(false);
    }
  }

  void loadMoreGames() {
    fetchGames(isLoadMore: true);
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
