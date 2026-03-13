import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/config/app_config.dart';
import 'package:todo/data/local/local_auth_service.dart';
import 'package:todo/view/home/calendar_view.dart';
import 'package:todo/view_model/controller/home_controller.dart';
import '../../../view_model/responsive.dart';
import 'search_dialog.dart';
import '../stats_view.dart';

class CustomAppBar extends StatelessWidget {
  CustomAppBar({super.key});
  final controller = Get.find<HomeController>();

  void _showSearch(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SearchDialog(),
    );
  }

  void _showProfilePopup(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.primary,
                ),
                child: Icon(
                  Icons.person,
                  size: 48,
                  color: scheme.onPrimary,
                ),
              ),
              const SizedBox(height: 16),
              // Name
              Obx(() => Text(
                controller.name.value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              )),
              const SizedBox(height: 4),
              // Email if available
              Obx(() {
                final email = controller.userData['EMAIL'];
                if (email != null && email.toString().isNotEmpty) {
                  return Text(
                    email.toString(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 24),
              // Logout button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _confirmLogout(context);
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              LocalAuthService().signOut();
            },
            style: FilledButton.styleFrom(
              backgroundColor: scheme.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        children: [
          if (Responsive.isTablet(context)) const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (AppConfig.firebaseAvailable) ...[
                Text(
                  'Hello,',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w400,
                    height: 0,
                    letterSpacing: 2,
                    fontSize: 18,
                  ),
                ),
                Obx(() => Text(
                  controller.name.value,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    height: 0,
                    fontSize: 25,
                  ),
                )),
              ] else
                Text(
                  'My Tasks',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    height: 0,
                    fontSize: 25,
                  ),
                ),
            ],
          ),
          const Spacer(flex: 10),
          // Stats button
          InkWell(
            onTap: () => Get.to(() => const StatsView()),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: scheme.surfaceContainerHighest,
              ),
              child: Icon(Icons.bar_chart, color: scheme.onSurface),
            ),
          ),
          const SizedBox(width: 12),
          // Monthly calendar button
          InkWell(
            onTap: () => Get.to(() => const _MonthlyCalendarPage()),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: scheme.surfaceContainerHighest,
              ),
              child: Icon(Icons.calendar_month, color: scheme.onSurface),
            ),
          ),
          const SizedBox(width: 12),
          // Search button
          InkWell(
            onTap: () => _showSearch(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: scheme.surfaceContainerHighest,
              ),
              child: Icon(Icons.search, color: scheme.onSurface),
            ),
          ),
          if (AppConfig.firebaseAvailable) ...[
            const SizedBox(width: 12),
            // Profile button
            InkWell(
              onTap: () => _showProfilePopup(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: scheme.primary,
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(Icons.account_circle_outlined, color: scheme.onPrimary),
              ),
            ),
          ],
          if (Responsive.isTablet(context)) const Spacer(),
        ],
      ),
    );
  }
}

class _MonthlyCalendarPage extends StatelessWidget {
  const _MonthlyCalendarPage();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: scheme.onSurface),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Monthly Calendar',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
        ),
        centerTitle: true,
      ),
      body: const SafeArea(child: CalendarView()),
    );
  }
}
