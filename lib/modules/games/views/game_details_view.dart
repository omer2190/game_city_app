import 'package:flutter/material.dart';
import 'package:game_city_app/core/values/app_breakpoints.dart';
import 'package:game_city_app/shared/header.dart';
import 'package:game_city_app/shared/layout_mine.dart';
import 'package:game_city_app/shared/widgets/error_widget.dart' as app_error;
import 'package:game_city_app/shared/widgets/widgets.dart' hide ErrorWidget;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/game_model.dart';
import '../../../data/repositories/games_repository.dart';
import '../../wishlist/controllers/wishlist_controller.dart';
import '../widgets/chips_wrap.dart';
import '../widgets/cta_button.dart';
import '../widgets/deal_card.dart';
import '../widgets/description_section.dart';
import '../widgets/game_hero.dart';
import '../widgets/quick_stats.dart';
import '../widgets/requirements_section.dart';
import '../widgets/screenshots_gallery.dart';
import '../widgets/trailer_player.dart';
import '../widgets/section_title.dart';
import '../widgets/stores_list.dart';
import '../widgets/tags_wrap.dart';
import '../widgets/game_review_section.dart';

class GameDetailsView extends StatefulWidget {
  const GameDetailsView({super.key});

  @override
  State<GameDetailsView> createState() => _GameDetailsViewState();
}

class _GameDetailsViewState extends State<GameDetailsView> {
  final WishlistController _wishlistController = Get.find();
  final GamesRepository _gamesRepository = GamesRepository();

  late Future<Game?> _gameFuture;
  final String gameId = Get.arguments['gameId'];

  @override
  void initState() {
    super.initState();
    _gameFuture = _gamesRepository.getGameById(gameId);
  }

  Future<void> _openUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      Get.snackbar('تنبيه', 'تعذر فتح الرابط');
    }
  }

  void _retry() => setState(() {
    _gameFuture = _gamesRepository.getGameById(gameId);
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Game?>(
      future: _gameFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LayoutMine(
            body: Column(
              children: [
                Header(
                  title: 'تحميل التفاصيل',
                  leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                ),
                const Expanded(
                  child: LoadingWidget(message: 'جارٍ تحميل تفاصيل اللعبة...'),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return LayoutMine(
            body: Column(
              children: [
                Header(
                  title: 'خطأ',
                  leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                ),
                Expanded(
                  child: app_error.ErrorWidget(
                    message: 'حدث خطأ أثناء تحميل تفاصيل اللعبة.',
                    onRetry: _retry,
                  ),
                ),
              ],
            ),
          );
        }

        final game = snapshot.data!;
        final isDesktop = context.isDesktop;

        return LayoutMine(
          body: Column(
            children: [
              Header(
                title: 'تفاصيل اللعبة',
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
                trailing: Obx(() {
                  final isInWishlist = _wishlistController.isInWishlist(
                    game.id ?? '',
                  );
                  return IconButton(
                    onPressed: () {
                      if (game.id != null) {
                        _wishlistController.toggleWishlist(game.id!);
                      }
                    },
                    icon: Icon(
                      isInWishlist ? Icons.favorite : Icons.favorite_border,
                      color: isInWishlist ? Colors.red : null,
                    ),
                  );
                }),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: isDesktop
                      ? _buildDesktopLayout(game)
                      : _buildMobileLayout(game),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Mobile: single column stacked ─────────────────────────────────────

  Widget _buildMobileLayout(Game game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GameHero(game: game),
        const SizedBox(height: 16),
        QuickStats(game: game),
        const SizedBox(height: 16),
        if (game.deal != null || game.isFree == true) ...[
          DealCard(game: game),
          const SizedBox(height: 16),
        ],
        SectionTitle('التصنيفات'),
        const SizedBox(height: 8),
        ChipsWrap(items: game.genres),
        const SizedBox(height: 16),
        SectionTitle('المنصات المتوفرة'),
        const SizedBox(height: 8),
        ChipsWrap(items: game.platforms),
        const SizedBox(height: 16),
        DescriptionSection(game: game),
        _buildCommonSections(game),
      ],
    );
  }

  // ── Desktop: two-column layout ────────────────────────────────────────

  Widget _buildDesktopLayout(Game game) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column: Hero + Quick Stats
          Expanded(
            flex: 2,
            child: Column(
              children: [
                GameHero(game: game),
                const SizedBox(height: 16),
                QuickStats(game: game),
                const SizedBox(height: 16),
                if (game.deal != null || game.isFree == true) ...[
                  DealCard(game: game),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Right column: everything else
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle('التصنيفات'),
                const SizedBox(height: 8),
                ChipsWrap(items: game.genres),
                const SizedBox(height: 16),
                SectionTitle('المنصات المتوفرة'),
                const SizedBox(height: 8),
                ChipsWrap(items: game.platforms),
                const SizedBox(height: 16),
                DescriptionSection(game: game),
                _buildCommonSections(game),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Common content for both layouts ───────────────────────────────────

  Widget _buildCommonSections(Game game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        if (game.trailerUrl != null && game.trailerUrl!.isNotEmpty) ...[
          SectionTitle('فيديو ترويجي'),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TrailerPlayer(trailerUrl: game.trailerUrl!),
          ),
          const SizedBox(height: 16),
        ],
        if (game.screenshots != null && game.screenshots!.isNotEmpty) ...[
          SectionTitle('لقطات من اللعبة'),
          const SizedBox(height: 8),
          ScreenshotsGallery(screenshots: game.screenshots!),
          const SizedBox(height: 16),
        ],
        if (game.rawgRequirements != null &&
            game.rawgRequirements!.isNotEmpty) ...[
          SectionTitle('متطلبات التشغيل'),
          const SizedBox(height: 8),
          RequirementsSection(requirements: game.rawgRequirements!),
          const SizedBox(height: 16),
        ],
        if (game.rawgTags != null && game.rawgTags!.isNotEmpty) ...[
          SectionTitle('الوسوم'),
          const SizedBox(height: 8),
          TagsWrap(tags: game.rawgTags!),
          const SizedBox(height: 16),
        ],
        if (game.rawgStores != null && game.rawgStores!.isNotEmpty) ...[
          SectionTitle('المتاجر'),
          const SizedBox(height: 8),
          StoresList(stores: game.rawgStores!, onTap: _openUrl),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 8),
        GameReviewSection(game: game, gameId: gameId),
        const SizedBox(height: 16),
        CtaButton(
          game: game,
          onPressed: () => _openUrl(game.deal?.url ?? game.url),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

DateTime? tryParseDate(String value) {
  try {
    return DateTime.parse(value);
  } catch (_) {
    return null;
  }
}

String formatDate(String value) {
  final date = tryParseDate(value);
  if (date == null) return value;
  return DateFormat('yyyy/MM/dd', 'ar').format(date);
}

String formatPrice(double price) {
  return NumberFormat('#0.00').format(price);
}

String sourceName(String source) {
  switch (source) {
    case 'global':
      return 'عالمي';
    case 'discounted':
      return 'تخفيض';
    case 'free':
      return 'مجاني';
    default:
      return source;
  }
}
