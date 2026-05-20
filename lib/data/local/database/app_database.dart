import 'package:drift/drift.dart';
import 'package:todo/model/task_model.dart';

import 'database_native.dart'
    if (dart.library.html) 'database_web.dart' as db_connection;

part 'app_database.g.dart';

class Tasks extends Table {
  TextColumn get key => text()();
  TextColumn get title => text()();
  TextColumn get category => text()();
  TextColumn get description => text()();
  TextColumn get image => text()();
  TextColumn get priority => text()();
  TextColumn get startTime => text()();
  TextColumn get endTime => text()();
  TextColumn get date => text()();
  TextColumn get show => text()();
  TextColumn get status => text()();
  TextColumn get tags => text().withDefault(const Constant(''))();
  // Recurrence: 'none', 'daily', 'weekly', 'monthly'
  TextColumn get recurrence => text().withDefault(const Constant('none'))();
  // Minutes before task start time to send reminder (0 = at time, -1 = no reminder)
  IntColumn get reminderMinutesBefore => integer().withDefault(const Constant(-1))();
  // Stable 31-bit notification id; 0 means "not scheduled yet".
  IntColumn get notificationId => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {key};
}

class CaptureSessions extends Table {
  TextColumn get id => text()();
  DateTimeColumn get capturedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get imageFilePath => text()();
  TextColumn get syncStatus => text()();
  TextColumn get syncError => text().nullable()();
  TextColumn get rawVisionResponse => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ParsedItems extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId =>
      text().references(CaptureSessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => text()();
  TextColumn get content => text()();
  TextColumn get tags => text().nullable()();
  TextColumn get dueDate => text().nullable()();
  TextColumn get dueTime => text().nullable()();
  TextColumn get priority => text()();
  TextColumn get location => text().nullable()();
  TextColumn get parentProject => text().nullable()();
  TextColumn get status => text()();
  RealColumn get confidence => real().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get externalId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  IntColumn get color => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [Tasks, CaptureSessions, ParsedItems, Projects],
  daos: [TaskDao, CaptureSessionDao, ParsedItemDao, ProjectDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(projects);
          }
          if (from < 3) {
            await m.addColumn(tasks, tasks.tags);
          }
          if (from < 4) {
            await m.addColumn(tasks, tasks.recurrence);
            await m.addColumn(tasks, tasks.reminderMinutesBefore);
          }
          if (from < 5) {
            // Rename legacy `periority` -> `priority` and add a stable
            // notification id. We use raw SQL with DEFAULT clauses so that
            // existing rows satisfy the NOT NULL constraints during ALTER.
            await customStatement(
                "ALTER TABLE tasks ADD COLUMN priority TEXT NOT NULL DEFAULT 'Low'");
            await customStatement(
                "ALTER TABLE tasks ADD COLUMN notification_id INTEGER NOT NULL DEFAULT 0");
            // Copy data from the old misspelled column.
            await customStatement(
                "UPDATE tasks SET priority = periority WHERE periority IS NOT NULL");
            // Derive a stable 31-bit notification id from the existing key.
            // Keys created by the app are microsecondsSinceEpoch.toString();
            // for anything else (legacy / imported rows) fall back to rowid.
            await customStatement(
                "UPDATE tasks SET notification_id = "
                "CASE WHEN CAST(key AS INTEGER) > 0 "
                "  THEN CAST(key AS INTEGER) % 2147483647 "
                "  ELSE rowid END");
            // SQLite 3.35+ supports DROP COLUMN. sqlite3_flutter_libs bundles
            // a recent build, so this is safe.
            await customStatement("ALTER TABLE tasks DROP COLUMN periority");
          }
        },
      );
}

LazyDatabase _openConnection() {
  return db_connection.openConnection();
}

