import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/values/app_breakpoints.dart';
import '../../../data/models/news_model.dart';
import '../controllers/news_details_controller.dart';

class NewsDetailsInfo extends StatelessWidget {
  final News news;
  final NewsDetailsController controller;

  const NewsDetailsInfo({
    super.key,
    required this.news,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDesktop = context.isDesktop;
    final horizontalPad = isDesktop ? 24.0 : 16.0;

    return Column(
      children: [
        if (news.images != null && news.images!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: isDesktop ? 400 : 300),
              child: CachedNetworkImage(
                imageUrl: news.images!.first,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: isDesktop ? 300 : 200,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: isDesktop ? 300 : 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error, color: Colors.red),
                ),
              ),
            ),
          ),
        if (news.images != null && news.images!.isNotEmpty)
          SizedBox(height: isDesktop ? 20 : 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPad),
          child: Row(
            children: [
              if (news.newsType?.title != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    news.newsType!.title!,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: isDesktop ? 13 : 12,
                    ),
                  ),
                ),
              const Spacer(),
              Obx(
                () => Text(
                  '${controller.likesCount.value}',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: isDesktop ? 22 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Obx(
                () => IconButton(
                  icon: Icon(
                    controller.isLiked.value
                        ? Icons.thumb_up_alt_rounded
                        : Icons.thumb_up_alt_outlined,
                    color: controller.isLiked.value
                        ? colorScheme.primary
                        : colorScheme.onSurface.withOpacity(0.5),
                    size: isDesktop ? 30 : 28,
                  ),
                  onPressed: () => controller.toggleLike(news.id!),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
