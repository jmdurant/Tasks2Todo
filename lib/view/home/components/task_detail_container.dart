import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/view/home/components/task_detail_col.dart';
import '../../../util/utils.dart';
import '../../../view_model/controller/home_controller.dart';

class TaskDetailContainer extends StatelessWidget {
  TaskDetailContainer({super.key, required this.index, required this.ind});
  final int index;
  final int ind;
  final controller = Get.find<HomeController>();

  void _toggleComplete(BuildContext context) {
    final task = controller.list[ind][index];
    final newStatus = task.status == 'complete' ? 'unComplete' : 'complete';
    controller.db.update(task.key!, 'status', newStatus);
    // Update local state
    final updatedDay = List.of(controller.list[ind]);
    updatedDay[index] = task.copyWith(status: newStatus);
    controller.list[ind] = updatedDay;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final task = controller.list[ind][index];
    final bool isComplete = task.status == 'complete';

    return Dismissible(
      key: ValueKey(task.key),
      confirmDismiss: (direction) async {
        return await Utils.showWarningDialog(
          context,
          'Remove Task',
          'Are you sure to remove this task',
          'Confirm',
          () {
            controller.db.delete(task.key!, 'Tasks');
            final updatedDay = List.of(controller.list[ind]);
            updatedDay.removeAt(index);
            controller.list[ind] = updatedDay;
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.15),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
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
            Expanded(child: TaskTitle(index: index, ind: ind)),
            // Menu button
            PopupMenuButton(
              onSelected: (value) => controller.onTaskComplete(
                value,
                index,
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
                        Icon(Icons.delete_outline, color: scheme.primary, size: 14),
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


