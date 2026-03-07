import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/data/local/database/app_database.dart';
import 'package:todo/db_helper/db_helper.dart';
import 'package:todo/model/task_model.dart';
import 'package:todo/util/recurrence.dart';
import 'package:todo/util/utils.dart';
import 'package:todo/view/home/task_detail_view.dart';
import 'package:todo/view_model/services/notification_service.dart';
import '../../data/shared pref/shared_pref.dart';

class HomeController extends GetxController {
  RxMap userData = {}.obs;
  RxString name = ''.obs;
  RxInt currentIndex = 0.obs;
  final PageController pageController = PageController();
  final DbHelper db = DbHelper();
  final DateTime dateTime = DateTime.now();
  RxInt weekOffset = 0.obs;

  // Flattened structure: single reactive list holding 7 day-lists
  final RxList<List<TaskModel>> list = <List<TaskModel>>[
    [], [], [], [], [], [], [],
  ].obs;

  // Filter state
  RxString filterPriority = 'All'.obs;
  RxString filterStatus = 'All'.obs;
  RxString filterTag = ''.obs;

  /// Returns the number of active filters
  int get activeFilterCount {
    int count = 0;
    if (filterPriority.value != 'All') count++;
    if (filterStatus.value != 'All') count++;
    if (filterTag.value.isNotEmpty) count++;
    return count;
  }

  /// Whether any filter is active
  bool get hasActiveFilters => activeFilterCount > 0;

