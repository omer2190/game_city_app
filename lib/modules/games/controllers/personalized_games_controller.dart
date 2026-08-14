import 'package:get/get.dart';
import '../../../data/models/game_model.dart';
import '../../../data/repositories/games_repository.dart';

class PersonalizedGamesController extends GetxController {
  final GamesRepository _repository = GamesRepository();

  // ── Sections state ──────────────────────────────────────────────────────
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  final forYou = <Game>[].obs;
  final freeGames = <Game>[].obs;
  final discountedGames = <Game>[].obs;
  final giveaways = <Game>[].obs;
  final recentlyAdded = <Game>[].obs;
  final topRated = <Game>[].obs;
  final mostPlayed = <Game>[].obs;
  final comingSoon = <Game>[].obs;
  final favoriteGames = <Game>[].obs;
  final playNowGames = <Game>[].obs;

  // ── Search mode flag ────────────────────────────────────────────────────
  final isSearchMode = false.obs;

  // ── Search / Filter / Pagination state ──────────────────────────────────
  final searchResults = <Game>[].obs;
  final searchLoading = false.obs;
  final isLoadingMore = false.obs;
  final searchError = ''.obs;

  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final totalCount = 0.obs;
  final hasMore = true.obs;

  final searchQuery = ''.obs;
  final selectedType = ''.obs;
  final selectedGenre = ''.obs;
  final sectionTitle = ''.obs;

  // Available filters (from /api/games/filters)
  final genres = <String>[].obs;
  final sourceTypes = <String>[].obs;
  final platforms = <String>[].obs;
  final filtersLoading = false.obs;

  // ── Lifecycle ───────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    fetchPersonalizedGames();
    _fetchFilters();
  }

  // ── Sections fetching ───────────────────────────────────────────────────

  Future<void> fetchPersonalizedGames() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.getPersonalizedGames();

      if (response['success'] == true) {
        _parseSection(response, 'forYou', forYou);
        _parseSection(response, 'freeGames', freeGames);
        _parseSection(response, 'discountedGames', discountedGames);
        _parseSection(response, 'giveaways', giveaways);
        _parseSection(response, 'recentlyAdded', recentlyAdded);
        _parseSection(response, 'topRated', topRated);
        _parseSection(response, 'mostPlayed', mostPlayed);
        _parseSection(response, 'comingSoon', comingSoon);
        _parseSection(response, 'favoriteGames', favoriteGames);
        _parseSection(response, 'playNowGames', playNowGames);
      } else {
        errorMessage.value = 'حدث خطأ في تحميل البيانات';
      }
    } catch (e) {
      errorMessage.value = 'تعذر الاتصال بالخادم';
    } finally {
      isLoading.value = false;
    }
  }

  void _parseSection(
    Map<String, dynamic> response,
    String key,
    RxList<Game> target,
  ) {
    if (response[key] != null && response[key] is List) {
      target.value = (response[key] as List)
          .map((item) => Game.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      target.clear();
    }
  }

  /// Pull-to-refresh: refresh sections or search results depending on mode
  @override
  Future<void> refresh() async {
    if (isSearchMode.value) {
      await _fetchGames(reset: true);
    } else {
      await fetchPersonalizedGames();
    }
  }

  // ── Fetch filters ───────────────────────────────────────────────────────

  Future<void> _fetchFilters() async {
    filtersLoading.value = true;
    try {
      final response = await _repository.getGameFilters();
      if (response['success'] == true) {
        genres.value = List<String>.from(response['genres'] ?? []);
        sourceTypes.value = List<String>.from(response['sourceTypes'] ?? []);
        platforms.value = List<String>.from(response['platforms'] ?? []);
      }
    } catch (_) {
      // Silently fail — filters are optional
    } finally {
      filtersLoading.value = false;
    }
  }

  // ── Search / Paginated fetch ────────────────────────────────────────────

  Future<void> _fetchGames({bool reset = false}) async {
    if (reset) {
      currentPage.value = 1;
      hasMore.value = true;
      searchLoading.value = true;
      searchResults.clear();
    } else {
      if (!hasMore.value || isLoadingMore.value) return;
      isLoadingMore.value = true;
    }

    searchError.value = '';

    try {
      final response = await _repository.searchPersonalizedGames(
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        type: selectedType.value.isEmpty ? null : selectedType.value,
        genre: selectedGenre.value.isEmpty ? null : selectedGenre.value,
        page: currentPage.value,
        limit: 20,
      );

      if (response['success'] == true) {
        final items = response['items'] as List<dynamic>? ?? [];
        final newGames = items
            .map((e) => Game.fromJson(e as Map<String, dynamic>))
            .toList();

        if (reset) {
          searchResults.value = newGames;
        } else {
          searchResults.addAll(newGames);
        }

        totalPages.value = response['totalPages'] ?? 1;
        totalCount.value = response['total'] ?? 0;
        hasMore.value = currentPage.value < totalPages.value;
        currentPage.value++;
      } else {
        searchError.value = 'حدث خطأ في تحميل البيانات';
      }
    } catch (e) {
      searchError.value = 'تعذر الاتصال بالخادم';
    } finally {
      searchLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // ── Public actions ──────────────────────────────────────────────────────

  /// Enter search mode with optional pre-selected filters and section title
  void enterSearchMode({
    String? title,
    String? type,
    String? genre,
    String? search,
  }) {
    if (title != null) sectionTitle.value = title;
    if (type != null) selectedType.value = type;
    if (genre != null) selectedGenre.value = genre;
    if (search != null) searchQuery.value = search;
    isSearchMode.value = true;
    _fetchGames(reset: true);
  }

  /// Exit search mode and return to sections
  void exitSearchMode() {
    isSearchMode.value = false;
    searchQuery.value = '';
    selectedType.value = '';
    selectedGenre.value = '';
    searchResults.clear();
    searchError.value = '';
  }

  /// Load next page (infinite scroll)
  Future<void> loadMore() => _fetchGames(reset: false);

  /// Update search query and reload
  void onSearchChanged(String value) {
    searchQuery.value = value;
    _fetchGames(reset: true);
  }

  /// Update type filter and reload
  void onTypeChanged(String type) {
    if (selectedType.value == type) {
      selectedType.value = '';
    } else {
      selectedType.value = type;
    }
    _fetchGames(reset: true);
  }

  /// Update genre filter and reload
  void onGenreChanged(String genre) {
    if (selectedGenre.value == genre) {
      selectedGenre.value = '';
    } else {
      selectedGenre.value = genre;
    }
    _fetchGames(reset: true);
  }

  /// Clear all filters and search query
  void clearFilters() {
    searchQuery.value = '';
    selectedType.value = '';
    selectedGenre.value = '';
    _fetchGames(reset: true);
  }
}
