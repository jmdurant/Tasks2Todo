import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/view_model/controller/new_task_controller.dart';

class CreateTaskButton extends StatelessWidget {
   CreateTaskButton({super.key});
   final controller=Get.put(NewTaskController());
  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(80),
              topLeft: Radius.circular(80)),
          gradient: LinearGradient(colors: [
            scheme.primary,
            scheme.secondary,
            scheme.primary,
          ])),
      child: Obx(() => controller.loading.value ? SizedBox(
        height: 15,
        width: 15,
        child: CircularProgressIndicator(
          color: scheme.onPrimary,
        ),
      ) : Text(
        'Create Task',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: scheme.onPrimary,
            fontWeight: FontWeight.bold),
      ),)
    );
  }
}
