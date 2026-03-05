import 'package:flutter/material.dart';
import 'package:game_city_app/core/values/app_colors.dart';
import 'package:game_city_app/shared/header.dart';
import 'package:game_city_app/shared/layout_mine.dart';
import 'package:get/get.dart';
import 'matchmaking_controller.dart';
import 'views/search_form_view.dart';
import 'views/searching_view.dart';
import 'views/match_found_view.dart';

class OnlineSearch extends StatelessWidget {
  const OnlineSearch({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the controller
    final MatchmakingController controller = Get.put(MatchmakingController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryColor = isDark
        ? AppColors.primaryDark
        : AppColors.primaryLight;
    final secondaryColor = isDark
        ? AppColors.secondaryDark
        : AppColors.secondaryLight;
    final surfaceColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;

    return LayoutMine(
      body: Column(
        children: [
          Header(title: 'البحث عن لاعبين'),
          Expanded(
            child: Obx(() {
              // Priority 1: Match Found
              if (controller.matchFound.value &&
                  controller.matchResult.value != null) {
                return MatchFoundView(
                  controller: controller,
                  match: controller.matchResult.value!,
                  primary: primaryColor,
                );
              }

              // Priority 2: Searching Pulse
              if (controller.isSearching.value) {
                return SearchingView(
                  controller: controller,
                  primary: primaryColor,
                  secondary: secondaryColor,
                );
              }

              // Default: Initial Form
              return SearchFormView(
                controller: controller,
                primary: primaryColor,
                secondary: secondaryColor,
                surface: surfaceColor,
              );
            }),
          ),
        ],
      ),
    );
  }
}

/* 
  Refactored to follow Clean Code:
  - Separate views for each state (SearchForm, Searching, MatchFound).
  - Reusable widgets for UI components.
*/
