import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/data/local/database/app_database.dart';
import 'package:todo/db_helper/db_helper.dart';
import 'package:todo/model/task_model.dart';
import 'package:todo/util/utils.dart';
import '../../view_model/controller/home_controller.dart';

class ProjectDetailView extends StatefulWidget {
  final Project? project;
  final String projectName;
  final Color projectColor;

  const ProjectDetailView({
    super.key,
    this.project,
    required this.projectName,
    required this.projectColor,
  });

  @override
  State<ProjectDetailView> createState() => _ProjectDetailViewState();
}

class _ProjectDetailViewState extends State<ProjectDetailView> {
  final DbHelper _db = DbHelper();
  final HomeController _homeController = Get.find<HomeController>();
  List<TaskModel> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    // Both Inbox and specific projects filter by category name
    final tasks = await _db.getTasksForProject(widget.projectName);
    setState(() {
      _tasks = tasks;
      _loading = false;
    });
  }

  Future<void> _deleteTask(TaskModel task) async {
    await _db.delete(task.key!, 'Tasks');
    _loadTasks();
    _homeController.getTasks(); // Refresh home view
  }

  Future<void> _toggleComplete(TaskModel task) async {
    final newStatus = task.status == 'complete' ? 'unComplete' : 'complete';
    await _db.update(task.key!, 'status', newStatus);
    _loadTasks();
    _homeController.getTasks();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: scheme.onSurface),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.projectColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                widget.project != null ? Icons.folder : Icons.inbox,
                color: widget.projectColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.projectName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        backgroundColor: scheme.surface,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? _buildEmptyState(context)
              : _buildTaskList(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 64,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks in this project',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a new task and assign it to "${widget.projectName}"',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    // Group tasks by status
    final incompleteTasks = _tasks.where((t) => t.status != 'complete').toList();
    final completeTasks = _tasks.where((t) => t.status == 'complete').toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (incompleteTasks.isNotEmpty) ...[
          Text(
            'To Do (${incompleteTasks.length})',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ...incompleteTasks.map((task) => _buildTaskTile(context, task)),
        ],
        if (completeTasks.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'Completed (${completeTasks.length})',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ...completeTasks.map((task) => _buildTaskTile(context, task)),
        ],
      ],
    );
  }

  Widget _buildTaskTile(BuildContext context, TaskModel task) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isComplete = task.status == 'complete';

    return Dismissible(
      key: ValueKey(task.key),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: scheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete, color: scheme.onError),
      ),
      confirmDismiss: (direction) async {
        return await Utils.showWarningDialog(
          context,
          'Delete Task',
          'Are you sure you want to delete "${task.title}"?',
          'Delete',
          () {},
        );
      },
      onDismissed: (direction) => _deleteTask(task),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: InkWell(
            onTap: () => _toggleComplete(task),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isComplete ? scheme.primary : Colors.transparent,
                border: Border.all(
                  color: isComplete ? scheme.primary : scheme.outline,
                  width: 2,
                ),
              ),
              child: isComplete
                  ? Icon(Icons.check, size: 18, color: scheme.onPrimary)
                  : null,
            ),
          ),
          title: Text(
            task.title ?? '',
            style: TextStyle(
              decoration: isComplete ? TextDecoration.lineThrough : null,
              color: isComplete
                  ? scheme.onSurfaceVariant.withValues(alpha: 0.6)
                  : scheme.onSurface,
            ),
          ),
          subtitle: task.date != null
              ? Text(
                  '${task.date} ${task.startTime ?? ''}',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                )
              : null,
          trailing: _buildPriorityChip(context, task.periority),
        ),
      ),
    );
  }

  Widget? _buildPriorityChip(BuildContext context, String? priority) {
    if (priority == null || priority.isEmpty || priority == 'Low') return null;

    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color color = priority == 'High'
        ? scheme.error
        : scheme.tertiary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
