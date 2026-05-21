import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/data/local/database/app_database.dart';
import 'package:todo/model/task_model.dart';

AppDatabase createTestDb() => AppDatabase.forTesting(NativeDatabase.memory());

TaskModel makeTask({
  String key = 't1',
  String title = 'Test',
  String status = 'unComplete',
  int? updatedAt,
  bool deleted = false,
}) {
  return TaskModel(
    key: key,
    title: title,
    category: 'Inbox',
    description: '',
    image: '',
    priority: 'Low',
    startTime: '',
    endTime: '',
    date: '03/06/2026',
    show: 'yes',
    status: status,
    updatedAt: updatedAt,
    deleted: deleted,
  );
}

void main() {
  late AppDatabase db;
  late TaskDao dao;

  setUp(() {
    db = createTestDb();
    dao = TaskDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('soft delete', () {
    test('deleteTask hides the row from getAllTasks but keeps it for sync',
        () async {
      await dao.insertTask(makeTask(key: 'a'));
      await dao.deleteTask('a');

      expect(await dao.getAllTasks(), isEmpty);

      final forSync = await dao.getAllTasksForSync();
      expect(forSync, hasLength(1));
      expect(forSync.first.deleted, isTrue);
    });

    test('deleted rows are excluded from project grouping and counts',
        () async {
      await dao.insertTask(makeTask(key: 'a', title: 'live'));
      await dao.insertTask(makeTask(key: 'b', title: 'gone'));
      await dao.deleteTask('b');

      final grouped = await dao.getAllTasksGroupedByProject();
      expect(grouped['Inbox'], hasLength(1));
      expect(await dao.countTasksForProject('Inbox'), 1);
    });

    test('re-inserting a deleted key revives it (clears tombstone)', () async {
      await dao.insertTask(makeTask(key: 'a'));
      await dao.deleteTask('a');
      expect(await dao.getAllTasks(), isEmpty);

      await dao.insertTask(makeTask(key: 'a', title: 'back'));
      final live = await dao.getAllTasks();
      expect(live, hasLength(1));
      expect(live.first.deleted, isFalse);
    });
  });

  group('applyRemoteTask (last-write-wins)', () {
    test('applies a brand-new remote row', () async {
      final changed = await dao.applyRemoteTask(
          makeTask(key: 'r1', title: 'remote', updatedAt: 1000));
      expect(changed, isTrue);
      final all = await dao.getAllTasks();
      expect(all.single.title, 'remote');
    });

    test('remote newer than local wins', () async {
      await dao.insertTask(makeTask(key: 'x', title: 'local'));
      // Local updatedAt was just stamped to "now"; simulate a strictly newer
      // remote by using a far-future timestamp.
      final future = DateTime.now().millisecondsSinceEpoch + 100000;
      final changed = await dao.applyRemoteTask(
          makeTask(key: 'x', title: 'remote-wins', updatedAt: future));
      expect(changed, isTrue);
      final all = await dao.getAllTasks();
      expect(all.single.title, 'remote-wins');
    });

    test('local newer than remote is preserved', () async {
      await dao.insertTask(makeTask(key: 'x', title: 'local-wins'));
      final changed = await dao.applyRemoteTask(
          makeTask(key: 'x', title: 'stale-remote', updatedAt: 1));
      expect(changed, isFalse);
      final all = await dao.getAllTasks();
      expect(all.single.title, 'local-wins');
    });

    test('remote tombstone deletes a live local row when newer', () async {
      await dao.insertTask(makeTask(key: 'x', title: 'local'));
      final future = DateTime.now().millisecondsSinceEpoch + 100000;
      final changed = await dao.applyRemoteTask(
          makeTask(key: 'x', updatedAt: future, deleted: true));
      expect(changed, isTrue);
      expect(await dao.getAllTasks(), isEmpty);

      final forSync = await dao.getAllTasksForSync();
      expect(forSync.single.deleted, isTrue);
    });

    test('equal timestamps do not overwrite (local wins ties)', () async {
      await dao.applyRemoteTask(
          makeTask(key: 'x', title: 'first', updatedAt: 5000));
      final changed = await dao.applyRemoteTask(
          makeTask(key: 'x', title: 'second', updatedAt: 5000));
      expect(changed, isFalse);
      final all = await dao.getAllTasks();
      expect(all.single.title, 'first');
    });
  });

  group('tombstone GC', () {
    test('prunes only deleted rows older than the cutoff', () async {
      // Live row, old timestamp — must survive.
      await dao.applyRemoteTask(
          makeTask(key: 'live', updatedAt: 1000, deleted: false));
      // Old tombstone — must be pruned.
      await dao.applyRemoteTask(
          makeTask(key: 'old-dead', updatedAt: 1000, deleted: true));
      // Recent tombstone — must survive (other devices may not have seen it).
      await dao.applyRemoteTask(
          makeTask(key: 'fresh-dead', updatedAt: 9000, deleted: true));

      final removed = await dao.pruneTombstones(5000);
      expect(removed, 1);

      final remaining = await dao.getAllTasksForSync();
      final keys = remaining.map((t) => t.key).toSet();
      expect(keys, containsAll(['live', 'fresh-dead']));
      expect(keys, isNot(contains('old-dead')));
    });
  });
}
