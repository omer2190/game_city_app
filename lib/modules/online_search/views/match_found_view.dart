import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:game_city_app/core/values/app_breakpoints.dart';
import 'package:get/get.dart';
import '../matchmaking_controller.dart';
import '../../../modules/community/views/user_profile_view.dart';

class MatchFoundView extends StatelessWidget {
  final MatchmakingController controller;
  final Color primary;

  const MatchFoundView({
    super.key,
    required this.controller,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final records = controller.matchedRecords;

      if (records.isEmpty) {
        return _buildEmptyState(context);
      }

      final screenWidth = MediaQuery.of(context).size.width;
      final isDesktop = screenWidth >= AppBreakpoints.tabletBreakpoint;
      final isTablet =
          screenWidth >= AppBreakpoints.mobileBreakpoint &&
          screenWidth < AppBreakpoints.tabletBreakpoint;

      if (isDesktop || isTablet) {
        return _buildDesktopLayout(context, records);
      }
      return _buildMobileLayout(context, records);
    });
  }

  // ── Empty State ──────────────────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(32),
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.people_outline_rounded,
              size: 80,
              color: Colors.amber,
            ),
            const SizedBox(height: 24),
            Text(
              'لم يتم العثور على لاعبين',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'لم نجد لاعبين يطابقون خياراتك حالياً. حاول تعديل خيارات البحث أو إعادة المحاولة لاحقاً.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                controller.matchFound(false);
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('رجوع لتعديل البحث'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Desktop / Tablet Layout (Grid) ──────────────────────────────────
  Widget _buildDesktopLayout(BuildContext context, List<dynamic> records) {
    final isDesktop = context.isDesktop;
    final crossAxisCount = isDesktop ? 3 : 2;

    return Column(
      children: [
        // ── Header ──
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32 : 20,
            vertical: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'اللاعبين المتوفرين (${records.length})',
                style: TextStyle(
                  fontSize: isDesktop ? 22 : 20,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  controller.matchFound(false);
                },
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('رجوع'),
                style: TextButton.styleFrom(foregroundColor: primary),
              ),
            ],
          ),
        ),

        // ── Grid of Player Cards ──
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 32 : 20,
              vertical: 8,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.6,
            ),
            itemCount: records.length,
            itemBuilder: (context, index) {
              return _buildPlayerCard(context, records[index], isDesktop);
            },
          ),
        ),

        // ── Bottom Action ──
        Padding(
          padding: EdgeInsets.all(isDesktop ? 24 : 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    controller.matchFound(false);
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('بحث مجدد'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: BorderSide(color: primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Mobile Layout (List) ────────────────────────────────────────────
  Widget _buildMobileLayout(BuildContext context, List<dynamic> records) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'اللاعبين المتوفرين (${records.length})',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  controller.matchFound(false);
                },
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('رجوع'),
                style: TextButton.styleFrom(foregroundColor: primary),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              return _buildPlayerCard(context, records[index], false);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    controller.matchFound(false);
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('بحث مجدد'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: BorderSide(color: primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Player Card (shared between layouts) ────────────────────────────
  Widget _buildPlayerCard(
    BuildContext context,
    dynamic record,
    bool isDesktop,
  ) {
    final match = record.match;
    final userId = match?.withUserId ?? record.userId ?? record.id;
    final userName = record.userName ?? match?.userName ?? 'لاعب مجهول';
    final fullName =
        '${record.userFirstName ?? match?.firstName ?? ''} ${record.userLastName ?? match?.lastName ?? ''}'
            .trim();
    final displayName = fullName.isNotEmpty ? fullName : userName;
    final imageUrl =
        record.userImage ??
        ((match?.userImages != null && match!.userImages!.isNotEmpty)
            ? match.userImages!.first
            : null);
    final notes = match?.notes ?? record.notes;

    return Card(
      margin: const EdgeInsets.only(bottom: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 18 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: isDesktop ? 52 : 60,
                          height: isDesktop ? 52 : 60,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Container(
                          width: isDesktop ? 52 : 60,
                          height: isDesktop ? 52 : 60,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: TextStyle(
                          fontSize: isDesktop ? 15 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (record.type != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            record.type == 'solo' ? 'لاعب' : 'فريق',
                            style: TextStyle(
                              fontSize: 12,
                              color: primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (userId != null) {
                      // Get.to(() => UserProfileView(userId: userId));
                      if (Get.width > AppBreakpoints.mobileBreakpoint) {
                        Get.dialog(
                          UserProfileView(
                            userId: userId ?? '',
                            heroTag: 'avatar_${userId}',
                          ),
                        );
                      } else {
                        Get.to(() => UserProfileView(userId: userId!));
                      }
                    } else {
                      Get.snackbar('Error', 'User ID not found');
                    }
                  },
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: primary,
                    size: 20,
                  ),
                ),
              ],
            ),
            if (notes != null && notes.isNotEmpty) ...[
              const Divider(height: 20),
              Text(
                notes,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.8),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (userId != null) {
                  // Get.to(() => UserProfileView(userId: userId));
                  if (Get.width > AppBreakpoints.mobileBreakpoint) {
                    Get.dialog(
                      UserProfileView(
                        userId: userId ?? '',
                        heroTag: 'avatar_${userId}',
                      ),
                    );
                  } else {
                    Get.to(() => UserProfileView(userId: userId!));
                  }
                } else {
                  Get.snackbar('Error', 'User ID not found');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, isDesktop ? 36 : 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('عرض الملف الشخصي'),
            ),
          ],
        ),
      ),
    );
  }
}
