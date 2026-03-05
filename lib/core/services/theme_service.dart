import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService extends GetxController {
  final _storage = GetStorage();
  final _key = 'isDarkMode';

  final RxBool _isDarkMode = RxBool(GetStorage().read('isDarkMode') ?? false);

  ThemeService();

  /// Get isDarkMode info from local storage and return ThemeMode
  ThemeMode get theme => _loadThemeFromBox() ? ThemeMode.dark : ThemeMode.light;

  /// Load isDarkMode from local storage and if it's empty, returns false (light)
  bool _loadThemeFromBox() => _storage.read(_key) ?? false;

  /// Save isDarkMode to local storage
  void _saveThemeToBox(bool isDarkMode) {
    _storage.write(_key, isDarkMode);
    _isDarkMode.value = isDarkMode;
  }

  /// Switch theme and save it to local storage
  void switchTheme() {
    final newMode = !_isDarkMode.value;
    Get.changeThemeMode(newMode ? ThemeMode.dark : ThemeMode.light);
    _saveThemeToBox(newMode);
  }

  /// Returns true if current theme is dark
  bool isDarkMode() => _isDarkMode.value;
}
