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
import '../widgets/invite_code_card.dart';
import '../widgets/team_list_card.dart';
import '../widgets/who_invited_me_card.dart';
import '../../../data/models/user_model.dart';

class ProfileView extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final UserPlayNowController playNowController = Get.put(
    UserPlayNowController(),
  );

  ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutMine(
      body: Obx(() {
        if (!authController.isLoggedIn.value) {
          return const GuestView();
        }
        return const _ProfileBody();
      }),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authController = Get.find<AuthController>();

    return Obx(() {
      // Access all reactive variables so the single Obx tracks them all
      final user = authController.user;
      final isLoading = authController.isLoading.value;
      final allInfoTypes = authController.generalInfoTypes;
      final allSocialServices = authController.socialMediaServices;
      final playNowRaw = authController.userModel.value?.playNow ?? [];

      // Invitation data
      final inviteCode = authController.myInviteCode.value;
      final isInviteCodeLoading = authController.isInviteCodeLoading.value;
      final team = authController.myTeam;
      final isTeamLoading = authController.isTeamLoading.value;
      final whoInvitedMe = authController.whoInvitedMe.value;

      // Pre-compute general info items
      final userInfoList = user['generalInfo'] as List? ?? [];
      final userFilled = {
        for (var info in userInfoList) info['typeId']?.toString() ?? '': info,
      };
      final filledTypeIds = userFilled.keys.toSet();
      final generalInfoItems = <dynamic>[];
      for (var item in userInfoList) {
        generalInfoItems.add({'isFilled': true, 'data': item});
      }
      for (var type in allInfoTypes) {
        if (!filledTypeIds.contains(type['_id']?.toString())) {
          generalInfoItems.add({'isFilled': false, 'data': type});
        }
      }

      // Pre-compute social media items
      final userSocialMedia =
          (user['socialMedia'] as List<SocialMediaService>?) ?? [];
      final userIds = userSocialMedia
          .map((e) => e.key ?? e.name ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();
      final notAddedServices = allSocialServices
          .where((s) => !userIds.contains(s.key ?? s.name))
          .toList();

      return RefreshIndicator(
        onRefresh: () async {
          await authController.refreshProfile();
          await authController.fetchSocialMediaServices();
          await authController.fetchGeneralInfoTypes();
          await authController.loadInvitationData();
        },
        color: colorScheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            ProfileHeader(
              user: user,
              authController: authController,
              isLoading: isLoading,
            ),
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

                    // ── Invitation Section ──
                    const SizedBox(height: 25),
                    _sectionTitle('الدعوات', context),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: InviteCodeCard(
                        inviteCode: inviteCode,
                        isLoading: isInviteCodeLoading,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TeamListCard(team: team, isLoading: isTeamLoading),
                    ),
                    if (whoInvitedMe != null) ...[
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: WhoInvitedMeCard(invitedBy: whoInvitedMe),
                      ),
                    ],

                    const SizedBox(height: 25),
                    _sectionTitle('حسابات التواصل الاجتماعي', context),
                    const SizedBox(height: 15),
                    SocialMediaListCard(
                      socialMedia: userSocialMedia,
                      availableServices: notAddedServices,
                    ),

                    const SizedBox(height: 25),
                    ProfilePlayNowSection(playNow: playNowRaw),

                    const SizedBox(height: 25),
                    _sectionTitle('معلومات عامة', context),
                    const SizedBox(height: 15),
                    GeneralInfoGrid(
                      authController: authController,
                      allItems: generalInfoItems,
                    ),

                    const SizedBox(height: 40),
                    _buildBlockedUsersButton(),
                    const SizedBox(height: 20),
                    _buildSettingsButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBlockedUsersButton() {
    return CustomButton(
      text: 'المحظورين',
      type: ButtonType.outline,
      icon: const Icon(Icons.block_rounded),
      onPressed: () => Get.toNamed(AppRoutes.blockedUsers),
      width: double.infinity,
      height: 45,
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
