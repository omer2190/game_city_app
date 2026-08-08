import 'package:flutter/material.dart';
import 'package:game_city_app/data/models/user_model.dart';
import 'package:game_city_app/modules/profile/widgets/build_visitor_general_info_grid.dart';
import 'package:game_city_app/modules/profile/widgets/build_visitor_personal_info_card.dart';
import 'package:game_city_app/modules/profile/widgets/build_visitor_social_media_card.dart';

import '../views/desktop/desktop_section.dart';

Widget buildVisitorLeftColumn(BuildContext context, UserModel user) {
  return Column(
    children: [
      DesktopSection(
        title: 'المعلومات الشخصية',
        child: buildVisitorPersonalInfoCard(context, user),
      ),
      const SizedBox(height: 16),
      if (user.socialMedia != null && user.socialMedia!.isNotEmpty) ...[
        DesktopSection(
          title: 'حسابات التواصل الاجتماعي',
          child: buildVisitorSocialMediaCard(context, user),
        ),
        const SizedBox(height: 16),
      ],
      if (user.generalInfo != null && user.generalInfo!.isNotEmpty) ...[
        DesktopSection(
          title: 'معلومات عامة',
          child: buildVisitorGeneralInfoGrid(context, user.generalInfo!),
        ),
        const SizedBox(height: 16),
      ],
    ],
  );
}
