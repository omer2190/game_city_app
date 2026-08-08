import 'package:flutter/material.dart';
import 'package:game_city_app/core/values/app_breakpoints.dart';
import 'package:game_city_app/data/models/user_model.dart';
import 'package:game_city_app/modules/auth/controllers/auth_controller.dart';
import 'package:game_city_app/modules/profile/widgets/general_info_grid.dart';
import 'package:game_city_app/modules/profile/widgets/personal_info_card.dart';
import 'package:game_city_app/modules/profile/widgets/profile_header.dart';
import 'package:game_city_app/modules/profile/widgets/profile_play_now_section.dart';
import 'package:game_city_app/modules/profile/widgets/social_media_list_card.dart';
import 'package:game_city_app/modules/profile/widgets/support_friend_invite_card.dart';
import 'package:game_city_app/modules/profile/widgets/team_list_card.dart';
import 'package:game_city_app/routes/app_routes.dart';
import 'package:game_city_app/shared/widgets/widgets.dart';
import 'package:get/get.dart';

class OwnerMobileContent extends StatelessWidget {
  OwnerMobileContent();

  void _showTeamSheet(BuildContext context) {
    final auth = Get.find<AuthController>();
    final cs = Theme.of(context).colorScheme;

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.group_rounded, color: cs.primary, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'فريقي',
                    style: TextStyle(
                      color: cs.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: cs.onSurfaceVariant),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(() {
                  final team = auth.myTeam;
                  if (auth.isTeamLoading.value)
                    return const Center(child: CircularProgressIndicator());
                  if (team.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.group_off_rounded,
                              size: 56,
                              color: cs.onSurfaceVariant.withOpacity(0.4),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا يوجد أعضاء في فريقك بعد',
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return TeamListCard(team: team, isLoading: false);
                }),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final auth = Get.find<AuthController>();

    return Obx(() {
      final user = auth.user;
      final isLoading = auth.isLoading.value;
      final playNowRaw = auth.userModel.value?.playNow ?? [];
      final whoInvitedMe = auth.whoInvitedMe.value;
      final hasJoined = whoInvitedMe != null;
      final joinedCode = whoInvitedMe?.code;
      final friendName = whoInvitedMe?.inviter != null
          ? '${whoInvitedMe!.inviter!.firstName ?? ''} ${whoInvitedMe.inviter!.lastName ?? ''}'
                .trim()
          : '';
      final teamCount = auth.myTeam.length;
      final userInfoList = user['generalInfo'] as List? ?? [];
      final userFilled = {
        for (var info in userInfoList) info['typeId']?.toString() ?? '': info,
      };
      final filledTypeIds = userFilled.keys.toSet();
      final generalInfoItems = <dynamic>[];
      for (var item in userInfoList) {
        generalInfoItems.add({'isFilled': true, 'data': item});
      }
      for (var type in auth.generalInfoTypes) {
        if (!filledTypeIds.contains(type['_id']?.toString())) {
          generalInfoItems.add({'isFilled': false, 'data': type});
        }
      }
      final userSocialMedia =
          (user['socialMedia'] as List<SocialMediaService>?) ?? [];
      final userIds = userSocialMedia
          .map((e) => e.key ?? e.name ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();
      final notAddedServices = auth.socialMediaServices
          .where((s) => !userIds.contains(s.key ?? s.name))
          .toList();

      return RefreshIndicator(
        onRefresh: () async {
          await auth.refreshProfile();
          await auth.fetchSocialMediaServices();
          await auth.fetchGeneralInfoTypes();
          await auth.loadInvitationData();
        },
        color: cs.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            ProfileHeader(
              user: user,
              authController: auth,
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
                    const SizedBox(height: 25),
                    _sectionTitle('الدعوات', context),
                    const SizedBox(height: 15),
                    SupportFriendInviteCard(
                      hasJoined: hasJoined,
                      joinedCode: joinedCode,
                      friendName: friendName,
                      teamCount: teamCount,
                      isJoining: auth.isJoiningTeam.value,
                      isTeamLoading: auth.isTeamLoading.value,
                      onJoin: (code) => auth.joinWithInviteCode(code),
                      onViewTeam: () => _showTeamSheet(context),
                    ),
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
                      authController: auth,
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
          fontSize: context.isDesktopOrTablet ? 20 : 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
