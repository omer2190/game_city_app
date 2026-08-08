import 'package:flutter/material.dart';
import 'package:game_city_app/data/models/user_model.dart';
import 'package:game_city_app/modules/profile/widgets/profile_detail_item.dart';
import 'package:game_city_app/shared/widgets/widgets.dart';

Widget buildVisitorPersonalInfoCard(BuildContext context, UserModel user) {
  final g = user.gender == 'male'
      ? 'ذكر'
      : user.gender == 'female'
      ? 'أنثى'
      : 'غير محدد';
  return CustomCard(
    padding: EdgeInsets.zero,
    child: Column(
      children: [
        ProfileDetailItem(
          icon: Icons.person_outline,
          label: 'اسم المستخدم',
          value: user.userName ?? '—',
        ),
        if (user.firstName != null || user.lastName != null)
          ProfileDetailItem(
            icon: Icons.badge_outlined,
            label: 'الاسم الكامل',
            value: [
              user.firstName,
              user.lastName,
            ].where((e) => e != null).join(' '),
          ),
        if (user.gender != null)
          ProfileDetailItem(icon: Icons.wc_outlined, label: 'الجنس', value: g),
        if (user.birthDate != null)
          ProfileDetailItem(
            icon: Icons.cake_outlined,
            label: 'تاريخ الميلاد',
            value: user.birthDate!,
          ),
      ],
    ),
  );
}
