import 'package:flutter/material.dart';
import 'package:game_city_app/modules/auth/controllers/auth_controller.dart';
import 'package:game_city_app/modules/settings/controllers/settings_controller.dart';
import 'package:game_city_app/shared/header.dart';
import 'package:game_city_app/shared/layout_mine.dart';
import 'package:game_city_app/shared/widgets/widgets.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../routes/app_routes.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure SettingsController is available
    final controller = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>()
        : Get.put(SettingsController());

    // Ensure AuthController is available
    final authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());

    return LayoutMine(
      // appBar: AppBar(title: const Text('الإعدادات'), centerTitle: true),
      body: Column(
        children: [
          Header(title: 'الإعدادات', leading: BackButton()),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                _buildSectionHeader('الحساب والأمان'),
                CustomCard(
                  child: Column(
                    children: [
                      _buildListTile(
                        icon: Icons.notifications_active_outlined,
                        title: 'تفعيل الإشعارات',
                        subtitle: 'مطلوب للمتصفحات لاستلام التنبيهات',
                        trailing: Obx(
                          () => controller.isRequestingPermission.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: Get.theme.colorScheme.primary,
                                ),
                        ),
                        onTap: () => controller.requestNotificationPermission(),
                      ),
                      const Divider(height: 1, indent: 50, endIndent: 16),
                      _buildListTile(
                        icon: Icons.lock_outline_rounded,
                        title: 'تغيير كلمة المرور',
                        onTap: () => Get.toNamed(AppRoutes.changePassword),
                      ),
                    ],
                  ),
                ),
                _buildSectionHeader('التواصل والدعم'),
                CustomCard(
                  child: Column(
                    children: [
                      _buildListTile(
                        icon: Icons.bug_report_outlined,
                        title: 'إبلاغ عن خطأ أو اقتراح',
                        onTap: () async {
                          final email = 'city.gamig@gmail.com';
                          final subject = Uri.encodeComponent(
                            'إبلاغ عن خطأ أو اقتراح',
                          );
                          final mailtoLink = 'mailto:$email?subject=$subject';
                          if (await canLaunch(mailtoLink)) {
                            await launch(mailtoLink);
                          } else {
                            Get.snackbar(
                              'خطأ',
                              'تعذر فتح تطبيق البريد الإلكتروني',
                            );
                          }
                        },
                      ),
                      // _buildListTile(
                      //   icon: Icons.volunteer_activism_outlined,
                      //   title: 'الدعم والتبرع',
                      //   onTap: () {
                      //     // Action for support/donation
                      //   },
                      // ),
                    ],
                  ),
                ),
                _buildSectionHeader('عن التطبيق'),
                CustomCard(
                  child: Column(
                    children: [
                      _buildListTile(
                        icon: Icons.info_outline_rounded,
                        title: 'حول التطبيق',
                        onTap: () {
                          _showAboutDialog(context);
                        },
                      ),
                      _buildListTile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'سياسة الخصوصية وشروط الاستخدام',
                        onTap: () async {
                          await controller.openPrivacyPolicy();
                        },
                      ),
                      Obx(
                        () => _buildListTile(
                          icon: Icons.numbers_rounded,
                          title: 'إصدار التطبيق',
                          subtitle: controller.appVersion.value.isEmpty
                              ? 'جاري التحميل...'
                              : controller.appVersion.value,
                          onTap: null,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomButton(
                    text: 'تسجيل الخروج',
                    type: ButtonType.outline,
                    icon: const Icon(Icons.logout_rounded),
                    onPressed: () => authController.logout(),
                    width: double.infinity,
                    height: 45,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Get.theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Get.theme.colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(color: Get.theme.colorScheme.onSurfaceVariant),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  //TODO: نعديل الوصف
  void _showAboutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Text(
              'حول التطبيق',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          "Gaming City\n\n وجهتك الشاملة التي تدمج بين عالم الكيمنج وأحدث تكنولوجيا الهاردوير. يوفر التطبيق تغطية إخبارية حصرية، تقويماً لإصدارات الألعاب، وميزة البحث الفوري (Real-time) عن لاعبين لضمان عدم اللعب وحيداً أبداً. منصة ذكية، متكاملة، وقابلة للتطوير لتواكب مستقبلك التقني.",
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إغلاق')),
        ],
      ),
    );
  }
}
