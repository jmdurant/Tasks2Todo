import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:todo/config/app_config.dart';
import 'package:todo/theme/app_theme.dart';
import 'package:todo/view/splash/splash_screen.dart';
import 'package:todo/view_model/controller/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (AppConfig.firebaseAvailable) {
    await Firebase.initializeApp();
    await GoogleSignIn.instance.initialize();
  }
  final SettingsController settingsController =
      Get.put(SettingsController(), permanent: true);
  await settingsController.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashView(),
    );
  }
}
