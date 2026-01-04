import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../util/utils.dart';
import '../../../view_model/controller/home_controller.dart';

class TaskTitle extends StatelessWidget {
  const TaskTitle({super.key, required this.index, required this.ind});
  final int index;
  final int ind;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final task = controller.list[ind][index];
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final List<Color> palette = Utils.tagColors(context);

    // Get actual tags from task
    final List<String> taskTags = task.tagList;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.title ?? '',
          style: textTheme.titleMedium?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.bold,
              ) ??
              const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        if (task.startTime?.isNotEmpty == true || task.endTime?.isNotEmpty == true)
          Text(
            '${task.startTime ?? ''} ${task.startTime?.isNotEmpty == true && task.endTime?.isNotEmpty == true ? '-' : ''} ${task.endTime ?? ''}'.trim(),
            style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        if (taskTags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: taskTags.asMap().entries.map((entry) {
              final int idx = entry.key;
              final String tag = entry.value;
              final Color tagColor = palette[idx % palette.length];
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '@$tag',
                  style: TextStyle(
                    color: tagColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
