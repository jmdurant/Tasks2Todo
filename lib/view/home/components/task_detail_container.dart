import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/util/recurrence.dart';
import 'package:todo/view/home/components/task_detail_col.dart';
import 'package:todo/view_model/services/notification_service.dart';
import '../../../model/task_model.dart';
import '../../../view_model/controller/home_controller.dart';

class TaskDetailContainer extends StatelessWidget {
  TaskDetailContainer({super.key, required this.index, required this.ind, this.filteredTasks});
  final int index;
  final int ind;
  final List<TaskModel>? filteredTasks;
  final controller = Get.find<HomeController>();

  /// Get the task for this container, using filtered list if provided.
  TaskModel _getTask() {
    if (filteredTasks != null) return filteredTasks![index];
    return controller.list[ind][index];
  }

  /// Get the raw index in controller.list[ind] for the current task.
  int _getRawIndex() {
    if (filteredTasks == null) return index;
    final task = filteredTasks![index];
    return controller.list[ind].indexWhere((t) => t.key == task.key);
  }

  void _toggleComplete(BuildContext context) {
    final rawIndex = _getRawIndex();
    final task = controller.list[ind][rawIndex];
    final newStatus = task.status == 'complete' ? 'unComplete' : 'complete';
    controller.db.updateTaskStatus(task.key!, newStatus);
    final updatedDay = List.of(controller.list[ind]);
    updatedDay[rawIndex] = task.copyWith(status: newStatus);
    controller.list[ind] = updatedDay;
  }

  bool _isOverdue(String? date, String? status) {
    if (status == 'complete' || date == null || date.isEmpty) return false;
    try {
      final parts = date.split('/');
      if (parts.length == 3) {
        final taskDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
        final today = DateTime.now();
        return taskDate.isBefore(DateTime(today.year, today.month, today.day));
      }
    } catch (_) {}
    return false;
  }

  void _deleteWithUndo(BuildContext context, TaskModel task) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final rawIndex = _getRawIndex();

    // Remove from local state immediately
    final updatedDay = List<TaskModel>.from(controller.list[ind]);
    updatedDay.removeAt(rawIndex);
    controller.list[ind] = updatedDay;

    // Delete from DB and cancel reminder
    controller.db.deleteTask(task.key!);
    NotificationService.instance.cancelTaskReminder(task.key!);

    // Show undo snackbar
    Get.showSnackbar(
      GetSnackBar(
        backgroundColor: scheme.inverseSurface,
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.BOTTOM,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        titleText: Text(
          'Task deleted',
          style: TextStyle(
            color: scheme.onInverseSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        messageText: Text(
          '"${task.title}" was removed',
          style: TextStyle(color: scheme.onInverseSurface),
          overflow: TextOverflow.ellipsis,
        ),
        mainButton: TextButton(
          onPressed: () {
            Get.closeCurrentSnackbar();
            // Re-insert the task
            controller.db.insert(task);
            controller.getTasks();
          },
          child: Text(
            'UNDO',
            style: TextStyle(
              color: scheme.inversePrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _swipeComplete(BuildContext context, TaskModel task) {
    final rawIndex = _getRawIndex();
    final newStatus = task.status == 'complete' ? 'unComplete' : 'complete';
    controller.db.updateTaskStatus(task.key!, newStatus);
    final updatedDay = List.of(controller.list[ind]);
    updatedDay[rawIndex] = task.copyWith(status: newStatus);
    controller.list[ind] = updatedDay;
    // Handle recurring tasks
    if (newStatus == 'complete' && task.isRecurring) {
      final nextTask = RecurrenceHelper.createNextOccurrence(task);
      if (nextTask != null) {
        controller.db.insert(nextTask);
        if (nextTask.hasReminder) {
          NotificationService.instance.scheduleTaskReminder(nextTask);
        }
        controller.getTasks();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final task = _getTask();
    final bool isComplete = task.status == 'complete';
    final bool overdue = _isOverdue(task.date, task.status);

    return Dismissible(
      key: ValueKey(task.key),
      // Swipe right to complete, swipe left to delete
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Complete/uncomplete — don't actually dismiss
          _swipeComplete(context, task);
          return false;
        }
        // Delete direction — proceed
        return true;
      },
      onDismissed: (direction) {
        _deleteWithUndo(context, task);
      },
      // Right swipe background (complete)
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        padding: const EdgeInsets.only(left: 24),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: isComplete ? scheme.tertiary : scheme.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              isComplete ? Icons.undo : Icons.check_circle,
              color: isComplete ? scheme.onTertiary : scheme.onPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              isComplete ? 'Undo' : 'Complete',
              style: TextStyle(
                color: isComplete ? scheme.onTertiary : scheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      // Left swipe background (delete)
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        padding: const EdgeInsets.only(right: 24),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: scheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete',
              style: TextStyle(
                color: scheme.onError,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.delete_outline, color: scheme.onError),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: (overdue ? scheme.error : scheme.primary).withValues(alpha: 0.15),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: overdue
              ? Border.all(color: scheme.error.withValues(alpha: 0.4), width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            // Checkbox
            InkWell(
              onTap: () => _toggleComplete(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 32,
                width: 32,
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
            const SizedBox(width: 16),
            // Task details
            Expanded(child: TaskTitle(index: index, ind: ind, task: task)),
            // Overdue indicator
            if (overdue)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Overdue',
                  style: TextStyle(
                    color: scheme.error,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            // Menu button
            PopupMenuButton(
              onSelected: (value) => controller.onTaskComplete(
                value,
                _getRawIndex(),
                ind,
                task.key!,
                context,
              ),
              surfaceTintColor: scheme.surface,
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.more_vert_rounded,
                color: scheme.onSurfaceVariant,
                size: 24,
              ),
              shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    height: 25,
                    value: 1,
                    child: Row(
                      children: [
                        Icon(Icons.edit_note, color: scheme.primary, size: 14),
                        const SizedBox(width: 8),
                        const Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    height: 25,
                    value: 2,
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: scheme.error, size: 14),
                        const SizedBox(width: 8),
                        const Text('Delete'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    height: 25,
                    value: 3,
                    child: Row(
                      children: [
                        Icon(Icons.done_all_outlined, color: scheme.primary, size: 14),
                        const SizedBox(width: 8),
                        Text(isComplete ? 'Mark Incomplete' : 'Complete'),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}
