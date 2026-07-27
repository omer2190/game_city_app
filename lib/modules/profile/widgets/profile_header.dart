import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../auth/controllers/auth_controller.dart';
import 'edit_profile_bottom_sheet.dart';

class ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> user;
  final AuthController authController;
  final bool isLoading;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.authController,
    this.isLoading = false,
  });

  void _showImageSourcePicker(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
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
                color: colorScheme.onSurface.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'تغيير الصورة الشخصية',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerOption(
                  context: context,
                  icon: Icons.camera_alt_rounded,
                  label: 'الكاميرا',
                  onTap: () {
                    Get.back();
                    authController.uploadProfileImage(ImageSource.camera);
                  },
                ),
                _buildPickerOption(
                  context: context,
                  icon: Icons.photo_library_rounded,
                  label: 'المعرض',
                  onTap: () {
                    Get.back();
                    authController.uploadProfileImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colorScheme.primary, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showBackgroundImagePicker(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
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
                color: colorScheme.onSurface.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'تغيير صورة الغلاف',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerOption(
                  context: context,
                  icon: Icons.camera_alt_rounded,
                  label: 'الكاميرا',
                  onTap: () {
                    Get.back();
                    authController.uploadProfileBackgroundImage(
                      ImageSource.camera,
                    );
                  },
                ),
                _buildPickerOption(
                  context: context,
                  icon: Icons.photo_library_rounded,
                  label: 'المعرض',
                  onTap: () {
                    Get.back();
                    authController.uploadProfileBackgroundImage(
                      ImageSource.gallery,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final userProfile = user['userProfile'] as Map<String, dynamic>?;
    final bgImages = userProfile?['bgProfile'] as List<String>?;

    return SliverAppBar(
      expandedHeight: 280,
      collapsedHeight: kToolbarHeight + MediaQuery.of(context).padding.top,
      pinned: true,
      stretch: true,
      backgroundColor: colorScheme.secondary,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // --- Background Layer ---
            if (bgImages != null && bgImages.isNotEmpty)
              _buildCoverImage(bgImages.first, colorScheme)
            else
              _buildCoverPlaceholder(colorScheme),

            // --- Top Gradient for AppBar readability ---
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

            // --- Bottom Gradient for smooth transition ---
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 140,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      colorScheme.secondary,
                      colorScheme.secondary.withOpacity(0.8),
                      colorScheme.secondary.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // --- Edit Cover Button (top-right) ---
            Positioned(
              top: MediaQuery.of(context).padding.top + 4,
              right: 12,
              child: _buildEditCoverButton(context, colorScheme),
            ),

            // --- Avatar & Name (bottom-center) ---
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar with camera badge
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      // Outer ring glow
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Hero(
                          tag: 'profile_avatar',
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme.primary.withOpacity(0.6),
                                width: 2.5,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                _buildAvatar(user, colorScheme),
                                if (isLoading) _buildLoadingOverlay(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Camera badge
                      GestureDetector(
                        onTap: () => _showImageSourcePicker(context),
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.scaffoldBackgroundColor,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.camera_enhance_rounded,
                            size: 16,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Name
                  Text(
                    '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.7),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => showEditProfileBottomSheet(
            context,
            authController.user,
            authController,
          ),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.edit_outlined,
              size: 18,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ),
      ],
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          shape: BoxShape.circle,
        ),
        child: BackButton(color: Colors.white.withOpacity(0.9)),
      ),
    );
  }

  Widget _buildCoverImage(String imageUrl, ColorScheme colorScheme) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 500),
      errorWidget: (context, url, error) => _buildCoverPlaceholder(colorScheme),
      placeholder: (context, url) => _buildCoverPlaceholder(colorScheme),
      imageBuilder: (context, imageProvider) {
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.3),
                BlendMode.darken,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCoverPlaceholder(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.secondary,
            Color.lerp(
                  colorScheme.secondary,
                  colorScheme.primary.withOpacity(0.7),
                  0.6,
                ) ??
                colorScheme.secondary,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image_rounded,
          size: 64,
          color: Colors.white.withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildEditCoverButton(BuildContext context, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () => _showBackgroundImagePicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
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

  Widget _buildLoadingOverlay() {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
      child: const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(Map<String, dynamic> userData, ColorScheme colorScheme) {
    final images = userData['userImage'] as List?;
    return (images != null && images.isNotEmpty)
        ? CircleAvatar(
            radius: 44,
            backgroundImage: CachedNetworkImageProvider(images[0]),
          )
        : CircleAvatar(
            radius: 44,
            backgroundColor: colorScheme.primary.withOpacity(0.25),
            child: Text(
              (userData['userName'] ?? 'U')[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          );
  }
}
