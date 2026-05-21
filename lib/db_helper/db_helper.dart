import 'package:drift/drift.dart' show Value;
import 'package:todo/data/local/database/app_database.dart';
import 'package:todo/model/task_model.dart';
import 'package:todo/util/paper2todo_payload.dart';

class DbHelper {
  DbHelper._internal();

  static final DbHelper _instance = DbHelper._internal();

  factory DbHelper() => _instance;

  final AppDatabase _database = AppDatabase();
  late final TaskDao _taskDao = TaskDao(_database);
  late final CaptureSessionDao _captureSessionDao =
      CaptureSessionDao(_database);
  late final ParsedItemDao _parsedItemDao = ParsedItemDao(_database);
  late final ProjectDao _projectDao = ProjectDao(_database);

  CaptureSessionDao get captureSessions => _captureSessionDao;

  ParsedItemDao get parsedItems => _parsedItemDao;
  ProjectDao get projects => _projectDao;

  Future<TaskModel> insert(TaskModel model) async {
    await _taskDao.insertTask(model);
    return model;
  }

  Future<void> insertAll(List<TaskModel> models) async {
    if (models.isEmpty) return;
    await _taskDao.insertAllTasks(models);
  }

  Future<int> deleteTask(String id) async {
    return _taskDao.deleteTask(id);
  }

  Future<int> updateTaskStatus(String id, String status) {
    return _taskDao.updateTaskStatus(id, status);
  }

  Future<List<TaskModel>> getData() {
    return _taskDao.getAllTasks();
  }

  Future<List<TaskModel>> getTasksForDates(List<String> dates) {
    return _taskDao.getTasksForDates(dates);
  }

  Future<List<TaskModel>> getTasksForProject(String projectName) {
    return _taskDao.getTasksForProject(projectName);
  }

  Future<Map<String, List<TaskModel>>> getAllTasksGroupedByProject() {
    return _taskDao.getAllTasksGroupedByProject();
  }

  Stream<Map<String, List<TaskModel>>> watchAllTasksGroupedByProject() {
    return _taskDao.watchAllTasksGroupedByProject();
  }

  Future<int> countTasksForProject(String projectName) {
    return _taskDao.countTasksForProject(projectName);
  }

  Stream<Map<String, int>> watchTaskCountsByProject() {
    return _taskDao.watchTaskCountsByProject();
  }

  Future<void> addProject({
    required String id,
    required String name,
    String? description,
    required int color,
  }) {
    return _projectDao.insertProject(
      ProjectsCompanion(
        id: Value(id),
        name: Value(name),
        description: Value(description),
        color: Value(color),
      ),
    );
  }

  Stream<List<Project>> watchProjects() {
    return _projectDao.watchProjects();
  }

  Future<void> deleteProject(String id) {
    return _projectDao.deleteProject(id);
  }

  Future<List<TaskModel>> searchTasks(String query) {
    return _taskDao.searchTasks(query);
  }

  Future<List<TaskModel>> getTasksWithReminders() {
    return _taskDao.getTasksWithReminders();
  }

  // ─── Firebase sync ─────────────────────────────────────────────────────

  /// All rows including tombstones — the push side of sync.
  Future<List<TaskModel>> getAllTasksForSync() {
    return _taskDao.getAllTasksForSync();
  }

  /// Apply a row pulled from the cloud (last-write-wins). Returns true if the
  /// local row actually changed.
  Future<bool> applyRemoteTask(TaskModel remote) {
    return _taskDao.applyRemoteTask(remote);
  }

  /// Reactive all-rows stream (incl. tombstones) for the live-sync push.
  Stream<List<TaskModel>> watchAllTasksForSync() {
    return _taskDao.watchAllTasksForSync();
  }

  /// GC tombstones older than [cutoffMillis].
  Future<int> pruneTombstones(int cutoffMillis) {
    return _taskDao.pruneTombstones(cutoffMillis);
  }

  // ─── Paper2Todo Inbox ──────────────────────────────────────────────────

  /// Persist a paper2todo capture payload into the local CaptureSessions /
  /// ParsedItems tables. The Inbox view streams from these directly.
  Future<void> insertPaper2TodoCapture(Paper2TodoPayload payload) async {
    await _captureSessionDao.upsertSession(
      CaptureSessionsCompanion(
        id: Value(payload.sessionId),
        capturedAt: Value(payload.capturedAt),
        // We don't carry the image across processes — leave the path empty
        // so the Inbox card can render "no preview" without erroring.
        imageFilePath: const Value(''),
        syncStatus: const Value('pending'),
      ),
    );

    if (payload.items.isEmpty) return;
    await _parsedItemDao.upsertItems(payload.items.map((item) {
      return ParsedItemsCompanion(
        id: Value(item.id),
        sessionId: Value(payload.sessionId),
        type: Value(item.type),
        content: Value(item.content),
        tags: Value(item.tags.join(',')),
        dueDate: Value(item.dueDate),
        dueTime: Value(item.dueTime),
        priority: Value(item.priority),
        location: Value(item.location),
        parentProject: Value(item.parentProject),
        status: Value(item.status),
        confidence: Value(item.confidence),
        note: Value(item.note),
      );
    }).toList());
  }

  /// Streams every parsed item that hasn't been promoted to a Task yet.
  Stream<List<ParsedItem>> watchInboxItems() {
    return _parsedItemDao.watchPendingItems();
  }

  /// Streams capture sessions; consumers join with [watchInboxItems] to
  /// render headers per capture.
  Stream<List<CaptureSession>> watchCaptureSessions() {
    return _database.select(_database.captureSessions).watch();
  }

  /// Streams pending items joined with their capture session, ordered
  /// newest-capture-first. The UI groups these by `sessionId` so missed-day
  /// captures stay distinct from today's.
  Stream<List<({CaptureSession session, ParsedItem item})>>
      watchInboxGroupedBySession() {
    return _database.watchPendingInboxJoined();
  }

  /// Reject a single inbox item without promoting it.
  Future<int> rejectInboxItem(String id) {
    return _parsedItemDao.deleteItem(id);
  }

  /// Mark an inbox item as promoted: writes [taskKey] into its externalId so
  /// the stream filter hides it.
  Future<int> markInboxItemPromoted(String id, String taskKey) {
    return _parsedItemDao.markPromoted(id, taskKey);
  }
}