  /// Returns the filtered task list for a given day index
  List<TaskModel> filteredTasksForDay(int dayIndex) {
    final dayTasks = list[dayIndex];
    if (!hasActiveFilters) return dayTasks;

    return dayTasks.where((task) {
      // Priority filter
      if (filterPriority.value != 'All' && task.periority != filterPriority.value) {
        return false;
      }
      // Status filter
      if (filterStatus.value != 'All') {
        if (filterStatus.value == 'Complete' && task.status != 'complete') {
          return false;
        }
        if (filterStatus.value == 'Incomplete' && task.status == 'complete') {
          return false;
        }
      }
      // Tag filter
      if (filterTag.value.isNotEmpty && !task.tagList.contains(filterTag.value)) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Reset all filters to defaults
  void resetFilters() {
    filterPriority.value = 'All';
    filterStatus.value = 'All';
    filterTag.value = '';
  }

  RxInt barIndex = 0.obs;
  final ScrollController scrollController = ScrollController();
  final RxList<Project> projects = <Project>[].obs;
  StreamSubscription<List<Project>>? _projectSubscription;
  final RxMap<String, int> taskCountsByProject = <String, int>{}.obs;
  StreamSubscription<Map<String, int>>? _taskCountsSubscription;

  /// Total count of all tasks across all days (for Inbox display)
  int get totalTaskCount => list.fold(0, (sum, dayList) => sum + dayList.length);

  void nextWeek() {
    weekOffset.value++;
    getTasks();
  }

  void previousWeek() {
    weekOffset.value--;
    getTasks();
  }

  DateTime getWeekStartDate() {
    return dateTime.add(Duration(days: weekOffset.value * 7));
  }


  @override
  void onInit() {
    super.onInit();
    if (userData['NAME'] == null) {
      getUserData();
    }
    getTasks();
    _projectSubscription = db.watchProjects().listen((event) {
      projects.assignAll(event);
    });
    _taskCountsSubscription = db.watchTaskCountsByProject().listen((counts) {
      taskCountsByProject.assignAll(counts);
    });
  }

  @override
  void onClose() {
    _projectSubscription?.cancel();
    _taskCountsSubscription?.cancel();
    super.onClose();
  }



  Future<void> getUserData() async {
    userData.value = await UserPref.getUser();
    getName();
  }

  void getName() {
    name.value = userData['NAME'];
  }

  Future<void> getTasks() async {
    // Build list of 7 date strings for the current week view
    final List<String> dates = List.generate(7, (i) => _formatDate(i));

    // Query only tasks matching these dates (filtered at DB level)
    final tasks = await db.getTasksForDates(dates);

    // Group tasks by day index in a single pass
    final Map<int, List<TaskModel>> grouped = {};
    for (int i = 0; i < 7; i++) {
      grouped[i] = [];
    }
    for (final task in tasks) {
      final dayIndex = dates.indexOf(task.date!);
      if (dayIndex >= 0) {
        grouped[dayIndex]!.add(task);
      }
    }

    // Sort each day by priority (High > Medium > Low), incomplete first
    const priorityOrder = {'High': 0, 'Medium': 1, 'Low': 2};
    for (final dayList in grouped.values) {
      dayList.sort((a, b) {
        // Incomplete tasks first
        if (a.status != b.status) {
          return a.status == 'complete' ? 1 : -1;
        }
        // Then by priority
        final pa = priorityOrder[a.periority] ?? 2;
        final pb = priorityOrder[b.periority] ?? 2;
        return pa.compareTo(pb);
      });
    }

    // Update the reactive list once
    list.value = List.generate(7, (i) => grouped[i]!);
  }

  String _formatDate(int dayOffset) {
    final date = dateTime.add(Duration(days: dayOffset + weekOffset.value * 7));
    return '${Utils.addPrefix(date.day.toString())}/${Utils.addPrefix(date.month.toString())}/${date.year}';
  }

  void setIndex(int value) {
    pageController.animateToPage(value,
        duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    currentIndex.value = value;
  }

  String getDateAccordingTabs(int value) {
    return _formatDate(value);
  }

  void onMoveNextPage() {
    if (currentIndex.value < 7) {
      setIndex(currentIndex.value + 1);
    }
  }

  void onMoveBack() {
    if (currentIndex.value > 0) {
      setIndex(currentIndex.value - 1);
    }
  }

  void onTaskComplete(int value, int index, int ind, String key, BuildContext context) {
    final task = list[ind][index];
    switch (value) {
      case 1:
        Get.to(() => TaskDetailView(task: task, dayIndex: ind));
      case 2:
        _deleteTaskWithUndo(task, index, ind, context);
      case 3:
        final newStatus = task.status == 'complete' ? 'unComplete' : 'complete';
        db.updateTaskStatus(key, newStatus);
        final updatedDay = List<TaskModel>.from(list[ind]);
        updatedDay[index] = updatedDay[index].copyWith(status: newStatus);
        list[ind] = updatedDay;
        // Handle recurring tasks: create next occurrence when completing
        if (newStatus == 'complete') {
          _handleRecurrence(task);
        }
    }
  }

  void _deleteTaskWithUndo(TaskModel task, int index, int ind, BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    // Remove from local state
    final updatedDay = List<TaskModel>.from(list[ind]);
    updatedDay.removeAt(index);
    list[ind] = updatedDay;

    // Delete from DB and cancel any reminder
    db.deleteTask(task.key!);
    NotificationService.instance.cancelTaskReminder(task.key!);

    // Show undo snackbar
    Get.showSnackbar(
      GetSnackBar(
        backgroundColor: scheme.inverseSurface,
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.BOTTOM,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        titleText: Text(
          'Task deleted',
          style: TextStyle(
            color: scheme.onInverseSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        messageText: Text(
          '"${task.title}" was removed',
          style: TextStyle(color: scheme.onInverseSurface),
          overflow: TextOverflow.ellipsis,
        ),
        mainButton: TextButton(
          onPressed: () {
            Get.closeCurrentSnackbar();
            db.insert(task);
            getTasks();
          },
          child: Text(
            'UNDO',
            style: TextStyle(
              color: scheme.inversePrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }


  Future<void> _handleRecurrence(TaskModel completedTask) async {
    final nextTask = RecurrenceHelper.createNextOccurrence(completedTask);
    if (nextTask == null) return;
    await db.insert(nextTask);
    // Schedule reminder for the new occurrence if it has one
    if (nextTask.hasReminder) {
      NotificationService.instance.scheduleTaskReminder(nextTask);
    }
    getTasks();
  }

  Future<void> createProject({
    required String name,
    String? description,
    required Color color,
  }) async {
    final String id = DateTime.now().microsecondsSinceEpoch.toString();
    await db.addProject(
      id: id,
      name: name,
      description: description?.trim().isEmpty ?? true ? null : description,
      color: color.toARGB32(),
    );
  }

  Future<void> deleteProject(String id) async {
    await db.deleteProject(id);
  }

}
