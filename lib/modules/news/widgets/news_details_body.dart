import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../data/models/news_model.dart';

class NewsDetailsBody extends StatelessWidget {
  final News news;

  const NewsDetailsBody({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    print('NewsDetailsBody: Building with news title: ${news.title}');
    print('NewsDetailsBody: News content: ${news.userId?.toJson()}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            news.title ?? 'تفاصيل الخبر',
            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
        ),
        // تاريخ النشر
        if (news.updatedAt != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'اخر تحديث: ${news.updatedAt!.toLocal().toString().split(' ')[0]}',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            news.contentNew ?? '',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 16,
              height: 1.8,
            ),
          ),
        ),
        const SizedBox(height: 40),
        // معلومات الكاتب
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'الكاتب',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colorScheme.primary.withOpacity(0.1),
                backgroundImage:
                    news.userId?.userImage != null &&
                        news.userId!.userImage!.isNotEmpty
                    ? CachedNetworkImageProvider(news.userId!.userImage!.first)
                    : null,
                child:
                    news.userId?.userImage == null ||
                        news.userId!.userImage!.isEmpty
                    ? Text(
                        (news.userId?.firstName ?? 'U')[0].toUpperCase(),
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                "${news.userId?.firstName ?? 'كاتب'} ${news.userId?.lastName ?? ''}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
