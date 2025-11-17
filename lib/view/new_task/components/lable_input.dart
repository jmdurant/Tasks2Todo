
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/view/new_task/components/periority_container.dart';
import 'package:todo/view/new_task/components/text_input.dart';
import 'package:todo/view_model/controller/new_task_controller.dart';


import '../../../res/constants.dart';

class LabelInput extends StatelessWidget {
   LabelInput({super.key});
  final controller=Get.put(NewTaskController());
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Title',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: defaultPadding / 2,
                ),
                Obx(() => TextInputField(
                    controller: controller.label.value,
                    hint: 'Enter Title',
                    onTap: () => controller.setLabelFocus(),
                    focus: controller.labelFocus.value),),
              ],
            ),
          ),
          const SizedBox(
            width: defaultPadding,
          ),
           Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Priority',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: defaultPadding / 2,
              ),
              Row(
                children: [
                  Obx(() => InkWell(
                    onTap: () => controller.selectedPriority.value = 'Low',
                      child: PeriorityContainer(text: 'Low', selected: controller.selectedPriority.value == 'Low')),),
                  const SizedBox(
                    width: defaultPadding / 2,
                  ),
                  Obx(() => InkWell(
                    onTap: () => controller.selectedPriority.value = 'Medium',
                      child: PeriorityContainer(text: 'Med', selected: controller.selectedPriority.value == 'Medium')),),
                  const SizedBox(
                    width: defaultPadding / 2,
                  ),
                  Obx(() => InkWell(
                  onTap: () => controller.selectedPriority.value = 'High',
                      child: PeriorityContainer(text: 'High', selected: controller.selectedPriority.value == 'High')),)
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
