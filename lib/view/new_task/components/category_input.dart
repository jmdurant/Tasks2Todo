import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../res/constants.dart';
import '../../../view_model/controller/home_controller.dart';
import '../../../view_model/controller/new_task_controller.dart';

class CategoryInput extends StatelessWidget {
  CategoryInput({super.key});

  final controller = Get.put(NewTaskController());
  final HomeController homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: defaultPadding / 2,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Project',
              style: TextStyle(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Obx(() {
            controller.syncProjects(homeController.projects);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: scheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: scheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: controller.selectedProject.value,
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: Icon(Icons.arrow_drop_down, color: scheme.primary),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface,
                        ),
                    dropdownColor: scheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    items: controller.availableProjects.map((String project) {
                      IconData icon;
                      Color iconColor;

                      switch (project) {
                        case 'Inbox':
                          icon = Icons.inbox;
                          iconColor = scheme.primary;
                          break;
                        default:
                          icon = Icons.folder;
                          iconColor = scheme.secondary;
                      }

                      return DropdownMenuItem<String>(
                        value: project,
                        child: Row(
                          children: [
                            Icon(icon, color: iconColor, size: 20),
                            const SizedBox(width: 12),
                            Text(project),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.setSelectedProject(newValue);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _showCreateProjectDialog(context, scheme),
                    icon: const Icon(Icons.add),
                    label: const Text('Add project'),
                  ),
                ),
              ],
            );
          })
        ],
      ),
    );
  }

  Future<void> _showCreateProjectDialog(
      BuildContext context, ColorScheme scheme) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController =
        TextEditingController();
    Color selectedColor = scheme.primary;
    final palette = [
      scheme.primary,
      scheme.secondary,
      scheme.tertiary,
      scheme.primaryContainer,
      scheme.secondaryContainer,
      scheme.tertiaryContainer,
    ];

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setState) {
          return AlertDialog(
            title: const Text('New Project'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    decoration:
                        const InputDecoration(labelText: 'Description (optional)'),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Color',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: palette
                        .map(
                          (color) => GestureDetector(
                            onTap: () => setState(() => selectedColor = color),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selectedColor == color
                                      ? scheme.onPrimary
                                      : scheme.outlineVariant,
                                  width: selectedColor == color ? 2 : 1,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final description = descriptionController.text.trim();
                  if (name.isEmpty) {
                    Get.snackbar(
                      'Name required',
                      'Please provide a project name.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: scheme.errorContainer,
                      colorText: scheme.onErrorContainer,
                    );
                    return;
                  }
                  await homeController.createProject(
                    name: name,
                    description: description.isEmpty ? null : description,
                    color: selectedColor,
                  );
                  controller.syncProjects(homeController.projects);
                  controller.setSelectedProject(name);
                  if (context.mounted) {
                    Navigator.of(ctx).pop();
                  }
                  Get.snackbar(
                    'Project added',
                    '"$name" is ready for tasks.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: scheme.primaryContainer,
                    colorText: scheme.onPrimaryContainer,
                  );
                },
                child: const Text('Create'),
              ),
            ],
          );
        });
      },
    );
  }
}
