import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'core/constants/app_constants.dart';
import 'core/routes/app_pages.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/security_service.dart';
import 'services/storage_service.dart';
import 'services/listing_stats_service.dart';

import 'services/notification_service.dart';
import 'controllers/home_controller.dart';
import 'controllers/favorite_controller.dart';
import 'controllers/profile_controller.dart';
import 'controllers/main_controller.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'package:flutter/services.dart';
import 'core/localization/translations.dart';
import 'core/utils/initial_route.dart';

Future<void> _precacheShaders() async {
  // Pre-cache common shaders to prevent stutters
  await Future.delayed(const Duration(milliseconds: 100));
}

Future<void> main() async {
  // Keep native splash screen
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Pre-cache shaders to prevent animation stutters
  await _precacheShaders();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize GetStorage
  await GetStorage.init();

  // Read theme and locale from storage
  final box = GetStorage();
  String? themeModeStr = box.read('theme_mode');
  String? localeStr = box.read('locale');

  ThemeMode initialThemeMode;
  if (themeModeStr == 'ThemeMode.dark') {
    initialThemeMode = ThemeMode.dark;
  } else if (themeModeStr == 'ThemeMode.light') {
    initialThemeMode = ThemeMode.light;
  } else if (themeModeStr == 'ThemeMode.system') {
    initialThemeMode = ThemeMode.system;
  } else {
    initialThemeMode = ThemeMode.light;
  }

  Locale initialLocale;
  if (localeStr == 'en') {
    initialLocale = const Locale('en', 'US');
  } else {
    initialLocale = const Locale('az', 'AZ');
  }

  // Initialize services
  Get.put(SecurityService(), permanent: true);
  Get.put(StorageService(), permanent: true);
  Get.put(FirestoreService(), permanent: true);
  Get.put(ListingStatsService(), permanent: true);

  // AuthService'i önce başlat ama navigasyon yapmasını engelle
  final authService =
      Get.put(AuthService(disableInitialNavigation: true), permanent: true);

  // Initialize controllers
  Get.put(HomeController(), permanent: true);
  Get.put(FavoriteController(), permanent: true);
  Get.put(ProfileController(), permanent: true);
  Get.put(MainController(), permanent: true);

  // Status bar şəffaflığı
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Remove splash screen after initialization
  FlutterNativeSplash.remove();

  runApp(MyApp(
    initialThemeMode: initialThemeMode,
    initialLocale: initialLocale,
  ));
}

class MyApp extends StatelessWidget {
  final ThemeMode initialThemeMode;
  final Locale initialLocale;
  const MyApp(
      {super.key, required this.initialThemeMode, required this.initialLocale});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final locale = Get.locale ?? initialLocale;
      final themeMode = Get.isDarkMode
          ? ThemeMode.dark
          : (Get.isPlatformDarkMode ? ThemeMode.system : initialThemeMode);

      // GetMaterialApp oluşturulduktan sonra navigasyonu etkinleştir
      if (Get.isRegistered<AuthService>()) {
        AuthService.to.enableNavigation();
      }

      return GetMaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        debugShowCheckedModeBanner: false,
        getPages: AppPages.pages,
        translations: Messages(),
        locale: locale,
        fallbackLocale: const Locale('en', 'US'),
        initialRoute: getInitialRoute(),
        defaultTransition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 200),
      );
    });
  }
}
