/// Desktop sidebar navigation for Game City App.
///
/// A [NavigationRail] (or expanded sidebar) displayed on the left side
/// of the screen on tablet and desktop devices. Contains the same tabs
/// as the mobile BottomNavigationBar plus the user avatar header.
///
/// Usage:
/// ```dart
/// DesktopSidebar(
///   currentIndex: controller.currentIndex.value,
///   onTap: controller.changePage,
/// )
/// ```

import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_breakpoints.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../notifications/controllers/notifications_controller.dart';
import '../../../routes/app_routes.dart';

class DesktopSidebar extends StatelessWidget {
  const DesktopSidebar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isExpanded = true,
  });

  /// Index of the currently selected tab.
  final int currentIndex;

  /// Callback when a tab is tapped.
  final ValueChanged<int> onTap;

  /// Whether the sidebar is in expanded mode (showing text labels).
  final bool isExpanded;

  // ── Tab data ───────────────────────────────────────────────────────────

  static const List<_SidebarTab> _tabs = [
    _SidebarTab(icon: Icons.home_rounded, label: 'الرئيسية'),
    _SidebarTab(icon: Icons.newspaper_rounded, label: 'أخبار'),
    _SidebarTab(icon: Icons.saved_search_rounded, label: 'بحث'),
    _SidebarTab(icon: Icons.sports_esports_rounded, label: 'ألعاب'),
    _SidebarTab(icon: Icons.timelapse_rounded, label: 'تقويم'),
    _SidebarTab(icon: Icons.notifications_rounded, label: 'الإشعارات'),
    _SidebarTab(icon: Icons.favorite_rounded, label: 'قائمة الأمنيات'),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final notificationsController = Get.find<NotificationsController>();
    final authController = Get.find<AuthController>();

    return Container(
      width: isExpanded ? 240 : 72,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          right: BorderSide(
            color: colorScheme.surface.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),

          // ── User Avatar + Greeting ──────────────────────────────────
          _buildUserHeader(context, authController, colorScheme),

          const SizedBox(height: 12),
          const Divider(height: 1, indent: 16, endIndent: 16),
          const SizedBox(height: 12),

          // ── Navigation Tabs ────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                ...List.generate(_tabs.length, (index) {
                  final tab = _tabs[index];
                  final isSelected = currentIndex == index;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: _SidebarItem(
                      icon: tab.icon,
                      label: tab.label,
                      isSelected: isSelected,
                      isExpanded: isExpanded,
                      badgeCount: index == 0
                          ? notificationsController.unreadCount > 0
                                ? '${notificationsController.unreadCount}'
                                : null
                          : null,
                      onTap: () => onTap(index),
                    ),
                  );
                }),
              ],
            ),
          ),

          // ── Bottom Actions ─────────────────────────────────────────
          const Divider(height: 1, indent: 16, endIndent: 16),
          const SizedBox(height: 8),

          // Wishlist
          _SidebarItem(
            icon: Icons.favorite_rounded,
            label: 'قائمة الأمنيات',
            isSelected: false,
            isExpanded: isExpanded,
            onTap: () => Get.toNamed(AppRoutes.wishlist),
          ),

          // Settings
          _SidebarItem(
            icon: Icons.settings_rounded,
            label: 'الإعدادات',
            isSelected: false,
            isExpanded: isExpanded,
            onTap: () => Get.toNamed(AppRoutes.settings),
          ),

          // Profile
          _SidebarItem(
            icon: Icons.person_rounded,
            label: 'الملف الشخصي',
            isSelected: false,
            isExpanded: isExpanded,
            onTap: () => Get.toNamed(AppRoutes.profile),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── User Header ──────────────────────────────────────────────────────────

  Widget _buildUserHeader(
    BuildContext context,
    AuthController authController,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => Get.toNamed('/profile'),
        child: isExpanded
            ? Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: colorScheme.primary,
                    backgroundImage: _userImage(authController),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() {
                      final name =
                          authController.userModel.value?.firstName ?? 'ضيف';
                      return Text(
                        'مرحباً $name',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      );
                    }),
                  ),
                ],
              )
            : Column(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: colorScheme.primary,
                    backgroundImage: _userImage(authController),
                  ),
                ],
              ),
      ),
    );
  }

  ImageProvider? _userImage(AuthController authController) {
    final images = authController.userModel.value?.userImage;
    if (images != null && images.isNotEmpty && images.first.isNotEmpty) {
      return CachedNetworkImageProvider(images.first);
    }
    return null;
  }
}

// ── Sidebar Tab Data ────────────────────────────────────────────────────────

class _SidebarTab {
  final IconData icon;
  final String label;

  const _SidebarTab({required this.icon, required this.label});
}

// ── Sidebar Item Widget ─────────────────────────────────────────────────────

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
    this.badgeCount,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onTap;
  final String? badgeCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Material(
        color: isSelected
            ? colorScheme.primary.withOpacity(0.15)
            : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: isExpanded
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      _buildIcon(context, colorScheme),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (badgeCount != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            badgeCount!,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: _buildIcon(context, colorScheme),
                ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context, ColorScheme colorScheme) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Stack(
        children: [
          Icon(
            icon,
            size: 24,
            color: isSelected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
          if (badgeCount != null && !isExpanded)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
