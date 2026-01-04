import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/view_model/controller/home_controller.dart';

class TodayButton extends StatelessWidget {
  const TodayButton({super.key});

  void _goToToday(HomeController controller) {
    controller.weekOffset.value = 0;
    controller.setIndex(0);
    controller.getTasks();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () => _goToToday(controller),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow:  [
              BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 8
              )
            ],
            color: Theme.of(context).colorScheme.primary,
        ),
        child:  Text(
          'Today',style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
        ),
      ),
    );
  }
}
