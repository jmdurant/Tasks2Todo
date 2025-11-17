import 'package:intl/intl.dart';
import '../model/task_model.dart';

class ParsedTask {
  final String title;
  final String status; // 'unComplete', 'complete', 'deferred'
  final String? project;
  final String? date;
  final String? startTime;
  final String? endTime;
  final String priority; // 'Low', 'Medium', 'High'
  final String? location;
  final List<String> tags;
  final String? note;
  final String? reference;
  final bool isSubtask;

  ParsedTask({
    required this.title,
    required this.status,
    this.project,
    this.date,
    this.startTime,
    this.endTime,
    required this.priority,
    this.location,
    this.tags = const [],
    this.note,
    this.reference,
    this.isSubtask = false,
  });
}

class TaskParser {
  static List<ParsedTask> parseQuickEntry(String text,
      {String defaultProject = 'Inbox'}) {
    final List<ParsedTask> tasks = [];
    final lines = text.split('\n');
    String? currentProject = defaultProject;

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Check for project heading (+ ProjectName)
      if (trimmed.startsWith('+')) {
        currentProject = trimmed.substring(1).trim();
        continue;
      }

      // Check for comment lines (// text)
      if (trimmed.startsWith('//')) {
        continue;
      }

      // Parse task
      final task = _parseTaskLine(trimmed, currentProject);
      if (task != null) {
        tasks.add(task);
      }
    }

