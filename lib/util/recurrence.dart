import 'package:intl/intl.dart';
import '../model/task_model.dart';

class RecurrenceHelper {
  /// Given a completed recurring task, create the next occurrence.
  /// Returns null if the task is not recurring.
  static TaskModel? createNextOccurrence(TaskModel completedTask) {
    if (completedTask.recurrence == null || completedTask.recurrence == 'none') {
      return null;
    }

    final nextDate = _getNextDate(completedTask.date!, completedTask.recurrence!);
    if (nextDate == null) return null;

    return completedTask.copyWith(
      key: DateTime.now().microsecondsSinceEpoch.toString(),
      date: nextDate,
      status: 'unComplete',
    );
  }

  static String? _getNextDate(String currentDate, String recurrence) {
    try {
      final parts = currentDate.split('/');
      if (parts.length != 3) return null;

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      final current = DateTime(year, month, day);

      DateTime next;
      switch (recurrence) {
        case 'daily':
          next = current.add(const Duration(days: 1));
          break;
        case 'weekly':
          next = current.add(const Duration(days: 7));
          break;
        case 'monthly':
          // Handle month overflow correctly
          final nextMonth = month == 12 ? 1 : month + 1;
          final nextYear = month == 12 ? year + 1 : year;
          // Clamp day to valid range for the target month
          final maxDay = DateTime(nextYear, nextMonth + 1, 0).day;
          next = DateTime(nextYear, nextMonth, day > maxDay ? maxDay : day);
          break;
        default:
          return null;
      }

      return DateFormat('dd/MM/yyyy').format(next);
    } catch (_) {
      return null;
    }
  }

  static const List<String> options = ['none', 'daily', 'weekly', 'monthly'];

  static String displayName(String recurrence) {
    switch (recurrence) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      default:
        return 'None';
    }
  }

  static IconLabel iconFor(String recurrence) {
    switch (recurrence) {
      case 'daily':
        return IconLabel.daily;
      case 'weekly':
        return IconLabel.weekly;
      case 'monthly':
        return IconLabel.monthly;
      default:
        return IconLabel.none;
    }
  }
}

enum IconLabel { none, daily, weekly, monthly }
