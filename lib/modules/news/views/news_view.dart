import 'package:flutter/material.dart';
import 'package:game_city_app/core/values/app_breakpoints.dart';
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
    final isDesktop = context.isDesktop;

    return LayoutMine(
      body: RefreshIndicator(
        onRefresh: () async => controller.fetchNews(),
        child: Column(
          children: [
            NewsHeader(
              controller: controller,
              searchController: searchController,
            ),
            NewsCategories(controller: controller),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.newsList.isEmpty) {
                  return const LoadingWidget(message: 'جاري تحميل الأخبار...');
                }
                if (controller.filteredNews.isEmpty) {
                  return const Center(child: Text('لا توجد أخبار.'));
                }
                // Grid on desktop, list on mobile/tablet
                if (isDesktop) {
                  return _buildNewsGrid(context);
                }
                return _buildNewsList(context);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsList(BuildContext context) {
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
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
      },
    );
  }

  Widget _buildNewsGrid(BuildContext context) {
    return SingleChildScrollView(
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          for (final news in controller.filteredNews)
            Container(
              constraints: const BoxConstraints(maxWidth: 400, minHeight: 350),
              child: NewsCard(news: news),
            ),
          if (controller.isMoreLoading.value)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
        ],
      ),
    );
  }
}
