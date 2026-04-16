import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart'
//     show kIsWeb, defaultTargetPlatform, kDebugMode;
import 'package:get/get.dart';
import 'package:game_city_app/core/services/storage_service.dart';
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
import 'core/services/version_service.dart';
import 'core/bindings/initial_binding.dart';

// Must be top-level or static
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('--- Background Message Received ---');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');
    print('----------------------------------');
  }
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();

  try {
    // Set timeago to Arabic
    timeago.setLocaleMessages('ar', timeago.ArMessages());

    // Initialize Firebase
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Set the background messaging handler early on, as a function not a method.
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      await Get.putAsync(() => NotificationService().init());
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } else {
        debugPrint('Firebase already initialized');
      }
    } catch (e) {
      if (e is FirebaseException && e.code == 'duplicate-app') {
        debugPrint('Firebase duplicate app handled');
      } else {
        debugPrint('Firebase init error: $e');
      }
    }

    // Set background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    debugPrint('StorageService initialized successfully');

    // Initialize Services
    final notificationService = Get.put(NotificationService());
    await notificationService.init();
    debugPrint('NotificationService initialized successfully');

    // Version Check
    final versionService = Get.put(VersionService());
    versionService.checkVersion();
  } catch (e) {
    debugPrint('Error during initialization: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // if (kIsWeb &&
    //     defaultTargetPlatform != TargetPlatform.android &&
    //     defaultTargetPlatform != TargetPlatform.iOS) {
    //   return const MobileOnlyWrapper();
    // }

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

class MobileOnlyWrapper extends StatelessWidget {
  const MobileOnlyWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFF0F172A), const Color(0xFF1E293B)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Use the generated image or a placeholder icon if image fails
              Image.asset(
                'assets/images/mobile_only_illustration.png',
                width: 300,
                height: 300,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.phonelink_lock_rounded,
                  size: 150,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                "هذا التطبيق مخصص للهواتف فقط",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Cairo', // Assuming Cairo is used or default
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "يرجى فتح الرابط من متصفح هاتفك المحمول للحصول على أفضل تجربة.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ),
              const SizedBox(height: 50),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blueAccent, Colors.purpleAccent],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Text(
                    "Mobile App Only",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
