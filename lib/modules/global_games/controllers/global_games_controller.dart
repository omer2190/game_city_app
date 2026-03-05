import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/games_repository.dart';

class GlobalGamesController extends GetxController {
  final GamesRepository _gamesRepository = GamesRepository();
  var games = <dynamic>[].obs;
  var isLoading = false.obs;
  var isMoreLoading = false.obs;
  var currentPage = 1;
  var hasMore = true.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    fetchGames();
    super.onInit();
  }

  void fetchGames({bool isLoadMore = false, bool isPageChange = false}) async {
    if (isLoadMore) {
      if (isMoreLoading.value || !hasMore.value) return;
      isMoreLoading(true);
      currentPage++;
    } else if (isPageChange) {
      isLoading(true);
      // Keep current page, just fetching new data for it
    } else {
      isLoading(true);
      currentPage = 1;
      games.clear();
      hasMore(true);
    }

    try {
      final response = await _gamesRepository.getGlobalGames(
        page: currentPage,
        search: searchQuery.value,
      );

      if (response.isEmpty) {
        hasMore(false);
        if (isPageChange && currentPage > 1) {
          // If we tried to change page but found nothing, maybe rollback?
          // But usually hasMore check prevents this.
          games.clear();
        }
      } else {
        if (isPageChange) {
          games.assignAll(response);
        } else if (isLoadMore) {
          games.addAll(response);
        } else {
          games.assignAll(response);
        }

        if (response.length < 20) {
          hasMore(false);
        } else {
          hasMore(true);
        }
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحميل الألعاب: $e');
    } finally {
      isLoading(false);
      isMoreLoading(false);
    }
  }

  void nextPage() {
    if (!hasMore.value) return;
    currentPage++;
    fetchGames(isPageChange: true);
  }

  void previousPage() {
    if (currentPage <= 1) return;
    currentPage--;
    hasMore(true); // Reset hasMore when going back
    fetchGames(isPageChange: true);
  }

  void search(String query) {
    searchQuery.value = query;
    fetchGames();
  }

  void requestGameAddition() async {
    if (searchQuery.value.isEmpty) return;

    try {
      isLoading(true);
      final result = await _gamesRepository.searchGlobalGame(searchQuery.value);
      final int statusCode = result['statusCode'] ?? 500;

      if (statusCode == 200) {
        // Scenario 1: Found locally
        final game = result['game'];
        if (game != null) {
          games.assignAll([game]);
          hasMore(false); // Stop pagination since we have specific result
        }
        Get.snackbar(
          'موجودة!',
          'وجدنا اللعبة في مكتبتنا المحلية.',
          backgroundColor: Colors.blueAccent.withOpacity(0.1),
          colorText: Colors.white,
        );
      } else if (statusCode == 201) {
        // Scenario 2: Found externally
        final List<dynamic> foundGames = result['games'] ?? [];
        if (foundGames.isNotEmpty) {
          games.assignAll(foundGames);
          hasMore(false);
        }
        Get.snackbar(
          'تمت الإضافة!',
          'وجدنا ${foundGames.length} لعبة وتمت إضافتها للمكتبة.',
          backgroundColor: Colors.greenAccent.withOpacity(0.1),
          colorText: Colors.white,
        );
      } else if (statusCode == 202) {
        // Scenario 3: Queued
        Get.snackbar(
          'جاري البحث...',
          'لم نجدها فوراً، لكننا بدأنا بحثاً متقدماً. تحقق لاحقاً!',
          backgroundColor: Colors.amber.withOpacity(0.1),
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      print('Error requesting game addition: $e');
      Get.snackbar('خطأ', 'فشل البحث المتقدم: $e');
    } finally {
      isLoading(false);
    }
  }
}
