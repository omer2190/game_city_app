import 'package:flutter/material.dart';
import 'package:game_city_app/modules/auth/controllers/auth_controller.dart';
import 'package:game_city_app/modules/profile/controllers/user_play_now_controller.dart';
import 'package:game_city_app/shared/layout_mine.dart';
import 'package:game_city_app/shared/widgets/widgets.dart';
import 'package:get/get.dart';

import 'owner_mobile_content.dart';

class OwnerMobileShell extends StatelessWidget {
  const OwnerMobileShell({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());
    Get.put(UserPlayNowController());

    return LayoutMine(
      body: Obx(() {
        if (!authController.isLoggedIn.value) return const GuestView();
        return OwnerMobileContent();
      }),
    );
  }
}
