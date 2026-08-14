import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/news_model.dart';

class NewsCard extends StatelessWidget {
  final News news;

  const NewsCard({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/news-details', arguments: news),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (news.images != null && news.images!.isNotEmpty)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _buildImageStack(context),
                ),
              if (news.images != null && news.images!.isNotEmpty)
                const SizedBox(height: 8),
              _buildNewsTypeTag(context),
              const SizedBox(height: 6),
              Text(
                news.title ?? 'بدون عنوان',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                news.contentNew ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageStack(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: news.images!.first,
            placeholder: (context, url) => Container(
              color: Colors.grey[900],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[900],
              child: const Icon(Icons.error, color: Colors.red),
            ),
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
          if (news.newsType?.title != null)
            Positioned(top: 8, right: 8, child: _buildBadge(context)),
        ],
      ),
    );
  }

  Widget _buildNewsTypeTag(BuildContext context) {
    if (news.newsType?.title == null ||
        (news.images != null && news.images!.isNotEmpty)) {
      return const SizedBox.shrink();
    }
    return _buildBadge(context);
  }

  Widget _buildBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        news.newsType!.title!,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
