import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo/view_model/controller/home_controller.dart';
import 'package:todo/view_model/controller/settings_controller.dart';
import 'package:todo/view_model/services/sync_service.dart';
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
          const _SyncNowCard(),
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

/// "Sync now" control. Only shown when Firebase is compiled in and cloud mode
/// is on. Runs a manual last-write-wins reconcile and reports the result.
class _SyncNowCard extends StatefulWidget {
  const _SyncNowCard();

  @override
  State<_SyncNowCard> createState() => _SyncNowCardState();
}

class _SyncNowCardState extends State<_SyncNowCard> {
  final SettingsController _settings = Get.find<SettingsController>();
  bool _busy = false;
  String? _status;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Obx(() {
      // Read the observable unconditionally — `firebaseAvailable && ...` would
      // short-circuit on web (firebaseAvailable=false) and leave the Obx with
      // nothing to track, which throws "[Get] improper use of GetX".
      final bool localOnly = _settings.useLocalOnly.value;
      final bool show = _settings.firebaseAvailable && !localOnly;
      if (!show) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.cloud_sync_outlined, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cloud sync',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        _status ?? 'Sync tasks with your Firebase account',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: _busy ? null : _sync,
                  child: _busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sync now'),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Future<void> _sync() async {
    setState(() {
      _busy = true;
      _status = 'Syncing…';
    });
    final SyncResult result = await SyncService.instance.syncNow();
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (result.ok) {
        final time = DateFormat('h:mm a').format(DateTime.now());
        _status = 'Last synced $time · ↓${result.pulled} ↑${result.pushed}';
      } else {
        _status = 'Sync failed: ${result.error}';
      }
    });
  }
}



