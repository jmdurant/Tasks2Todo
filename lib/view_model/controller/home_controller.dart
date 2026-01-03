import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/data/local/database/app_database.dart';
import 'package:todo/db_helper/db_helper.dart';
import 'package:todo/model/task_model.dart';
import 'package:todo/util/utils.dart';
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

  RxInt barIndex = 0.obs;
  final ScrollController scrollController = ScrollController();
  final RxList<Project> projects = <Project>[].obs;
  StreamSubscription<List<Project>>? _projectSubscription;

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
  }

  @override
  void onClose() {
    _projectSubscription?.cancel();
    super.onClose();
  }












  getUserData() async {
    userData.value = await UserPref.getUser();
    getName();
  }
  getName() {
    name.value = userData['NAME'];
  }

  getTasks() async {
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

    // Update the reactive list once
    list.value = List.generate(7, (i) => grouped[i]!);
  }

  String _formatDate(int dayOffset) {
    final date = dateTime.add(Duration(days: dayOffset + weekOffset.value * 7));
    return '${Utils.addPrefix(date.day.toString())}/${Utils.addPrefix(date.month.toString())}/${date.year}';
  }

  setIndex(int value) {
    pageController.animateToPage(value,
        duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    currentIndex.value = value;
  }

  String getDateAccordingTabs(int value) {
    return _formatDate(value);
  }
  onMoveNextPage(){
    if(currentIndex.value<7){
      setIndex(currentIndex.value+1);
    }
  }
  onMoveBack(){
    if(currentIndex.value>0){
      setIndex(currentIndex.value-1);
    }
  }
  onTaskComplete(int value, int index, int ind, String key, BuildContext context) {
    switch (value) {
      case 3:
        {
          Utils.showWarningDialog(context, 'Complete Task',
              'This task will be marked as completed', 'Confirm', () {
            db.update(key, 'status', 'complete');
            // Update local state using copyWith
            final updatedDay = List<TaskModel>.from(list[ind]);
            updatedDay[index] = updatedDay[index].copyWith(status: 'complete');
            list[ind] = updatedDay;
          });
        }
      case 2:
        {
          Utils.showWarningDialog(context, 'Delete Task',
              'Are you want to sure to remove', 'Confirm', () {
            db.delete(key, 'Tasks');
            final updatedDay = List<TaskModel>.from(list[ind]);
            updatedDay.removeAt(index);
            list[ind] = updatedDay;
          });
        }
    }
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
      color: color.value,
    );
  }

  Future<void> deleteProject(String id) async {
    await db.deleteProject(id);
  }

}
