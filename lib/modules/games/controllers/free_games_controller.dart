import 'package:game_city_app/data/models/game_model.dart';
import 'package:get/get.dart';
import '../../../data/repositories/games_repository.dart';

class FreeGamesController extends GetxController {
  final GamesRepository _gamesRepository = GamesRepository();
  static const int _pageSize = 20;

  var isLoading = true.obs;
  var isLoadingMore = false.obs;
  var hasMore = true.obs;
  var currentPage = 1.obs;
  var freeGames = <Game>[].obs;
  var searchQuery = ''.obs;
  var selectedPlatform = ''.obs;

  @override
  void onInit() {
    fetchFreeGames();
    super.onInit();
  }

  void fetchFreeGames({bool isLoadMore = false}) async {
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
        type: 'free',
        page: pageToLoad,
        search: searchQuery.value,
        platform: selectedPlatform.value,
        limit: _pageSize,
      );

      if (response['items'] != null) {
        final List<dynamic> items = response['items'];
        final loadedGames = items.map((item) => Game.fromJson(item)).toList();

        if (isLoadMore) {
          freeGames.addAll(loadedGames);
        } else {
          freeGames.assignAll(loadedGames);
        }

        currentPage.value = pageToLoad;
        hasMore(loadedGames.isNotEmpty);
      } else {
        if (!isLoadMore) {
          freeGames.clear();
        }
        hasMore(false);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load free games: $e');
    } finally {
      isLoading(false);
      isLoadingMore(false);
    }
  }

  void loadMoreGames() {
    fetchFreeGames(isLoadMore: true);
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
