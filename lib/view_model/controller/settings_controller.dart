import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_config.dart';

class SettingsController extends GetxController {
  static const String _localOnlyKey = 'USE_LOCAL_ONLY';
  static const String _darkModeKey = 'USE_DARK_MODE';

  final bool firebaseAvailable = AppConfig.firebaseAvailable;

  final RxBool useLocalOnly = true.obs;
  final RxBool darkMode = false.obs;

  Future<void> initialize() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    darkMode.value = prefs.getBool(_darkModeKey) ?? false;

    if (!firebaseAvailable) {
      useLocalOnly.value = true;
      return;
    }
    useLocalOnly.value = prefs.getBool(_localOnlyKey) ?? true;
  }

  Future<void> setUseLocalOnly(bool value) async {
    if (!firebaseAvailable) {
      useLocalOnly.value = true;
      return;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_localOnlyKey, value);
    useLocalOnly.value = value;
  }

  Future<void> setDarkMode(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
    darkMode.value = value;
  }
}
