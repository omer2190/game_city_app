import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

    return Column(
      children: [
        if (news.images != null && news.images!.isNotEmpty)
          CachedNetworkImage(
            imageUrl: news.images!.first,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            imageBuilder: (context, imageProvider) => Container(
              constraints: const BoxConstraints(
                minHeight: 150,
                maxHeight: 300,
                maxWidth: double.infinity,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              ),
            ),
          ),
        if (news.images != null && news.images!.isNotEmpty)
          const SizedBox(height: 16),
        Row(
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
                    fontSize: 12,
                  ),
                ),
              ),
            const Spacer(),
            Obx(
              () => IconButton(
                icon: Icon(
                  controller.isLiked.value
                      ? Icons.thumb_up_alt_rounded
                      : Icons.thumb_up_alt_outlined,
                  color: controller.isLiked.value
                      ? colorScheme.primary
                      : colorScheme.onSurface.withOpacity(0.5),
                  size: 28,
                ),
                onPressed: () => controller.toggleLike(news.id!),
              ),
            ),
            Obx(
              () => Text(
                '${controller.likesCount.value}',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
