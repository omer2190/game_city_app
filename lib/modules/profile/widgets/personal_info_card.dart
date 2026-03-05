import 'package:flutter/material.dart';
import '../../../shared/widgets/widgets.dart';
import 'profile_detail_item.dart';

class PersonalInfoCard extends StatelessWidget {
  final Map<String, dynamic> user;

  const PersonalInfoCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ProfileDetailItem(
            icon: Icons.email_outlined,
            label: 'البريد الإلكتروني',
            value: user['email'] ?? '',
          ),
          ProfileDetailItem(
            icon: Icons.person_outline,
            label: 'اسم المستخدم',
            value: user['userName'] ?? '',
          ),
          ProfileDetailItem(
            icon: Icons.phone_android_outlined,
            label: 'رقم الهاتف',
            value: user['phone'] ?? 'غير متوفر',
          ),
          ProfileDetailItem(
            icon: Icons.cake_outlined,
            label: 'تاريخ الميلاد',
            value: user['birthDate'] ?? 'غير متوفر',
          ),
          ProfileDetailItem(
            icon: Icons.wc_outlined,
            label: 'الجنس',
            value: user['gender'] == 'male'
                ? 'ذكر'
                : user['gender'] == 'female'
                ? 'أنثى'
                : 'غير محدد',
          ),
        ],
      ),
    );
  }
}
