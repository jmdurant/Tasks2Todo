import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:todo/config/app_config.dart';
import 'package:todo/theme/app_theme.dart';
import 'package:todo/view/home/home.dart';
import 'package:todo/view/splash/splash_screen.dart';
import 'package:todo/view_model/controller/home_controller.dart';
import 'package:todo/view_model/controller/new_task_controller.dart';
import 'package:todo/view_model/controller/settings_controller.dart';
import 'package:todo/view_model/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (AppConfig.firebaseAvailable) {
    await Firebase.initializeApp();
    await GoogleSignIn.instance.initialize();
  }
  final SettingsController settingsController =
      Get.put(SettingsController(), permanent: true);
  await settingsController.initialize();

  // Initialize notifications and reschedule existing reminders
  await NotificationService.instance.initialize();
  await NotificationService.instance.requestPermission();
  NotificationService.instance.rescheduleAllReminders();

  if (!AppConfig.firebaseAvailable) {
    Get.put(HomeController());
    Get.put(NewTaskController());
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController = Get.find();
    final Widget home = AppConfig.firebaseAvailable
        ? const SplashView()
        : HomePage();
    return Obx(() => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode:
              settingsController.darkMode.value ? ThemeMode.dark : ThemeMode.light,
          home: home,
        ));
  }
}
