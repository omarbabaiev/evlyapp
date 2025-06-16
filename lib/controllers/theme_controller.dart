import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  final GetStorage _storage = GetStorage();
  final RxBool _isDarkMode = false.obs;

  bool get isDarkMode => _isDarkMode.value;
  ThemeMode get themeMode =>
      _isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromStorage();
  }

  void _loadThemeFromStorage() {
    final isDark = _storage.read('isDarkMode') ?? false;
    _isDarkMode.value = isDark;
  }

  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    _storage.write('isDarkMode', _isDarkMode.value);
    Get.changeThemeMode(themeMode);
  }

  void setTheme(bool isDark) {
    _isDarkMode.value = isDark;
    _storage.write('isDarkMode', isDark);
    Get.changeThemeMode(themeMode);
  }

  void setLightTheme() {
    setTheme(false);
  }

  void setDarkTheme() {
    setTheme(true);
  }

  void setSystemTheme() {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    setTheme(brightness == Brightness.dark);
  }
}
