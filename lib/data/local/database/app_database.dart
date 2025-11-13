import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:todo/model/task_model.dart';

part 'app_database.g.dart';

class Tasks extends Table {
  TextColumn get key => text()();
  TextColumn get title => text()();
  TextColumn get category => text()();
  TextColumn get description => text()();
  TextColumn get image => text()();
  TextColumn get periority => text()();
  TextColumn get startTime => text()();
  TextColumn get endTime => text()();
  TextColumn get date => text()();
  TextColumn get show => text()();
  TextColumn get status => text()();

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

@DriftDatabase(
  tables: [Tasks, CaptureSessions, ParsedItems],
  daos: [TaskDao, CaptureSessionDao, ParsedItemDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File(p.join(directory.path, 'paper2todo.db'));
    return NativeDatabase.createInBackground(file);
  });
}

@DriftAccessor(tables: [Tasks])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  Future<void> insertTask(TaskModel model) {
    return into(tasks).insertOnConflictUpdate(
      TasksCompanion(
        key: Value(model.key!),
        title: Value(model.title!),
        category: Value(model.category!),
        description: Value(model.description!),
        image: Value(model.image!),
        periority: Value(model.periority!),
        startTime: Value(model.startTime!),
        endTime: Value(model.endTime!),
        date: Value(model.date!),
        show: Value(model.show!),
        status: Value(model.status!),
      ),
    );
  }

  Future<List<TaskModel>> getAllTasks() async {
    final List<Task> rows = await select(tasks).get();
    return rows
        .map((Task row) => TaskModel(
              key: row.key,
              startTime: row.startTime,
              endTime: row.endTime,
              date: row.date,
              periority: row.periority,
              description: row.description,
              category: row.category,
              title: row.title,
              image: row.image,
              show: row.show,
              status: row.status,
            ))
        .toList();
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
}
