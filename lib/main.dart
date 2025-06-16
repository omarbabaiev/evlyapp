// ignore_for_file: unused_import

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

  // Initialize services
  Get.put(SecurityService(), permanent: true);
  Get.put(StorageService(), permanent: true);
  Get.put(FirestoreService(), permanent: true);
  Get.put(ListingStatsService(), permanent: true);

  // Initialize new services

  // Initialize AuthService and wait for auth state
  final authService = Get.put(AuthService(), permanent: true);

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

  // Wait a bit for auth state to initialize
  await Future.delayed(const Duration(seconds: 2));

  // Remove splash screen after initialization
  FlutterNativeSplash.remove();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      getPages: AppPages.pages,
      translations: Messages(),
      locale: const Locale('az', 'AZ'),
      fallbackLocale: const Locale('en', 'US'),
      initialRoute: _getInitialRoute(),
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 200),
    );
  }

  String _getInitialRoute() {
    // Check if intro has been shown
    final storage = GetStorage();
    final introShown = storage.read('intro_shown') ?? false;

    if (!introShown) {
      return '/intro';
    }

    // Check if user is already logged in
    try {
      final authService = Get.find<AuthService>();
      if (authService.firebaseUser.value != null) {
        return '/main';
      }
    } catch (e) {
      print('Error getting auth service: $e');
    }
    return '/login';
  }
}
