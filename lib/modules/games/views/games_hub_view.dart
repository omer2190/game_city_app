import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/game_model.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/header.dart';
import '../../../shared/layout_mine.dart';
import '../controllers/personalized_games_controller.dart';
import '../widgets/game_card.dart';
import '../widgets/game_section_row.dart';

class GamesHubView extends StatefulWidget {
  GamesHubView({super.key});

  @override
  State<GamesHubView> createState() => _GamesHubViewState();
}

class _GamesHubViewState extends State<GamesHubView> {
  final PersonalizedGamesController controller = Get.put(
    PersonalizedGamesController(),
  );
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  var _showSearchInHeader = false;
  var _showFilters = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!controller.isSearchMode.value) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      controller.loadMore();
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  void _navigateToDetails(Game game) {
    Get.toNamed(AppRoutes.gameDetails, arguments: {'gameId': game.id});
  }

  void _navigateToSearch({required String title, String? type}) {
    controller.enterSearchMode(title: title, type: type);
  }

  void _toggleSearch() {
    setState(() {
      _showSearchInHeader = !_showSearchInHeader;
    });
    if (_showSearchInHeader) {
      _searchFocusNode.requestFocus();
    } else {
      _searchController.clear();
      _searchFocusNode.unfocus();
      if (controller.isSearchMode.value) {
        controller.exitSearchMode();
      }
    }
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  Widget _buildFilterChips(ThemeData theme) {
    return Obx(() {
      if (controller.sourceTypes.isEmpty && controller.genres.isEmpty) {
        return const SizedBox.shrink();
      }
      return SizedBox(
        height: 44,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            ...controller.genres.take(20).map((genre) {
              final isSelected = controller.selectedGenre.value == genre;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(genre),
                  selected: isSelected,
                  onSelected: (_) {
                    if (!controller.isSearchMode.value) {
                      controller.enterSearchMode(genre: genre);
                    } else {
                      controller.onGenreChanged(genre);
                    }
                  },
                  backgroundColor: theme.cardColor,
                  selectedColor: theme.colorScheme.primary.withOpacity(0.3),
                  checkmarkColor: theme.colorScheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.textTheme.bodyMedium?.color,
                    fontSize: 12,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.grey.shade600,
                  ),
                ),
              );
            }),
          ],
        ),
      );
    });
  }

  // ── Search Results ──────────────────────────────────────────────────────

  Widget _buildSearchResults(ThemeData theme) {
    // Loading
    if (controller.searchLoading.value) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'جاري البحث...',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      );
    }

    // Error
    if (controller.searchError.isNotEmpty && controller.searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              controller.searchError.value,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => controller.refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    // Empty
    if (controller.searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sports_esports_outlined,
              size: 64,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد ألعاب',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
            ),
          ],
        ),
      );
    }

    // Responsive grid with GameCard
    return RefreshIndicator(
      onRefresh: () => controller.refresh(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cols = constraints.maxWidth > 1024
              ? 4
              : constraints.maxWidth > 600
              ? 3
              : 2;
          return GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount:
                controller.searchResults.length +
                (controller.hasMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.searchResults.length) {
                return const Center(child: CircularProgressIndicator());
              }
              final game = controller.searchResults[index];
              return GameCard(
                game: game,
                onTap: () => _navigateToDetails(game),
              );
            },
          );
        },
      ),
    );
  }

  // ── Sections ────────────────────────────────────────────────────────────

  Widget _buildSections() {
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          GameSectionRow(
            title: 'مجانية الآن',
            games: controller.giveaways,
            onGameTap: (game) => _navigateToDetails(game),
            onSeeAll: () =>
                _navigateToSearch(title: 'مجانية الآن', type: 'giveaways'),
          ),
          GameSectionRow(
            title: 'عليها تخفيض',
            games: controller.discountedGames,
            onGameTap: (game) => _navigateToDetails(game),
            onSeeAll: () => _navigateToSearch(
              title: 'عليها تخفيض',
              type: 'discountedGames',
            ),
          ),
          GameSectionRow(
            title: 'مجانية دائما',
            games: controller.freeGames,
            onGameTap: (game) => _navigateToDetails(game),
            onSeeAll: () =>
                _navigateToSearch(title: 'مجانية دائما', type: 'freeGames'),
          ),
          GameSectionRow(
            title: 'صدرت حديثا',
            games: controller.recentlyAdded,
            onGameTap: (game) => _navigateToDetails(game),
            onSeeAll: () =>
                _navigateToSearch(title: 'صدرت حديثا', type: 'recentlyAdded'),
          ),
          GameSectionRow(
            title: 'الأعلى تقييماً',
            games: controller.topRated,
            onGameTap: (game) => _navigateToDetails(game),
            onSeeAll: () =>
                _navigateToSearch(title: 'الأعلى تقييماً', type: 'topRated'),
          ),
          GameSectionRow(
            title: 'الأكثر لعباً',
            games: controller.mostPlayed,
            onGameTap: (game) => _navigateToDetails(game),
            onSeeAll: () =>
                _navigateToSearch(title: 'الأكثر لعباً', type: 'mostPlayed'),
          ),
          GameSectionRow(
            title: 'ألعاب لك',
            games: controller.forYou,
            onGameTap: (game) => _navigateToDetails(game),
            onSeeAll: () =>
                _navigateToSearch(title: 'ألعاب لك', type: 'forYou'),
          ),

          // GameSectionRow(
          //   title: 'القادمة قريباً',
          //   games: controller.comingSoon,
          //   onGameTap: (game) => _navigateToDetails(game),
          //   onSeeAll: () =>
          //       _navigateToSearch(title: 'القادمة قريباً', type: 'comingSoon'),
          // ),
          // GameSectionRow(
          //   title: 'ألعابك المفضلة',
          //   games: controller.favoriteGames,
          //   onGameTap: (game) => _navigateToDetails(game),
          //   // onSeeAll: () => _navigateToSearch(title: 'ألعابك المفضلة'),
          // ),
          // GameSectionRow(
          //   title: 'العب الآن',
          //   games: controller.playNowGames,
          //   onGameTap: (game) => _navigateToDetails(game),
          //   // onSeeAll: () => _navigateToSearch(title: 'العب الآن'),
          // ),
          // SizedBox(height: 50),
        ],
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutMine(
      body: Column(
        children: [
          // Header with search toggle (right) and filter toggle (left)
          // Header: leading = back in search mode | filter toggle otherwise
          Obx(() {
            return Header(
              leading: Obx(
                () => IconButton(
                  icon: Icon(
                    controller.isSearchMode.value
                        ? Icons.arrow_back
                        : _showFilters
                        ? Icons.filter_alt_rounded
                        : Icons.filter_list,
                    color: controller.isSearchMode.value
                        ? theme.colorScheme.primary
                        : _showFilters
                        ? theme.colorScheme.primary
                        : Colors.grey.shade400,
                  ),
                  onPressed: () {
                    if (controller.isSearchMode.value) {
                      _searchController.clear();
                      _searchFocusNode.unfocus();
                      setState(() {
                        _showSearchInHeader = false;
                        _showFilters = false;
                      });
                      controller.exitSearchMode();
                    } else {
                      _toggleFilters();
                    }
                  },
                ),
              ),
              titleWidget: _showSearchInHeader
                  ? TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onChanged: (value) {
                        if (!controller.isSearchMode.value) {
                          controller.enterSearchMode();
                        }
                        controller.onSearchChanged(value);
                      },
                      textInputAction: TextInputAction.search,
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن لعبة...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        filled: false,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    )
                  : null,
              title: _showSearchInHeader
                  ? null
                  : (controller.isSearchMode.value
                        ? controller.sectionTitle.value
                        : 'مكتبة الألعاب'),
              trailing: IconButton(
                icon: Icon(
                  _showSearchInHeader ? Icons.close : Icons.search,
                  color: _showSearchInHeader
                      ? theme.colorScheme.primary
                      : Colors.grey.shade400,
                ),
                onPressed: _toggleSearch,
              ),
            );
          }),

          // Filter chips (show/hide via toggle)
          if (_showFilters) _buildFilterChips(theme),

          // Content: sections or search results
          Expanded(
            child: Obx(() {
              // Sections loading state
              if (!controller.isSearchMode.value &&
                  controller.isLoading.value) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'جاري تحميل الألعاب...',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                );
              }

              // Sections error state
              if (!controller.isSearchMode.value &&
                  controller.errorMessage.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 56,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        controller.errorMessage.value,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: controller.refresh,
                        icon: const Icon(Icons.refresh),
                        label: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                );
              }

              // Search mode → show results
              if (controller.isSearchMode.value) {
                return _buildSearchResults(theme);
              }

              // Normal mode → show sections
              return _buildSections();
            }),
          ),
        ],
      ),
    );
  }
}
