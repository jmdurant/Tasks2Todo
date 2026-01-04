import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/db_helper/db_helper.dart';
import 'package:todo/model/task_model.dart';
import 'package:todo/util/utils.dart';
import '../../view_model/controller/home_controller.dart';

class TaskDetailView extends StatefulWidget {
  final TaskModel task;
  final int? dayIndex; // Index in the week view (for updating local state)

  const TaskDetailView({
    super.key,
    required this.task,
    this.dayIndex,
  });

  @override
  State<TaskDetailView> createState() => _TaskDetailViewState();
}

class _TaskDetailViewState extends State<TaskDetailView> {
  final DbHelper _db = DbHelper();
  final HomeController _homeController = Get.find<HomeController>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedProject;
  late String _selectedPriority;
  late String _selectedDate;
  late String _startTime;
  late String _endTime;

  bool _saving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title ?? '');
    _descriptionController = TextEditingController(text: widget.task.description ?? '');
    _selectedProject = widget.task.category ?? 'Inbox';
    _selectedPriority = widget.task.periority ?? 'Low';
    _selectedDate = widget.task.date ?? '';
    _startTime = widget.task.startTime ?? '';
    _endTime = widget.task.endTime ?? '';

    _titleController.addListener(_onChanged);
    _descriptionController.addListener(_onChanged);
  }

  void _onChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (_titleController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Task title cannot be empty',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        colorText: Theme.of(context).colorScheme.onErrorContainer,
      );
      return;
    }

    setState(() => _saving = true);

    final updatedTask = widget.task.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedProject,
      periority: _selectedPriority,
      date: _selectedDate,
      startTime: _startTime,
      endTime: _endTime,
    );

    await _db.insert(updatedTask); // insertOnConflictUpdate handles updates
    _homeController.getTasks(); // Refresh the task list

    setState(() => _saving = false);

    Get.back();
    Get.snackbar(
      'Saved',
      'Task updated successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      colorText: Theme.of(context).colorScheme.onPrimaryContainer,
    );
  }

  Future<void> _deleteTask() async {
    final confirmed = await Utils.showWarningDialog(
      context,
      'Delete Task',
      'Are you sure you want to delete "${widget.task.title}"?',
      'Delete',
      () {},
    );

    if (confirmed == true) {
      await _db.delete(widget.task.key!, 'Tasks');
      _homeController.getTasks();
      Get.back();
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _parseDate(_selectedDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = '${Utils.addPrefix(picked.day.toString())}/${Utils.addPrefix(picked.month.toString())}/${picked.year}';
        _hasChanges = true;
      });
    }
  }

  DateTime? _parseDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (_) {}
    return null;
  }

  Future<void> _pickTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final timeStr = '${Utils.addPrefix(picked.hourOfPeriod.toString())}:${Utils.addPrefix(picked.minute.toString())}:${picked.period.name.toUpperCase()}';
      setState(() {
        if (isStart) {
          _startTime = timeStr;
        } else {
          _endTime = timeStr;
        }
        _hasChanges = true;
      });
    }
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
        title: Text(
          'Edit Task',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        backgroundColor: scheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: scheme.error),
            onPressed: _deleteTask,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            _buildLabel('Title'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Task title',
                filled: true,
                fillColor: scheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Project
            _buildLabel('Project'),
            const SizedBox(height: 8),
            Obx(() {
              final projects = ['Inbox', ..._homeController.projects.map((p) => p.name)];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: projects.contains(_selectedProject) ? _selectedProject : 'Inbox',
                    isExpanded: true,
                    items: projects.map((p) => DropdownMenuItem(
                      value: p,
                      child: Text(p),
                    )).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedProject = value;
                          _hasChanges = true;
                        });
                      }
                    },
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),

            // Description
            _buildLabel('Description'),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add description...',
                filled: true,
                fillColor: scheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Priority
            _buildLabel('Priority'),
            const SizedBox(height: 8),
            Row(
              children: ['Low', 'Medium', 'High'].map((priority) {
                final isSelected = _selectedPriority == priority;
                final Color color = priority == 'High'
                    ? scheme.error
                    : priority == 'Medium'
                        ? scheme.tertiary
                        : scheme.outline;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ChoiceChip(
                    label: Text(priority),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedPriority = priority;
                          _hasChanges = true;
                        });
                      }
                    },
                    selectedColor: color.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? color : scheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Date & Time Row
            _buildLabel('Date & Time'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDateTimeChip(
                    icon: Icons.calendar_today,
                    label: _selectedDate.isEmpty ? 'Select date' : _selectedDate,
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateTimeChip(
                    icon: Icons.access_time,
                    label: _startTime.isEmpty ? 'Start' : _startTime,
                    onTap: () => _pickTime(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateTimeChip(
                    icon: Icons.access_time,
                    label: _endTime.isEmpty ? 'End' : _endTime,
                    onTap: () => _pickTime(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Status
            _buildLabel('Status'),
            const SizedBox(height: 8),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Incomplete'),
                  selected: widget.task.status != 'complete',
                  onSelected: (selected) async {
                    if (selected && widget.task.status == 'complete') {
                      await _db.update(widget.task.key!, 'status', 'unComplete');
                      _homeController.getTasks();
                      setState(() {});
                    }
                  },
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('Complete'),
                  selected: widget.task.status == 'complete',
                  selectedColor: scheme.primary.withValues(alpha: 0.2),
                  onSelected: (selected) async {
                    if (selected && widget.task.status != 'complete') {
                      await _db.update(widget.task.key!, 'status', 'complete');
                      _homeController.getTasks();
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _saveTask,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _saving
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.onPrimary,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }

  Widget _buildDateTimeChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: scheme.primary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
