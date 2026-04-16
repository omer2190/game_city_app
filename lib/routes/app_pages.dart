import 'package:game_city_app/data/models/news_model.dart';
import 'package:game_city_app/modules/community/views/community_view.dart';
import 'package:game_city_app/modules/games/views/games_hub_view.dart';
import 'package:game_city_app/modules/news/views/news_view.dart';
import 'package:game_city_app/modules/profile/views/profile_view.dart';
import 'package:get/get.dart';
import '../modules/home/views/home_view.dart';
import '../modules/home/controllers/home_controller.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/auth/views/verify_account_view.dart';
import '../modules/auth/views/forgot_password_view.dart';
import '../modules/auth/views/reset_password_view.dart';
import '../modules/auth/views/change_password_view.dart';
import '../modules/news/views/news_details_view.dart';
import '../modules/news/controllers/news_details_controller.dart';
import '../modules/games/views/game_details_view.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/splash/splash_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/settings/controllers/settings_controller.dart';
import '../modules/game_coming_soon/views/game_coming_soon.dart';
import '../modules/game_coming_soon/controllers/game_coming_soon_controller.dart';
import '../core/middleware/auth_middleware.dart';
import 'app_routes.dart';
import '../modules/online_search/online_search.dart';
import '../modules/online_search/matchmaking_controller.dart';
import '../modules/notifications/views/notifications_view.dart';
import '../modules/notifications/controllers/notifications_controller.dart';
import '../modules/wishlist/views/wishlist_view.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => HomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HomeController());
      }),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(name: AppRoutes.login, page: () => LoginView()),
    GetPage(name: AppRoutes.register, page: () => RegisterView()),
    GetPage(
      name: AppRoutes.verifyAccount,
      page: () => VerifyAccountView(email: Get.arguments ?? ''),
    ),
    GetPage(name: AppRoutes.forgotPassword, page: () => ForgotPasswordView()),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => ResetPasswordView(email: Get.arguments ?? ''),
    ),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => ChangePasswordView(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(name: AppRoutes.profile, page: () => ProfileView()),
    GetPage(name: AppRoutes.chatRoom, page: () => CommunityView()),
    GetPage(name: AppRoutes.news, page: () => const NewsView()),
    GetPage(
      name: AppRoutes.newsDetails,
      page: () {
        final args = Get.arguments;
        if (args is News) {
          return NewsDetailsView(news: args);
        }
        return const NewsDetailsView();
      },
      binding: BindingsBuilder(() {
        Get.lazyPut(() => NewsDetailsController());
      }),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(name: AppRoutes.game, page: () => GamesHubView()),
    GetPage(
      name: AppRoutes.gameDetails,
      page: () {
        return GameDetailsView();
      },
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SettingsController());
      }),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.gameComingSoon,
      page: () => GameComingSoon(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => GameComingSoonController());
      }),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.onlineSearch,
      page: () => const OnlineSearch(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => MatchmakingController());
      }),
      middlewares: [AuthMiddleware()],
    ),
    //CommunityView(),
    GetPage(name: '/messages', page: () => CommunityView()),
    // ProfileView(),
    GetPage(name: '/profile', page: () => ProfileView()),

    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => NotificationsController());
      }),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: AppRoutes.wishlist,
      page: () => WishlistView(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
