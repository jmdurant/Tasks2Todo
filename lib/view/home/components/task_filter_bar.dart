import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/util/utils.dart';
import 'package:todo/view_model/controller/home_controller.dart';

/// A filter icon button with badge that opens a bottom sheet with filter options.
class TaskFilterButton extends StatelessWidget {
  TaskFilterButton({super.key});
  final controller = Get.find<HomeController>();

  void _showFilterSheet(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Tasks',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  Obx(() => controller.hasActiveFilters
                      ? TextButton.icon(
                          onPressed: () {
                            controller.resetFilters();
                          },
                          icon: Icon(Icons.clear_all, size: 18, color: scheme.error),
                          label: Text(
                            'Clear filters',
                            style: TextStyle(color: scheme.error),
                          ),
                        )
                      : const SizedBox.shrink()),
                ],
              ),
              const SizedBox(height: 16),
              // Priority filter
              Text(
                'Priority',
                style: textTheme.labelLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                    spacing: 8,
                    children: ['All', 'High', 'Medium', 'Low'].map((priority) {
                      final isSelected = controller.filterPriority.value == priority;
                      return FilterChip(
                        label: Text(priority),
                        selected: isSelected,
                        onSelected: (_) {
                          controller.filterPriority.value = priority;
                        },
                        selectedColor: scheme.primaryContainer,
                        checkmarkColor: scheme.onPrimaryContainer,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? scheme.onPrimaryContainer
                              : scheme.onSurfaceVariant,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? scheme.primaryContainer
                              : scheme.outlineVariant,
                        ),
                      );
                    }).toList(),
                  )),
              const SizedBox(height: 16),
              // Status filter
              Text(
                'Status',
                style: textTheme.labelLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                    spacing: 8,
                    children: ['All', 'Incomplete', 'Complete'].map((status) {
                      final isSelected = controller.filterStatus.value == status;
                      return FilterChip(
                        label: Text(status),
                        selected: isSelected,
                        onSelected: (_) {
                          controller.filterStatus.value = status;
                        },
                        selectedColor: scheme.secondaryContainer,
                        checkmarkColor: scheme.onSecondaryContainer,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? scheme.onSecondaryContainer
                              : scheme.onSurfaceVariant,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? scheme.secondaryContainer
                              : scheme.outlineVariant,
                        ),
                      );
                    }).toList(),
                  )),
              const SizedBox(height: 16),
              // Tag filter
              Text(
                'Tag',
                style: textTheme.labelLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: Obx(() => ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: const Text('All'),
                            selected: controller.filterTag.value.isEmpty,
                            onSelected: (_) {
                              controller.filterTag.value = '';
                            },
                            selectedColor: scheme.tertiaryContainer,
                            checkmarkColor: scheme.onTertiaryContainer,
                            labelStyle: TextStyle(
                              color: controller.filterTag.value.isEmpty
                                  ? scheme.onTertiaryContainer
                                  : scheme.onSurfaceVariant,
                            ),
                            side: BorderSide(
                              color: controller.filterTag.value.isEmpty
                                  ? scheme.tertiaryContainer
                                  : scheme.outlineVariant,
                            ),
                          ),
                        ),
                        ...Utils.tags.map((tag) {
                          final isSelected = controller.filterTag.value == tag;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(tag),
                              selected: isSelected,
                              onSelected: (_) {
                                controller.filterTag.value = isSelected ? '' : tag;
                              },
                              selectedColor: scheme.tertiaryContainer,
                              checkmarkColor: scheme.onTertiaryContainer,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? scheme.onTertiaryContainer
                                    : scheme.onSurfaceVariant,
                              ),
                              side: BorderSide(
                                color: isSelected
                                    ? scheme.tertiaryContainer
                                    : scheme.outlineVariant,
                              ),
                            ),
                          );
                        }),
                      ],
                    )),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Obx(() {
      final count = controller.activeFilterCount;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          InkWell(
            onTap: () => _showFilterSheet(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 44,
              width: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: count > 0
                    ? scheme.primaryContainer
                    : scheme.surfaceContainerHighest,
              ),
              child: Icon(
                Icons.filter_list,
                color: count > 0
                    ? scheme.onPrimaryContainer
                    : scheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
          if (count > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                height: 20,
                width: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.primary,
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}
