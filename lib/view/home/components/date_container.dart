import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../view_model/controller/home_controller.dart';
import 'dates.dart';
class DateContainer extends StatelessWidget {
  final int index;
  DateContainer({super.key, required this.index});
  final controller = Get.find<HomeController>();
  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Obx(() {
      final bool isSelected = controller.currentIndex.value==index;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
          height: 110,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isSelected ? scheme.primary : scheme.surfaceContainerHighest,
              boxShadow: isSelected ? [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.35),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ] : null,
          ),
          child: Dates(index: index)
      );
    });
  }
}
