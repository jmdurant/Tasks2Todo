import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/db_helper/db_helper.dart';
import 'package:todo/model/task_model.dart';
import 'package:todo/util/utils.dart';
import 'package:todo/view/home/task_detail_view.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final DbHelper _db = DbHelper();
  late DateTime _currentMonth;
  DateTime? _selectedDay;
  Map<String, List<TaskModel>> _tasksByDate = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _selectedDay = now;
    _loadTasks();
  }

  String _formatDate(DateTime date) {
    return '${Utils.addPrefix(date.day.toString())}/${Utils.addPrefix(date.month.toString())}/${date.year}';
  }

  Future<void> _loadTasks() async {
    setState(() => _loading = true);

    // Get all dates visible in the calendar grid
    final dates = _getVisibleDates();
    final dateStrings = dates.map(_formatDate).toList();

    final tasks = await _db.getTasksForDates(dateStrings);

    // Group tasks by date
    final Map<String, List<TaskModel>> grouped = {};
    for (final task in tasks) {
      if (task.date != null) {
        grouped.putIfAbsent(task.date!, () => []).add(task);
      }
    }

    // Sort each day by priority
    const priorityOrder = {'High': 0, 'Medium': 1, 'Low': 2};
    for (final dayList in grouped.values) {
      dayList.sort((a, b) {
        if (a.status != b.status) {
          return a.status == 'complete' ? 1 : -1;
        }
        final pa = priorityOrder[a.periority] ?? 2;
        final pb = priorityOrder[b.periority] ?? 2;
        return pa.compareTo(pb);
      });
    }

    setState(() {
      _tasksByDate = grouped;
      _loading = false;
    });
  }

  List<DateTime> _getVisibleDates() {
    final firstOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);

    // Start from the Monday on or before the first day
    final startWeekday = firstOfMonth.weekday; // 1=Mon, 7=Sun
    final gridStart = firstOfMonth.subtract(Duration(days: startWeekday - 1));

    // We need enough days to cover the month grid (6 weeks max = 42 days)
    final daysInGrid = ((lastOfMonth.difference(gridStart).inDays + 1) / 7).ceil() * 7;

    return List.generate(daysInGrid, (i) => gridStart.add(Duration(days: i)));
  }

  void _goToPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    _loadTasks();
  }

  void _goToNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    _loadTasks();
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _currentMonth = DateTime(now.year, now.month);
      _selectedDay = now;
    });
    _loadTasks();
  }

  void _selectDay(DateTime day) {
    setState(() {
      _selectedDay = day;
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isToday(DateTime day) {
    return _isSameDay(day, DateTime.now());
  }

  Color _priorityColor(String? priority, ColorScheme scheme) {
    switch (priority) {
      case 'High':
        return scheme.error;
      case 'Medium':
        return scheme.tertiary;
      case 'Low':
        return scheme.primary;
      default:
        return scheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // Month header with navigation
        _buildMonthHeader(scheme, textTheme),
        // Weekday headers
        _buildWeekdayHeaders(scheme, textTheme),
        // Calendar grid
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          _buildCalendarGrid(scheme, textTheme),
        const Divider(height: 1),
        // Selected day's tasks
        Expanded(
          child: _buildSelectedDayTasks(scheme, textTheme),
        ),
      ],
    );
  }

  Widget _buildMonthHeader(ColorScheme scheme, TextTheme textTheme) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
      child: Row(
        children: [
          Text(
            '${months[_currentMonth.month - 1]} ${_currentMonth.year}',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _goToToday,
            icon: Icon(Icons.today, color: scheme.primary, size: 22),
            tooltip: 'Go to today',
          ),
          IconButton(
            onPressed: _goToPreviousMonth,
            icon: Icon(Icons.chevron_left, color: scheme.primary, size: 28),
          ),
          IconButton(
            onPressed: _goToNextMonth,
            icon: Icon(Icons.chevron_right, color: scheme.primary, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders(ColorScheme scheme, TextTheme textTheme) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: days.map((day) => Expanded(
          child: Center(
            child: Text(
              day,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(ColorScheme scheme, TextTheme textTheme) {
    final dates = _getVisibleDates();
    final weekCount = dates.length ~/ 7;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        children: List.generate(weekCount, (weekIndex) {
          return Row(
            children: List.generate(7, (dayIndex) {
              final date = dates[weekIndex * 7 + dayIndex];
              return Expanded(
                child: _buildDayCell(date, scheme, textTheme),
              );
            }),
          );
        }),
      ),
    );
  }

  Widget _buildDayCell(DateTime date, ColorScheme scheme, TextTheme textTheme) {
    final isCurrentMonth = date.month == _currentMonth.month;
    final isSelected = _selectedDay != null && _isSameDay(date, _selectedDay!);
    final today = _isToday(date);
    final dateString = _formatDate(date);
    final tasksForDay = _tasksByDate[dateString] ?? [];
    final hasTask = tasksForDay.isNotEmpty;

    // Collect unique priorities for dot colors
    final priorities = tasksForDay
        .map((t) => t.periority)
        .toSet()
        .take(3)
        .toList();

    return GestureDetector(
      onTap: () => _selectDay(date),
      child: Container(
        margin: const EdgeInsets.all(1),
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? scheme.primaryContainer
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Day number
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: today
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.primary,
                    )
                  : null,
              child: Text(
                '${date.day}',
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: today || isSelected ? FontWeight.bold : FontWeight.normal,
                  color: today
                      ? scheme.onPrimary
                      : isCurrentMonth
                          ? scheme.onSurface
                          : scheme.onSurface.withValues(alpha: 0.3),
                ),
              ),
            ),
            // Task dots
            SizedBox(
              height: 10,
              child: hasTask
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: priorities.map((p) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCurrentMonth
                                ? _priorityColor(p, scheme)
                                : _priorityColor(p, scheme).withValues(alpha: 0.3),
                          ),
                        );
                      }).toList(),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDayTasks(ColorScheme scheme, TextTheme textTheme) {
    if (_selectedDay == null) {
      return Center(
        child: Text(
          'Select a day to see tasks',
          style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      );
    }

    final dateString = _formatDate(_selectedDay!);
    final tasks = _tasksByDate[dateString] ?? [];
    final today = _isToday(_selectedDay!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(
            children: [
              Text(
                today
                    ? 'Today'
                    : '${_selectedDay!.day} ${_monthName(_selectedDay!.month)}',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              if (tasks.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: tasks.isEmpty
              ? Center(
                  child: Text(
                    'No tasks for this day',
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return _buildTaskTile(tasks[index], scheme, textTheme);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTaskTile(TaskModel task, ColorScheme scheme, TextTheme textTheme) {
    final isComplete = task.status == 'complete';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: scheme.surfaceContainerHighest,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await Get.to(() => TaskDetailView(task: task, dayIndex: 0));
          _loadTasks(); // Refresh after returning
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Priority indicator
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: _priorityColor(task.periority, scheme),
                ),
              ),
              const SizedBox(width: 12),
              // Task info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title ?? 'Untitled',
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w500,
                        decoration: isComplete ? TextDecoration.lineThrough : null,
                        decorationColor: scheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (task.startTime != null && task.startTime!.isNotEmpty)
                      Text(
                        '${task.startTime}${task.endTime != null && task.endTime!.isNotEmpty ? ' - ${task.endTime}' : ''}',
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              // Status icon
              if (isComplete)
                Icon(Icons.check_circle, color: scheme.primary, size: 20)
              else
                Icon(Icons.circle_outlined, color: scheme.outline, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return names[month - 1];
  }
}
