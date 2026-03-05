import 'package:flutter/material.dart';
import 'package:game_city_app/modules/news/widgets/news_details_body.dart';
import 'package:game_city_app/modules/news/widgets/news_details_comments.dart';
import 'package:game_city_app/modules/news/widgets/news_details_header.dart';
import 'package:game_city_app/modules/news/widgets/news_details_info.dart';
import 'package:game_city_app/shared/layout_mine.dart';
import 'package:get/get.dart';
import '../../../data/models/news_model.dart';
import '../controllers/news_details_controller.dart';

class NewsDetailsView extends StatelessWidget {
  final News news;
  final NewsDetailsController controller = Get.put(NewsDetailsController());
  final TextEditingController commentController = TextEditingController();

  NewsDetailsView({super.key, required this.news}) {
    controller.initDetails(news);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutMine(
      body: RefreshIndicator(
        onRefresh: () async => controller.initDetails(news),
        color: Theme.of(context).colorScheme.primary,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const NewsDetailsHeader(),
                  NewsDetailsInfo(news: news, controller: controller),
                  NewsDetailsBody(news: news),
                  NewsDetailsComments(
                    newsId: news.id!,
                    controller: controller,
                    commentController: commentController,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
