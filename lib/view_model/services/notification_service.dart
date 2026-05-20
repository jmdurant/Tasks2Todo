import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:todo/db_helper/db_helper.dart';
import 'package:todo/model/task_model.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return true; // iOS handles it via DarwinInitializationSettings
  }

  /// Schedule a reminder notification for a task.
  /// Returns the notification ID, or -1 if nothing was scheduled.
  Future<int> scheduleTaskReminder(TaskModel task) async {
    if (!_initialized) await initialize();
    if (!task.hasReminder) return -1;

    final scheduledTime = _getScheduledTime(task);
    if (scheduledTime == null) return -1;

    if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) return -1;

    final int notificationId = _notificationIdFor(task);

    final reminderLabel = task.reminderMinutesBefore == 0
        ? 'Now'
        : '${task.reminderMinutesBefore} min';

    await _plugin.zonedSchedule(
      notificationId,
      task.title ?? 'Task Reminder',
      '${task.category ?? 'Inbox'} - $reminderLabel',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          channelDescription: 'Reminders for scheduled tasks',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null,
    );

    return notificationId;
  }

  /// Cancel a specific task's reminder by its stored notification id.
  Future<void> cancelTaskReminder(TaskModel task) async {
    await _plugin.cancel(_notificationIdFor(task));
  }

  /// Returns the persisted notification id, falling back to a deterministic
  /// 31-bit derivation from the task key for pre-v5 rows.
  int _notificationIdFor(TaskModel task) {
    final int? stored = task.notificationId;
    if (stored != null && stored != 0) return stored;
    final int? parsed = int.tryParse(task.key ?? '');
    return ((parsed ?? task.key.hashCode) & 0x7FFFFFFF);
  }

  /// Cancel all reminders and reschedule from the database
  Future<void> rescheduleAllReminders() async {
    if (!_initialized) await initialize();
    await _plugin.cancelAll();

    try {
      final db = DbHelper();
      final tasks = await db.getTasksWithReminders();
      for (final task in tasks) {
        await scheduleTaskReminder(task);
      }
      debugPrint('NotificationService: scheduled ${tasks.length} reminders');
    } catch (e) {
      debugPrint('NotificationService: error rescheduling: $e');
    }
  }

  /// Parse task date (dd/MM/yyyy) and startTime (HH:MM:AM/PM) into a TZDateTime,
  /// then subtract reminderMinutesBefore.
  tz.TZDateTime? _getScheduledTime(TaskModel task) {
    if (task.date == null || task.date!.isEmpty) return null;
    if (task.startTime == null || task.startTime!.isEmpty) return null;

    try {
      // Parse date: dd/MM/yyyy
      final dateParts = task.date!.split('/');
      if (dateParts.length != 3) return null;
      final day = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final year = int.parse(dateParts[2]);

      // Parse time: HH:MM:AM or HH:MM:PM
      final timeParts = task.startTime!.split(':');
      if (timeParts.length != 3) return null;
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final period = timeParts[2].toUpperCase();

      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;

      final taskDateTime = tz.TZDateTime(
        tz.local,
        year,
        month,
        day,
        hour,
        minute,
      );

      // Subtract reminder offset
      return taskDateTime
          .subtract(Duration(minutes: task.reminderMinutesBefore ?? 0));
    } catch (e) {
      debugPrint('NotificationService: failed to parse time for ${task.key}: $e');
      return null;
    }
  }
}
