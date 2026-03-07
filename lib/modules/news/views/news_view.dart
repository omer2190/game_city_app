import 'package:flutter/material.dart';
import 'package:game_city_app/shared/layout_mine.dart';
import 'package:get/get.dart';
import '../controllers/news_controller.dart';
import '../widgets/news_header.dart';
import '../widgets/news_categories.dart';
import '../widgets/news_card.dart';
import '../../../shared/widgets/widgets.dart';

class NewsView extends StatefulWidget {
  const NewsView({super.key});

  @override
  State<NewsView> createState() => _NewsViewState();
}

class _NewsViewState extends State<NewsView> {
  final NewsController controller = Get.put(NewsController());
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        controller.loadMoreNews();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutMine(
      body: RefreshIndicator(
        onRefresh: () async => controller.fetchNews(),
        child: Column(
          children: [
            // Extracted Header Logic
            NewsHeader(
              controller: controller,
              searchController: searchController,
            ),

            // Extracted Categories Logic
            NewsCategories(controller: controller),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.newsList.isEmpty) {
                  return const LoadingWidget(message: 'جاري تحميل الأخبار...');
                }
                if (controller.filteredNews.isEmpty) {
                  return const Center(child: Text('لا توجد أخبار.'));
                }
                return ListView.builder(
                  controller: scrollController,
                  itemCount:
                      controller.filteredNews.length +
                      (controller.isMoreLoading.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < controller.filteredNews.length) {
                      final news = controller.filteredNews[index];
                      return NewsCard(news: news);
                    } else {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
