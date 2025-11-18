import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:todo/config/app_config.dart';
import 'package:todo/theme/app_theme.dart';
import 'package:todo/view/splash/splash_screen.dart';
import 'package:todo/view_model/controller/settings_controller.dart';

import 'data/local/database/database_native.dart'
    if (dart.library.html) 'data/local/database/database_web.dart' as db_preload;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Parallelize all initialization tasks for faster startup
  await Future.wait([
    if (AppConfig.firebaseAvailable) ...[
      Firebase.initializeApp(),
      GoogleSignIn.instance.initialize(),
    ],
    () async {
      final SettingsController settingsController =
          Get.put(SettingsController(), permanent: true);
      await settingsController.initialize();
    }(),
    // Preload database (especially important for WASM on web)
    db_preload.preloadDatabase(),
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController = Get.find();
    return Obx(() => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode:
              settingsController.darkMode.value ? ThemeMode.dark : ThemeMode.light,
          home: const SplashView(),
        ));
  }
}
