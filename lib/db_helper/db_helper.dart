import 'package:flutter/material.dart';
import 'package:todo/data/local/database/app_database.dart';
import 'package:todo/model/task_model.dart';
import 'package:todo/util/utils.dart';

class DbHelper {
  DbHelper._internal();

  static final DbHelper _instance = DbHelper._internal();

  factory DbHelper() => _instance;

  final AppDatabase _database = AppDatabase();
  late final TaskDao _taskDao = TaskDao(_database);
  late final CaptureSessionDao _captureSessionDao =
      CaptureSessionDao(_database);
  late final ParsedItemDao _parsedItemDao = ParsedItemDao(_database);

  CaptureSessionDao get captureSessions => _captureSessionDao;

  ParsedItemDao get parsedItems => _parsedItemDao;

  Future<TaskModel> insert(TaskModel model) async {
    await _taskDao.insertTask(model);
    return model;
  }

  Future<int> delete(String id, String table) async {
    final int result = await _taskDao.deleteTask(id);
    if (result > 0) {
      Utils.showSnackBar(
          'Deleted',
          'Task is removed successfully',
          const Icon(
            Icons.done,
            color: Colors.white,
            size: 16,
          ));
    }
    return result;
  }

  Future<int> update(String id, String key, String value) {
    if (key == 'status') {
      return _taskDao.updateTaskStatus(id, value);
    }
    throw UnimplementedError('Update for $key is not supported.');
  }

  Future<List<TaskModel>> getData() {
    return _taskDao.getAllTasks();
  }
}


