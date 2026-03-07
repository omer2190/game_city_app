import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/news_model.dart';
import '../../../data/repositories/news_repository.dart';

class NewsController extends GetxController {
  final NewsRepository _newsRepository = NewsRepository();
  var isLoading = true.obs;
  var isMoreLoading = false.obs;
  var newsList = <News>[].obs;
  var newsTypes = <NewsType>[].obs;

  // Pagination
  var currentPage = 1.obs;
  var hasMore = true.obs;

  // Filtering and Searching
  var selectedTypeId = ''.obs;
  var searchText = ''.obs;
  var isSearching = false.obs;
  var showCategories = false.obs;
  var sortBy = 'الأحدث'.obs; // 'الأحدث' or 'الأقدم'

  @override
  void onInit() {
    fetchNews();
    super.onInit();
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      setSearch('');
    }
  }

  void toggleCategories() {
    showCategories.value = !showCategories.value;
  }

  void fetchNews() async {
    try {
      isLoading(true);
      currentPage.value = 1;
      hasMore.value = true;

      var response = await _newsRepository.getNews(
        page: currentPage.value,
        newsType: selectedTypeId.value,
        search: searchText.value,
      );

      if (response.news != null) {
        newsList.assignAll(response.news!);
        // Update hasMore based on totalPages
        if (response.totalPages != null) {
          hasMore.value = currentPage.value < response.totalPages!;
        } else {
          hasMore.value = response.news!.isNotEmpty;
        }
      }
      if (response.newsTypes != null) {
        newsTypes.assignAll(response.newsTypes!);
      }
    } catch (e) {
      debugPrint(e.toString());
      Get.snackbar('Error', 'Failed to load news: $e');
    } finally {
      isLoading(false);
    }
  }

  void loadMoreNews() async {
    if (isMoreLoading.value || !hasMore.value) return;

    try {
      isMoreLoading(true);
      currentPage.value++;

      var response = await _newsRepository.getNews(
        page: currentPage.value,
        newsType: selectedTypeId.value,
        search: searchText.value,
      );

      if (response.news != null && response.news!.isNotEmpty) {
        newsList.addAll(response.news!);
        if (response.totalPages != null) {
          hasMore.value = currentPage.value < response.totalPages!;
        }
      } else {
        hasMore.value = false;
      }
    } catch (e) {
      debugPrint(e.toString());
      currentPage.value--;
    } finally {
      isMoreLoading(false);
    }
  }

  List<News> get filteredNews {
    List<News> list = newsList.toList();

    // Local Sorting (Filtering is now done in API)
    if (sortBy.value == 'الأحدث') {
      list.sort(
        (a, b) =>
            (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
      );
    } else {
      list.sort(
        (a, b) =>
            (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0)),
      );
    }

    return list;
  }

  void setCategory(String typeId) {
    if (selectedTypeId.value == typeId) return;
    selectedTypeId.value = typeId;
    fetchNews();
  }

  void setSearch(String text) {
    searchText.value = text;
    fetchNews();
  }

  void setSort(String sort) {
    sortBy.value = sort;
  }
}
