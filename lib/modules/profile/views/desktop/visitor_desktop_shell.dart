import 'package:flutter/material.dart';
import 'package:game_city_app/modules/community/controllers/user_profile_controller.dart';
import 'package:game_city_app/modules/profile/views/desktop/desktop_two_columns.dart';
import 'package:game_city_app/modules/profile/widgets/build_visitor_left_column.dart';
import 'package:game_city_app/modules/profile/widgets/build_visitor_right_column.dart';
import 'package:game_city_app/modules/profile/widgets/desktop_banner.dart';
import 'package:game_city_app/shared/widgets/widgets.dart';
import 'package:get/get.dart';

import 'desktop_scaffold.dart';

class VisitorDesktopShell extends StatelessWidget {
  final String userId;
  final String? heroTag;
  const VisitorDesktopShell({super.key, required this.userId, this.heroTag});

  @override
  Widget build(BuildContext context) {
    final UserProfileController ctrl = Get.put(UserProfileController());
    ctrl.loadUserProfile(userId);
    final cs = Theme.of(context).colorScheme;

    return DesktopScaffold(
      child: Obx(() {
        if (ctrl.isLoading.value) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: LoadingWidget(message: 'جاري تحميل الملف الشخصي...'),
            ),
          );
        }
        final user = ctrl.user.value;
        if (user == null) {
          return SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_off_outlined,
                    size: 56,
                    color: cs.onSurfaceVariant.withOpacity(0.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'المستخدم غير موجود',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }
        final fullName = [
          user.firstName,
          user.lastName,
        ].where((e) => e != null).join(' ');
        final coverUrl =
            (user.userProfile?.bgProfile is List &&
                (user.userProfile!.bgProfile as List).isNotEmpty)
            ? (user.userProfile!.bgProfile as List).first
            : null;

        return Column(
          children: [
            DesktopBanner(
              coverUrl: coverUrl,
              avatarUrl: (user.userImage?.isNotEmpty == true)
                  ? user.userImage!.first
                  : null,
              name: fullName,
              username: '@${user.userName ?? ''}',
              heroTag: heroTag ?? 'avatar_${user.id}',
              isLoading: false,
              isOwner: false,
              visitorController: ctrl,
              visitorUser: user,
            ),
            Expanded(
              child: DesktopTwoColumns(
                left: buildVisitorLeftColumn(context, user),
                right: buildVisitorRightColumn(context, user),
              ),
            ),
          ],
        );
      }),
    );
  }
}
