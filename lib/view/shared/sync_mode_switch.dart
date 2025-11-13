import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../view_model/controller/settings_controller.dart';

class SyncModeSwitch extends StatelessWidget {
  SyncModeSwitch({super.key});

  final SettingsController settingsController =
      Get.find<SettingsController>();

  @override
  Widget build(BuildContext context) {
    if (!settingsController.firebaseAvailable) {
      return const ListTile(
        title: Text('Cloud sync unavailable'),
        subtitle: Text('Rebuild with USE_FIREBASE=true to enable Firebase.'),
      );
    }
    return Obx(() {
      final bool cloudEnabled = !settingsController.useLocalOnly.value;
      return SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Enable cloud sync (Firebase)'),
        subtitle: Text(
          cloudEnabled
              ? 'Tasks sync with Firebase'
              : 'Local-only mode (default)',
        ),
        value: cloudEnabled,
        onChanged: (bool value) {
          settingsController.setUseLocalOnly(!value);
        },
      );
    });
  }
}
