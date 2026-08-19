import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:game_city_app/core/values/level_assets.dart';
import 'package:game_city_app/data/models/user_model.dart';
import 'package:game_city_app/modules/auth/controllers/auth_controller.dart';
import 'package:game_city_app/modules/community/controllers/user_profile_controller.dart';
import 'package:game_city_app/modules/profile/widgets/visitor_action_row.dart';
import 'package:game_city_app/shared/widgets/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class DesktopBanner extends StatelessWidget {
  final String? coverUrl, avatarUrl, username, heroTag;
  final String name;
  final bool isLoading, isOwner;
  final AuthController? authController;
  final UserProfileController? visitorController;
  final UserModel? visitorUser;

  const DesktopBanner({
    super.key,
    required this.coverUrl,
    required this.avatarUrl,
    required this.name,
    required this.username,
    required this.heroTag,
    required this.isLoading,
    required this.isOwner,
    this.authController,
    this.visitorController,
    this.visitorUser,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final avatarUser = isOwner ? authController?.userModel.value : visitorUser;
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.secondary,
        image: coverUrl != null
            ? DecorationImage(
                image: CachedNetworkImageProvider(coverUrl!),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.35),
                  BlendMode.darken,
                ),
              )
            : null,
        gradient: coverUrl == null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.secondary,
                  Color.lerp(cs.secondary, cs.primary.withOpacity(0.7), 0.6) ??
                      cs.secondary,
                ],
              )
            : null,
      ),
      child: Stack(
        children: [
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          ),
          if (isOwner && authController != null)
            Positioned(
              top: 12,
              left: 12,
              child: _buildEditCoverButton(context, authController!),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Hero(
                      tag: heroTag ?? '',
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        // decoration: BoxDecoration(
                        //   shape: BoxShape.circle,
                        //   border: Border.all(
                        //     // color: cs.primary.withOpacity(0.6),
                        //     width: 3,
                        //   ),
                        //   color: cs.surface,
                        // ),
                        child: avatarUser != null
                            ? SafeCachedAvatar(
                                user: avatarUser,
                                radius: 46,
                                backgroundColor: cs.primary.withOpacity(0.2),
                              )
                            : Container(
                                width: 92,
                                height: 92,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: cs.primary.withOpacity(0.2),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.person,
                                  color: cs.primary,
                                  size: 46,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (name.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
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
                        const SizedBox(width: 6),
                        LevelEmoji(
                          level: isOwner
                              ? (authController?.userModel.value != null
                                    ? LevelAssets.levelOf(
                                            authController!.userModel.value!,
                                          ) ??
                                          0
                                    : 0)
                              : (visitorUser != null
                                    ? LevelAssets.levelOf(visitorUser!) ?? 0
                                    : 0),
                          height: 22,
                        ),
                      ],
                    ),
                  const SizedBox(height: 2),
                  Text(
                    username ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      shadows: const [
                        Shadow(color: Colors.black38, blurRadius: 4),
                      ],
                    ),
                  ),
                  if (!isOwner &&
                      visitorController != null &&
                      visitorUser != null) ...[
                    const SizedBox(height: 14),
                    VisitorActionRow(
                      controller: visitorController!,
                      user: visitorUser!,
                      colorScheme: cs,
                    ),
                  ],
                  if (isOwner && authController != null) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => _showAvatarPicker(context, authController!),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.camera_enhance_rounded,
                              size: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'تغيير الصورة',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditCoverButton(BuildContext context, AuthController auth) {
    return GestureDetector(
      onTap: () => _showBgPicker(context, auth),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_a_photo_rounded,
              size: 16,
              color: Colors.white.withOpacity(0.9),
            ),
            const SizedBox(width: 6),
            Text(
              'تغيير الغلاف',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBgPicker(BuildContext context, AuthController auth) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _pickerSheet(
        context,
        'تغيير صورة الغلاف',
        () {
          Get.back();
          auth.uploadProfileBackgroundImage(ImageSource.camera);
        },
        () {
          Get.back();
          auth.uploadProfileBackgroundImage(ImageSource.gallery);
        },
      ),
    );
  }

  void _showAvatarPicker(BuildContext context, AuthController auth) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _pickerSheet(
        context,
        'تغيير الصورة الشخصية',
        () {
          Get.back();
          auth.uploadProfileImage(ImageSource.camera);
        },
        () {
          Get.back();
          auth.uploadProfileImage(ImageSource.gallery);
        },
      ),
    );
  }

  Widget _pickerSheet(
    BuildContext context,
    String title,
    VoidCallback onCamera,
    VoidCallback onGallery,
  ) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.onSurface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _pickerOption(
                context,
                Icons.camera_alt_rounded,
                'الكاميرا',
                onCamera,
              ),
              _pickerOption(
                context,
                Icons.photo_library_rounded,
                'المعرض',
                onGallery,
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _pickerOption(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: cs.primary, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
