import 'dart:core';

class TaskModel {
  String? key;
  String? title;
  String? category;
  String? description;
  String? image;
  String? priority;
  String? startTime;
  String? endTime;
  String? date;
  String? show;
  String? status;
  String? tags; // Comma-separated list of tags
  String? recurrence; // 'none', 'daily', 'weekly', 'monthly'
  int? reminderMinutesBefore; // -1 = no reminder, 0 = at time, 15 = 15 min before, etc.
  int? notificationId; // Stable 31-bit id used to schedule/cancel the reminder.
  int? updatedAt; // Epoch millis of last mutation (Firebase sync LWW key).
  bool deleted; // Soft-delete tombstone.

  TaskModel({
    required this.key,
    required this.startTime,
    required this.endTime,
    required this.date,
    required this.priority,
    required this.description,
    required this.category,
    required this.title,
    required this.image,
    required this.show,
    required this.status,
    this.tags,
    this.recurrence = 'none',
    this.reminderMinutesBefore = -1,
    this.notificationId,
    this.updatedAt,
    this.deleted = false,
  });

  TaskModel.fromMap(Map<String, dynamic> res)
      : deleted = res['deleted'] == true || res['deleted'] == 1 {
    key = res['key'];
    title = res['title'];
    category = res['category'];
    description = res['description'];
    image = res['image'];
    priority = res['priority'];
    show = res['show'];
    startTime = res['startTime'];
    endTime = res['endTime'];
    date = res['date'];
    status = res['status'];
    tags = res['tags'];
    recurrence = res['recurrence'] ?? 'none';
    reminderMinutesBefore = res['reminderMinutesBefore'] ?? -1;
    notificationId = res['notificationId'];
    updatedAt = res['updatedAt'];
  }

  Map<String, Object?> toMap() {
    return {
      'key': key,
      'title': title,
      'category': category,
      'description': description,
      'image': image,
      'priority': priority,
      'startTime': startTime,
      'endTime': endTime,
      'date': date,
      'show': show,
      'status': status,
      'tags': tags,
      'recurrence': recurrence,
      'reminderMinutesBefore': reminderMinutesBefore,
      'notificationId': notificationId,
      'updatedAt': updatedAt,
      'deleted': deleted,
    };
  }

  TaskModel copyWith({
    String? key,
    String? title,
    String? category,
    String? description,
    String? image,
    String? priority,
    String? startTime,
    String? endTime,
    String? date,
    String? show,
    String? status,
    String? tags,
    String? recurrence,
    int? reminderMinutesBefore,
    int? notificationId,
    int? updatedAt,
    bool? deleted,
  }) {
    return TaskModel(
      key: key ?? this.key,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      image: image ?? this.image,
      priority: priority ?? this.priority,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      date: date ?? this.date,
      show: show ?? this.show,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      recurrence: recurrence ?? this.recurrence,
      reminderMinutesBefore: reminderMinutesBefore ?? this.reminderMinutesBefore,
      notificationId: notificationId ?? this.notificationId,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
    );
  }

  /// Serialize for Firebase RTDB. Booleans/ints map cleanly to JSON.
  Map<String, Object?> toSyncJson() => toMap();

  factory TaskModel.fromSyncJson(Map<String, dynamic> json) =>
      TaskModel.fromMap(json);

  /// Helper to get tags as a list
  List<String> get tagList =>
      tags?.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList() ?? [];

  /// Helper to set tags from a list
  set tagList(List<String> list) => tags = list.join(',');

  bool get isRecurring => recurrence != null && recurrence != 'none';

  bool get hasReminder => reminderMinutesBefore != null && reminderMinutesBefore! >= 0;
}
