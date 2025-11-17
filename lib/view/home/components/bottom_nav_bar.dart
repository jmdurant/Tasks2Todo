import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../view_model/controller/home_controller.dart';
class BottomNavBar extends StatelessWidget {
  BottomNavBar({super.key});
  final controller = Get.put(HomeController());
  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Obx(()=>AnimatedBottomNavigationBar(
      elevation: 10,
      height: 60,
      backgroundColor: scheme.surface,
      inactiveColor: scheme.onSurfaceVariant,
      activeColor: scheme.primary,
      icons: const [
        Icons.calendar_month,
        Icons.edit_note,
        Icons.folder_open,
        Icons.settings
      ],
      activeIndex: controller.barIndex.value,
      gapLocation: GapLocation.center,
      notchSmoothness: NotchSmoothness.verySmoothEdge,
      leftCornerRadius: 32,
      rightCornerRadius: 32,
      onTap: (index){controller.barIndex.value=index;},
      //other params
    ),);
  }
}
