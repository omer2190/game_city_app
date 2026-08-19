import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:game_city_app/core/values/level_assets.dart';
import 'package:game_city_app/data/models/user_model.dart';
import 'package:game_city_app/modules/auth/controllers/auth_controller.dart';
import 'package:game_city_app/modules/community/controllers/user_profile_controller.dart';
import 'package:game_city_app/modules/profile/widgets/visitor_action_row.dart';
import 'package:game_city_app/shared/widgets/widgets.dart';
import 'package:get/get.dart';

class VisitorAppBar extends StatelessWidget {
  final UserModel user;
  final String? heroTag;
  final UserProfileController controller;
  const VisitorAppBar({
    super.key,
    required this.user,
    this.heroTag,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final auth = Get.find<AuthController>();
    final fullName = [
      user.firstName,
      user.lastName,
    ].where((e) => e != null).join(' ');
    final bgImages = user.userProfile?.bgProfile;

    return SliverAppBar(
      expandedHeight: 320,
      collapsedHeight: kToolbarHeight + MediaQuery.of(context).padding.top,
      pinned: true,
      stretch: true,
      automaticallyImplyLeading: false,
      backgroundColor: cs.secondary,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (bgImages != null && bgImages.isNotEmpty)
              _buildCoverImage(bgImages.first, cs)
            else
              _buildCoverPlaceholder(cs),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 120,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.55),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 180,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      cs.secondary,
                      cs.secondary.withOpacity(0.8),
                      cs.secondary.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 4,
              left: 8,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        // BoxShadow(
                        //   color: cs.primary.withOpacity(0.35),
                        //   blurRadius: 12,
                        //   spreadRadius: 2,
                        // ),
                      ],
                    ),
                    child: Hero(
                      tag: heroTag ?? 'avatar_${user.id}',
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        // decoration: BoxDecoration(
                        //   shape: BoxShape.circle,
                        //   border: Border.all(
                        //     color: cs.primary.withOpacity(0.6),
                        //     width: 2.5,
                        //   ),
                        // ),
                        child: SafeCachedAvatar(
                          user: user,
                          radius: 42,
                          // backgroundColor: cs.primary.withOpacity(0.25),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (fullName.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user.levelName ?? '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 14,
                          shadows: const [
                            Shadow(color: Colors.black38, blurRadius: 4),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      LevelEmoji(
                        level: LevelAssets.levelOf(user) ?? 0,
                        height: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (auth.userModel.value?.id?.toString() !=
                      user.id?.toString())
                    VisitorActionRow(
                      controller: controller,
                      user: user,
                      colorScheme: cs,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage(String url, ColorScheme cs) => CachedNetworkImage(
    imageUrl: url,
    fit: BoxFit.cover,
    fadeInDuration: const Duration(milliseconds: 500),
    errorWidget: (_, __, ___) => _buildCoverPlaceholder(cs),
    placeholder: (_, __) => _buildCoverPlaceholder(cs),
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
  );
  Widget _buildCoverPlaceholder(ColorScheme cs) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          cs.secondary,
          Color.lerp(cs.secondary, cs.primary.withOpacity(0.7), 0.6) ??
              cs.secondary,
        ],
      ),
    ),
    child: Center(
      child: Icon(
        Icons.image_rounded,
        size: 64,
        color: Colors.white.withOpacity(0.08),
      ),
    ),
  );
}