@DriftAccessor(tables: [Tasks])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  TaskModel _rowToModel(Task row) => TaskModel(
        key: row.key,
        startTime: row.startTime,
        endTime: row.endTime,
        date: row.date,
        priority: row.priority,
        description: row.description,
        category: row.category,
        title: row.title,
        image: row.image,
        show: row.show,
        status: row.status,
        tags: row.tags,
        recurrence: row.recurrence,
        reminderMinutesBefore: row.reminderMinutesBefore,
        notificationId: row.notificationId,
      );

  Future<void> insertTask(TaskModel model) {
    final int notifId = model.notificationId == null || model.notificationId == 0
        ? _stableNotificationId(model.key!)
        : model.notificationId!;
    return into(tasks).insertOnConflictUpdate(
      TasksCompanion(
        key: Value(model.key!),
        title: Value(model.title!),
        category: Value(model.category!),
        description: Value(model.description!),
        image: Value(model.image!),
        priority: Value(model.priority!),
        startTime: Value(model.startTime!),
        endTime: Value(model.endTime!),
        date: Value(model.date!),
        show: Value(model.show!),
        status: Value(model.status!),
        tags: Value(model.tags ?? ''),
        recurrence: Value(model.recurrence ?? 'none'),
        reminderMinutesBefore: Value(model.reminderMinutesBefore ?? -1),
        notificationId: Value(notifId),
      ),
    );
  }

  /// Derives a deterministic 31-bit notification id from the task key.
  /// Keys created by the app are `microsecondsSinceEpoch.toString()`, so this
  /// is essentially the low 31 bits of the creation time — stable across
  /// restarts and unique unless two keys collide on those bits.
  static int _stableNotificationId(String key) {
    final int? parsed = int.tryParse(key);
    final int raw = parsed ?? key.hashCode;
    return raw & 0x7FFFFFFF;
  }

  Future<void> insertAllTasks(List<TaskModel> models) {
    return batch((b) {
      b.insertAllOnConflictUpdate(
        tasks,
        models.map((m) {
          final int notifId = m.notificationId == null || m.notificationId == 0
              ? _stableNotificationId(m.key!)
              : m.notificationId!;
          return TasksCompanion(
            key: Value(m.key!),
            title: Value(m.title!),
            category: Value(m.category!),
            description: Value(m.description!),
            image: Value(m.image!),
            priority: Value(m.priority!),
            startTime: Value(m.startTime!),
            endTime: Value(m.endTime!),
            date: Value(m.date!),
            show: Value(m.show!),
            status: Value(m.status!),
            tags: Value(m.tags ?? ''),
            recurrence: Value(m.recurrence ?? 'none'),
            reminderMinutesBefore: Value(m.reminderMinutesBefore ?? -1),
            notificationId: Value(notifId),
          );
        }).toList(),
      );
    });
  }

  Future<List<TaskModel>> getAllTasks() async {
    final List<Task> rows = await select(tasks).get();
    return rows.map(_rowToModel).toList();
  }

  Future<int> deleteTask(String keyValue) {
    return (delete(tasks)..where((tbl) => tbl.key.equals(keyValue))).go();
  }

  Future<int> updateTaskStatus(String keyValue, String statusValue) {
    return (update(tasks)..where((tbl) => tbl.key.equals(keyValue))).write(
      TasksCompanion(
        status: Value(statusValue),
      ),
    );
  }

  /// Get tasks for a list of date strings (e.g., ["03/01/2026", "04/01/2026", ...])
  Future<List<TaskModel>> getTasksForDates(List<String> dates) async {
    final List<Task> rows = await (select(tasks)
          ..where((tbl) => tbl.date.isIn(dates)))
        .get();
    return rows.map(_rowToModel).toList();
  }

  /// Get tasks for a specific project/category
  Future<List<TaskModel>> getTasksForProject(String projectName) async {
    final List<Task> rows = await (select(tasks)
          ..where((tbl) => tbl.category.equals(projectName)))
        .get();
    return rows.map(_rowToModel).toList();
  }

  /// Get all tasks grouped by project/category
  Future<Map<String, List<TaskModel>>> getAllTasksGroupedByProject() async {
    final List<Task> rows = await select(tasks).get();
    final Map<String, List<TaskModel>> grouped = {};
    for (final row in rows) {
      (grouped[row.category] ??= []).add(_rowToModel(row));
    }
    return grouped;
  }

  /// Reactive version of [getAllTasksGroupedByProject]. Emits a fresh map
  /// whenever any task row changes, so views can rebuild without manually
  /// refreshing.
  Stream<Map<String, List<TaskModel>>> watchAllTasksGroupedByProject() {
    return select(tasks).watch().map((rows) {
      final Map<String, List<TaskModel>> grouped = {};
      for (final row in rows) {
        (grouped[row.category] ??= []).add(_rowToModel(row));
      }
      return grouped;
    });
  }

  /// Count tasks for a specific project/category
  Future<int> countTasksForProject(String projectName) async {
    final query = selectOnly(tasks)
      ..addColumns([tasks.key.count()])
      ..where(tasks.category.equals(projectName));
    final result = await query.getSingle();
    return result.read(tasks.key.count()) ?? 0;
  }

  /// Stream of task counts by project
  Stream<Map<String, int>> watchTaskCountsByProject() {
    return select(tasks).watch().map((rows) {
      final counts = <String, int>{};
      for (final row in rows) {
        counts[row.category] = (counts[row.category] ?? 0) + 1;
      }
      return counts;
    });
  }

  /// Search tasks by title, description, category, or tags
  Future<List<TaskModel>> searchTasks(String query) async {
    final pattern = '%$query%';
    final List<Task> rows = await (select(tasks)
          ..where((tbl) =>
              tbl.title.like(pattern) |
              tbl.description.like(pattern) |
              tbl.category.like(pattern) |
              tbl.tags.like(pattern)))
        .get();
    return rows.map(_rowToModel).toList();
  }

  /// Get all tasks with reminders set (for scheduling notifications)
  Future<List<TaskModel>> getTasksWithReminders() async {
    final List<Task> rows = await (select(tasks)
          ..where((tbl) =>
              tbl.reminderMinutesBefore.isBiggerOrEqualValue(0) &
              tbl.status.equals('unComplete')))
        .get();
    return rows.map(_rowToModel).toList();
  }
}

