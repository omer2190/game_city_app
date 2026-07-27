import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_city_app/shared/layout_mine.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/user_profile_controller.dart';
import '../../../data/models/user_model.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../modules/profile/widgets/profile_detail_item.dart';
import '../../chat/views/chat_view.dart';

class UserProfileView extends StatelessWidget {
  final String userId;
  final String? heroTag;

  UserProfileView({super.key, required this.userId, this.heroTag});

  final UserProfileController controller = Get.put(UserProfileController());

  @override
  Widget build(BuildContext context) {
    controller.loadUserProfile(userId);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutMine(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: 'جاري تحميل الملف الشخصي...');
        }

        final user = controller.user.value;
        if (user == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_off_outlined,
                  size: 64,
                  color: colorScheme.onBackground.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'المستخدم غير موجود',
                  style: TextStyle(
                    color: colorScheme.onBackground.withOpacity(0.6),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadUserProfile(userId),
          color: colorScheme.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildAppBar(context, user),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // --- Personal Info ---
                    _sectionTitle('المعلومات الشخصية', context),
                    const SizedBox(height: 12),
                    _buildPersonalInfoCard(context, user),
                    const SizedBox(height: 24),

                    // --- Social Media ---
                    if (user.socialMedia != null &&
                        user.socialMedia!.isNotEmpty) ...[
                      _sectionTitle('حسابات التواصل الاجتماعي', context),
                      const SizedBox(height: 12),
                      _buildSocialMediaCard(context, user),
                      const SizedBox(height: 24),
                    ],

                    // --- Play Now ---
                    if (user.playNow != null && user.playNow!.isNotEmpty) ...[
                      _sectionTitle('يلعب الآن', context),
                      const SizedBox(height: 12),
                      _buildPlayNowSection(context, user),
                      const SizedBox(height: 24),
                    ],

                    // --- General Info (userInfos) ---
                    if (user.generalInfo != null &&
                        user.generalInfo!.isNotEmpty) ...[
                      _sectionTitle('معلومات عامة', context),
                      const SizedBox(height: 12),
                      _buildGeneralInfoGrid(context, user.generalInfo!),
                      const SizedBox(height: 24),
                    ],

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ─── App Bar ──────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context, UserModel user) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authController = Get.find<AuthController>();
    final fullName = [
      user.firstName,
      user.lastName,
    ].where((e) => e != null).join(' ');
    final bgImages = user.userProfile?.bgProfile;

    return SliverAppBar(
      expandedHeight: 320,
      collapsedHeight: kToolbarHeight + MediaQuery.of(context).padding.top,
      pinned: true,
      stretch: true,
      automaticallyImplyLeading: false,
      backgroundColor: colorScheme.secondary,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // --- Cover Image ---
            if (bgImages != null && bgImages.isNotEmpty)
              _buildCoverImage(bgImages.first, colorScheme)
            else
              _buildCoverPlaceholder(colorScheme),

            // --- Top Gradient for AppBar readability ---
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 120,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.55),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // --- Bottom Gradient for smooth transition ---
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 180,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      colorScheme.secondary,
                      colorScheme.secondary.withOpacity(0.8),
                      colorScheme.secondary.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // --- Back Button (top-left) ---
            Positioned(
              top: MediaQuery.of(context).padding.top + 4,
              left: 8,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ),

            // --- Avatar & Name (bottom-center) ---
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar with glow ring
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.35),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Hero(
                      tag: heroTag ?? 'avatar_$userId',
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.primary.withOpacity(0.6),
                            width: 2.5,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 42,
                          backgroundColor: colorScheme.primary.withOpacity(
                            0.25,
                          ),
                          backgroundImage:
                              (user.userImage != null &&
                                  user.userImage!.isNotEmpty)
                              ? CachedNetworkImageProvider(
                                  user.userImage!.first,
                                )
                              : null,
                          child:
                              (user.userImage == null ||
                                  user.userImage!.isEmpty)
                              ? Icon(
                                  Icons.person,
                                  size: 42,
                                  color: Colors.white.withOpacity(0.7),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Full name
                  if (fullName.isNotEmpty)
                    Text(
                      fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  // Username
                  Text(
                    '@${user.userName ?? ''}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 14,
                      shadows: const [
                        Shadow(color: Colors.black38, blurRadius: 4),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Action Buttons Row ---
                  if (authController.userModel.value?.id?.toString() != userId)
                    _buildActionButtons(
                      context,
                      user,
                      authController,
                      colorScheme,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    UserModel user,
    AuthController authController,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Obx(() {
        if (controller.isSendingRequest.value || controller.isBlocking.value) {
          return const SizedBox(
            height: 36,
            width: 36,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Friend button
              _buildActionChip(
                context: context,
                label: user.isFriend == true
                    ? 'صديق'
                    : controller.requestSent.value
                    ? 'تم الإرسال'
                    : 'إضافة صديق',
                icon: user.isFriend == true
                    ? Icons.check
                    : controller.requestSent.value
                    ? Icons.access_time_rounded
                    : Icons.person_add,
                color: user.isFriend == true
                    ? Colors.green
                    : controller.requestSent.value
                    ? Colors.grey
                    : colorScheme.primary,
                onTap: user.isFriend == true
                    ? () {
                        Get.dialog(
                          _confirmDialog(
                            title: 'حذف الصديق',
                            message: 'هل أنت متأكد من حذف هذا الصديق؟',
                            confirmLabel: 'حذف',
                            confirmColor: Colors.red,
                            onConfirm: () {
                              Get.back();
                              controller.removeFriend();
                            },
                          ),
                        );
                      }
                    : controller.requestSent.value
                    ? null
                    : () => controller.sendFriendRequest(),
              ),
              const SizedBox(width: 10),
              // Message button
              _buildActionChip(
                context: context,
                label: 'رسالة',
                icon: Icons.send_rounded,
                color: Colors.blue,
                onTap: () => Get.to(() => ChatView(recipient: user)),
              ),
              const SizedBox(width: 10),
              // Block button
              _buildActionChip(
                context: context,
                label: controller.isBlocked.value ? 'محظور' : 'حظر',
                icon: controller.isBlocked.value
                    ? Icons.lock_open_rounded
                    : Icons.block_flipped,
                color: controller.isBlocked.value
                    ? Colors.orange
                    : Colors.redAccent,
                onTap: () {
                  if (controller.isBlocked.value) {
                    Get.dialog(
                      _confirmDialog(
                        title: 'فك الحظر',
                        message: 'هل أنت متأكد من فك حظر هذا المستخدم؟',
                        confirmLabel: 'فك الحظر',
                        confirmColor: Colors.orange,
                        onConfirm: () {
                          Get.back();
                          controller.toggleBlockUser();
                        },
                      ),
                    );
                  } else {
                    Get.dialog(
                      _confirmDialog(
                        title: 'حظر المستخدم',
                        message:
                            'هل أنت متأكد من حظر هذا المستخدم؟ لن يتمكن من مراسلتك.',
                        confirmLabel: 'حظر',
                        confirmColor: Colors.red,
                        onConfirm: () {
                          Get.back();
                          controller.toggleBlockUser();
                        },
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildActionChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _confirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Text(title, style: const TextStyle(color: Colors.white)),
      content: Text(message, style: const TextStyle(color: Colors.white70)),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
        TextButton(
          onPressed: onConfirm,
          child: Text(confirmLabel, style: TextStyle(color: confirmColor)),
        ),
      ],
    );
  }

  Widget _buildCoverImage(String imageUrl, ColorScheme colorScheme) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 500),
      errorWidget: (context, url, error) => _buildCoverPlaceholder(colorScheme),
      placeholder: (context, url) => _buildCoverPlaceholder(colorScheme),
      imageBuilder: (context, imageProvider) {
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.3),
                BlendMode.darken,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCoverPlaceholder(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.secondary,
            Color.lerp(
                  colorScheme.secondary,
                  colorScheme.primary.withOpacity(0.7),
                  0.6,
                ) ??
                colorScheme.secondary,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image_rounded,
          size: 64,
          color: Colors.white.withOpacity(0.08),
        ),
      ),
    );
  }

  // ─── Section Title ─────────────────────────────────────────────────────────

  Widget _sectionTitle(String title, BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onBackground,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ─── Personal Info ─────────────────────────────────────────────────────────

  Widget _buildPersonalInfoCard(BuildContext context, UserModel user) {
    final genderText = user.gender == 'male'
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
            ProfileDetailItem(
              icon: Icons.wc_outlined,
              label: 'الجنس',
              value: genderText,
            ),
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

  // ─── Social Media ──────────────────────────────────────────────────────────

  Widget _buildSocialMediaCard(BuildContext context, UserModel user) {
    final links = user.socialMedia;
    if (links == null) return const SizedBox.shrink();

    if (links.isEmpty) {
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
        children: links.map((e) {
          return InkWell(
            onTap: e.value != null
                ? () async {
                    // نسخ الرابط إلى الحافظة
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
                        'فشل نسخ الرابط، حاول مرة أخرى',
                        backgroundColor: Colors.red.withOpacity(0.1),
                        colorText: Colors.white,
                      );
                    }
                  }
                : null,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      (e.name != null && e.name!.isNotEmpty)
                          ? e.name![0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.name ?? '',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          e.value ?? '',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (e.value != null)
                    Icon(
                      Icons.content_copy_rounded,
                      size: 14,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.5),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Play Now ──────────────────────────────────────────────────────────────

  Widget _buildPlayNowSection(BuildContext context, UserModel user) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        itemCount: user.playNow!.length,
        itemBuilder: (context, index) {
          final game = user.playNow![index] as Map<String, dynamic>;
          final imageUrl =
              (game['image'] ?? game['backgroundImage'] ?? '') as String;
          final title = (game['title'] ?? game['name'] ?? '') as String;

          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 14, bottom: 4),
            child: CustomCard(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Game image
                    imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: Colors.white10,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: Colors.white10,
                              child: const Icon(
                                Icons.videogame_asset,
                                color: Colors.white30,
                                size: 40,
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.white10,
                            child: const Icon(
                              Icons.videogame_asset,
                              color: Colors.white30,
                              size: 40,
                            ),
                          ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.85),
                          ],
                          stops: const [0.45, 1.0],
                        ),
                      ),
                    ),
                    // Title
                    Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── General Info ──────────────────────────────────────────────────────────

  Widget _buildGeneralInfoGrid(
    BuildContext context,
    List<GeneralInfoItem> infoList,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: infoList.map((item) {
        return Container(
          constraints: BoxConstraints(
            minWidth: (MediaQuery.of(context).size.width - 64) / 2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(7),
            // border: Border.all(color: colorScheme.primary.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.title,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
