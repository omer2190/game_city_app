import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/user_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../shared/widgets/widgets.dart';
import 'profile_detail_item.dart';

class SocialMediaListCard extends StatelessWidget {
  final List<SocialMediaService> socialMedia;

  const SocialMediaListCard({super.key, required this.socialMedia});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final List<SocialMediaService> allAvailable =
          authController.socialMediaServices;

      // Filter out services already added by the user
      final userIds = socialMedia.map((e) => e.key ?? e.name).toSet();
      final List<SocialMediaService> notAdded = allAvailable
          .where((s) => !userIds.contains(s.key ?? s.name))
          .toList();

      return CustomCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // List of added social media
            ...socialMedia.map((e) {
              return ProfileDetailItem(
                label: e.name ?? '',
                value: e.value ?? '',
                onTap: (e.value != null && e.value!.isNotEmpty)
                    ? () async {
                        try {
                          final Uri uri = Uri.parse(e.value!);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        } catch (_) {}
                      }
                    : null,
                onDelete: () {
                  Get.dialog(
                    AlertDialog(
                      title: const Text('حذف رابط'),
                      content: const Text(
                        'هل أنت متأكد من رغبتك في حذف هذا الرابط؟',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('إلغاء'),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.back();
                            authController.deleteSocialMediaLink(e.id);
                          },
                          child: Text(
                            'حذف',
                            style: TextStyle(color: colorScheme.error),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),

            // List of available but not added social media
            ...notAdded.map((s) {
              return ProfileDetailItem(
                label: s.name ?? '',
                value: 'أضف رابط الـ ${s.name}',
                onTap: () => _showAddDialog(context, authController, s),
              );
            }),

            if (socialMedia.isEmpty && notAdded.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'لا توجد حسابات تواصل اجتماعي مضافة بعد.',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  void _showAddDialog(
    BuildContext context,
    AuthController authController,
    SocialMediaService service,
  ) {
    final TextEditingController linkController = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;

    Get.dialog(
      AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'إضافة ${service.name}',
          style: TextStyle(color: colorScheme.primary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'أدخل رابط الحساب أو اسم المستخدم الخاص بك على ${service.name}',
              style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: linkController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'https://...',
                hintStyle: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.35),
                ),
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (linkController.text.isNotEmpty) {
                final text = linkController.text;
                // Get.back(); // Close dialog

                try {
                  await authController.addSocialMediaLink(service.id, text);
                  await authController.refreshProfile();
                  Get.snackbar(
                    'نجاح',
                    'تم إضافة رابط ${service.name} بنجاح',
                    backgroundColor: Colors.green.withOpacity(0.1),
                    colorText: Colors.white,
                  );
                } catch (_) {
                  Get.snackbar(
                    'خطأ',
                    'فشل إضافة الرابط',
                    backgroundColor: Colors.red.withOpacity(0.1),
                    colorText: Colors.white,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
