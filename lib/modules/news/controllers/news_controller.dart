import 'package:get/get.dart';
import '../../../data/models/news_model.dart';
import '../../../data/repositories/news_repository.dart';

class NewsController extends GetxController {
  final NewsRepository _newsRepository = NewsRepository();
  var isLoading = true.obs;
  var newsList = <News>[].obs;
  var newsTypes = <NewsType>[].obs;

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
      var response = await _newsRepository.getNews(
        newsType: selectedTypeId.value,
        search: searchText.value,
      );
      if (response.news != null) {
        newsList.assignAll(response.news!);
      }
      if (response.newsTypes != null) {
        newsTypes.assignAll(response.newsTypes!);
      }
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'Failed to load news: $e');
    } finally {
      isLoading(false);
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
