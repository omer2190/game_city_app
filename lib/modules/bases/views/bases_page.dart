import 'dart:ui';
import 'package:flutter/material.dart';
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

              // --- Advertisements Carousel ---
              if (data.advertisements != null &&
                  data.advertisements!.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildAdsCarousel(context, data.advertisements!),
                ),

              // --- Suggested Players ---
              if (data.randomFriends != null && data.randomFriends!.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildSuggestedPlayers(context, data.randomFriends!),
                ),

              // --- Latest Free Games ---
              if (data.latestFreeGames != null &&
                  data.latestFreeGames!.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildLatestFreeGames(context, data.latestFreeGames!),
                ),

              // --- Wishlist Games ---
              if (data.wishlistGames != null && data.wishlistGames!.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildWishlistGames(context, data.wishlistGames!),
                ),

              // --- Online Matchmakers ---
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
                        const SizedBox(height: 24),
                        const Text(
                          'آخر الأخبار',
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 18,
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

  // ─── Ads Carousel ──────────────────────────────────────────────────────────

  Widget _buildAdsCarousel(BuildContext context, List<Advertisement> ads) {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.9),
        itemCount: ads.length,
        itemBuilder: (context, index) {
          final ad = ads[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: (ad.imageUrl != null && ad.imageUrl!.isNotEmpty)
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(ad.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : const DecorationImage(
                      image: NetworkImage(AppConstants.defaultGameImage),
                      fit: BoxFit.cover,
                    ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                ),
              ),
              child: const ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Suggested Players ─────────────────────────────────────────────────────

  Widget _buildSuggestedPlayers(
    BuildContext context,
    List<RandomUser> players,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Text(
            'الاصدقاء',
            style: TextStyle(
              color: AppColors.primaryDark,
              fontSize: 18,
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
                onTap: () => Get.to(() => UserProfileView(userId: player.id!)),
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
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.transparent,
                          backgroundImage:
                              (player.userImage != null &&
                                  player.userImage!.isNotEmpty &&
                                  player.userImage!.first.isNotEmpty)
                              ? CachedNetworkImageProvider(
                                  player.userImage!.first,
                                )
                              : null,
                          child:
                              (player.userImage == null ||
                                  player.userImage!.isEmpty ||
                                  player.userImage!.first.isEmpty)
                              ? const Icon(Icons.person, color: Colors.white30)
                              : null,
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

  // ─── Random Matchmakers ──────────────────────────────────────────────────

  Widget _buildRandomMatchmakers(
    BuildContext context,
    List<RandomUser> matchmakers,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Text(
            'يبحث الان عن لاعبين',
            style: TextStyle(
              color: AppColors.primaryDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: matchmakers.length,
            itemBuilder: (context, index) {
              final user = matchmakers[index];
              return GestureDetector(
                onTap: () => Get.to(() => UserProfileView(userId: user.id!)),
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
                            color: Colors.orangeAccent,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white10,
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
                              ? const Icon(Icons.person, color: Colors.white30)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user.userName ?? user.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
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
