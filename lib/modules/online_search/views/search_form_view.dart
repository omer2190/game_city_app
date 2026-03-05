import 'package:flutter/material.dart';
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
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionTitle('اختر اللعبة', primary),
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
                          title: const Text('أنا فريق'),
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
              label: 'انا فريق',
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

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: color,
        fontFamily: 'Almarai',
      ),
    );
  }
}
