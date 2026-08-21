import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/values/level_assets.dart';
import '../../data/models/user_model.dart';

class SafeCachedAvatar extends StatelessWidget {
  const SafeCachedAvatar({
    super.key,
    required this.user,
    this.radius = 22,
    this.borderColor,
    this.borderWidth = 0,
    this.backgroundColor,
    this.onTap,
    this.showLevelFrame = true,
  });

  final UserModel user;

  /// Avatar radius in logical pixels.
  final double radius;

  final Color? borderColor;
  final double borderWidth;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  /// Whether to overlay the user's level frame on the avatar.
  ///
  /// The frame is only rendered when the avatar is large enough to show it
  /// meaningfully (radius >= 24) and the user has a known level.
  final bool showLevelFrame;

  /// Minimum avatar radius for which the level frame is rendered.
  static const double _minFrameRadius = 24;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderColor =
        borderColor ?? theme.colorScheme.primary.withAlpha(50);
    final effectiveBgColor = backgroundColor ?? theme.colorScheme.secondary;

    final level = showLevelFrame && radius >= _minFrameRadius
        ? LevelAssets.levelOf(user)
        : null;
    final geometry = level != null ? LevelAssets.geometryFor(level) : null;
    final frameAsset = level != null ? LevelAssets.frameAssetFor(level) : null;

    Widget avatar;
    if (geometry != null && frameAsset != null) {
      avatar = _buildFramedAvatar(
        theme,
        effectiveBgColor,
        geometry,
        frameAsset,
      );
    } else {
      avatar = SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: ClipOval(
          child: _buildPhoto(theme, effectiveBgColor, radius * 2, radius * 2),
        ),
      );
    }

    // Optional border (skipped when the level frame is shown).
    if (borderWidth > 0 && geometry == null) {
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

  /// Avatar with the level frame overlaid on top.
  ///
  /// The photo is clipped to the exact shape of the frame hole and the frame
  /// image is positioned so its hole aligns with the avatar center. The frame
  /// extends beyond the avatar bounds (decorative border).
  Widget _buildFramedAvatar(
    ThemeData theme,
    Color bgColor,
    LevelFrameGeometry geometry,
    String frameAsset,
  ) {
    // Scale the frame so the hole height matches the avatar diameter.
    final scale = (radius * 2) / geometry.holeH;

    // Slight overscan so the photo always covers the hole edge (no gaps).
    const overscan = 1.03;
    final boxW = geometry.maxHalfWidth * geometry.holeH * scale * overscan;
    final boxH = geometry.holeH * scale * overscan;

    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Avatar photo clipped to the frame hole shape.
          Positioned(
            left: radius - boxW / 2,
            top: radius - boxH / 2,
            child: ClipPath(
              clipper: LevelHoleClipper(geometry.holePts),
              child: SizedBox(
                width: boxW,
                height: boxH,
                child: _buildPhoto(theme, bgColor, boxW, boxH),
              ),
            ),
          ),
          // Frame overlay.
          Positioned(
            left: radius - geometry.holeCx * scale,
            top: radius - geometry.holeCy * scale + 1,
            child: Image.asset(
              frameAsset,
              width: geometry.imgW * scale,
              height: geometry.imgH * scale,
              fit: BoxFit.fill,
            ),
          ),
        ],
      ),
    );
  }

  /// The photo (or fallback) filling a box of the given size.
  Widget _buildPhoto(ThemeData theme, Color bgColor, double w, double h) {
    if (user.userImage != null && user.userImage!.isNotEmpty) {
      return SizedBox(
        width: w,
        height: w,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: user.userImage!.first,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => _buildFallback(theme, h),
            placeholder: (_, __) => _buildFallback(theme, h),
            imageBuilder: (_, p) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: p,
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return SizedBox(
      width: w,
      height: w,
      child: ClipOval(
        child: Container(
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          // color: bgColor,
          alignment: Alignment.center,
          child: _buildFallback(theme, h),
        ),
      ),
    );
  }

  Widget _buildFallback(ThemeData theme, double size) {
    final letter = user.firstName != null && user.firstName!.isNotEmpty
        ? user.firstName!.toUpperCase().substring(0, 1)
        : null;

    if (letter != null) {
      return Center(
        child: Text(
          letter,
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontSize: size * 0.35,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Icon(
      Icons.person,
      color: theme.colorScheme.primary,
      size: size * 0.5,
    );
  }
}
