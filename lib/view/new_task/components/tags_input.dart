import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/util/utils.dart';
import 'package:todo/view_model/controller/new_task_controller.dart';

class TagsInput extends StatelessWidget {
  TagsInput({super.key});

  final controller = Get.find<NewTaskController>();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final List<Color> palette = Utils.tagColors(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tags',
            style: TextStyle(
              color: scheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...Utils.tags.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final tag = entry.value;
                    final isSelected = controller.selectedTags.contains(tag);
                    final color = palette[idx % palette.length];
                    return FilterChip(
                      label: Text(tag),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          controller.selectedTags.add(tag);
                        } else {
                          controller.selectedTags.remove(tag);
                        }
                      },
                      selectedColor: color.withValues(alpha: 0.25),
                      checkmarkColor: color,
                      labelStyle: TextStyle(
                        color: isSelected ? color : scheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected ? color.withValues(alpha: 0.5) : scheme.outlineVariant,
                      ),
                      visualDensity: VisualDensity.compact,
                    );
                  }),
                ],
              )),
        ],
      ),
    );
  }
}
