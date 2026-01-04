
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../res/constants.dart';
import '../../../view_model/controller/home_controller.dart';
import 'custom_app_bar.dart';
import 'date_container.dart';

class UperBody extends StatelessWidget {
  UperBody({super.key});
  final controller = Get.find<HomeController>();
  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        const SizedBox(height: defaultPadding),
        CustomAppBar(),
        Padding(
          padding: const EdgeInsets.only(bottom: 16, top: defaultPadding),
          child: Row(
            children: [
              // Previous week arrow
              InkWell(
                onTap: () => controller.previousWeek(),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 32,
                  height: 110,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.chevron_left_rounded,
                    color: scheme.primary,
                    size: 28,
                  ),
                ),
              ),
              // Day blocks - auto-fit width
              ...List.generate(7, (index) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => controller.setIndex(index),
                    child: DateContainer(index: index),
                  ),
                ),
              )),
              // Next week arrow
              InkWell(
                onTap: () => controller.nextWeek(),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 32,
                  height: 110,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: scheme.primary,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}