import 'package:flutter/material.dart';
import 'package:game_city_app/shared/widgets/widgets.dart';
import '../../../core/values/app_breakpoints.dart';
import '../../../data/models/news_model.dart';

class NewsDetailsBody extends StatelessWidget {
  final News news;

  const NewsDetailsBody({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDesktop = context.isDesktop;
    final horizontalPad = isDesktop ? 24.0 : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: isDesktop ? 28 : 24),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPad),
          child: Text(
            news.title ?? 'تفاصيل الخبر',
            style: TextStyle(
              fontSize: isDesktop ? 20 : 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // تاريخ النشر
        if (news.updatedAt != null)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPad,
              vertical: 8,
            ),
            child: Text(
              'اخر تحديث: ${news.updatedAt!.toLocal().toString().split(' ')[0]}',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: isDesktop ? 13 : 12,
              ),
            ),
          ),
        SizedBox(height: isDesktop ? 20 : 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPad),
          child: Text(
            news.contentNew ?? '',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: isDesktop ? 17 : 16,
              height: 1.8,
            ),
          ),
        ),
        SizedBox(height: isDesktop ? 48 : 40),
        // معلومات الكاتب
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPad),
          child: Text(
            'الكاتب',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: isDesktop ? 15 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: isDesktop ? 14 : 12),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPad),
          child: Row(
            children: [
              SafeCachedAvatar(
                user: news.userId!,
                radius: isDesktop ? 22 : 20,
                backgroundColor: colorScheme.primary.withOpacity(0.1),
              ),
              const SizedBox(width: 12),
              Text(
                "${news.userId?.firstName ?? 'كاتب'} ${news.userId?.lastName ?? ''}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isDesktop ? 15 : 14,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isDesktop ? 28 : 24),
      ],
    );
  }
}
