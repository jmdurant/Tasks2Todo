import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/data/local/database/app_database.dart';
import 'package:todo/model/task_model.dart';

AppDatabase createTestDb() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}

TaskModel makeTask({
  String key = 'task-1',
  String title = 'Test Task',
  String category = 'Work',
  String description = 'A test task',
  String image = '',
  String periority = 'High',
  String startTime = '09:00',
  String endTime = '10:00',
  String date = '03/06/2026',
  String show = 'true',
  String status = 'pending',
  String tags = '',
}) {
  return TaskModel(
    key: key,
    title: title,
    category: category,
    description: description,
    image: image,
    periority: periority,
    startTime: startTime,
    endTime: endTime,
    date: date,
    show: show,
    status: status,
    tags: tags,
  );
}

void main() {
  // ── TaskDao ──────────────────────────────────────────────────────────────

  group('TaskDao', () {
    late AppDatabase db;
    late TaskDao dao;

    setUp(() {
      db = createTestDb();
      dao = TaskDao(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('insertTask and getAllTasks returns the inserted task', () async {
      final task = makeTask();
      await dao.insertTask(task);

      final tasks = await dao.getAllTasks();
      expect(tasks, hasLength(1));
      expect(tasks.first.key, 'task-1');
      expect(tasks.first.title, 'Test Task');
      expect(tasks.first.category, 'Work');
      expect(tasks.first.status, 'pending');
    });

    test('insertTask with same key performs upsert', () async {
      await dao.insertTask(makeTask(title: 'Original'));
      await dao.insertTask(makeTask(title: 'Updated'));

      final tasks = await dao.getAllTasks();
      expect(tasks, hasLength(1));
      expect(tasks.first.title, 'Updated');
    });

    test('getAllTasks returns empty list when no tasks exist', () async {
      final tasks = await dao.getAllTasks();
      expect(tasks, isEmpty);
    });

    test('deleteTask removes the task and returns affected row count', () async {
      await dao.insertTask(makeTask(key: 'a'));
      await dao.insertTask(makeTask(key: 'b'));

      final deleted = await dao.deleteTask('a');
      expect(deleted, 1);

      final tasks = await dao.getAllTasks();
      expect(tasks, hasLength(1));
      expect(tasks.first.key, 'b');
    });

    test('deleteTask returns 0 when key does not exist', () async {
      final deleted = await dao.deleteTask('nonexistent');
      expect(deleted, 0);
    });

    test('updateTaskStatus changes the status of a task', () async {
      await dao.insertTask(makeTask(key: 'x', status: 'pending'));

      final updated = await dao.updateTaskStatus('x', 'completed');
      expect(updated, 1);

      final tasks = await dao.getAllTasks();
      expect(tasks.first.status, 'completed');
    });

    test('updateTaskStatus returns 0 for nonexistent key', () async {
      final updated = await dao.updateTaskStatus('nope', 'completed');
      expect(updated, 0);
    });

    test('getTasksForDates returns only tasks matching the given dates',
        () async {
      await dao.insertTask(makeTask(key: '1', date: '03/01/2026'));
      await dao.insertTask(makeTask(key: '2', date: '03/02/2026'));
      await dao.insertTask(makeTask(key: '3', date: '03/03/2026'));

      final results =
          await dao.getTasksForDates(['03/01/2026', '03/03/2026']);
      expect(results, hasLength(2));
      final keys = results.map((t) => t.key).toSet();
      expect(keys, containsAll(['1', '3']));
    });

    test('getTasksForDates returns empty list when no dates match', () async {
      await dao.insertTask(makeTask(key: '1', date: '03/01/2026'));
      final results = await dao.getTasksForDates(['12/31/2099']);
      expect(results, isEmpty);
    });

    test('getTasksForProject returns tasks with matching category', () async {
      await dao.insertTask(makeTask(key: '1', category: 'Work'));
      await dao.insertTask(makeTask(key: '2', category: 'Personal'));
      await dao.insertTask(makeTask(key: '3', category: 'Work'));

      final results = await dao.getTasksForProject('Work');
      expect(results, hasLength(2));
      for (final t in results) {
        expect(t.category, 'Work');
      }
    });

    test('getTasksForProject returns empty list for unknown project', () async {
      await dao.insertTask(makeTask(key: '1', category: 'Work'));
      final results = await dao.getTasksForProject('Unknown');
      expect(results, isEmpty);
    });

    test('countTasksForProject returns correct count', () async {
      await dao.insertTask(makeTask(key: '1', category: 'Work'));
      await dao.insertTask(makeTask(key: '2', category: 'Work'));
      await dao.insertTask(makeTask(key: '3', category: 'Personal'));

      expect(await dao.countTasksForProject('Work'), 2);
      expect(await dao.countTasksForProject('Personal'), 1);
      expect(await dao.countTasksForProject('Other'), 0);
    });

    group('searchTasks (SQL LIKE)', () {
      setUp(() async {
        await dao.insertTask(makeTask(
          key: '1',
          title: 'Buy groceries',
          description: 'milk and eggs',
          category: 'Shopping',
          tags: 'food,errands',
        ));
        await dao.insertTask(makeTask(
          key: '2',
          title: 'Write report',
          description: 'quarterly earnings',
          category: 'Work',
          tags: 'office',
        ));
        await dao.insertTask(makeTask(
          key: '3',
          title: 'Fix bug',
          description: 'null pointer in parser',
          category: 'Work',
          tags: 'dev,urgent',
        ));
      });

      test('matches by title', () async {
        final results = await dao.searchTasks('groceries');
        expect(results, hasLength(1));
        expect(results.first.key, '1');
      });

      test('matches by description', () async {
        final results = await dao.searchTasks('quarterly');
        expect(results, hasLength(1));
        expect(results.first.key, '2');
      });

      test('matches by category', () async {
        final results = await dao.searchTasks('Shopping');
        expect(results, hasLength(1));
        expect(results.first.key, '1');
      });

      test('matches by tags', () async {
        final results = await dao.searchTasks('urgent');
        expect(results, hasLength(1));
        expect(results.first.key, '3');
      });

      test('matches multiple tasks', () async {
        final results = await dao.searchTasks('Work');
        expect(results, hasLength(2));
      });

      test('returns empty list when nothing matches', () async {
        final results = await dao.searchTasks('zzzzz');
        expect(results, isEmpty);
      });

      test('is case-insensitive for ASCII (SQLite default LIKE)', () async {
        final results = await dao.searchTasks('buy');
        // SQLite LIKE is case-insensitive for ASCII letters
        expect(results, hasLength(1));
        expect(results.first.key, '1');
      });
    });

    test('getAllTasksGroupedByProject groups tasks by category', () async {
      await dao.insertTask(makeTask(key: '1', category: 'Work'));
      await dao.insertTask(makeTask(key: '2', category: 'Work'));
      await dao.insertTask(makeTask(key: '3', category: 'Personal'));

      final grouped = await dao.getAllTasksGroupedByProject();
      expect(grouped.keys, containsAll(['Work', 'Personal']));
      expect(grouped['Work'], hasLength(2));
      expect(grouped['Personal'], hasLength(1));
    });

    test('getAllTasksGroupedByProject returns empty map with no tasks',
        () async {
      final grouped = await dao.getAllTasksGroupedByProject();
      expect(grouped, isEmpty);
    });

    test('insertTask preserves tags field', () async {
      await dao.insertTask(makeTask(key: '1', tags: 'a,b,c'));
      final tasks = await dao.getAllTasks();
      expect(tasks.first.tags, 'a,b,c');
    });
  });

  // ── ProjectDao ───────────────────────────────────────────────────────────

  group('ProjectDao', () {
    late AppDatabase db;
    late ProjectDao dao;

    setUp(() {
      db = createTestDb();
      dao = ProjectDao(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('insertProject adds a project', () async {
      await dao.insertProject(ProjectsCompanion(
        id: const Value('p1'),
        name: const Value('My Project'),
        description: const Value('desc'),
        color: const Value(0xFF0000),
      ));

      // Use watchProjects to verify (get first emission)
      final projects = await dao.watchProjects().first;
      expect(projects, hasLength(1));
      expect(projects.first.id, 'p1');
      expect(projects.first.name, 'My Project');
      expect(projects.first.color, 0xFF0000);
    });

    test('insertProject with same id performs upsert', () async {
      await dao.insertProject(ProjectsCompanion(
        id: const Value('p1'),
        name: const Value('Original'),
      ));
      await dao.insertProject(ProjectsCompanion(
        id: const Value('p1'),
        name: const Value('Updated'),
      ));

      final projects = await dao.watchProjects().first;
      expect(projects, hasLength(1));
      expect(projects.first.name, 'Updated');
    });

    test('watchProjects emits updates', () async {
      // Take the first two emissions: initial empty, then after insert
      final stream = dao.watchProjects();
      final first = await stream.first;
      expect(first, isEmpty);

      await dao.insertProject(ProjectsCompanion(
        id: const Value('p1'),
        name: const Value('Proj'),
      ));

      final second = await stream.first;
      expect(second, hasLength(1));
    });

    test('deleteProject removes a project', () async {
      await dao.insertProject(ProjectsCompanion(
        id: const Value('p1'),
        name: const Value('To Delete'),
      ));

      final deleted = await dao.deleteProject('p1');
      expect(deleted, 1);

      final projects = await dao.watchProjects().first;
      expect(projects, isEmpty);
    });

    test('deleteProject returns 0 for nonexistent id', () async {
      final deleted = await dao.deleteProject('nonexistent');
      expect(deleted, 0);
    });
  });

  // ── CaptureSessionDao ────────────────────────────────────────────────────

  group('CaptureSessionDao', () {
    late AppDatabase db;
    late CaptureSessionDao dao;

    setUp(() {
      db = createTestDb();
      dao = CaptureSessionDao(db);
    });

    tearDown(() async {
      await db.close();
    });

    CaptureSessionsCompanion makeSession({
      String id = 'session-1',
      String imageFilePath = '/path/to/image.png',
      String syncStatus = 'pending',
      String? syncError,
      String? rawVisionResponse,
    }) {
      return CaptureSessionsCompanion(
        id: Value(id),
        imageFilePath: Value(imageFilePath),
        syncStatus: Value(syncStatus),
        syncError: Value(syncError),
        rawVisionResponse: Value(rawVisionResponse),
      );
    }

    test('upsertSession inserts a new session', () async {
      await dao.upsertSession(makeSession());

      final found = await dao.findSession('session-1');
      expect(found, isNotNull);
      expect(found!.id, 'session-1');
      expect(found.syncStatus, 'pending');
      expect(found.imageFilePath, '/path/to/image.png');
    });

    test('upsertSession updates an existing session', () async {
      await dao.upsertSession(makeSession(syncStatus: 'pending'));
      await dao.upsertSession(makeSession(syncStatus: 'synced'));

      final found = await dao.findSession('session-1');
      expect(found!.syncStatus, 'synced');
    });

    test('findSession returns null for nonexistent id', () async {
      final found = await dao.findSession('nonexistent');
      expect(found, isNull);
    });

    test('deleteSession removes the session', () async {
      await dao.upsertSession(makeSession());

      final deleted = await dao.deleteSession('session-1');
      expect(deleted, 1);

      final found = await dao.findSession('session-1');
      expect(found, isNull);
    });

    test('deleteSession returns 0 for nonexistent id', () async {
      final deleted = await dao.deleteSession('nonexistent');
      expect(deleted, 0);
    });

    test('updateSyncStatus changes status and error', () async {
      await dao.upsertSession(makeSession(syncStatus: 'pending'));

      final updated = await dao.updateSyncStatus(
        'session-1',
        status: 'failed',
        error: 'Network error',
      );
      expect(updated, 1);

      final found = await dao.findSession('session-1');
      expect(found!.syncStatus, 'failed');
      expect(found.syncError, 'Network error');
    });

    test('updateSyncStatus can clear the error by passing null', () async {
      await dao.upsertSession(
          makeSession(syncStatus: 'failed', syncError: 'old error'));

      await dao.updateSyncStatus('session-1', status: 'synced', error: null);

      final found = await dao.findSession('session-1');
      expect(found!.syncStatus, 'synced');
      expect(found.syncError, isNull);
    });

    test('updateSyncStatus returns 0 for nonexistent id', () async {
      final updated = await dao.updateSyncStatus(
        'nonexistent',
        status: 'synced',
      );
      expect(updated, 0);
    });
  });

  // ── ParsedItemDao ────────────────────────────────────────────────────────

  group('ParsedItemDao', () {
    late AppDatabase db;
    late CaptureSessionDao sessionDao;
    late ParsedItemDao dao;

    setUp(() {
      db = createTestDb();
      sessionDao = CaptureSessionDao(db);
      dao = ParsedItemDao(db);
    });

    tearDown(() async {
      await db.close();
    });

    Future<void> insertParentSession({String id = 'session-1'}) async {
      await sessionDao.upsertSession(CaptureSessionsCompanion(
        id: Value(id),
        imageFilePath: const Value('/img.png'),
        syncStatus: const Value('pending'),
      ));
    }

    ParsedItemsCompanion makeItem({
      String id = 'item-1',
      String sessionId = 'session-1',
      String type = 'task',
      String content = 'Do something',
      String? tags,
      String? dueDate,
      String? dueTime,
      String priority = 'medium',
      String? location,
      String? parentProject,
      String status = 'pending',
      double? confidence,
      String? note,
      String? externalId,
    }) {
      return ParsedItemsCompanion(
        id: Value(id),
        sessionId: Value(sessionId),
        type: Value(type),
        content: Value(content),
        tags: Value(tags),
        dueDate: Value(dueDate),
        dueTime: Value(dueTime),
        priority: Value(priority),
        location: Value(location),
        parentProject: Value(parentProject),
        status: Value(status),
        confidence: Value(confidence),
        note: Value(note),
        externalId: Value(externalId),
      );
    }

    test('upsertItem inserts a new item', () async {
      await insertParentSession();
      await dao.upsertItem(makeItem());

      final items = await dao.findBySession('session-1');
      expect(items, hasLength(1));
      expect(items.first.id, 'item-1');
      expect(items.first.content, 'Do something');
    });

    test('upsertItem updates an existing item', () async {
      await insertParentSession();
      await dao.upsertItem(makeItem(content: 'Original'));
      await dao.upsertItem(makeItem(content: 'Updated'));

      final items = await dao.findBySession('session-1');
      expect(items, hasLength(1));
      expect(items.first.content, 'Updated');
    });

    test('upsertItems inserts multiple items in a batch', () async {
      await insertParentSession();
      await dao.upsertItems([
        makeItem(id: 'a'),
        makeItem(id: 'b'),
        makeItem(id: 'c'),
      ]);

      final items = await dao.findBySession('session-1');
      expect(items, hasLength(3));
    });

    test('upsertItems updates existing items in a batch', () async {
      await insertParentSession();
      await dao.upsertItem(makeItem(id: 'a', content: 'Old'));
      await dao.upsertItems([
        makeItem(id: 'a', content: 'New'),
        makeItem(id: 'b', content: 'Brand new'),
      ]);

      final items = await dao.findBySession('session-1');
      expect(items, hasLength(2));
      final itemA = items.firstWhere((i) => i.id == 'a');
      expect(itemA.content, 'New');
    });

    test('findBySession returns only items for the given session', () async {
      await insertParentSession(id: 'session-1');
      await insertParentSession(id: 'session-2');

      await dao.upsertItem(makeItem(id: '1', sessionId: 'session-1'));
      await dao.upsertItem(makeItem(id: '2', sessionId: 'session-2'));
      await dao.upsertItem(makeItem(id: '3', sessionId: 'session-1'));

      final items = await dao.findBySession('session-1');
      expect(items, hasLength(2));
      for (final item in items) {
        expect(item.sessionId, 'session-1');
      }
    });

    test('findBySession returns empty list for unknown session', () async {
      final items = await dao.findBySession('nonexistent');
      expect(items, isEmpty);
    });

    test('deleteBySession removes all items for the session', () async {
      await insertParentSession(id: 'session-1');
      await insertParentSession(id: 'session-2');

      await dao.upsertItem(makeItem(id: '1', sessionId: 'session-1'));
      await dao.upsertItem(makeItem(id: '2', sessionId: 'session-1'));
      await dao.upsertItem(makeItem(id: '3', sessionId: 'session-2'));

      final deleted = await dao.deleteBySession('session-1');
      expect(deleted, 2);

      final remaining1 = await dao.findBySession('session-1');
      expect(remaining1, isEmpty);

      final remaining2 = await dao.findBySession('session-2');
      expect(remaining2, hasLength(1));
    });

    test('deleteBySession returns 0 when no items match', () async {
      final deleted = await dao.deleteBySession('nonexistent');
      expect(deleted, 0);
    });

    test('cascade delete removes parsed items when session is deleted',
        () async {
      await insertParentSession();
      await dao.upsertItem(makeItem(id: '1'));
      await dao.upsertItem(makeItem(id: '2'));

      // Delete the parent session
      await sessionDao.deleteSession('session-1');

      final items = await dao.findBySession('session-1');
      expect(items, isEmpty);
    });

    test('upsertItem preserves nullable fields', () async {
      await insertParentSession();
      await dao.upsertItem(makeItem(
        tags: 'tag1,tag2',
        dueDate: '2026-03-10',
        dueTime: '14:00',
        location: 'Office',
        parentProject: 'ProjectX',
        confidence: 0.95,
        note: 'A note',
        externalId: 'ext-123',
      ));

      final items = await dao.findBySession('session-1');
      final item = items.first;
      expect(item.tags, 'tag1,tag2');
      expect(item.dueDate, '2026-03-10');
      expect(item.dueTime, '14:00');
      expect(item.location, 'Office');
      expect(item.parentProject, 'ProjectX');
      expect(item.confidence, 0.95);
      expect(item.note, 'A note');
      expect(item.externalId, 'ext-123');
    });
  });
}
