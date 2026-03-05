import 'package:flutter/material.dart';
import 'package:game_city_app/shared/layout_mine.dart';
import 'package:get/get.dart';
import 'package:game_city_app/routes/app_routes.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/user_play_now_controller.dart';
import '../../../shared/widgets/widgets.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_play_now_section.dart';
import '../widgets/personal_info_card.dart';
import '../widgets/social_media_list_card.dart';
import '../widgets/general_info_grid.dart';

class ProfileView extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final UserPlayNowController playNowController = Get.put(
    UserPlayNowController(),
  );

  ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutMine(
      body: Obx(() {
        if (!authController.isLoggedIn.value) {
          return const GuestView();
        }

        final user = authController.user;

        return RefreshIndicator(
          onRefresh: () async {
            await authController.refreshProfile();
            await authController.fetchSocialMediaServices();
            await authController.fetchGeneralInfoTypes();
          },
          color: colorScheme.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              ProfileHeader(user: user, authController: authController),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 25),
                      _sectionTitle('المعلومات الشخصية', context),
                      const SizedBox(height: 15),
                      PersonalInfoCard(user: user),

                      const SizedBox(height: 25),
                      _sectionTitle('حسابات التواصل الاجتماعي', context),
                      const SizedBox(height: 15),
                      SocialMediaListCard(
                        socialMedia: user['socialMedia'] ?? [],
                      ),

                      const SizedBox(height: 25),
                      ProfilePlayNowSection(authController: authController),

                      const SizedBox(height: 25),
                      _sectionTitle('معلومات عامة', context),
                      const SizedBox(height: 15),
                      GeneralInfoGrid(
                        authController: authController,
                        infoList: user['generalInfo'] ?? [],
                      ),

                      const SizedBox(height: 40),
                      _buildSettingsButton(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSettingsButton() {
    return CustomButton(
      text: 'الإعدادات',
      type: ButtonType.outline,
      icon: const Icon(Icons.settings_rounded),
      onPressed: () => Get.toNamed(AppRoutes.settings),
      width: double.infinity,
      height: 45,
    );
  }

  Widget _sectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
