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

    // Derive stable indices from task key hash to prevent flickering
    final int hash = task.key?.hashCode ?? 0;
    final int colorIndex1 = hash.abs() % palette.length;
    final int colorIndex2 = (hash.abs() ~/ palette.length) % palette.length;
    final int tagIndex1 = hash.abs() % Utils.tags.length;
    final int tagIndex2 = (hash.abs() ~/ Utils.tags.length) % Utils.tags.length;

    final Color colorOne = palette[colorIndex1];
    final Color colorTwo = palette[colorIndex2];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          task.title ?? '',
          style: textTheme.titleMedium?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.bold,
              ) ??
              const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          '${task.startTime} - ${task.endTime}',
          style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
              decoration: BoxDecoration(
                color: colorOne.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                Utils.tags[tagIndex1],
                style: TextStyle(color: colorOne, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
              decoration: BoxDecoration(
                color: colorTwo.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                Utils.tags[tagIndex2],
                style: TextStyle(color: colorTwo, fontWeight: FontWeight.w600),
              ),
            )
          ],
        ),
      ],
    );
  }
}
