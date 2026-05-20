import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/view/new_task/components/tags_input.dart';
import 'package:todo/view/new_task/components/task_button.dart';
import 'package:todo/view_model/controller/new_task_controller.dart';
import 'package:todo/view_model/responsive.dart';
import 'components/category_input.dart';
import 'components/date_time.dart';
import 'components/description_input.dart';
import 'components/lable_input.dart';

class NewTask extends StatelessWidget {
  NewTask({super.key});

  final controller = Get.put(NewTaskController());

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Size screen = MediaQuery.sizeOf(context);
    // Use ~88% of the screen height so the date/time row is visible without
    // scrolling on phones, while leaving a peek of the underlying content.
    // Cap at 760 so the form doesn't get cartoonishly tall on a desktop.
    final double sheetHeight =
        (screen.height * 0.88).clamp(560.0, 760.0).toDouble();
    return ClipRRect(
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30)),
      child: Container(
          height: sheetHeight,
          width: Responsive.isLargeTablet(context)
              ? screen.width / 2.5
              : Responsive.isTablet(context)
                  ? screen.width / 1.6
                  : screen.width,
          decoration: BoxDecoration(
            color: scheme.surface,
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      LabelInput(),
                      CategoryInput(),
                      DescriptionInput(),
                      TagsInput(),
                      DateTimeInput(),
                    ],
                  ),
                ),
              ),
              TaskButtonRow(),
            ],
          )),
    );
  }
}


