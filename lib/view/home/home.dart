import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/view_model/controller/home_controller.dart';
import 'components/bottom_nav_bar.dart';
import 'components/floating_action.dart';
import 'components/task_page_holder.dart';
import 'components/upper_body.dart';
import '../shared/sync_mode_switch.dart';
import '../shared/theme_mode_switch.dart';
import 'projects_view.dart';
import 'quick_entry_view.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: const FloatingButton(),
      bottomNavigationBar: BottomNavBar(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Obx(() => IndexedStack(
          index: controller.barIndex.value,
          children: [
            // Quick Entry View (index 0)
            const QuickEntryView(),
            // Calendar View (index 1)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UperBody(),
                const Expanded(
                  child: TaskPageBody(),
                ),
              ],
            ),
            // Projects View (index 2)
            const ProjectsView(),
            // Settings View (index 3)
            const _SettingsView(),
          ],
        )),
      ),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings, color: scheme.primary),
              const SizedBox(width: 12),
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SyncModeSwitch(),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ThemeModeSwitch(),
            ),
          ),
        ],
      ),
    );
  }
}



