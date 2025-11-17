import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/data/local/database/app_database.dart';
import 'package:todo/util/utils.dart';
import '../../view_model/controller/home_controller.dart';

class ProjectsView extends StatelessWidget {
  ProjectsView({super.key});

  final controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Projects',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Organize your tasks into projects',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Obx(() {
              final projects = controller.projects;
              return ListView(
                children: [
                  _buildStaticProjectCard(
                    context: context,
                    icon: Icons.inbox,
                    title: 'Inbox',
                    subtitle: 'Unprocessed tasks',
                    color: scheme.primary,
                    taskCount: controller.model.length,
                  ),
                  const SizedBox(height: 12),
                  _buildProjectsHeader(context),
                  if (projects.isEmpty)
                    _buildEmptyProjectsState(context)
                  else
                    ...projects.map(
                      (project) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildUserProjectCard(
                          context: context,
                          project: project,
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsHeader(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'My Projects',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
          ),
          IconButton(
            icon: Icon(Icons.add, color: scheme.primary),
            onPressed: () => _showCreateProjectDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyProjectsState(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: scheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withOpacity(.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No projects yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Projects help you group tasks by goal or area. Tap the + button to create your first project.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _showCreateProjectDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Create project'),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticProjectCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required int taskCount,
  }) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$taskCount',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProjectCard({
    required BuildContext context,
    required Project project,
  }) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color color = Color(project.color).withOpacity(1);
    final String subtitle =
        project.description?.isNotEmpty == true ? project.description! : 'No description yet';

    return InkWell(
      onTap: () {
        Get.snackbar(
          project.name,
          'Project view coming soon.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: scheme.primaryContainer,
          colorText: scheme.onPrimaryContainer,
        );
      },
      onLongPress: () => _confirmDelete(context, project),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: scheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.folder,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '0',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateProjectDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController =
        TextEditingController();
    final List<Color> palette = Utils.tagColors(context);
    int selectedColor = 0;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    showDialog(
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
                    decoration: const InputDecoration(
                      labelText: 'Name',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Color',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(palette.length, (index) {
                      final Color color = palette[index];
                      final bool isSelected = selectedColor == index;
                      return GestureDetector(
                        onTap: () => setState(() => selectedColor = index),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? scheme.onPrimary
                                  : scheme.surface.withOpacity(0),
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    }),
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
                  final String name = nameController.text.trim();
                  final String description = descriptionController.text.trim();
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
                  await controller.createProject(
                    name: name,
                    description: description,
                    color: palette[selectedColor],
                  );
                  Navigator.of(ctx).pop();
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

  void _confirmDelete(BuildContext context, Project project) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    Get.dialog(
      AlertDialog(
        title: const Text('Delete project'),
        content: Text('Are you sure you want to remove "${project.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await controller.deleteProject(project.id);
              Get.back();
              Get.snackbar(
                'Project removed',
                '"${project.name}" was deleted.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: scheme.primaryContainer,
                colorText: scheme.onPrimaryContainer,
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
