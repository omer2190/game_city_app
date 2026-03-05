import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FreeGameDetailsImage extends StatelessWidget {
  final String? imageUrl;

  const FreeGameDetailsImage({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.games, size: 100),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: double.infinity,
      placeholder: (context, url) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.error, color: Colors.red),
      ),
      imageBuilder: (context, imageProvider) => Container(
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