@DriftAccessor(tables: [CaptureSessions])
class CaptureSessionDao extends DatabaseAccessor<AppDatabase>
    with _$CaptureSessionDaoMixin {
  CaptureSessionDao(super.db);

  Future<void> upsertSession(CaptureSessionsCompanion session) {
    return into(captureSessions).insertOnConflictUpdate(session);
  }

  Future<List<CaptureSession>> getAllSessions() {
    return select(captureSessions).get();
  }

  Future<CaptureSession?> findSession(String id) {
    return (select(captureSessions)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> updateSyncStatus(String id,
      {required String status, String? error}) {
    return (update(captureSessions)..where((tbl) => tbl.id.equals(id))).write(
      CaptureSessionsCompanion(
        syncStatus: Value(status),
        syncError: Value(error),
      ),
    );
  }

  Stream<List<CaptureSession>> watchPendingSessions() {
    return (select(captureSessions)
          ..where((tbl) => tbl.syncStatus.isNotIn(<String>['synced'])))
        .watch();
  }

  Future<int> deleteSession(String id) {
    return (delete(captureSessions)..where((tbl) => tbl.id.equals(id))).go();
  }
}

@DriftAccessor(tables: [ParsedItems])
class ParsedItemDao extends DatabaseAccessor<AppDatabase>
    with _$ParsedItemDaoMixin {
  ParsedItemDao(super.db);

  Future<void> upsertItems(List<ParsedItemsCompanion> companions) {
    return batch((Batch batch) {
      batch.insertAllOnConflictUpdate(parsedItems, companions);
    });
  }

  Future<void> upsertItem(ParsedItemsCompanion companion) {
    return into(parsedItems).insertOnConflictUpdate(companion);
  }

  Future<List<ParsedItem>> findBySession(String sessionId) {
    return (select(parsedItems)..where((tbl) => tbl.sessionId.equals(sessionId)))
        .get();
  }

  Stream<List<ParsedItem>> watchItemsByStatus(String status) {
    return (select(parsedItems)..where((tbl) => tbl.status.equals(status)))
        .watch();
  }

  Future<int> deleteBySession(String sessionId) {
    return (delete(parsedItems)..where((tbl) => tbl.sessionId.equals(sessionId)))
        .go();
  }

  Future<int> deleteItem(String id) {
    return (delete(parsedItems)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Marks an item as promoted into the Tasks table; the new task's key is
  /// stored in externalId so the inbox can filter it out.
  Future<int> markPromoted(String id, String taskKey) {
    return (update(parsedItems)..where((tbl) => tbl.id.equals(id))).write(
      ParsedItemsCompanion(externalId: Value(taskKey)),
    );
  }

  /// Streams every parsed item that hasn't been promoted yet, newest first
  /// (paired with sessions in the UI layer).
  Stream<List<ParsedItem>> watchPendingItems() {
    return (select(parsedItems)..where((tbl) => tbl.externalId.isNull()))
        .watch();
  }
}

@DriftAccessor(tables: [Projects])
class ProjectDao extends DatabaseAccessor<AppDatabase> with _$ProjectDaoMixin {
  ProjectDao(super.db);

  Future<void> insertProject(ProjectsCompanion project) {
    return into(projects).insertOnConflictUpdate(project);
  }

  Stream<List<Project>> watchProjects() {
    return select(projects).watch();
  }

  Future<int> deleteProject(String id) {
    return (delete(projects)..where((tbl) => tbl.id.equals(id))).go();
  }
}
