import 'dart:convert';
import 'dart:io' show GZipCodec;

import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:todo/view_model/services/sync_service.dart';

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
  _initDeepLinkReceiver();
  _initSyncLifecycle(settingsController);

  runApp(const MyApp());
}

/// Starts/stops Firebase live sync whenever the auth state or the cloud-mode
/// toggle changes. Sync runs only when Firebase is compiled in, the user is
/// signed in, and cloud mode is on.
void _initSyncLifecycle(SettingsController settings) {
  if (!AppConfig.firebaseAvailable) return;

  void evaluate() {
    final signedIn = FirebaseAuth.instance.currentUser != null;
    if (signedIn && !settings.useLocalOnly.value) {
      SyncService.instance.startLiveSync();
    } else {
      SyncService.instance.stopLiveSync();
    }
  }

  // React to login/logout (also fires once on startup with the restored
  // session) and to the user flipping the cloud-sync toggle.
  FirebaseAuth.instance.authStateChanges().listen((_) => evaluate());
  ever(settings.useLocalOnly, (_) => evaluate());
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

/// Listens for `tasks2todo://` deep-link launches — the direct, no-share-sheet
/// route paper2todo can use as a one-tap "Open in Tasks2Todo" button after
/// processing.
///
/// URL format: `tasks2todo://import?data=<base64url(gzip(jsonBytes))>`. The
/// gzip + base64 keeps the URL well under the ~8KB practical limit for
/// realistic capture sessions; oversized captures should fall back to share.
void _initDeepLinkReceiver() {
  final appLinks = AppLinks();

  appLinks.uriLinkStream.listen(_processIncomingUri,
      onError: (Object e) => debugPrint('AppLinks stream error: $e'));

  appLinks.getInitialLink().then((Uri? uri) {
    if (uri == null) return;
    Future.delayed(const Duration(milliseconds: 500), () {
      _processIncomingUri(uri);
    });
  });
}

Future<void> _processIncomingUri(Uri uri) async {
  if (uri.scheme != 'tasks2todo') return;
  if (uri.host != 'import' && uri.path != '/import' && uri.path != 'import') {
    debugPrint('Deep link: unknown path ${uri.host}${uri.path}');
    return;
  }
  final String? data = uri.queryParameters['data'];
  if (data == null || data.isEmpty) {
    debugPrint('Deep link: missing data param');
    return;
  }
  try {
    // base64url-decode → gunzip → utf8 → re-prefix with sentinel so the
    // existing payload decoder can do the rest.
    final compressed = base64Url.decode(_padBase64(data));
    final jsonBytes = GZipCodec().decode(compressed);
    final jsonStr = utf8.decode(jsonBytes);
    await _ingestPaper2TodoJson(jsonStr);
  } catch (e) {
    debugPrint('Deep link: failed to decode payload: $e');
    Utils.showSnackBar(
      'Open failed',
      'Could not read the Tasks2Todo link: $e',
      const Icon(Icons.error_outline, color: Colors.white),
    );
  }
}

/// base64Url.decode requires correct padding; URL-safe base64 in real-world
/// use often strips it. Re-add `=` padding so decoding succeeds.
String _padBase64(String s) {
  final mod = s.length % 4;
  if (mod == 0) return s;
  return s + ('=' * (4 - mod));
}

/// Decodes a raw paper2todo JSON body (no sentinel), persists it, and
/// navigates to the Inbox. Shared by the deep-link and share-text paths.
Future<void> _ingestPaper2TodoJson(String jsonBody) async {
  final wrapped = '${Paper2TodoPayload.sentinel}\n$jsonBody';
  final payload = Paper2TodoPayload.tryDecode(wrapped);
  if (payload == null) {
    debugPrint('paper2todo: payload decode returned null');
    return;
  }
  await DbHelper().insertPaper2TodoCapture(payload);
  try {
    final home = Get.find<HomeController>();
    home.barIndex.value = 0;
    home.quickEntryMode.value = 2;
  } catch (_) {}
  Utils.showSnackBar(
    'Captured',
    'Got ${payload.items.length} item${payload.items.length == 1 ? '' : 's'} from Paper2Todo',
    const Icon(Icons.move_to_inbox, color: Colors.white),
  );
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
