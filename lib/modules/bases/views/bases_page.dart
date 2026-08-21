import 'dart:async';
import 'package:flutter/material.dart';
import 'package:game_city_app/core/values/app_breakpoints.dart';
import 'package:game_city_app/routes/app_routes.dart';
import 'package:game_city_app/shared/header.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/values/app_constants.dart';
import '../../../data/models/game_model.dart';
import '../../../data/models/news_model.dart';
import '../../../shared/layout_mine.dart';
import '../../../shared/widgets/widgets.dart';
import '../controllers/bases_controller.dart';
import '../../../data/models/home_dashboard_model.dart';
import '../../community/views/user_profile_view.dart';
import 'package:timeago/timeago.dart' as timeago;

class BasesPage extends StatelessWidget {
  const BasesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BasesController());
    final colorScheme = Theme.of(context).colorScheme;
    final isDesktopOrTablet = context.isDesktopOrTablet;

    return LayoutMine(
      body: Obx(() {
        if (controller.isLoading.value && controller.dashboard.value == null) {
          return const Center(
            child: LoadingWidget(message: 'جاري تحميل الواجهة الرئيسية...'),
          );
        }

        final data = controller.dashboard.value;
        if (data == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.white24,
                ),
                const SizedBox(height: 16),
                const Text(
                  'فشل تحميل البيانات',
                  style: TextStyle(color: AppColors.primaryDark),
                ),
                IconButton(
                  onPressed: () => controller.fetchDashboard(),
                  icon: const Icon(Icons.refresh, color: AppColors.primaryDark),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchDashboard(),
          color: colorScheme.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // --- Header ---
              SliverToBoxAdapter(child: Header(title: 'الواجهة الرئيسية')),

              // --- Advertisements Carousel (auto-slide, responsive) ---
              if (data.advertisements != null &&
                  data.advertisements!.isNotEmpty)
                SliverToBoxAdapter(
                  child: AdsCarouselWidget(ads: data.advertisements!),
                ),

              // --- Suggested Players ---
              if (data.randomFriends != null && data.randomFriends!.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildSuggestedPlayers(context, data.randomFriends!),
                ),

              // --- Latest Free Games (responsive grid) ---
              if (data.latestFreeGames != null &&
                  data.latestFreeGames!.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildLatestFreeGames(context, data.latestFreeGames!),
                ),

              // --- Wishlist Games (responsive grid) ---
              if (data.wishlistGames != null && data.wishlistGames!.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildWishlistGames(context, data.wishlistGames!),
                ),

              // --- Online Matchmakers (with Games) ---
              if (data.randomMatchmakers != null &&
                  data.randomMatchmakers!.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildRandomMatchmakers(
                    context,
                    data.randomMatchmakers!,
                  ),
                ),

              // --- Latest News ---
              if (data.latestNews != null && data.latestNews!.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: isDesktopOrTablet ? 32 : 24),
                        Text(
                          'آخر الأخبار',
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: isDesktopOrTablet ? 20 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

              if (data.latestNews != null && data.latestNews!.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _buildNewsItem(context, data.latestNews![index]),
                      childCount: data.latestNews!.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      }),
    );
  }

  // ─── News Item ─────────────────────────────────────────────────────────────

  Widget _buildSuggestedPlayers(
    BuildContext context,
    List<RandomUser> players,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Text(
            'الاصدقاء',
            style: TextStyle(
              color: AppColors.primaryDark,
              fontSize: context.isDesktopOrTablet ? 20 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              return GestureDetector(
                // onTap: () => Get.to(() => UserProfileView(userId: player.id!)),
                onTap: () {
                  if (Get.width > AppBreakpoints.mobileBreakpoint) {
                    Get.dialog(
                      UserProfileView(
                        userId: player.id ?? '',
                        heroTag: 'avatar_${player.id}',
                      ),
                    );
                  } else {
                    Get.to(() => UserProfileView(userId: player.id!));
                  }
                },
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: ClipOval(
                            child:
                                (player.userImage != null &&
                                    player.userImage!.isNotEmpty &&
                                    player.userImage!.first.isNotEmpty)
                                ? CachedNetworkImage(
                                    imageUrl: player.userImage!.first,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => const Icon(
                                      Icons.person,
                                      color: Colors.white30,
                                      size: 28,
                                    ),
                                    errorWidget: (_, __, ___) => const Icon(
                                      Icons.person,
                                      color: Colors.white30,
                                      size: 28,
                                    ),
                                    imageBuilder: (_, p) => Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: p,
                                          fit: BoxFit.cover,
                                          colorFilter: ColorFilter.mode(
                                            Colors.black.withOpacity(0.3),
                                            BlendMode.darken,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    color: Colors.white30,
                                    size: 28,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        player.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Latest Free Games ─────────────────────────────────────────────────────

  Widget _buildLatestFreeGames(BuildContext context, List<Game> games) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Text(
            'أحدث  الالعاب المجانية',
            style: TextStyle(
              color: AppColors.primaryDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return Container(
                width: 240,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: CustomCard(
                  padding: EdgeInsets.zero,
                  onTap: () {
                    Get.toNamed(
                      AppRoutes.gameDetails,
                      arguments: {'gameId': game.id},
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        if (game.image != null && game.image!.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: game.image!,
                            placeholder: (context, url) => Container(
                              color: Colors.white10,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Image.network(
                              AppConstants.defaultGameImage,
                              fit: BoxFit.cover,
                            ),
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          )
                        else
                          Image.network(
                            AppConstants.defaultGameImage,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.8),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                game.title ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      game.store ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    game.worth ?? 'Free',
                                    style: const TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'مجاني',
                                      style: Get.textTheme.labelSmall!.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Wishlist Games ────────────────────────────────────────────────────────

  Widget _buildWishlistGames(BuildContext context, List<Game> games) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'قائمة أمنياتي',
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.wishlist),
                child: const Text('المزيد'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return Container(
                width: 240,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: CustomCard(
                  padding: EdgeInsets.zero,
                  onTap: () {
                    Get.toNamed(
                      AppRoutes.gameDetails,
                      arguments: {'gameId': game.id},
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        if (game.image != null && game.image!.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: game.image!,
                            placeholder: (context, url) => Container(
                              color: Colors.white10,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Image.network(
                              AppConstants.defaultGameImage,
                              fit: BoxFit.cover,
                            ),
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          )
                        else
                          Image.network(
                            AppConstants.defaultGameImage,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.8),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                game.title ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    game.store ?? '',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (game.status == 'available')
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'متاح',
                                        style: Get.textTheme.labelSmall!
                                            .copyWith(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    )
                                  else if (game.status == 'coming_soon')
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'قادمة',
                                        style: Get.textTheme.labelSmall!
                                            .copyWith(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Random Matchmakers (with Games) ──────────────────────────────────────

  Widget _buildRandomMatchmakers(
    BuildContext context,
    List<MatchmakerUser> matchmakers,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Text(
            'يلعبون نفس ألعابك',
            style: TextStyle(
              color: AppColors.primaryDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: matchmakers.length,
            itemBuilder: (context, index) {
              final matchmaker = matchmakers[index];
              final user = matchmaker.user;
              final game = matchmaker.game;
              if (user == null) return const SizedBox.shrink();

              return GestureDetector(
                onTap: () {
                  if (Get.width > AppBreakpoints.mobileBreakpoint) {
                    Get.dialog(
                      UserProfileView(
                        userId: user.id ?? '',
                        heroTag: 'avatar_${user.id}',
                      ),
                    );
                  } else {
                    Get.to(() => UserProfileView(userId: user.id!));
                  }
                },
                child: Container(
                  width: 160,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white.withOpacity(0.06),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // --- Game Image or Placeholder ---
                      Expanded(
                        flex: 3,
                        child: Stack(
                          children: [
                            // Background: game image or gradient
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(15),
                              ),
                              child:
                                  game != null &&
                                      game.image != null &&
                                      game.image!.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: game.image!,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          _matchmakerGamePlaceholder(),
                                      errorWidget: (context, url, error) =>
                                          _matchmakerGamePlaceholder(),
                                    )
                                  : _matchmakerGamePlaceholder(),
                            ),
                            // Gradient overlay
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),
                            // Game title at bottom of image
                            if (game != null)
                              Positioned(
                                bottom: 8,
                                left: 8,
                                right: 8,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.sports_esports,
                                      color: Colors.white70,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        game.title ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (game == null)
                              const Positioned(
                                bottom: 8,
                                left: 8,
                                right: 8,
                                child: Text(
                                  '🎮 يبحث عن شريك',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // --- User Info ---
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              // Avatar
                              SafeCachedAvatar(
                                user: user.toUserModel(),
                                radius: 18,
                                backgroundColor: Colors.white10,
                                borderColor: game != null
                                    ? colorScheme.primary
                                    : Colors.grey,
                                borderWidth: 2,
                              ),
                              const SizedBox(width: 8),
                              // Name
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.fullName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '@${user.userName ?? ''}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.4),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _matchmakerGamePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondaryDark.withOpacity(0.6),
            AppColors.primaryDark.withOpacity(0.3),
          ],
        ),
      ),
      child: const Center(
        child: Icon(Icons.sports_esports, color: Colors.white10, size: 48),
      ),
    );
  }

  // ─── News Item ─────────────────────────────────────────────────────────────

  Widget _buildNewsItem(BuildContext context, News news) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: CustomCard(
        padding: const EdgeInsets.all(12),
        onTap: () {
          Get.toNamed(AppRoutes.newsDetails, arguments: news);
        },
        child: Row(
          children: [
            if (news.images != null && news.images!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: news.images!.first,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.white.withOpacity(0.4),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        news.createdAt != null
                            ? timeago.format(news.createdAt!, locale: 'ar')
                            : '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Ads Carousel Widget – auto-slide, desktop-compatible, no image crop/distort
// ═══════════════════════════════════════════════════════════════════════════════

class AdsCarouselWidget extends StatefulWidget {
  final List<Advertisement> ads;

  const AdsCarouselWidget({super.key, required this.ads});

  @override
  State<AdsCarouselWidget> createState() => _AdsCarouselWidgetState();
}

class _AdsCarouselWidgetState extends State<AdsCarouselWidget> {
  late PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentPage = 0;
  bool _isUserInteracting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _isUserInteracting) return;

      final total = widget.ads.length;
      if (total == 0) return;

      final nextPage = (_currentPage + 1) % total;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _onUserInteraction() {
    _isUserInteracting = true;
    _autoSlideTimer?.cancel();
    // Resume auto-slide after 6 seconds of no interaction
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        _isUserInteracting = false;
        _startAutoSlide();
      }
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > AppBreakpoints.mobileBreakpoint;

    // Responsive sizing
    final carouselHeight = isDesktop ? 340.0 : 200.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ─── Carousel ────────────────────────────────────────────────
        SizedBox(
          height: carouselHeight,
          child: NotificationListener<ScrollNotification>(
            onNotification: (_) {
              _onUserInteraction();
              return false;
            },
            child: Container(
              constraints: BoxConstraints(
                maxHeight: carouselHeight,
                minWidth: 500,
                maxWidth: 700,
              ),
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.ads.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final ad = widget.ads[index];
                  return _AdCard(ad: ad);
                },
              ),
            ),
          ),
        ),

        // ─── Dot Indicators ─────────────────────────────────────────
        if (widget.ads.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.ads.length, (index) {
                final isActive = _currentPage == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white24,
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

// ─── Single Ad Card ─────────────────────────────────────────────────────────

class _AdCard extends StatelessWidget {
  final Advertisement ad;
  const _AdCard({required this.ad});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: (ad.imageUrl != null && ad.imageUrl!.isNotEmpty)
          ? ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                imageUrl: ad.imageUrl!,
                fit: BoxFit.contain,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image(image: imageProvider, fit: BoxFit.cover),
                ),
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(
                    Icons.campaign_outlined,
                    color: Colors.white24,
                    size: 56,
                  ),
                ),
              ),
            )
          : const Center(
              child: Icon(
                Icons.campaign_outlined,
                color: Colors.white24,
                size: 56,
              ),
            ),
    );
  }
}
