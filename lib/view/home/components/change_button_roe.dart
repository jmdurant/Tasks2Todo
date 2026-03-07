import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/view/home/components/task_filter_bar.dart';
import 'package:todo/view/home/components/today_button.dart';
import 'package:todo/view_model/controller/home_controller.dart';
import '../../../res/constants.dart';
import 'change_icon.dart';

class ChangeButtonRow extends StatelessWidget {
  ChangeButtonRow({super.key});
  final controller = Get.find<HomeController>();

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.getWeekStartDate(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      final today = DateTime.now();
      final difference = picked.difference(DateTime(today.year, today.month, today.day)).inDays;
      controller.weekOffset.value = difference ~/ 7;
      controller.getTasks();
      // Set the day index within the week
      final dayIndex = difference % 7;
      if (dayIndex >= 0 && dayIndex < 7) {
        controller.setIndex(dayIndex);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.sizeOf(context).width * 0.06),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous day
          InkWell(
            onTap: () => controller.onMoveBack(),
            child: ChangeIconButton(
              icon: Icon(Icons.arrow_back_ios_rounded, color: scheme.onPrimary, size: 15),
            ),
          ),
          const SizedBox(width: defaultPadding / 2),
          // Today (highlighted when not on current week)
          Obx(() => controller.weekOffset.value != 0
              ? const TodayButton()
              : Opacity(opacity: 0.5, child: TodayButton())),
          const SizedBox(width: defaultPadding / 2),
          // Calendar
          InkWell(
            onTap: () => _showDatePicker(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 44,
              width: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.surfaceContainerHighest,
              ),
              child: Icon(Icons.calendar_month, color: scheme.onSurfaceVariant, size: 20),
            ),
          ),
          const SizedBox(width: defaultPadding / 2),
          // Filter
          TaskFilterButton(),
          const SizedBox(width: defaultPadding / 2),
          // Next day
          InkWell(
            onTap: () => controller.onMoveNextPage(),
            child: ChangeIconButton(
              icon: Icon(Icons.arrow_forward_ios_rounded, color: scheme.onPrimary, size: 15),
            ),
          ),
        ],
      ),
    );
  }
}


