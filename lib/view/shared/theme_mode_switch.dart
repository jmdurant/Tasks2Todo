import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../view_model/controller/settings_controller.dart';

class ThemeModeSwitch extends StatelessWidget {
  ThemeModeSwitch({super.key});

  final SettingsController settingsController = Get.find<SettingsController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isDark = settingsController.darkMode.value;
      return SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Dark mode'),
        subtitle: Text(
          isDark ? 'Using dark appearance' : 'Using light appearance',
        ),
        value: isDark,
        onChanged: settingsController.setDarkMode,
      );
    });
  }
}
