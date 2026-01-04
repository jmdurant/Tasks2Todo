import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../view_model/controller/settings_controller.dart';

class SyncModeSwitch extends StatelessWidget {
  SyncModeSwitch({super.key});

  final SettingsController settingsController =
      Get.find<SettingsController>();

  @override
  Widget build(BuildContext context) {
    // Hide sync options entirely when Firebase is not available
    if (!settingsController.firebaseAvailable) {
      return const SizedBox.shrink();
    }
    return Obx(() {
      final bool cloudEnabled = !settingsController.useLocalOnly.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SwitchListTile(
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
            ),
          ),
        ),
      );
    });
  }
}
