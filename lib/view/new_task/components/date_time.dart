import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/view_model/controller/new_task_controller.dart';

import '../../../res/constants.dart';

class DateTimeInput extends StatelessWidget {
  DateTimeInput({super.key});

  final controller = Get.put(NewTaskController());

  static const _reminderOptions = <int, String>{
    -1: 'None',
    0: 'At time',
    5: '5 min before',
    15: '15 min before',
    30: '30 min before',
    60: '1 hour before',
  };

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context)
        .textTheme
        .labelLarge
        ?.copyWith(fontWeight: FontWeight.bold);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date & Time row
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date', style: labelStyle),
                  const SizedBox(height: defaultPadding / 2),
                  InkWell(
                      onTap: () => controller.showDatePick(context),
                      child: Obx(() => DateTimeContainer(
                          text: controller.selectedDate.isEmpty
                              ? 'dd/mm/yyyy'
                              : controller.selectedDate.value)))
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Start Time', style: labelStyle),
                  const SizedBox(height: defaultPadding / 2),
                  InkWell(
                      onTap: () => controller.picStartTime(context),
                      child: Obx(() => DateTimeContainer(
                          text: controller.startTime.isEmpty
                              ? "hh:mm:a"
                              : controller.startTime.value)))
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('End Time', style: labelStyle),
                  const SizedBox(height: defaultPadding / 2),
                  InkWell(
                      onTap: () => controller.picEndTime(context),
                      child: Obx(() => DateTimeContainer(
                          text: controller.endTime.isEmpty
                              ? "hh:mm:a"
                              : controller.endTime.value)))
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Recurrence & Reminder row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Repeat', style: labelStyle),
                    const SizedBox(height: defaultPadding / 2),
                    Obx(() => _RecurrenceSelector(
                          value: controller.selectedRecurrence.value,
                          onChanged: (v) => controller.selectedRecurrence.value = v,
                        )),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reminder', style: labelStyle),
                    const SizedBox(height: defaultPadding / 2),
                    Obx(() => _ReminderSelector(
                          value: controller.selectedReminderMinutes.value,
                          options: _reminderOptions,
                          onChanged: (v) => controller.selectedReminderMinutes.value = v,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecurrenceSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _RecurrenceSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          isDense: true,
          icon: Icon(Icons.repeat, size: 16, color: scheme.primary),
          items: const [
            DropdownMenuItem(value: 'none', child: Text('None')),
            DropdownMenuItem(value: 'daily', child: Text('Daily')),
            DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
            DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _ReminderSelector extends StatelessWidget {
  final int value;
  final Map<int, String> options;
  final ValueChanged<int> onChanged;

  const _ReminderSelector({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          isExpanded: true,
          isDense: true,
          icon: Icon(Icons.notifications_none, size: 16, color: scheme.primary),
          items: options.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class DateTimeContainer extends StatelessWidget {
  const DateTimeContainer({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            Icons.date_range,
            color: scheme.primary,
            size: 16,
          ),
          SizedBox(
            width: defaultPadding / 4,
          ),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
