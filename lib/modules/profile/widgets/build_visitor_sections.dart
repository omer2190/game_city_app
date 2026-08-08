import 'package:flutter/material.dart';
import 'package:game_city_app/data/models/user_model.dart';
import 'package:game_city_app/modules/profile/widgets/build_visitor_general_info_grid.dart';
import 'package:game_city_app/modules/profile/widgets/build_visitor_personal_info_card.dart';
import 'package:game_city_app/modules/profile/widgets/build_visitor_play_now_section.dart';
import 'package:game_city_app/modules/profile/widgets/build_visitor_social_media_card.dart';
import 'package:game_city_app/modules/profile/widgets/section_title.dart';

Widget buildVisitorSections(BuildContext context, UserModel user) {
  return SliverToBoxAdapter(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        sectionTitle('المعلومات الشخصية', context),
        const SizedBox(height: 12),
        buildVisitorPersonalInfoCard(context, user),
        const SizedBox(height: 24),
        if (user.socialMedia != null && user.socialMedia!.isNotEmpty) ...[
          sectionTitle('حسابات التواصل الاجتماعي', context),
          const SizedBox(height: 12),
          buildVisitorSocialMediaCard(context, user),
          const SizedBox(height: 24),
        ],
        if (user.playNow != null && user.playNow!.isNotEmpty) ...[
          sectionTitle('يلعب الآن', context),
          const SizedBox(height: 12),
          buildVisitorPlayNowSection(context, user),
          const SizedBox(height: 24),
        ],
        if (user.generalInfo != null && user.generalInfo!.isNotEmpty) ...[
          sectionTitle('معلومات عامة', context),
          const SizedBox(height: 12),
          buildVisitorGeneralInfoGrid(context, user.generalInfo!),
          const SizedBox(height: 24),
        ],
        const SizedBox(height: 60),
      ],
    ),
  );
}
