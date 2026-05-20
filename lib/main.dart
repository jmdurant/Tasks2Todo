import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:share_handler/share_handler.dart';
import 'package:todo/config/app_config.dart';
import 'package:todo/db_helper/db_helper.dart';
import 'package:todo/theme/app_theme.dart';
import 'package:todo/util/paper2todo_payload.dart';
import 'package:todo/util/task_parser.dart';
import 'package:todo/util/utils.dart';
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

  // Register task controllers once for the app's lifetime. Auth flows reset
  // their state via Get.delete + Get.put on sign-out.
  Get.put(HomeController(), permanent: true);
  Get.put(NewTaskController(), permanent: true);

  await NotificationService.instance.initialize();
  await NotificationService.instance.requestPermission();
  NotificationService.instance.rescheduleAllReminders();

  _initShareReceiver();

  runApp(const MyApp());
}

/// Listens for incoming share intents containing text — typically the DSL
/// payload from Paper2Todo. Parses with [TaskParser] and bulk-inserts into
/// the Tasks table, then refreshes the home view.
void _initShareReceiver() {
  final handler = ShareHandlerPlatform.instance;

  handler.sharedMediaStream.listen((SharedMedia media) {
    _processIncomingShare(media);
  });

  handler.getInitialSharedMedia().then((SharedMedia? media) {
    if (media == null) return;
    // Delay slightly so MyApp has mounted and Get.context is available for
    // the success snackbar.
    Future.delayed(const Duration(milliseconds: 500), () {
      _processIncomingShare(media);
    });
  });
}

Future<void> _processIncomingShare(SharedMedia media) async {
  final String? raw = media.content;
  if (raw == null || raw.trim().isEmpty) return;

  // Phase B: paper2todo sends rich JSON with a sentinel prefix. Lands in the
  // Inbox view for review rather than going straight to the Tasks table.
  try {
    final payload = Paper2TodoPayload.tryDecode(raw);
    if (payload != null) {
      await DbHelper().insertPaper2TodoCapture(payload);
      // Jump the user straight to Quick Entry → Inbox so they see the new
      // capture without manually navigating. Wrapped in try because the
      // HomeController might not be registered yet on cold-start share.
      try {
        final home = Get.find<HomeController>();
        home.barIndex.value = 0; // Quick Entry tab
        home.quickEntryMode.value = 2; // Inbox sub-mode
      } catch (_) {}
      Utils.showSnackBar(
        'Captured',
        'Got ${payload.items.length} item${payload.items.length == 1 ? '' : 's'} from Paper2Todo',
        const Icon(Icons.move_to_inbox, color: Colors.white),
      );
      return;
    }
  } catch (e) {
    debugPrint('Share receiver: paper2todo payload malformed: $e');
    Utils.showSnackBar(
      'Paper2Todo error',
      'Could not read the shared payload: $e',
      const Icon(Icons.error_outline, color: Colors.white),
    );
    return;
  }

  // Phase A fallback: plain DSL text → Quick Entry parser → Tasks table.
  final parsed = TaskParser.parseQuickEntry(raw);
  if (parsed.isEmpty) return;

  final models = TaskParser.convertToTaskModels(parsed);
  await DbHelper().insertAll(models);

  try {
    Get.find<HomeController>().getTasks();
  } catch (_) {
    // HomeController may not be registered yet on a cold-start share — the
    // initial getTasks() in its onInit will pick everything up.
  }

  final count = models.length;
  Utils.showSnackBar(
    'Imported',
    'Added $count task${count == 1 ? '' : 's'} from share',
    const Icon(Icons.move_to_inbox, color: Colors.white),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController = Get.find();
    final Widget home =
        AppConfig.firebaseAvailable ? const SplashView() : HomePage();
    return Obx(() => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settingsController.darkMode.value
              ? ThemeMode.dark
              : ThemeMode.light,
          home: home,
        ));
  }
}
