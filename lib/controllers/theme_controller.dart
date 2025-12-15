import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final GetStorage _box = GetStorage();

  static const String _themeKey = 'isDarkMode';
  static const String _ageKey = 'ageVerified';

  RxBool isDarkMode = true.obs;
  RxBool ageVerified = false.obs;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _loadThemeFromBox();
    ageVerified.value = _loadAgeFromBox();
  }

  // ===== Theme =====
  bool _loadThemeFromBox() => _box.read(_themeKey) ?? true;

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    _box.write(_themeKey, isDarkMode.value);
  }

  ThemeMode get theme => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  // ===== Age Verification =====
  bool _loadAgeFromBox() => _box.read(_ageKey) ?? false;

  void verifyAge(bool verified) {
    ageVerified.value = verified;
    _box.write(_ageKey, verified);
  }
}
