import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'routes/app_routes.dart';
import 'routes/app_pages.dart';
import 'firebase_options.dart';
import 'core/values/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'core/services/theme_service.dart';
import 'core/services/version_service.dart';
import 'core/bindings/initial_binding.dart';

// Must be top-level or static
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set timeago to Arabic
  timeago.setLocaleMessages('ar', timeago.ArMessages());

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await GetStorage.init();

  // Initialize Services
  final notificationService = NotificationService();
  Get.put(notificationService);
  if (GetPlatform.isMobile) {
    await notificationService.init();
  }

  Get.put(ThemeService());

  // Version Check
  final versionService = Get.put(VersionService());
  versionService.checkVersion();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'AE'),
      fallbackLocale: const Locale('ar', 'AE'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar', 'AE'), Locale('en', 'US')],
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      // themeMode: Get.find<ThemeService>().theme,
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}
