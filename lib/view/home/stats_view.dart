import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/db_helper/db_helper.dart';
import 'package:todo/model/task_model.dart';

class StatsView extends StatefulWidget {
  const StatsView({super.key});

  @override
  State<StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView> {
  List<TaskModel> _allTasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final tasks = await DbHelper().getData();
    setState(() {
      _allTasks = tasks;
      _loading = false;
    });
  }

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateFormat('dd/MM/yyyy').parseStrict(dateStr);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSummaryCards(scheme),
                  const SizedBox(height: 20),
                  _buildWeekProgress(scheme),
                  const SizedBox(height: 20),
                  _buildPriorityBreakdown(scheme),
                  const SizedBox(height: 20),
                  _buildStreak(scheme),
                  const SizedBox(height: 20),
                  _buildCategoryBreakdown(scheme),
                  const SizedBox(height: 20),
                  _buildRecentCompletions(scheme),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  // --- Summary cards ---
  Widget _buildSummaryCards(ColorScheme scheme) {
    final total = _allTasks.length;
    final completed = _allTasks.where((t) => t.status == 'complete').length;
    final pending = total - completed;
    final rate = total > 0 ? (completed / total * 100) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Overview',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface)),
        const SizedBox(height: 12),
        Row(
          children: [
            _summaryCard('Total', '$total', Icons.list_alt, scheme.primary,
                scheme),
            const SizedBox(width: 8),
            _summaryCard('Done', '$completed', Icons.check_circle,
                scheme.tertiary, scheme),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _summaryCard('Pending', '$pending', Icons.pending_actions,
                scheme.secondary, scheme),
            const SizedBox(width: 8),
            _summaryCard('Rate', '${rate.toStringAsFixed(0)}%',
                Icons.percent, scheme.primary, scheme),
          ],
        ),
      ],
    );
  }

  Widget _summaryCard(String label, String value, IconData icon,
      Color accentColor, ColorScheme scheme) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: scheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface)),
                  Text(label,
                      style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- This week progress ---
  Widget _buildWeekProgress(ColorScheme scheme) {
    final now = DateTime.now();
    // Start of week (Monday)
    final monday = now.subtract(Duration(days: now.weekday - 1));

    int weekTotal = 0;
    int weekCompleted = 0;

    for (final task in _allTasks) {
      final d = _parseDate(task.date);
      if (d != null) {
        final dayStart = DateTime(d.year, d.month, d.day);
        final weekStart = DateTime(monday.year, monday.month, monday.day);
        final weekEnd = weekStart.add(const Duration(days: 7));
        if (!dayStart.isBefore(weekStart) && dayStart.isBefore(weekEnd)) {
          weekTotal++;
          if (task.status == 'complete') weekCompleted++;
        }
      }
    }

    final progress = weekTotal > 0 ? weekCompleted / weekTotal : 0.0;

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: scheme.primary),
                const SizedBox(width: 8),
                Text('This Week',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface)),
                const Spacer(),
                Text('$weekCompleted / $weekTotal',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: scheme.primary)),
              ],
            ),
            const SizedBox(height: 16),
            Stack(
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              weekTotal == 0
                  ? 'No tasks this week'
                  : '${(progress * 100).toStringAsFixed(0)}% complete',
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  // --- Priority breakdown ---
  Widget _buildPriorityBreakdown(ColorScheme scheme) {
    int high = 0, medium = 0, low = 0;
    for (final task in _allTasks) {
      switch (task.periority) {
        case 'High':
          high++;
          break;
        case 'Medium':
          medium++;
          break;
        case 'Low':
          low++;
          break;
      }
    }
    final total = _allTasks.length;

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag, size: 18, color: scheme.primary),
                const SizedBox(width: 8),
                Text('Priority Breakdown',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface)),
              ],
            ),
            const SizedBox(height: 16),
            _priorityBar('High', high, total, scheme.error, scheme),
            const SizedBox(height: 10),
            _priorityBar(
                'Medium', medium, total, scheme.tertiary, scheme),
            const SizedBox(height: 10),
            _priorityBar('Low', low, total, scheme.primary, scheme),
          ],
        ),
      ),
    );
  }

  Widget _priorityBar(
      String label, int count, int total, Color color, ColorScheme scheme) {
    final fraction = total > 0 ? count / total : 0.0;
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(label,
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: fraction,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 28,
          child: Text('$count',
              textAlign: TextAlign.end,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface)),
        ),
      ],
    );
  }

  // --- Streak ---
  Widget _buildStreak(ColorScheme scheme) {
    // Build a set of dates that have at least one completed task
    final Set<String> completedDates = {};
    for (final task in _allTasks) {
      if (task.status == 'complete' && task.date != null) {
        completedDates.add(task.date!);
      }
    }

    int streak = 0;
    final fmt = DateFormat('dd/MM/yyyy');
    DateTime day = DateTime.now();

    // Check today first; if no completed task today, start from yesterday
    final todayStr = fmt.format(day);
    if (!completedDates.contains(todayStr)) {
      day = day.subtract(const Duration(days: 1));
    }

    while (true) {
      final dayStr = fmt.format(day);
      if (completedDates.contains(dayStr)) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.tertiary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.local_fire_department,
                  color: scheme.tertiary, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$streak day${streak == 1 ? '' : 's'}',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface)),
                Text('Completion streak',
                    style: TextStyle(
                        fontSize: 13, color: scheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Category / Project breakdown ---
  Widget _buildCategoryBreakdown(ColorScheme scheme) {
    final Map<String, _CatStats> cats = {};
    for (final task in _allTasks) {
      final cat = (task.category != null && task.category!.isNotEmpty)
          ? task.category!
          : 'Uncategorized';
      cats.putIfAbsent(cat, () => _CatStats());
      cats[cat]!.total++;
      if (task.status == 'complete') cats[cat]!.completed++;
    }

    final sorted = cats.entries.toList()
      ..sort((a, b) => b.value.total.compareTo(a.value.total));

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.folder_outlined, size: 18, color: scheme.primary),
                const SizedBox(width: 8),
                Text('Projects / Categories',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface)),
              ],
            ),
            const SizedBox(height: 16),
            if (sorted.isEmpty)
              Text('No tasks yet',
                  style: TextStyle(color: scheme.onSurfaceVariant)),
            ...sorted.take(8).map((e) {
              final rate = e.value.total > 0
                  ? e.value.completed / e.value.total
                  : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(e.key,
                              style: TextStyle(
                                  fontSize: 13, color: scheme.onSurface),
                              overflow: TextOverflow.ellipsis),
                        ),
                        Text(
                            '${e.value.completed}/${e.value.total}  (${(rate * 100).toStringAsFixed(0)}%)',
                            style: TextStyle(
                                fontSize: 12,
                                color: scheme.onSurfaceVariant)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Stack(
                      children: [
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: rate,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // --- Recent completions ---
  Widget _buildRecentCompletions(ColorScheme scheme) {
    final completed = _allTasks
        .where((t) => t.status == 'complete' && t.date != null)
        .toList();

    // Sort by date descending
    completed.sort((a, b) {
      final da = _parseDate(a.date);
      final db = _parseDate(b.date);
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    });

    final recent = completed.take(5).toList();

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, size: 18, color: scheme.primary),
                const SizedBox(width: 8),
                Text('Recent Completions',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface)),
              ],
            ),
            const SizedBox(height: 12),
            if (recent.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('No completed tasks yet',
                    style: TextStyle(color: scheme.onSurfaceVariant)),
              ),
            ...recent.map((task) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          size: 18, color: scheme.tertiary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(task.title ?? 'Untitled',
                            style: TextStyle(
                                fontSize: 14, color: scheme.onSurface),
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text(task.date ?? '',
                          style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _CatStats {
  int total = 0;
  int completed = 0;
}
