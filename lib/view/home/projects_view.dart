import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/data/local/database/app_database.dart';
import 'package:todo/db_helper/db_helper.dart';
import 'package:todo/model/task_model.dart';
import 'package:todo/util/utils.dart';
import '../../view_model/controller/home_controller.dart';
import 'task_detail_view.dart';

class ProjectsView extends StatefulWidget {
  const ProjectsView({super.key});

  @override
  State<ProjectsView> createState() => _ProjectsViewState();
}

class _ProjectsViewState extends State<ProjectsView> {
  final controller = Get.find<HomeController>();
  final DbHelper _db = DbHelper();

  // Track which projects are expanded
  final Set<String> _expandedProjects = {};

  // Cache of tasks per project
  final Map<String, List<TaskModel>> _tasksByProject = {};

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAllProjectTasks();
  }

  Future<void> _loadAllProjectTasks() async {
    setState(() => _isLoading = true);

    // Single query to load all tasks, grouped by project
    final grouped = await _db.getAllTasksGroupedByProject();
    _tasksByProject
      ..clear()
      ..addAll(grouped);
    // Ensure Inbox always exists even if empty
    _tasksByProject.putIfAbsent('Inbox', () => []);

    setState(() => _isLoading = false);
  }

  Future<void> _moveTaskToProject(TaskModel task, String newProjectName) async {
    if (task.category == newProjectName) return;

    final oldProject = task.category ?? 'Inbox';

    // Update in database
    // Re-insert with updated category (insertOnConflictUpdate handles it)
    await _db.insert(task.copyWith(category: newProjectName));

    // Update local cache with immutable copy
    final movedTask = task.copyWith(category: newProjectName);
    setState(() {
      _tasksByProject[oldProject]?.removeWhere((t) => t.key == task.key);
      _tasksByProject[newProjectName] ??= [];
      _tasksByProject[newProjectName]!.add(movedTask);
    });

    // Refresh home controller
    controller.getTasks();

    Utils.showSnackBar(
      'Moved',
      'Task moved to $newProjectName',
      const Icon(Icons.check),
    );
  }

  void _toggleExpanded(String projectName) {
    setState(() {
      if (_expandedProjects.contains(projectName)) {
        _expandedProjects.remove(projectName);
      } else {
        _expandedProjects.add(projectName);
      }
    });
  }

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
            'Drag tasks between projects to organize',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Obx(() {
                    final projects = controller.projects;
                    return ListView(
                      children: [
                        _buildProjectSection(
                          context: context,
                          projectName: 'Inbox',
                          icon: Icons.inbox,
                          color: scheme.primary,
                          subtitle: 'Unprocessed tasks',
                          project: null,
                        ),
                        const SizedBox(height: 12),
                        _buildProjectsHeader(context),
                        if (projects.isEmpty)
                          _buildEmptyProjectsState(context)
                        else
                          ...projects.map(
                            (project) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildProjectSection(
                                context: context,
                                projectName: project.name,
                                icon: Icons.folder,
                                color: Color(project.color),
                                subtitle: project.description ?? 'No description',
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

  Widget _buildProjectSection({
    required BuildContext context,
    required String projectName,
    required IconData icon,
    required Color color,
    required String subtitle,
    required Project? project,
  }) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isExpanded = _expandedProjects.contains(projectName);
    final tasks = _tasksByProject[projectName] ?? [];
    final incompleteTasks = tasks.where((t) => t.status != 'complete').toList();
    final taskCount = incompleteTasks.length;

    return DragTarget<TaskModel>(
      onWillAcceptWithDetails: (details) {
        return details.data.category != projectName;
      },
      onAcceptWithDetails: (details) {
        _moveTaskToProject(details.data, projectName);
      },
      builder: (context, candidateData, rejectedData) {
        final bool isHovering = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isHovering
                ? color.withValues(alpha: 0.15)
                : scheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovering ? color : scheme.outline.withValues(alpha: 0.2),
              width: isHovering ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              // Project header row
              InkWell(
                onTap: () => _toggleExpanded(projectName),
                onLongPress: project != null
                    ? () => _confirmDelete(context, project)
                    : null,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
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
                              projectName,
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
                          color: color.withValues(alpha: 0.2),
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
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: isExpanded ? 0.25 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.add,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Collapsible task list
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: _buildTaskList(context, incompleteTasks, color),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskList(BuildContext context, List<TaskModel> tasks, Color projectColor) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    if (tasks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Text(
          'No tasks',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: tasks.map((task) => _buildDraggableTask(context, task, projectColor)).toList(),
      ),
    );
  }

  Widget _buildDraggableTask(BuildContext context, TaskModel task, Color projectColor) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return LongPressDraggable<TaskModel>(
      data: task,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: projectColor, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.drag_indicator, color: scheme.onSurfaceVariant, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.title ?? 'Untitled',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: _buildTaskRow(context, task, projectColor),
      ),
      child: _buildTaskRow(context, task, projectColor),
    );
  }

  Widget _buildTaskRow(BuildContext context, TaskModel task, Color projectColor) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isComplete = task.status == 'complete';

    return InkWell(
      onTap: () async {
        await Get.to(() => TaskDetailView(task: task));
        _loadAllProjectTasks(); // Refresh after returning
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.drag_indicator,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
              size: 18,
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => _toggleTaskComplete(task),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isComplete ? projectColor : Colors.transparent,
                  border: Border.all(
                    color: isComplete ? projectColor : scheme.outline,
                    width: 2,
                  ),
                ),
                child: isComplete
                    ? Icon(Icons.check, size: 14, color: scheme.onPrimary)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                task.title ?? 'Untitled',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isComplete
                          ? scheme.onSurfaceVariant.withValues(alpha: 0.5)
                          : scheme.onSurface,
                      decoration: isComplete ? TextDecoration.lineThrough : null,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (task.periority == 'High')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: scheme.error.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '!!!',
                  style: TextStyle(
                    color: scheme.error,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else if (task.periority == 'Medium')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: scheme.tertiary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '!!',
                  style: TextStyle(
                    color: scheme.tertiary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleTaskComplete(TaskModel task) async {
    final newStatus = task.status == 'complete' ? 'unComplete' : 'complete';
    await _db.updateTaskStatus(task.key!, newStatus);

    // Reload from DB to get fresh immutable state
    await _loadAllProjectTasks();
    controller.getTasks();
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
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.2)),
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

  void _showCreateProjectDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final List<Color> palette = Utils.tagColors(context);
    int selectedColor = 0;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setDialogState) {
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
                        onTap: () => setDialogState(() => selectedColor = index),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? scheme.onPrimary
                                  : scheme.surface.withValues(alpha: 0),
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
                  if (!ctx.mounted) return;
                  Navigator.of(ctx).pop();
                  _loadAllProjectTasks(); // Refresh task lists
                  Get.snackbar(
                    'Project added',
                    '"$name" is ready for tasks.',
                    snackPosition: SnackPosition.BOTTOM,
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
              _loadAllProjectTasks(); // Refresh
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
