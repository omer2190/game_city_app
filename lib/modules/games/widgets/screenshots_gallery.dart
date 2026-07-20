import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'fullscreen_image_viewer.dart';

class ScreenshotsGallery extends StatelessWidget {
  final List<String> screenshots;

  const ScreenshotsGallery({required this.screenshots});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: screenshots.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              FullscreenImageViewer.show(
                context,
                images: screenshots,
                initialIndex: index,
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: screenshots[index],
                width: 240,
                height: 140,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 240,
                  height: 140,
                  color: Colors.grey[900],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 240,
                  height: 140,
                  color: Colors.grey[900],
                  child: const Icon(Icons.error, color: Colors.red),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
