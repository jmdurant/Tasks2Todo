import 'dart:core';

class TaskModel {
  String? key;
  String? title;
  String? category;
  String? description;
  String? image;
  String? periority;
  String? startTime;
  String? endTime;
  String? date;
  String? show;
  String? status;
  String? tags; // Comma-separated list of tags
  String? recurrence; // 'none', 'daily', 'weekly', 'monthly'
  int? reminderMinutesBefore; // -1 = no reminder, 0 = at time, 15 = 15 min before, etc.

  TaskModel({
    required this.key,
    required this.startTime,
    required this.endTime,
    required this.date,
    required this.periority,
    required this.description,
    required this.category,
    required this.title,
    required this.image,
    required this.show,
    required this.status,
    this.tags,
    this.recurrence = 'none',
    this.reminderMinutesBefore = -1,
  });

  TaskModel.fromMap(Map<String, dynamic> res) {
    key = res['key'];
    title = res['title'];
    category = res['category'];
    description = res['description'];
    image = res['image'];
    periority = res['periority'];
    show = res['show'];
    startTime = res['startTime'];
    endTime = res['endTime'];
    date = res['date'];
    status = res['status'];
    tags = res['tags'];
    recurrence = res['recurrence'] ?? 'none';
    reminderMinutesBefore = res['reminderMinutesBefore'] ?? -1;
  }

  Map<String, Object?> toMap() {
    return {
      'key': key,
      'title': title,
      'category': category,
      'description': description,
      'image': image,
      'periority': periority,
      'startTime': startTime,
      'endTime': endTime,
      'date': date,
      'show': show,
      'status': status,
      'tags': tags,
      'recurrence': recurrence,
      'reminderMinutesBefore': reminderMinutesBefore,
    };
  }

  TaskModel copyWith({
    String? key,
    String? title,
    String? category,
    String? description,
    String? image,
    String? periority,
    String? startTime,
    String? endTime,
    String? date,
    String? show,
    String? status,
    String? tags,
    String? recurrence,
    int? reminderMinutesBefore,
  }) {
    return TaskModel(
      key: key ?? this.key,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      image: image ?? this.image,
      periority: periority ?? this.periority,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      date: date ?? this.date,
      show: show ?? this.show,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      recurrence: recurrence ?? this.recurrence,
      reminderMinutesBefore: reminderMinutesBefore ?? this.reminderMinutesBefore,
    );
  }

  /// Helper to get tags as a list
  List<String> get tagList =>
      tags?.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList() ?? [];

  /// Helper to set tags from a list
  set tagList(List<String> list) => tags = list.join(',');

  /// Whether this task has a recurrence set
  bool get isRecurring => recurrence != null && recurrence != 'none';

  /// Whether this task has a reminder set
  bool get hasReminder => reminderMinutesBefore != null && reminderMinutesBefore! >= 0;
}
