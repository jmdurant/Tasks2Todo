import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:todo/util/task_parser.dart';

void main() {
  final dateFormat = DateFormat('dd/MM/yyyy');

  group('Basic task parsing', () {
    test('plain text line is parsed as unComplete task', () {
      final tasks = TaskParser.parseQuickEntry('Buy groceries');
      expect(tasks.length, 1);
      expect(tasks[0].title, 'Buy groceries');
      expect(tasks[0].status, 'unComplete');
      expect(tasks[0].priority, 'Low');
    });

    test('[ ] checkbox is parsed as unComplete', () {
      final tasks = TaskParser.parseQuickEntry('[ ] Buy milk');
      expect(tasks.length, 1);
      expect(tasks[0].title, 'Buy milk');
      expect(tasks[0].status, 'unComplete');
    });

    test('[x] checkbox is parsed as complete', () {
      final tasks = TaskParser.parseQuickEntry('[x] Finished task');
      expect(tasks.length, 1);
      expect(tasks[0].title, 'Finished task');
      expect(tasks[0].status, 'complete');
    });

    test('[>] checkbox is parsed as deferred', () {
      final tasks = TaskParser.parseQuickEntry('[>] Deferred task');
      expect(tasks.length, 1);
      expect(tasks[0].title, 'Deferred task');
      expect(tasks[0].status, 'deferred');
    });

    test('multiple plain text lines produce multiple tasks', () {
      final tasks = TaskParser.parseQuickEntry('Task one\nTask two\nTask three');
      expect(tasks.length, 3);
      expect(tasks[0].title, 'Task one');
      expect(tasks[1].title, 'Task two');
      expect(tasks[2].title, 'Task three');
    });

    test('default project is Inbox when not specified', () {
      final tasks = TaskParser.parseQuickEntry('A task');
      expect(tasks[0].project, 'Inbox');
    });

    test('custom default project is used when provided', () {
      final tasks =
          TaskParser.parseQuickEntry('A task', defaultProject: 'Work');
      expect(tasks[0].project, 'Work');
    });

    test('empty title results in Untitled Task', () {
      // A checkbox with only metadata that gets stripped away
      final tasks = TaskParser.parseQuickEntry('[ ] !! > today');
      expect(tasks.length, 1);
      expect(tasks[0].title, 'Untitled Task');
    });
  });

  group('Project headings', () {
    test('+ ProjectName sets project for subsequent tasks', () {
      final input = '+ Work\nDo report\nSend email';
      final tasks = TaskParser.parseQuickEntry(input);
      expect(tasks.length, 2);
      expect(tasks[0].project, 'Work');
      expect(tasks[1].project, 'Work');
    });

    test('project heading line is not itself a task', () {
      final input = '+ Work\nDo report';
      final tasks = TaskParser.parseQuickEntry(input);
      expect(tasks.length, 1);
    });

    test('multiple project headings change project for following tasks', () {
      final input = '+ Work\nTask A\n+ Personal\nTask B';
      final tasks = TaskParser.parseQuickEntry(input);
      expect(tasks.length, 2);
      expect(tasks[0].project, 'Work');
      expect(tasks[1].project, 'Personal');
    });

    test('tasks before any project heading use default project', () {
      final input = 'Task before heading\n+ MyProject\nTask after heading';
      final tasks = TaskParser.parseQuickEntry(input);
      expect(tasks.length, 2);
      expect(tasks[0].project, 'Inbox');
      expect(tasks[1].project, 'MyProject');
    });

    test('project heading with extra whitespace is trimmed', () {
      final input = '+   Spaced Project  \nA task';
      final tasks = TaskParser.parseQuickEntry(input);
      expect(tasks[0].project, 'Spaced Project');
    });
  });

  group('Priority', () {
    test('single ! maps to Low', () {
      final tasks = TaskParser.parseQuickEntry('Do laundry !');
      expect(tasks[0].priority, 'Low');
    });

    test('!! maps to Medium', () {
      final tasks = TaskParser.parseQuickEntry('Do laundry !!');
      expect(tasks[0].priority, 'Medium');
    });

    test('!!! maps to High', () {
      final tasks = TaskParser.parseQuickEntry('Do laundry !!!');
      expect(tasks[0].priority, 'High');
    });

    test('priority marker is removed from title', () {
      final tasks = TaskParser.parseQuickEntry('Do laundry !!');
      expect(tasks[0].title, 'Do laundry');
    });

    test('no priority marker defaults to Low', () {
      final tasks = TaskParser.parseQuickEntry('Simple task');
      expect(tasks[0].priority, 'Low');
    });
  });

  group('Date parsing', () {
    test('> today resolves to today date', () {
      final now = DateTime.now();
      final expected = dateFormat.format(now);
      final tasks = TaskParser.parseQuickEntry('Task > today');
      expect(tasks[0].date, expected);
    });

    test('> tomorrow resolves to tomorrow date', () {
      final now = DateTime.now();
      final expected = dateFormat.format(now.add(const Duration(days: 1)));
      final tasks = TaskParser.parseQuickEntry('Task > tomorrow');
      expect(tasks[0].date, expected);
    });

    test('> tmr resolves to tomorrow date', () {
      final now = DateTime.now();
      final expected = dateFormat.format(now.add(const Duration(days: 1)));
      final tasks = TaskParser.parseQuickEntry('Task > tmr');
      expect(tasks[0].date, expected);
    });

    test('> Mon resolves to next Monday', () {
      final now = DateTime.now();
      var daysToAdd = 1 - now.weekday; // Monday = 1
      if (daysToAdd <= 0) daysToAdd += 7;
      final expected = dateFormat.format(now.add(Duration(days: daysToAdd)));
      final tasks = TaskParser.parseQuickEntry('Task > Mon');
      expect(tasks[0].date, expected);
    });

    test('> Fri resolves to next Friday', () {
      final now = DateTime.now();
      var daysToAdd = 5 - now.weekday; // Friday = 5
      if (daysToAdd <= 0) daysToAdd += 7;
      final expected = dateFormat.format(now.add(Duration(days: daysToAdd)));
      final tasks = TaskParser.parseQuickEntry('Task > Fri');
      expect(tasks[0].date, expected);
    });

    test('> Wed resolves to next Wednesday', () {
      final now = DateTime.now();
      var daysToAdd = 3 - now.weekday; // Wednesday = 3
      if (daysToAdd <= 0) daysToAdd += 7;
      final expected = dateFormat.format(now.add(Duration(days: daysToAdd)));
      final tasks = TaskParser.parseQuickEntry('Task > Wed');
      expect(tasks[0].date, expected);
    });

    test('> Sun resolves to next Sunday', () {
      final now = DateTime.now();
      var daysToAdd = 7 - now.weekday; // Sunday = 7
      if (daysToAdd <= 0) daysToAdd += 7;
      final expected = dateFormat.format(now.add(Duration(days: daysToAdd)));
      final tasks = TaskParser.parseQuickEntry('Task > Sun');
      expect(tasks[0].date, expected);
    });

    test('> M/D format parses month/day correctly', () {
      final now = DateTime.now();
      // Use a future date to avoid year rollover
      final futureMonth = now.month == 12 ? 1 : now.month + 1;
      final input = 'Task > $futureMonth/15';
      final tasks = TaskParser.parseQuickEntry(input);

      var expectedYear = now.year;
      var expectedDate = DateTime(expectedYear, futureMonth, 15);
      if (expectedDate.isBefore(now)) {
        expectedDate = DateTime(expectedYear + 1, futureMonth, 15);
      }
      expect(tasks[0].date, dateFormat.format(expectedDate));
    });

    test('> M/D in past rolls to next year', () {
      final now = DateTime.now();
      // Use a past month
      final pastMonth = now.month == 1 ? 12 : now.month - 1;
      final input = 'Task > $pastMonth/1';
      final tasks = TaskParser.parseQuickEntry(input);

      var expectedDate = DateTime(now.year, pastMonth, 1);
      if (expectedDate.isBefore(now)) {
        expectedDate = DateTime(now.year + 1, pastMonth, 1);
      }
      expect(tasks[0].date, dateFormat.format(expectedDate));
    });

    test('date marker is removed from title', () {
      final tasks = TaskParser.parseQuickEntry('Buy milk > today');
      expect(tasks[0].title, 'Buy milk');
    });

    test('no date marker results in null date on ParsedTask', () {
      final tasks = TaskParser.parseQuickEntry('Simple task');
      expect(tasks[0].date, isNull);
    });
  });

  group('Time parsing', () {
    test('~ 9am parses to 09:00:AM', () {
      final tasks = TaskParser.parseQuickEntry('Meeting ~ 9am');
      expect(tasks[0].startTime, '09:00:AM');
      expect(tasks[0].endTime, '09:00:AM');
    });

    test('~ 2pm parses to 02:00:PM', () {
      final tasks = TaskParser.parseQuickEntry('Meeting ~ 2pm');
      expect(tasks[0].startTime, '02:00:PM');
    });

    test('~ 12pm parses to 12:00:PM (noon)', () {
      final tasks = TaskParser.parseQuickEntry('Lunch ~ 12pm');
      expect(tasks[0].startTime, '12:00:PM');
    });

    test('~ 12am parses to 12:00:AM (midnight)', () {
      // 12am => hour becomes 0, then displayHour = 12
      final tasks = TaskParser.parseQuickEntry('Late night ~ 12am');
      expect(tasks[0].startTime, '12:00:AM');
    });

    test('~ 14:00 parses to 02:00:PM (24h format)', () {
      final tasks = TaskParser.parseQuickEntry('Meeting ~ 14:00');
      expect(tasks[0].startTime, '02:00:PM');
    });

    test('~ 9:30am parses to 09:30:AM', () {
      final tasks = TaskParser.parseQuickEntry('Meeting ~ 9:30am');
      expect(tasks[0].startTime, '09:30:AM');
    });

    test('~ 0:00 midnight edge case (hour 0 becomes 12:00:AM)', () {
      final tasks = TaskParser.parseQuickEntry('Midnight ~ 0:00');
      expect(tasks[0].startTime, '12:00:AM');
    });

    test('~ 11pm parses to 11:00:PM', () {
      final tasks = TaskParser.parseQuickEntry('Bedtime ~ 11pm');
      expect(tasks[0].startTime, '11:00:PM');
    });

    test('time marker is removed from title', () {
      final tasks = TaskParser.parseQuickEntry('Meeting ~ 3pm');
      expect(tasks[0].title, 'Meeting');
    });

    test('no time marker results in null startTime on ParsedTask', () {
      final tasks = TaskParser.parseQuickEntry('Simple task');
      expect(tasks[0].startTime, isNull);
    });

    test('startTime and endTime are set to the same value', () {
      final tasks = TaskParser.parseQuickEntry('Call ~ 4pm');
      expect(tasks[0].startTime, tasks[0].endTime);
    });
  });

  group('Location', () {
    test('^ office sets location', () {
      final tasks = TaskParser.parseQuickEntry('Meeting ^ office');
      expect(tasks[0].location, 'office');
    });

    test('^ home sets location', () {
      final tasks = TaskParser.parseQuickEntry('Chores ^ home');
      expect(tasks[0].location, 'home');
    });

    test('location marker is removed from title', () {
      final tasks = TaskParser.parseQuickEntry('Meeting ^ office');
      expect(tasks[0].title, 'Meeting');
    });

    test('no location marker results in null location', () {
      final tasks = TaskParser.parseQuickEntry('Simple task');
      expect(tasks[0].location, isNull);
    });
  });

  group('Tags', () {
    test('single @tag is parsed', () {
      final tasks = TaskParser.parseQuickEntry('Buy stuff @errands');
      expect(tasks[0].tags, ['errands']);
    });

    test('multiple @tags are parsed', () {
      final tasks =
          TaskParser.parseQuickEntry('Call supplier @phone @errands');
      expect(tasks[0].tags, containsAll(['phone', 'errands']));
      expect(tasks[0].tags.length, 2);
    });

    test('tags are removed from title', () {
      final tasks = TaskParser.parseQuickEntry('Buy stuff @errands');
      expect(tasks[0].title, 'Buy stuff');
    });

    test('no tags results in empty list', () {
      final tasks = TaskParser.parseQuickEntry('Simple task');
      expect(tasks[0].tags, isEmpty);
    });
  });

  group('Notes', () {
    test(': some note text sets note', () {
      final tasks = TaskParser.parseQuickEntry('Task : remember to check');
      expect(tasks[0].note, 'remember to check');
    });

    test('note text is trimmed', () {
      final tasks = TaskParser.parseQuickEntry('Task :   extra spaces   ');
      expect(tasks[0].note, isNotNull);
      expect(tasks[0].note!.trim(), isNotEmpty);
    });

    test('note marker is removed from title', () {
      final tasks = TaskParser.parseQuickEntry('Buy milk : get 2% only');
      // Title should not contain the note
      expect(tasks[0].title.contains('get 2% only'), isFalse);
    });

    test('no note results in null', () {
      final tasks = TaskParser.parseQuickEntry('Simple task');
      expect(tasks[0].note, isNull);
    });
  });

  group('References', () {
    test('# ref-123 sets reference', () {
      final tasks = TaskParser.parseQuickEntry('Fix bug # ref-123');
      expect(tasks[0].reference, 'ref-123');
    });

    test('reference marker is removed from title', () {
      final tasks = TaskParser.parseQuickEntry('Fix bug # JIRA-456');
      expect(tasks[0].title.contains('JIRA-456'), isFalse);
    });

    test('no reference results in null', () {
      final tasks = TaskParser.parseQuickEntry('Simple task');
      expect(tasks[0].reference, isNull);
    });
  });

  group('Subtasks', () {
    test('- line is parsed as subtask', () {
      final tasks = TaskParser.parseQuickEntry('- Buy eggs');
      expect(tasks.length, 1);
      expect(tasks[0].title, 'Buy eggs');
      expect(tasks[0].isSubtask, isTrue);
      expect(tasks[0].status, 'unComplete');
    });

    test('subtask title has dash prefix removed', () {
      final tasks = TaskParser.parseQuickEntry('- Subtask text');
      expect(tasks[0].title, 'Subtask text');
    });

    test('non-subtask lines are not marked as subtasks', () {
      final tasks = TaskParser.parseQuickEntry('Regular task');
      expect(tasks[0].isSubtask, isFalse);
    });

    test('checkbox tasks are not subtasks', () {
      final tasks = TaskParser.parseQuickEntry('[ ] Checkbox task');
      expect(tasks[0].isSubtask, isFalse);
    });
  });

  group('Comments', () {
    test('// comment lines are skipped', () {
      final tasks = TaskParser.parseQuickEntry('// This is a comment');
      expect(tasks, isEmpty);
    });

    test('comment among tasks does not produce a task', () {
      final input = 'Task one\n// a comment\nTask two';
      final tasks = TaskParser.parseQuickEntry(input);
      expect(tasks.length, 2);
      expect(tasks[0].title, 'Task one');
      expect(tasks[1].title, 'Task two');
    });
  });

  group('Empty lines', () {
    test('empty lines are skipped', () {
      final tasks = TaskParser.parseQuickEntry('');
      expect(tasks, isEmpty);
    });

    test('whitespace-only lines are skipped', () {
      final tasks = TaskParser.parseQuickEntry('   \n   \n  ');
      expect(tasks, isEmpty);
    });

    test('empty lines between tasks are skipped', () {
      final input = 'Task one\n\n\nTask two';
      final tasks = TaskParser.parseQuickEntry(input);
      expect(tasks.length, 2);
    });
  });

  group('convertToTaskModels', () {
    test('produces TaskModel list with correct field mapping', () {
      final parsed = TaskParser.parseQuickEntry(
        '[ ] Buy milk @errands ^ store > today ~ 9am !! : get organic # REF-1',
      );
      final models = TaskParser.convertToTaskModels(parsed);

      expect(models.length, 1);
      final m = models[0];
      expect(m.title, isNotNull);
      expect(m.status, 'unComplete');
      expect(m.periority, 'Medium');
      expect(m.category, 'Inbox');
      expect(m.startTime, '09:00:AM');
      expect(m.endTime, '09:00:AM');
      expect(m.date, dateFormat.format(DateTime.now()));
      expect(m.show, 'yes');
      expect(m.image, '');
      expect(m.tags, contains('errands'));
      expect(m.description, contains('Location: store'));
      expect(m.description, contains('Ref: REF-1'));
      expect(m.description, contains('organic'));
    });

    test('each TaskModel gets a unique key', () {
      final parsed = TaskParser.parseQuickEntry('Task A\nTask B\nTask C');
      final models = TaskParser.convertToTaskModels(parsed);
      final keys = models.map((m) => m.key).toSet();
      expect(keys.length, 3, reason: 'All keys should be unique');
    });

    test('task without date gets today as default in TaskModel', () {
      final parsed = TaskParser.parseQuickEntry('No date task');
      final models = TaskParser.convertToTaskModels(parsed);
      final today = dateFormat.format(DateTime.now());
      expect(models[0].date, today);
    });

    test('task without time gets empty string in TaskModel', () {
      final parsed = TaskParser.parseQuickEntry('No time task');
      final models = TaskParser.convertToTaskModels(parsed);
      expect(models[0].startTime, '');
      expect(models[0].endTime, '');
    });

    test('multiple tags are comma-separated in TaskModel', () {
      final parsed = TaskParser.parseQuickEntry('Task @phone @errands');
      final models = TaskParser.convertToTaskModels(parsed);
      expect(models[0].tags, 'phone,errands');
    });

    test('no tags yields empty string for tags', () {
      final parsed = TaskParser.parseQuickEntry('Task without tags');
      final models = TaskParser.convertToTaskModels(parsed);
      expect(models[0].tags, '');
    });

    test('description is empty when no location, note, or reference', () {
      final parsed = TaskParser.parseQuickEntry('Plain task');
      final models = TaskParser.convertToTaskModels(parsed);
      expect(models[0].description, '');
    });

    test('project is mapped to category', () {
      final parsed = TaskParser.parseQuickEntry('+ Work\nDo stuff');
      final models = TaskParser.convertToTaskModels(parsed);
      expect(models[0].category, 'Work');
    });
  });

  group('Complex multi-line input', () {
    test('realistic multi-line entry with mixed syntax', () {
      final input = '''
+ Work
[ ] Write quarterly report !!! > today ~ 9am ^ office @work : due by EOD # RPT-2024
[x] Review PR #42
- Update dependencies

+ Personal
Buy groceries @errands ^ store > tmr
// Remember to check pantry first
[ ] Call dentist @phone !! ~ 2pm
[>] Clean garage > Sat
''';
      final tasks = TaskParser.parseQuickEntry(input);

      // Should have 6 tasks (no comment, no project headings, no empty lines)
      expect(tasks.length, 6);

      // Task 0: Write quarterly report
      expect(tasks[0].project, 'Work');
      expect(tasks[0].status, 'unComplete');
      expect(tasks[0].priority, 'High');
      expect(tasks[0].date, dateFormat.format(DateTime.now()));
      expect(tasks[0].startTime, '09:00:AM');
      expect(tasks[0].location, 'office');
      expect(tasks[0].tags, contains('work'));
      expect(tasks[0].reference, isNotNull);
      expect(tasks[0].isSubtask, isFalse);

      // Task 1: Review PR (complete)
      expect(tasks[1].project, 'Work');
      expect(tasks[1].status, 'complete');

      // Task 2: Update dependencies (subtask)
      expect(tasks[2].project, 'Work');
      expect(tasks[2].isSubtask, isTrue);
      expect(tasks[2].title, 'Update dependencies');

      // Task 3: Buy groceries (Personal project)
      expect(tasks[3].project, 'Personal');
      expect(tasks[3].tags, contains('errands'));
      expect(tasks[3].location, 'store');
      expect(tasks[3].date,
          dateFormat.format(DateTime.now().add(const Duration(days: 1))));

      // Task 4: Call dentist
      expect(tasks[4].project, 'Personal');
      expect(tasks[4].priority, 'Medium');
      expect(tasks[4].startTime, '02:00:PM');
      expect(tasks[4].tags, contains('phone'));

      // Task 5: Clean garage (deferred)
      expect(tasks[5].project, 'Personal');
      expect(tasks[5].status, 'deferred');
    });

    test('convertToTaskModels on multi-line input produces unique keys', () {
      final input = '+ Project\nTask A\nTask B\nTask C\nTask D';
      final parsed = TaskParser.parseQuickEntry(input);
      final models = TaskParser.convertToTaskModels(parsed);

      expect(models.length, 4);
      final keys = models.map((m) => m.key).toSet();
      expect(keys.length, 4, reason: 'All keys must be unique');

      for (final model in models) {
        expect(model.category, 'Project');
        expect(model.show, 'yes');
      }
    });
  });
}
