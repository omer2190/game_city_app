import 'package:flutter/material.dart';
import 'package:game_city_app/shared/layout_mine.dart';
import 'package:get/get.dart';
import '../controllers/news_controller.dart';
import '../widgets/news_header.dart';
import '../widgets/news_categories.dart';
import '../widgets/news_card.dart';
import '../../../shared/widgets/widgets.dart';

class NewsView extends StatelessWidget {
  final NewsController controller = Get.put(NewsController());
  final TextEditingController searchController = TextEditingController();

  NewsView({super.key});

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
                if (controller.isLoading.value) {
                  return const LoadingWidget(message: 'جاري تحميل الأخبار...');
                }
                if (controller.filteredNews.isEmpty) {
                  return const Center(child: Text('لا توجد أخبار.'));
                }
                return ListView.builder(
                  itemCount: controller.filteredNews.length,
                  itemBuilder: (context, index) {
                    final news = controller.filteredNews[index];
                    return NewsCard(news: news);
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
