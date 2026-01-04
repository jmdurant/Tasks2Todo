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
    );
  }

  /// Helper to get tags as a list
  List<String> get tagList =>
      tags?.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList() ?? [];

  /// Helper to set tags from a list
  set tagList(List<String> list) => tags = list.join(',');
}