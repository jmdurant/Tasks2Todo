import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/data/local/database/app_database.dart';
import 'package:todo/db_helper/db_helper.dart';
import 'package:todo/model/task_model.dart';
import 'package:todo/util/utils.dart';
import 'package:todo/view_model/controller/home_controller.dart';

class NewTaskController extends GetxController {
  DateTime? pickedDate;
  final DbHelper db = DbHelper();
  RxInt selectedImage = (-1).obs;
  RxString selectedPriority = 'Low'.obs;
  RxBool labelFocus = false.obs;
  RxBool categoryFocus = false.obs;
  RxBool descriptionFocus = false.obs;
  RxString selectedDate = ''.obs;
  RxString startTime = ''.obs;
  RxString endTime = ''.obs;
  RxBool loading = false.obs;
  final HomeController homeController = Get.put(HomeController());
  final label = TextEditingController().obs;
  final description = TextEditingController().obs;
  final category = TextEditingController().obs;

  // Project management
  RxList<String> availableProjects = <String>['Inbox'].obs;
  RxString selectedProject = 'Inbox'.obs;

  void setSelectedProject(String project) {
    selectedProject.value = project;
    category.value.text = project; // Keep category in sync for database
  }

  void syncProjects(List<Project> projects) {
    final names = <String>['Inbox'];
    names.addAll(projects.map((p) => p.name).whereType<String>());
    availableProjects.value = names.toSet().toList();
    if (!availableProjects.contains(selectedProject.value)) {
      setSelectedProject('Inbox');
    }
  }

  @override
  void onInit() {
    super.onInit();
    syncProjects(homeController.projects);
    ever<List<Project>>(homeController.projects, (projList) {
      syncProjects(projList);
    });
  }

  picStartTime(BuildContext context) async {
    var picker =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picker != null) {
      startTime.value =
          '${Utils.addPrefix(picker.hourOfPeriod.toString())}:${Utils.addPrefix(picker.minute.toString())}:${picker.period.name.toUpperCase()}';
    }
  }
  picEndTime(BuildContext context) async {
    var picker =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picker != null) {
      endTime.value =
          '${Utils.addPrefix(picker.hourOfPeriod.toString())}:${Utils.addPrefix(picker.minute.toString())}:${picker.period.name.toUpperCase()}';
    }
  }
  showDatePick(BuildContext context) async {
    var picker = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 7)));
    if (picker != null) {
      pickedDate=picker;
      selectedDate.value =
          '${Utils.addPrefix(picker.day.toString())}/${Utils.addPrefix(picker.month.toString())}/${picker.year}';
    }
  }
  changeImage(int index) {
    selectedImage.value = index;
  }
  setLabelFocus() {
    labelFocus.value = true;
    categoryFocus.value = false;
    descriptionFocus.value = false;
  }
  setCategoryFocus() {
    labelFocus.value = false;
    categoryFocus.value = true;
    descriptionFocus.value = false;
  }
  setDescriptionFocus() {
    labelFocus.value = false;
    categoryFocus.value = false;
    descriptionFocus.value = true;
  }
  onTapOutside() {
    labelFocus.value = false;
    categoryFocus.value = false;
    descriptionFocus.value = false;
  }
  insertTask(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    if (label.value.text.toString().isEmpty) {
      Utils.showSnackBar(
        'Warning',
        'Enter valid label',
        Icon(
          Icons.warning_amber_rounded,
          color: scheme.error,
        ),
      );
      return;
    }
    if (category.value.text.toString().isEmpty) {
      Utils.showSnackBar(
        'Warning',
        'Select a Project',
        Icon(
          Icons.warning_amber_rounded,
          color: scheme.error,
        ),
      );
      return;
    }
    if (selectedDate.isEmpty) {
      // selectedDate.value =
      //     '${Utils.addPrefix(DateTime.now().day.toString())}/${Utils.addPrefix(DateTime.now().month.toString())}/${Utils.addPrefix(DateTime.now().year.toString())}';
      showDatePick(context);
    }
    if (startTime.isEmpty) {
      picStartTime(context);
      return;
    }
    if (endTime.isEmpty) {
      picEndTime(context);
      return;
    }
    loading.value = true;

    db.insert(TaskModel(
        key: DateTime.now().microsecondsSinceEpoch.toString(),
        startTime: startTime.value,
        endTime: endTime.value,
        date: selectedDate.value,
        periority: selectedPriority.value,
        description: description.value.text.toString(),
        category: category.value.text.toString(),
        title: label.value.text.toString(),
        image: selectedImage.value >= 0 ? selectedImage.value.toString() : '',
        show: 'yes',
        status: 'unComplete'))
        .then((value) {

          // homeController.getTasks();

      Duration dif=pickedDate!.difference(DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day));
      homeController.list[dif.inDays].add(value);
      Timer(const Duration(seconds: 1), () {
        loading.value = false;
        Get.back();
        Utils.showSnackBar(
          'Successful',
          'Task is created',
          Icon(
            Icons.done,
            color: scheme.onPrimary,
          ),
        );
      });
    });
  }
}
