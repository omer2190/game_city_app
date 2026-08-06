/// Responsive navigation shell for Game City App.
///
/// Switches between:
/// - **Mobile** (< 600px): [BottomNavigationBar] with center FAB (current app style)
/// - **Tablet** (600-1024px): Compact [NavigationRail] on left + content on right
/// - **Desktop** (> 1024px): Expanded [DesktopSidebar] on left + content on right
///
/// Usage:
/// ```dart
/// ResponsiveShell(
///   pages: _pages,
///   currentIndex: controller.currentIndex.value,
///   onTabChanged: controller.changePage,
/// )
/// ```

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_breakpoints.dart';
import '../../../core/values/app_dimensions.dart';
import '../../notifications/controllers/notifications_controller.dart';
import 'desktop_sidebar.dart';

class ResponsiveShell extends StatelessWidget {
  const ResponsiveShell({
    super.key,
    required this.pages,
    required this.currentIndex,
    required this.onTabChanged,
  });

  /// The list of page widgets (same as HomeView._pages).
  final List<Widget> pages;

  /// Currently selected tab index.
  final int currentIndex;

  /// Callback when the user changes tabs.
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= AppBreakpoints.tabletBreakpoint) {
          return _buildDesktopLayout(context);
        } else {
          return _buildMobileLayout(context);
        }
      },
    );
  }

  // ── Desktop / Tablet Layout (Sidebar + Content) ──────────────────────────

  Widget _buildDesktopLayout(BuildContext context) {
    final isDesktop = context.isDesktop;

    return Scaffold(
      body: Row(
        children: [
          // Left sidebar
          DesktopSidebar(
            currentIndex: currentIndex,
            onTap: onTabChanged,
            isExpanded: isDesktop,
          ),

          // Main content
          Expanded(child: pages[currentIndex]),
        ],
      ),
    );
  }

  // ── Mobile Layout (BottomNavigationBar + FAB) ────────────────────────────

  Widget _buildMobileLayout(BuildContext context) {
    final notificationsController = Get.find<NotificationsController>();

    return Scaffold(
      extendBody: true,
      body: pages[currentIndex],
      floatingActionButton: _buildFAB(context, notificationsController),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(context, notificationsController),
    );
  }

  // ── Mobile FAB (Online Search) ───────────────────────────────────────────

  Widget _buildFAB(BuildContext context, NotificationsController nc) {
    return Container(
      height: 65,
      width: 65,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: FloatingActionButton(
        onPressed: () => onTabChanged(2),
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: CircleBorder(
          side: BorderSide(
            color: currentIndex == 2
                ? Theme.of(context).colorScheme.primary
                : Colors.black,
            width: currentIndex == 2 ? 3 : 1,
          ),
        ),
        elevation: 0,
        child: Icon(
          Icons.saved_search,
          size: 32,
          color: currentIndex == 2
              ? Theme.of(context).colorScheme.primary
              : Colors.white,
        ),
      ),
    );
  }

  // ── Mobile BottomNavigationBar ────────────────────────────────────────────

  Widget _buildBottomNav(BuildContext context, NotificationsController nc) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) {
                if (index != 2) {
                  onTabChanged(index);
                }
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: true,
              showUnselectedLabels: false,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withOpacity(0.5),
              selectedFontSize: 12,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              items: [
                BottomNavigationBarItem(
                  icon: Obx(
                    () => Stack(
                      children: [
                        Icon(
                          Icons.home,
                          size: 24,
                          color: currentIndex == 0
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white,
                        ),
                        if (nc.unreadCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 10,
                                minHeight: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  label: 'الرئيسية',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.newspaper,
                    size: 24,
                    color: currentIndex == 1
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white,
                  ),
                  label: 'أخبار',
                ),
                const BottomNavigationBarItem(
                  icon: SizedBox.shrink(),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.sports_esports_rounded,
                    size: 26,
                    color: currentIndex == 3
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white,
                  ),
                  label: 'العاب',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.timelapse,
                    size: 24,
                    color: currentIndex == 4
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white,
                  ),
                  label: 'تقويم',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
