import 'package:flutter/material.dart';
import 'package:game_city_app/modules/auth/controllers/auth_controller.dart';
import 'package:game_city_app/modules/profile/controllers/user_play_now_controller.dart';
import 'package:game_city_app/modules/profile/views/desktop/desktop_scaffold.dart';
import 'package:game_city_app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:game_city_app/routes/app_routes.dart';
import 'package:game_city_app/shared/widgets/widgets.dart';
import 'package:get/get.dart';

import 'owner_desktop_content.dart';

class OwnerDesktopShell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthController auth = Get.put(AuthController());
    Get.put(UserPlayNowController());
    Get.put(WishlistController());
    final cs = Theme.of(context).colorScheme;

    return DesktopScaffold(
      child: Obx(() {
        if (!auth.isLoggedIn.value) {
          return SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_rounded,
                    size: 56,
                    color: cs.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'يرجى تسجيل الدخول لعرض الملف الشخصي',
                    style: TextStyle(color: cs.onSurface, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'تسجيل دخول',
                    onPressed: () => Get.toNamed(AppRoutes.login),
                    width: 200,
                  ),
                ],
              ),
            ),
          );
        }
        return OwnerDesktopContent();
      }),
    );
  }
}