    return tasks;
  }

  static ParsedTask? _parseTaskLine(String line, String? project) {
    // Check if it's a task (starts with [ ] or [x] or [>])
    final taskPattern = RegExp(r'^\[([ x>])\](.*)$');
    final match = taskPattern.firstMatch(line);

    String status;
    String content;
    bool isSubtask = false;

    if (match != null) {
      // It's a checkbox task
      final statusChar = match.group(1)!;
      status = statusChar == 'x'
          ? 'complete'
          : statusChar == '>'
              ? 'deferred'
              : 'unComplete';
      content = match.group(2)!.trim();
    } else if (line.startsWith('-')) {
      // It's a subtask without checkbox
      status = 'unComplete';
      content = line.substring(1).trim();
      isSubtask = true;
    } else {
      // Plain text - treat as a task
      status = 'unComplete';
      content = line;
    }

    // Extract metadata
    String title = content;
    String? date;
    String? time;
    String? location;
    String priority = 'Low';
    List<String> tags = [];
    String? note;
    String? reference;

    // Extract priority (!, !!, !!!)
    final priorityMatch = RegExp(r'(!{1,3})').firstMatch(content);
    if (priorityMatch != null) {
      final exclamations = priorityMatch.group(1)!;
      priority = exclamations.length == 1
          ? 'Low'
          : exclamations.length == 2
              ? 'Medium'
              : 'High';
      content = content.replaceAll(exclamations, '').trim();
    }

    // Extract due date (> date)
    final datePattern = RegExp(r'>\s*([^\s@^~:#]+)');
    final dateMatch = datePattern.firstMatch(content);
    if (dateMatch != null) {
      date = _parseDate(dateMatch.group(1)!);
      content = content.replaceAll(dateMatch.group(0)!, '').trim();
    }

    // Extract time (~ time)
    final timePattern = RegExp(r'~\s*([^\s@^>:#]+)');
    final timeMatch = timePattern.firstMatch(content);
    if (timeMatch != null) {
      time = _parseTime(timeMatch.group(1)!);
      content = content.replaceAll(timeMatch.group(0)!, '').trim();
    }

    // Extract location (^ place)
    final locationPattern = RegExp(r'\^\s*([^\s@~>:#]+(?:\s+[^\s@~>:#]+)*)');
    final locationMatch = locationPattern.firstMatch(content);
    if (locationMatch != null) {
      location = locationMatch.group(1)!;
      content = content.replaceAll(locationMatch.group(0)!, '').trim();
    }

    // Extract context tags (@word)
    final tagPattern = RegExp(r'@(\w+)');
    final tagMatches = tagPattern.allMatches(content);
    for (var tagMatch in tagMatches) {
      tags.add(tagMatch.group(1)!);
      content = content.replaceAll(tagMatch.group(0)!, '').trim();
    }

    // Extract note (: text)
    final notePattern = RegExp(r':\s*([^#//]+)');
    final noteMatch = notePattern.firstMatch(content);
    if (noteMatch != null) {
      note = noteMatch.group(1)!.trim();
      content = content.replaceAll(noteMatch.group(0)!, '').trim();
    }

    // Extract reference (# ref)
    final refPattern = RegExp(r'#\s*(\S+)');
    final refMatch = refPattern.firstMatch(content);
    if (refMatch != null) {
      reference = refMatch.group(1)!;
      content = content.replaceAll(refMatch.group(0)!, '').trim();
    }

    title = content.trim();
    if (title.isEmpty) {
      title = 'Untitled Task';
    }

    return ParsedTask(
      title: title,
      status: status,
      project: project ?? 'Inbox',
      date: date,
      startTime: time,
      endTime: time,
      priority: priority,
      location: location,
      tags: tags,
      note: note,
      reference: reference,
      isSubtask: isSubtask,
    );
  }

  static String _parseDate(String dateStr) {
    final now = DateTime.now();
    dateStr = dateStr.toLowerCase().trim();

    // Handle relative days
    if (dateStr == 'today') {
      return DateFormat('dd/MM/yyyy').format(now);
    } else if (dateStr == 'tomorrow' || dateStr == 'tmr') {
      return DateFormat('dd/MM/yyyy').format(now.add(const Duration(days: 1)));
    }

    // Handle day names (Mon, Tue, etc.)
    final dayNames = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    final dayIndex = dayNames.indexWhere((d) => dateStr.startsWith(d));
    if (dayIndex != -1) {
      final targetDay = (dayIndex + 1) % 7; // Convert to DateTime weekday
      final currentDay = now.weekday % 7;
      var daysToAdd = targetDay - currentDay;
      if (daysToAdd <= 0) daysToAdd += 7;
      return DateFormat('dd/MM/yyyy')
          .format(now.add(Duration(days: daysToAdd)));
    }

    // Handle M/D or MM/DD format
    if (dateStr.contains('/')) {
      try {
        final parts = dateStr.split('/');
        if (parts.length == 2) {
          final month = int.parse(parts[0]);
          final day = int.parse(parts[1]);
          var year = now.year;
          var date = DateTime(year, month, day);

          // If the date is in the past, assume next year
          if (date.isBefore(now)) {
            date = DateTime(year + 1, month, day);
          }

          return DateFormat('dd/MM/yyyy').format(date);
        }
      } catch (e) {
        // Fall through to default
      }
    }

    // Default to today if can't parse
    return DateFormat('dd/MM/yyyy').format(now);
  }

  static String _parseTime(String timeStr) {
    timeStr = timeStr.toLowerCase().trim();

    // Handle formats like 9am, 2pm, 14:00
    final timePattern = RegExp(r'^(\d{1,2}):?(\d{2})?\s*(am|pm)?$');
    final match = timePattern.firstMatch(timeStr);

    if (match != null) {
      int hour = int.parse(match.group(1)!);
      final minutes = match.group(2) != null ? int.parse(match.group(2)!) : 0;
      final period = match.group(3);

      if (period != null) {
        // 12-hour format
        if (period == 'pm' && hour != 12) hour += 12;
        if (period == 'am' && hour == 12) hour = 0;
      }

      final hourStr = hour > 12 ? hour - 12 : hour;
      final periodStr = hour >= 12 ? 'PM' : 'AM';
      return '${hourStr.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:$periodStr';
    }

    // Default to current time
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:$period';
  }

  static List<TaskModel> convertToTaskModels(List<ParsedTask> parsedTasks) {
    return parsedTasks.map((parsed) {
      final now = DateTime.now();
      final description = [
        if (parsed.location != null) 'Location: ${parsed.location}',
        if (parsed.tags.isNotEmpty) 'Tags: ${parsed.tags.join(", ")}',
        if (parsed.note != null) parsed.note,
        if (parsed.reference != null) 'Ref: ${parsed.reference}',
      ].join('\n');

      return TaskModel(
        key: now.microsecondsSinceEpoch.toString(),
        title: parsed.title,
        category: parsed.project ?? 'Inbox',
        description: description.isEmpty ? 'Quick entry task' : description,
        image: '0',
        periority: parsed.priority,
        startTime: parsed.startTime ?? '',
        endTime: parsed.endTime ?? '',
        date: parsed.date ?? DateFormat('dd/MM/yyyy').format(now),
        show: 'yes',
        status: parsed.status,
      );
  }).toList();
}
}
