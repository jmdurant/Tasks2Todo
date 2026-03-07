import 'package:drift/drift.dart' show Value;
import 'package:todo/data/local/database/app_database.dart';
import 'package:todo/model/task_model.dart';

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
}
