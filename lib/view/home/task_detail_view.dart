import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/db_helper/db_helper.dart';
import 'package:todo/model/task_model.dart';
import 'package:todo/util/recurrence.dart';
import 'package:todo/util/utils.dart';
import 'package:todo/view_model/services/notification_service.dart';
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
  late String _recurrence;
  late int _reminderMinutesBefore;
  late List<String> _selectedTags;

  bool _saving = false;
  bool _hasChanges = false;

  static const _reminderOptions = <int, String>{
    -1: 'None',
    0: 'At time',
    5: '5 min before',
    15: '15 min before',
    30: '30 min before',
    60: '1 hour before',
  };

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
    _recurrence = widget.task.recurrence ?? 'none';
    _reminderMinutesBefore = widget.task.reminderMinutesBefore ?? -1;
    _selectedTags = List<String>.from(widget.task.tagList);

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
      recurrence: _recurrence,
      reminderMinutesBefore: _reminderMinutesBefore,
      tags: _selectedTags.join(','),
    );

    await _db.insert(updatedTask); // insertOnConflictUpdate handles updates
    // Reschedule reminder
    await NotificationService.instance.cancelTaskReminder(updatedTask.key!);
    if (updatedTask.hasReminder) {
      await NotificationService.instance.scheduleTaskReminder(updatedTask);
    }
    _homeController.getTasks(); // Refresh the task list

    if (!mounted) return;
    setState(() => _saving = false);

    Get.back();
    Get.snackbar(
      'Saved',
      'Task updated successfully',
      snackPosition: SnackPosition.BOTTOM,
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
      await _db.deleteTask(widget.task.key!);
      NotificationService.instance.cancelTaskReminder(widget.task.key!);
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

            // Tags
            _buildLabel('Tags'),
            const SizedBox(height: 8),
            _buildTagsEditor(scheme),
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

            // Recurrence & Reminder
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Repeat'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _recurrence,
                            isExpanded: true,
                            icon: Icon(Icons.repeat, size: 16, color: scheme.primary),
                            items: const [
                              DropdownMenuItem(value: 'none', child: Text('None')),
                              DropdownMenuItem(value: 'daily', child: Text('Daily')),
                              DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                              DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                setState(() {
                                  _recurrence = v;
                                  _hasChanges = true;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Reminder'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _reminderMinutesBefore,
                            isExpanded: true,
                            icon: Icon(Icons.notifications_none, size: 16, color: scheme.primary),
                            items: _reminderOptions.entries
                                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() {
                                  _reminderMinutesBefore = v;
                                  _hasChanges = true;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
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
                      await _db.updateTaskStatus(widget.task.key!, 'unComplete');
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
                      await _db.updateTaskStatus(widget.task.key!, 'complete');
                      // Handle recurring task
                      if (widget.task.isRecurring) {
                        final nextTask = RecurrenceHelper.createNextOccurrence(widget.task);
                        if (nextTask != null) {
                          await _db.insert(nextTask);
                          if (nextTask.hasReminder) {
                            NotificationService.instance.scheduleTaskReminder(nextTask);
                          }
                        }
                      }
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

  Widget _buildTagsEditor(ColorScheme scheme) {
    final List<Color> palette = Utils.tagColors(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: Utils.tags.asMap().entries.map((entry) {
        final idx = entry.key;
        final tag = entry.value;
        final isSelected = _selectedTags.contains(tag);
        final color = palette[idx % palette.length];
        return FilterChip(
          label: Text(tag),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedTags.add(tag);
              } else {
                _selectedTags.remove(tag);
              }
              _hasChanges = true;
            });
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
      }).toList(),
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
