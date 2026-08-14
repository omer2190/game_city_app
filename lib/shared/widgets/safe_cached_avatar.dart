import 'package:any_image_view/any_image_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A safe avatar widget that gracefully handles broken / unreachable image URLs.
///
/// Unlike [CachedNetworkImageProvider] used directly as a [CircleAvatar]
/// `backgroundImage`, this widget never throws and always shows a fallback
/// (first letter of [fallbackName] or a person icon).
class SafeCachedAvatar extends StatelessWidget {
  const SafeCachedAvatar({
    super.key,
    this.imageUrl,
    this.fallbackName,
    this.radius = 22,
    this.borderColor,
    this.borderWidth = 0,
    this.backgroundColor,
    this.onTap,
  });

  /// The network image URL (can be null / empty / unreachable).
  final String? imageUrl;

  /// Fallback text — the first character is used when the image fails.
  final String? fallbackName;

  /// Avatar radius in logical pixels.
  final double radius;

  final Color? borderColor;
  final double borderWidth;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  bool get _hasUrl => imageUrl != null && imageUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderColor =
        borderColor ?? theme.colorScheme.primary.withAlpha(50);
    final effectiveBgColor =
        backgroundColor ?? theme.colorScheme.primary.withAlpha(25);

    Widget avatar = SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: ClipOval(
        child: _hasUrl
            ? AnyImageView(
                imagePath: imageUrl!,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                // placeholder: (_, __) =>
                //     _buildFallbackBox(theme, effectiveBgColor),
                // errorWidget: (_, __, ___) =>
                //     _buildFallbackBox(theme, effectiveBgColor),
              )
            : _buildFallbackBox(theme, effectiveBgColor),
      ),
    );

    // Optional border
    if (borderWidth > 0) {
      avatar = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: effectiveBorderColor, width: borderWidth),
        ),
        child: avatar,
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }

    return avatar;
  }

  /// A box the same size as the avatar containing the fallback content.
  Widget _buildFallbackBox(ThemeData theme, Color bgColor) {
    return Container(
      color: bgColor,
      alignment: Alignment.center,
      child: _buildFallback(theme),
    );
  }

  Widget _buildFallback(ThemeData theme) {
    final letter = (fallbackName != null && fallbackName!.isNotEmpty)
        ? fallbackName![0].toUpperCase()
        : null;

    if (letter != null) {
      return Center(
        child: Text(
          letter,
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontSize: radius * 0.7,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Icon(Icons.person, color: theme.colorScheme.primary, size: radius);
  }
}
