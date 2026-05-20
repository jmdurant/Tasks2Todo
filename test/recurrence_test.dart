import 'package:flutter_test/flutter_test.dart';
import 'package:todo/model/task_model.dart';
import 'package:todo/util/recurrence.dart';

TaskModel _task({
  String key = 't1',
  String date = '15/03/2026',
  String recurrence = 'daily',
}) {
  return TaskModel(
    key: key,
    title: 'T',
    category: 'Inbox',
    description: '',
    image: '',
    priority: 'Low',
    startTime: '',
    endTime: '',
    date: date,
    show: 'yes',
    status: 'complete',
    recurrence: recurrence,
  );
}

void main() {
  group('createNextOccurrence', () {
    test('returns null when recurrence is none', () {
      expect(
        RecurrenceHelper.createNextOccurrence(_task(recurrence: 'none')),
        isNull,
      );
    });

    test('returns null when recurrence is null', () {
      final task = _task()..recurrence = null;
      expect(RecurrenceHelper.createNextOccurrence(task), isNull);
    });

    test('daily advances by one day', () {
      final next =
          RecurrenceHelper.createNextOccurrence(_task(date: '15/03/2026'));
      expect(next!.date, '16/03/2026');
    });

    test('daily crosses month boundary', () {
      final next = RecurrenceHelper.createNextOccurrence(
          _task(date: '31/03/2026'));
      expect(next!.date, '01/04/2026');
    });

    test('daily crosses year boundary', () {
      final next = RecurrenceHelper.createNextOccurrence(
          _task(date: '31/12/2026'));
      expect(next!.date, '01/01/2027');
    });

    test('weekly advances by seven days', () {
      final next = RecurrenceHelper.createNextOccurrence(
          _task(date: '01/01/2026', recurrence: 'weekly'));
      expect(next!.date, '08/01/2026');
    });

    test('monthly advances by one month', () {
      final next = RecurrenceHelper.createNextOccurrence(
          _task(date: '15/03/2026', recurrence: 'monthly'));
      expect(next!.date, '15/04/2026');
    });

    test('monthly clamps day-of-month when target month is shorter', () {
      // Jan 31 → Feb 28 (2026 is not a leap year)
      final next = RecurrenceHelper.createNextOccurrence(
          _task(date: '31/01/2026', recurrence: 'monthly'));
      expect(next!.date, '28/02/2026');
    });

    test('monthly handles leap year correctly (Feb 29)', () {
      // 2024 is a leap year: Jan 31 → Feb 29
      final next = RecurrenceHelper.createNextOccurrence(
          _task(date: '31/01/2024', recurrence: 'monthly'));
      expect(next!.date, '29/02/2024');
    });

    test('monthly Dec → Jan rolls year', () {
      final next = RecurrenceHelper.createNextOccurrence(
          _task(date: '15/12/2026', recurrence: 'monthly'));
      expect(next!.date, '15/01/2027');
    });

    test('monthly Dec 31 → Jan 31 (no clamp)', () {
      final next = RecurrenceHelper.createNextOccurrence(
          _task(date: '31/12/2026', recurrence: 'monthly'));
      expect(next!.date, '31/01/2027');
    });

    test('next occurrence has fresh key and unComplete status', () {
      final completed = _task(date: '15/03/2026');
      final next = RecurrenceHelper.createNextOccurrence(completed);
      expect(next!.key, isNot(completed.key));
      expect(next.status, 'unComplete');
    });

    test('returns null on malformed date', () {
      final task = _task(date: 'not-a-date');
      expect(RecurrenceHelper.createNextOccurrence(task), isNull);
    });

    test('unknown recurrence value returns null', () {
      final next = RecurrenceHelper.createNextOccurrence(
          _task(recurrence: 'yearly'));
      expect(next, isNull);
    });
  });
}
