import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../auth/controllers/auth_controller.dart';
import 'edit_profile_bottom_sheet.dart';

class ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> user;
  final AuthController authController;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.authController,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: theme.colorScheme.secondary,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // User Avatar and Name
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Hero(
                        tag: 'profile_avatar',
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Obx(() {
                                final userData = authController.user;
                                final images = userData['userImage'] as List?;

                                return (images != null && images.isNotEmpty)
                                    ? CircleAvatar(
                                        radius: 46,
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                              images[0],
                                            ),
                                      )
                                    : CircleAvatar(
                                        radius: 46,
                                        backgroundColor: colorScheme.primary
                                            .withOpacity(0.2),
                                        child: Text(
                                          (userData['userName'] ?? 'U')[0]
                                              .toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                      );
                              }),
                              Obx(() {
                                if (authController.isLoading.value) {
                                  return Container(
                                    width: 92,
                                    height: 92,
                                    decoration: BoxDecoration(
                                      color: Colors.black45,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showImageSourcePicker(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.cardColor,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.camera_enhance_rounded,
                            size: 18,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => Text(
                      '${authController.user['firstName'] ?? ''} ${authController.user['lastName'] ?? ''}',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
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
          icon: Icon(Icons.edit_outlined, color: colorScheme.onSurfaceVariant),
        ),
      ],
      leading: BackButton(color: colorScheme.onSurfaceVariant),
    );
  }
}
