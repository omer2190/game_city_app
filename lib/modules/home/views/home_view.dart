import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:game_city_app/modules/bases/views/bases_page.dart';
import 'package:game_city_app/modules/game_coming_soon/views/game_coming_soon.dart';
import 'package:game_city_app/modules/online_search/online_search.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
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
    // CommunityView(),
    // ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Obx(() => _pages[controller.currentIndex.value]),
      floatingActionButton: Obx(
        () => Container(
          height: 65,
          width: 65,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // boxShadow: [
            //   BoxShadow(
            //     color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            //     blurRadius: 15,
            //     offset: const Offset(0, 5),
            //   ),
            // ],
          ),
          child: FloatingActionButton(
            onPressed: () => controller.changePage(2),
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: CircleBorder(
              side: BorderSide(
                color: controller.currentIndex.value == 2
                    ? Theme.of(context).colorScheme.primary
                    : Colors.black,
                width: controller.currentIndex.value == 2 ? 3 : 1,
              ),
            ),
            elevation: 0,
            child: Icon(
              Icons.saved_search,
              size: 32,
              color: controller.currentIndex.value == 2
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Obx(
        () => Container(
          // margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            // borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                decoration: BoxDecoration(
                  // color: Theme.of(context).cardColor.withOpacity(0.8),
                  // borderRadius: BorderRadius.circular(25),
                  // border: Border.all(color: Colors.white10),
                ),
                child: BottomNavigationBar(
                  currentIndex: controller.currentIndex.value,
                  onTap: (index) {
                    if (index != 2) {
                      controller.changePage(index);
                    }
                  },
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  type: BottomNavigationBarType.fixed,
                  showSelectedLabels: true,
                  showUnselectedLabels: false,
                  selectedItemColor: Theme.of(context).colorScheme.primary,
                  unselectedItemColor: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withOpacity(0.5),
                  selectedFontSize: 12,
                  selectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  items: [
                    BottomNavigationBarItem(
                      icon: Obx(
                        () => Stack(
                          children: [
                            Icon(
                              Icons.home,
                              size: 24,
                              color: controller.currentIndex.value == 0
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.white,
                            ),
                            if (notificationsController.unreadCount > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 10,
                                    minHeight: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      label: 'الرئيسية',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.newspaper,
                        size: 24,
                        color: controller.currentIndex.value == 1
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
                      ),
                      label: 'أخبار',
                    ),
                    const BottomNavigationBarItem(
                      icon: SizedBox.shrink(),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.sports_esports_rounded,
                        size: 26,
                        color: controller.currentIndex.value == 3
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
                      ),
                      label: 'العاب',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.timelapse,
                        size: 24,
                        color: controller.currentIndex.value == 4
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
                      ),
                      label: 'تقويم',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
