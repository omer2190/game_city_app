import 'package:flutter/material.dart';
import 'package:game_city_app/modules/community/controllers/user_profile_controller.dart';
import 'package:game_city_app/modules/profile/widgets/visitor_app_bar.dart';
import 'package:game_city_app/shared/layout_mine.dart';
import 'package:game_city_app/shared/widgets/widgets.dart';
import 'package:get/get.dart';

import '../../widgets/build_visitor_sections.dart';

class VisitorMobileShell extends StatelessWidget {
  final String userId;
  final String? heroTag;
  const VisitorMobileShell({required this.userId, this.heroTag});

  @override
  Widget build(BuildContext context) {
    final UserProfileController ctrl = Get.put(UserProfileController());
    ctrl.loadUserProfile(userId);
    final cs = Theme.of(context).colorScheme;

    return LayoutMine(
      body: Obx(() {
        if (ctrl.isLoading.value)
          return const LoadingWidget(message: 'جاري تحميل الملف الشخصي...');
        final user = ctrl.user.value;
        if (user == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_off_outlined,
                  size: 64,
                  color: cs.onBackground.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'المستخدم غير موجود',
                  style: TextStyle(
                    color: cs.onBackground.withOpacity(0.6),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => ctrl.loadUserProfile(userId),
          color: cs.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              VisitorAppBar(user: user, heroTag: heroTag, controller: ctrl),
              buildVisitorSections(context, user),
            ],
          ),
        );
      }),
    );
  }
}
