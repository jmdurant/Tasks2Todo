import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../util/utils.dart';
import '../../../view_model/controller/home_controller.dart';

class Dates extends StatelessWidget {
  const Dates({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Obx(() {
      // Calculate date based on weekOffset
      final date = DateTime.now().add(Duration(days: index + controller.weekOffset.value * 7));
      final bool isSelected = controller.currentIndex.value == index;
      final Color textColor = isSelected ? scheme.onPrimary : scheme.onSurface;
      final int taskCount = controller.list[index].length;

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            Utils.getMonth(date),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              height: 0,
            ),
          ),
          Text(
            Utils.getDate(date),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 26,
              height: 0,
            ),
          ),
          Text(
            Utils.getDay(date),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          if (taskCount > 0)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? scheme.onPrimary
                    : scheme.primary,
              ),
            ),
        ],
      );
    });
  }
}