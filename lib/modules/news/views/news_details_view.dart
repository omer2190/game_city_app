import 'package:flutter/material.dart';
import 'package:game_city_app/core/values/app_breakpoints.dart';
import 'package:game_city_app/modules/news/widgets/news_details_body.dart';
import 'package:game_city_app/modules/news/widgets/news_details_comments.dart';
import 'package:game_city_app/modules/news/widgets/news_details_header.dart';
import 'package:game_city_app/modules/news/widgets/news_details_info.dart';
import 'package:game_city_app/shared/layout_mine.dart';
import 'package:game_city_app/shared/header.dart';
import 'package:get/get.dart';
import '../../../data/models/news_model.dart';
import '../../../data/repositories/news_repository.dart';
import '../controllers/news_details_controller.dart';

class NewsDetailsView extends StatefulWidget {
  final News? news;

  const NewsDetailsView({super.key, this.news});

  @override
  State<NewsDetailsView> createState() => _NewsDetailsViewState();
}

class _NewsDetailsViewState extends State<NewsDetailsView> {
  final NewsDetailsController controller = Get.put(NewsDetailsController());
  final TextEditingController commentController = TextEditingController();
  final NewsRepository _newsRepository = NewsRepository();

  late Future<News?> _newsFuture;
  late String newsId;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments;
    if (widget.news != null) {
      newsId = widget.news!.id!;
    } else if (args is News) {
      newsId = args.id!;
    } else if (args is Map) {
      newsId = args['newsId'] ?? args['id'] ?? '';
    } else {
      newsId = '';
    }

    _newsFuture = _newsRepository.getNewsById(newsId).then((fetchedNews) {
      controller.initDetails(fetchedNews);
      return fetchedNews;
    });

    final initialNews = widget.news ?? (args is News ? args : null);
    if (initialNews != null) {
      controller.initDetails(initialNews);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<News?>(
      future: _newsFuture,
      builder: (context, snapshot) {
        final initialNews =
            widget.news ??
            (Get.arguments is News ? Get.arguments as News : null);
        final News? displayNews = snapshot.data ?? initialNews;

        if (snapshot.connectionState == ConnectionState.waiting &&
            displayNews == null) {
          return LayoutMine(
            body: Column(
              children: [
                Header(
                  title: 'تحميل تفاصيل الخبر',
                  leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'جاري تحميل تفاصيل الخبر...',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError || displayNews == null) {
          return LayoutMine(
            body: Column(
              children: [
                Header(
                  title: 'خطأ',
                  leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'حدث خطأ أثناء تحميل تفاصيل الخبر.',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _newsFuture = _newsRepository
                                  .getNewsById(newsId)
                                  .then((fetchedNews) {
                                    controller.initDetails(fetchedNews);
                                    return fetchedNews;
                                  });
                            });
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return LayoutMine(
          body: Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  final newNews = await _newsRepository.getNewsById(newsId);
                  controller.initDetails(newNews);
                  setState(() {
                    _newsFuture = Future.value(newNews);
                  });
                },
                color: Theme.of(context).colorScheme.primary,
                child: context.isDesktop
                    ? _buildDesktopContent(displayNews)
                    : _buildMobileContent(displayNews),
              ),
              if (snapshot.connectionState == ConnectionState.waiting)
                Positioned.fill(
                  child: Container(
                    color: Theme.of(
                      context,
                    ).scaffoldBackgroundColor.withOpacity(0.3),
                    child: const Center(
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileContent(News displayNews) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const NewsDetailsHeader(),
              NewsDetailsInfo(news: displayNews, controller: controller),
              NewsDetailsBody(news: displayNews),
              NewsDetailsComments(
                newsId: displayNews.id!,
                controller: controller,
                commentController: commentController,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopContent(News displayNews) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxContentWidth = screenWidth > 1400 ? 1200.0 : screenWidth * 0.85;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main content column (left side)
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const NewsDetailsHeader(),
                        NewsDetailsInfo(
                          news: displayNews,
                          controller: controller,
                        ),
                        NewsDetailsBody(news: displayNews),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Comments column (right side) - independently scrollable
                  Expanded(
                    flex: 3,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height - 120,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: NewsDetailsComments(
                          newsId: displayNews.id!,
                          controller: controller,
                          commentController: commentController,
                        ),
                      ),
                    ),
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
