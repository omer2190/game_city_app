import 'package:flutter/material.dart';
import 'package:game_city_app/modules/bases/views/bases_page.dart';
import 'package:game_city_app/modules/game_coming_soon/views/game_coming_soon.dart';
import 'package:game_city_app/modules/online_search/online_search.dart';
import 'package:get/get.dart';
import '../../notifications/views/notifications_view.dart';
import '../../wishlist/views/wishlist_view.dart';
import '../controllers/home_controller.dart';
import '../widgets/responsive_shell.dart';
import '../../notifications/controllers/notifications_controller.dart';
import '../../news/views/news_view.dart';
import '../../games/views/games_hub_view.dart';

class HomeView extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());
  final NotificationsController notificationsController =
      Get.find<NotificationsController>();

  HomeView({super.key});

  final List<Widget> _pages = [
    BasesPage(),
    NewsView(),
    OnlineSearch(),
    GamesHubView(),
    GameComingSoon(),
    NotificationsView(), // Uncomment when NotificationsPage is implemented
    WishlistView(), // Uncomment when WishlistPage is implemented
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ResponsiveShell(
        pages: _pages,
        currentIndex: controller.currentIndex.value,
        onTabChanged: controller.changePage,
      ),
    );
  }
}
