import 'package:flutter/material.dart';
import 'package:game_city_app/modules/games/controllers/discounted_games_controller.dart';
import 'package:game_city_app/modules/games/controllers/free_games_controller.dart';
import 'package:game_city_app/modules/games/controllers/totally_free_games_controller.dart';
import 'package:game_city_app/shared/layout_mine.dart';
import 'package:get/get.dart';
import '../../../shared/header.dart';
import 'free_games_view.dart';
import 'totally_free_games_view.dart';
import 'discounted_games_view.dart';

class GamesHubController extends GetxController {
  var isSearching = false.obs;
  var showFilters = false.obs;
  var currentTab = 0.obs;
  var selectedPlatform = ''.obs;
  final searchTextController = TextEditingController();

  final List<String> platforms = [
    'الكل',
    'PC',
    'PlayStation 5',
    'PlayStation 4',
    'Xbox Series X|S',
    'Xbox One',
    'Nintendo Switch',
    'Android',
    'iOS',
    'Steam',
    'Epic Games',
  ];

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchTextController.clear();
      updateSearch('');
    }
  }

  void toggleFilters() {
    showFilters.value = !showFilters.value;
  }

  void setPlatform(String platform) {
    if (platform == 'الكل') {
      selectedPlatform.value = '';
    } else {
      selectedPlatform.value = platform;
    }
    _triggerFetch();
  }

  void updateSearch(String query) {
    _triggerFetch();
  }

  void _triggerFetch() {
    final query = searchTextController.text;
    final platform = selectedPlatform.value;

    if (currentTab.value == 0) {
      Get.find<FreeGamesController>().setSearchAndPlatform(query, platform);
    } else if (currentTab.value == 1) {
      Get.find<TotallyFreeGamesController>().setSearchAndPlatform(
        query,
        platform,
      );
    } else if (currentTab.value == 2) {
      Get.find<DiscountedGamesController>().setSearchAndPlatform(
        query,
        platform,
      );
    }
  }
}

class GamesHubView extends StatelessWidget {
  GamesHubView({super.key});
  final hubController = Get.put(GamesHubController());

  // Pre-instantiate controllers to ensure they exist for search functionality
  final freeGamesController = Get.put(FreeGamesController());
  final totallyFreeGamesController = Get.put(TotallyFreeGamesController());
  final discountedGamesController = Get.put(DiscountedGamesController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context);
          tabController.addListener(() {
            hubController.currentTab.value = tabController.index;
          });

          return LayoutMine(
            body: Column(
              children: [
                Obx(
                  () => Header(
                    title: hubController.isSearching.value ? null : 'ألعاب',
                    titleWidget: hubController.isSearching.value
                        ? TextField(
                            controller: hubController.searchTextController,
                            autofocus: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'بحث في هذا القسم...',
                              hintStyle: TextStyle(color: Colors.white54),
                              border: InputBorder.none,
                            ),
                            onChanged: (val) => hubController.updateSearch(val),
                          )
                        : null,
                    leading: IconButton(
                      onPressed: hubController.toggleSearch,
                      icon: Icon(
                        hubController.isSearching.value
                            ? Icons.close_rounded
                            : Icons.search_rounded,
                        color: Get.theme.colorScheme.primary,
                      ),
                    ),
                    trailing: IconButton(
                      onPressed: hubController.toggleFilters,
                      icon: Icon(
                        Icons.filter_list_rounded,
                        color: hubController.selectedPlatform.value.isNotEmpty
                            ? Colors.redAccent
                            : Get.theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                Obx(
                  () => Visibility(
                    visible: hubController.showFilters.value,
                    child: Column(
                      children: [
                        _buildPlatformChips(),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                Container(
                  // margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Theme.of(context).colorScheme.primary),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      overflow: TextOverflow.fade,
                      color: Colors.black,
                    ),
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'مجانية دائماً'),
                      Tab(text: 'عروض محدودة'),
                      Tab(text: 'تخفيضات'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _wrapWithBodyOnly(FreeGamesView()),
                      _wrapWithBodyOnly(TotallyFreeGamesView()),
                      _wrapWithBodyOnly(DiscountedGamesView()),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlatformChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: hubController.platforms.length,
        itemBuilder: (context, index) {
          final platform = hubController.platforms[index];
          return Obx(() {
            final isSelected =
                (platform == 'الكل' &&
                    hubController.selectedPlatform.value.isEmpty) ||
                (hubController.selectedPlatform.value == platform);

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(
                  platform,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white70,
                    fontSize: 12,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    hubController.setPlatform(platform);
                  }
                },
                selectedColor: Theme.of(context).colorScheme.primary,
                // backgroundColor: Colors.white.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                  side: BorderSide(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surface,
                  ),
                ),
                showCheckmark: false,
              ),
            );
          });
        },
      ),
    );
  }

  Widget _wrapWithBodyOnly(Widget view) {
    return view;
  }
}
