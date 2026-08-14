import 'package:flutter/material.dart';
import 'package:game_city_app/core/values/app_breakpoints.dart';
import 'package:game_city_app/modules/global_games/views/global_games_view.dart';
import 'package:game_city_app/shared/widgets/widgets.dart';
import 'package:get/get.dart';
import '../matchmaking_controller.dart';
import '../widgets/game_selector_card.dart';
import '../widgets/search_mode_toggle.dart';

class SearchFormView extends StatelessWidget {
  final MatchmakingController controller;
  final Color primary;
  final Color secondary;
  final Color surface;

  const SearchFormView({
    super.key,
    required this.controller,
    required this.primary,
    required this.secondary,
    required this.surface,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= AppBreakpoints.tabletBreakpoint;

    if (isDesktop) {
      return _buildDesktopLayout(context);
    }
    return _buildMobileLayout(context);
  }

  // ── Desktop Layout (≥1024px) ──────────────────────────────────────────
  Widget _buildDesktopLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Row: Title + Info Button ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('اختر اللعبة', primary, fontSize: 22),
                  IconButton(
                    onPressed: () => Get.to(() => GlobalGamesView()),
                    icon: Icon(Icons.add_rounded, color: primary, size: 26),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Game List ──
              _buildGameListDesktop(),
              const SizedBox(height: 40),

              // ── Two Column Section ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Left Column: Search Mode ──
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildSectionTitle(
                              'نوع البحث',
                              primary,
                              fontSize: 20,
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              iconSize: 18,
                              onPressed: () {
                                Get.defaultDialog(
                                  title: 'أنواع البحث',
                                  content: Column(
                                    children: [
                                      ListTile(
                                        leading: const Icon(Icons.person),
                                        title: const Text('أنا لاعب'),
                                        subtitle: const Text(
                                          'تبحث عن لاعبين آخرين للعب معهم',
                                        ),
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.group),
                                        title: const Text('أنا الفريق'),
                                        subtitle: const Text(
                                          'تبحث عن فرق أخرى للتنافس معها',
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.info_outline,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildModeSelectorsDesktop(),
                      ],
                    ),
                  ),

                  const SizedBox(width: 40),

                  // ── Right Column: Notes + Button ──
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(
                          'ملاحظات إضافية',
                          primary,
                          fontSize: 20,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          hintColor: Colors.white,
                          controller: controller.notesController,
                          maxLines: 4,
                          hint: 'أهلاً، أحتاج لاعب محترف لرفع الرنك...',
                          prefixIcon: Icons.edit_note,
                        ),
                        const SizedBox(height: 32),
                        _buildStartButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Mobile / Tablet Layout ────────────────────────────────────────────
  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle('اختر اللعبة', primary),
              IconButton(
                onPressed: () => Get.to(() => GlobalGamesView()),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildGameList(),
          const SizedBox(height: 32),
          Row(
            children: [
              _buildSectionTitle('نوع البحث', primary),
              IconButton(
                iconSize: 16,
                onPressed: () {
                  Get.defaultDialog(
                    title: 'أنواع البحث',
                    content: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: const Text('أنا لاعب'),
                          subtitle: const Text(
                            'تبحث عن لاعبين آخرين للعب معهم',
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.group),
                          title: const Text('أنا الفريق'),
                          subtitle: const Text('تبحث عن فرق أخرى للتنافس معها'),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(Icons.info_outline, color: Colors.white54),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildModeSelectors(),
          const SizedBox(height: 32),
          _buildSectionTitle('ملاحظات إضافية', primary),
          const SizedBox(height: 12),
          CustomTextField(
            hintColor: Colors.white,
            controller: controller.notesController,
            maxLines: 2,
            hint: 'أهلاً، أحتاج لاعب محترف لرفع الرنك...',
            prefixIcon: Icons.edit_note,
          ),
          const SizedBox(height: 48),
          _buildStartButton(),
        ],
      ),
    );
  }

  // ── Game List (Desktop - wider cards, larger height) ───────────────────
  Widget _buildGameListDesktop() {
    return SizedBox(
      height: 170,
      child: Obx(() {
        if (controller.myGames.isEmpty) {
          return Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: const Center(
              child: Text(
                "لا توجد ألعاب مضافة في قائمة العب الآن",
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ),
          );
        }
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: controller.myGames.length,
          itemBuilder: (context, index) {
            final game = controller.myGames[index];
            return Obx(() {
              final String gameId = game['id'].toString();
              return GameSelectorCard(
                game: game,
                isSelected: controller.selectedGameId.value == gameId,
                primary: primary,
                surface: surface,
                onTap: () => controller.selectedGameId.value = gameId,
              );
            });
          },
        );
      }),
    );
  }

  // ── Game List (Mobile - original) ─────────────────────────────────────
  Widget _buildGameList() {
    return SizedBox(
      height: 140,
      child: Obx(() {
        if (controller.myGames.isEmpty) {
          return Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: const Center(
              child: Text(
                "لا توجد ألعاب مضافة في قائمة العب الآن",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: controller.myGames.length,
          itemBuilder: (context, index) {
            final game = controller.myGames[index];
            return Obx(() {
              final String gameId = game['id'].toString();
              return GameSelectorCard(
                game: game,
                isSelected: controller.selectedGameId.value == gameId,
                primary: primary,
                surface: surface,
                onTap: () => controller.selectedGameId.value = gameId,
              );
            });
          },
        );
      }),
    );
  }

  // ── Mode Selectors (Desktop - horizontal layout with bigger buttons) ──
  Widget _buildModeSelectorsDesktop() {
    return Row(
      children: [
        Expanded(
          child: Obx(
            () => SearchModeToggle(
              label: 'انا لاعب',
              icon: Icons.person,
              isSelected: controller.selectedType.value == 'solo',
              primary: primary,
              surface: surface,
              onTap: () => controller.selectedType.value = 'solo',
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Obx(
            () => SearchModeToggle(
              label: 'انا الفريق',
              icon: Icons.group,
              isSelected: controller.selectedType.value == 'team',
              primary: primary,
              surface: surface,
              onTap: () => controller.selectedType.value = 'team',
            ),
          ),
        ),
      ],
    );
  }

  // ── Mode Selectors (Mobile - original) ───────────────────────────────
  Widget _buildModeSelectors() {
    return Row(
      children: [
        Expanded(
          child: Obx(
            () => SearchModeToggle(
              label: 'انا لاعب',
              icon: Icons.person,
              isSelected: controller.selectedType.value == 'solo',
              primary: primary,
              surface: surface,
              onTap: () => controller.selectedType.value = 'solo',
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Obx(
            () => SearchModeToggle(
              label: 'انا الفريق',
              icon: Icons.group,
              isSelected: controller.selectedType.value == 'team',
              primary: primary,
              surface: surface,
              onTap: () => controller.selectedType.value = 'team',
            ),
          ),
        ),
      ],
    );
  }

  // ── Start Button ─────────────────────────────────────────────────────
  Widget _buildStartButton() {
    return Obx(
      () => CustomButton(
        text: 'بدء البحث',
        onPressed: controller.myGames.isEmpty ? null : controller.startSearch,
        isLoading: controller.isLoading.value,
        backgroundColor: primary,
        height: 55,
        borderRadius: 16,
      ),
    );
  }

  // ── Section Title ────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title, Color color, {double fontSize = 18}) {
    return Text(
      title,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: color,
        fontFamily: 'Almarai',
      ),
    );
  }
}
