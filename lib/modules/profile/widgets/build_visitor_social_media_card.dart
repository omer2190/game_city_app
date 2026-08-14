import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_city_app/data/models/user_model.dart';
import 'package:game_city_app/modules/profile/widgets/profile_detail_item.dart';
import 'package:game_city_app/shared/widgets/widgets.dart';
import 'package:get/get.dart';

Widget buildVisitorSocialMediaCard(BuildContext context, UserModel user) {
  final links = user.socialMedia;
  if (links == null || links.isEmpty) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'لا توجد حسابات مضافة',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ),
      ),
    );
  }
  return CustomCard(
    padding: EdgeInsets.zero,
    child: Column(
      children: links
          .map(
            (e) => ProfileDetailItem(
              label: e.name ?? '',
              value: e.value ?? '',
              onTap: (e.value != null && e.value!.isNotEmpty)
                  ? () async {
                      try {
                        await Clipboard.setData(
                          ClipboardData(text: e.value ?? ''),
                        );
                        Get.snackbar(
                          'تم النسخ',
                          'تم نسخ رابط ${e.name} إلى الحافظة',
                          backgroundColor: Colors.green.withOpacity(0.1),
                          colorText: Colors.white,
                        );
                      } catch (_) {
                        Get.snackbar(
                          'خطأ',
                          'فشل نسخ الرابط',
                          backgroundColor: Colors.red.withOpacity(0.1),
                          colorText: Colors.white,
                        );
                      }
                    }
                  : null,
            ),
          )
          .toList(),
    ),
  );
}
