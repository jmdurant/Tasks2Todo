// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imageMeta = const VerificationMeta('image');
  @override
  late final GeneratedColumn<String> image = GeneratedColumn<String>(
      'image', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _periorityMeta =
      const VerificationMeta('periority');
  @override
  late final GeneratedColumn<String> periority = GeneratedColumn<String>(
      'periority', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
      'start_time', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<String> endTime = GeneratedColumn<String>(
      'end_time', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _showMeta = const VerificationMeta('show');
  @override
  late final GeneratedColumn<String> show = GeneratedColumn<String>(
      'show', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        key,
        title,
        category,
        description,
        image,
        periority,
        startTime,
        endTime,
        date,
        show,
        status
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(Insertable<Task> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('image')) {
      context.handle(
          _imageMeta, image.isAcceptableOrUnknown(data['image']!, _imageMeta));
    } else if (isInserting) {
      context.missing(_imageMeta);
    }
    if (data.containsKey('periority')) {
      context.handle(_periorityMeta,
          periority.isAcceptableOrUnknown(data['periority']!, _periorityMeta));
    } else if (isInserting) {
      context.missing(_periorityMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('show')) {
      context.handle(
          _showMeta, show.isAcceptableOrUnknown(data['show']!, _showMeta));
    } else if (isInserting) {
      context.missing(_showMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      image: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image'])!,
      periority: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}periority'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}start_time'])!,
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}end_time'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      show: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}show'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final String key;
  final String title;
  final String category;
  final String description;
  final String image;
  final String periority;
  final String startTime;
  final String endTime;
  final String date;
  final String show;
  final String status;
  const Task(
      {required this.key,
      required this.title,
      required this.category,
      required this.description,
      required this.image,
      required this.periority,
      required this.startTime,
      required this.endTime,
      required this.date,
      required this.show,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['title'] = Variable<String>(title);
    map['category'] = Variable<String>(category);
    map['description'] = Variable<String>(description);
    map['image'] = Variable<String>(image);
    map['periority'] = Variable<String>(periority);
    map['start_time'] = Variable<String>(startTime);
    map['end_time'] = Variable<String>(endTime);
    map['date'] = Variable<String>(date);
    map['show'] = Variable<String>(show);
    map['status'] = Variable<String>(status);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      key: Value(key),
      title: Value(title),
      category: Value(category),
      description: Value(description),
      image: Value(image),
      periority: Value(periority),
      startTime: Value(startTime),
      endTime: Value(endTime),
      date: Value(date),
      show: Value(show),
      status: Value(status),
    );
  }

  factory Task.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      key: serializer.fromJson<String>(json['key']),
      title: serializer.fromJson<String>(json['title']),
      category: serializer.fromJson<String>(json['category']),
      description: serializer.fromJson<String>(json['description']),
      image: serializer.fromJson<String>(json['image']),
      periority: serializer.fromJson<String>(json['periority']),
      startTime: serializer.fromJson<String>(json['startTime']),
      endTime: serializer.fromJson<String>(json['endTime']),
      date: serializer.fromJson<String>(json['date']),
      show: serializer.fromJson<String>(json['show']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'title': serializer.toJson<String>(title),
      'category': serializer.toJson<String>(category),
      'description': serializer.toJson<String>(description),
      'image': serializer.toJson<String>(image),
      'periority': serializer.toJson<String>(periority),
      'startTime': serializer.toJson<String>(startTime),
      'endTime': serializer.toJson<String>(endTime),
      'date': serializer.toJson<String>(date),
      'show': serializer.toJson<String>(show),
      'status': serializer.toJson<String>(status),
    };
  }

  Task copyWith(
          {String? key,
          String? title,
          String? category,
          String? description,
          String? image,
          String? periority,
          String? startTime,
          String? endTime,
          String? date,
          String? show,
          String? status}) =>
      Task(
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
      );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      key: data.key.present ? data.key.value : this.key,
      title: data.title.present ? data.title.value : this.title,
      category: data.category.present ? data.category.value : this.category,
      description:
          data.description.present ? data.description.value : this.description,
      image: data.image.present ? data.image.value : this.image,
      periority: data.periority.present ? data.periority.value : this.periority,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      date: data.date.present ? data.date.value : this.date,
      show: data.show.present ? data.show.value : this.show,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('key: $key, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('image: $image, ')
          ..write('periority: $periority, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('date: $date, ')
          ..write('show: $show, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, title, category, description, image,
      periority, startTime, endTime, date, show, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.key == this.key &&
          other.title == this.title &&
          other.category == this.category &&
          other.description == this.description &&
          other.image == this.image &&
          other.periority == this.periority &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.date == this.date &&
          other.show == this.show &&
          other.status == this.status);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<String> key;
  final Value<String> title;
  final Value<String> category;
  final Value<String> description;
  final Value<String> image;
  final Value<String> periority;
  final Value<String> startTime;
  final Value<String> endTime;
  final Value<String> date;
  final Value<String> show;
  final Value<String> status;
  final Value<int> rowid;
  const TasksCompanion({
    this.key = const Value.absent(),
    this.title = const Value.absent(),
    this.category = const Value.absent(),
    this.description = const Value.absent(),
    this.image = const Value.absent(),
    this.periority = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.date = const Value.absent(),
    this.show = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String key,
    required String title,
    required String category,
    required String description,
    required String image,
    required String periority,
    required String startTime,
    required String endTime,
    required String date,
    required String show,
    required String status,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        title = Value(title),
        category = Value(category),
        description = Value(description),
        image = Value(image),
        periority = Value(periority),
        startTime = Value(startTime),
        endTime = Value(endTime),
        date = Value(date),
        show = Value(show),
        status = Value(status);
  static Insertable<Task> custom({
    Expression<String>? key,
    Expression<String>? title,
    Expression<String>? category,
    Expression<String>? description,
    Expression<String>? image,
    Expression<String>? periority,
    Expression<String>? startTime,
    Expression<String>? endTime,
    Expression<String>? date,
    Expression<String>? show,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (title != null) 'title': title,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (image != null) 'image': image,
      if (periority != null) 'periority': periority,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (date != null) 'date': date,
      if (show != null) 'show': show,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith(
      {Value<String>? key,
      Value<String>? title,
      Value<String>? category,
      Value<String>? description,
      Value<String>? image,
      Value<String>? periority,
      Value<String>? startTime,
      Value<String>? endTime,
      Value<String>? date,
      Value<String>? show,
      Value<String>? status,
      Value<int>? rowid}) {
    return TasksCompanion(
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
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (image.present) {
      map['image'] = Variable<String>(image.value);
    }
    if (periority.present) {
      map['periority'] = Variable<String>(periority.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<String>(endTime.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (show.present) {
      map['show'] = Variable<String>(show.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('key: $key, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('image: $image, ')
          ..write('periority: $periority, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('date: $date, ')
          ..write('show: $show, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CaptureSessionsTable extends CaptureSessions
    with TableInfo<$CaptureSessionsTable, CaptureSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CaptureSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _capturedAtMeta =
      const VerificationMeta('capturedAt');
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
      'captured_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _imageFilePathMeta =
      const VerificationMeta('imageFilePath');
  @override
  late final GeneratedColumn<String> imageFilePath = GeneratedColumn<String>(
      'image_file_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _syncErrorMeta =
      const VerificationMeta('syncError');
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
      'sync_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _rawVisionResponseMeta =
      const VerificationMeta('rawVisionResponse');
  @override
  late final GeneratedColumn<String> rawVisionResponse =
      GeneratedColumn<String>('raw_vision_response', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, capturedAt, imageFilePath, syncStatus, syncError, rawVisionResponse];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'capture_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<CaptureSession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('captured_at')) {
      context.handle(
          _capturedAtMeta,
          capturedAt.isAcceptableOrUnknown(
              data['captured_at']!, _capturedAtMeta));
    }
    if (data.containsKey('image_file_path')) {
      context.handle(
          _imageFilePathMeta,
          imageFilePath.isAcceptableOrUnknown(
              data['image_file_path']!, _imageFilePathMeta));
    } else if (isInserting) {
      context.missing(_imageFilePathMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    } else if (isInserting) {
      context.missing(_syncStatusMeta);
    }
    if (data.containsKey('sync_error')) {
      context.handle(_syncErrorMeta,
          syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta));
    }
    if (data.containsKey('raw_vision_response')) {
      context.handle(
          _rawVisionResponseMeta,
          rawVisionResponse.isAcceptableOrUnknown(
              data['raw_vision_response']!, _rawVisionResponseMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CaptureSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CaptureSession(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      capturedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}captured_at'])!,
      imageFilePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}image_file_path'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      syncError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_error']),
      rawVisionResponse: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}raw_vision_response']),
    );
  }

  @override
  $CaptureSessionsTable createAlias(String alias) {
    return $CaptureSessionsTable(attachedDatabase, alias);
  }
}

class CaptureSession extends DataClass implements Insertable<CaptureSession> {
  final String id;
  final DateTime capturedAt;
  final String imageFilePath;
  final String syncStatus;
  final String? syncError;
  final String? rawVisionResponse;
  const CaptureSession(
      {required this.id,
      required this.capturedAt,
      required this.imageFilePath,
      required this.syncStatus,
      this.syncError,
      this.rawVisionResponse});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['captured_at'] = Variable<DateTime>(capturedAt);
    map['image_file_path'] = Variable<String>(imageFilePath);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    if (!nullToAbsent || rawVisionResponse != null) {
      map['raw_vision_response'] = Variable<String>(rawVisionResponse);
    }
    return map;
  }

  CaptureSessionsCompanion toCompanion(bool nullToAbsent) {
    return CaptureSessionsCompanion(
      id: Value(id),
      capturedAt: Value(capturedAt),
      imageFilePath: Value(imageFilePath),
      syncStatus: Value(syncStatus),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
      rawVisionResponse: rawVisionResponse == null && nullToAbsent
          ? const Value.absent()
          : Value(rawVisionResponse),
    );
  }

  factory CaptureSession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CaptureSession(
      id: serializer.fromJson<String>(json['id']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      imageFilePath: serializer.fromJson<String>(json['imageFilePath']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      syncError: serializer.fromJson<String?>(json['syncError']),
      rawVisionResponse:
          serializer.fromJson<String?>(json['rawVisionResponse']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'imageFilePath': serializer.toJson<String>(imageFilePath),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'syncError': serializer.toJson<String?>(syncError),
      'rawVisionResponse': serializer.toJson<String?>(rawVisionResponse),
    };
  }

  CaptureSession copyWith(
          {String? id,
          DateTime? capturedAt,
          String? imageFilePath,
          String? syncStatus,
          Value<String?> syncError = const Value.absent(),
          Value<String?> rawVisionResponse = const Value.absent()}) =>
      CaptureSession(
        id: id ?? this.id,
        capturedAt: capturedAt ?? this.capturedAt,
        imageFilePath: imageFilePath ?? this.imageFilePath,
        syncStatus: syncStatus ?? this.syncStatus,
        syncError: syncError.present ? syncError.value : this.syncError,
        rawVisionResponse: rawVisionResponse.present
            ? rawVisionResponse.value
            : this.rawVisionResponse,
      );
  CaptureSession copyWithCompanion(CaptureSessionsCompanion data) {
    return CaptureSession(
      id: data.id.present ? data.id.value : this.id,
      capturedAt:
          data.capturedAt.present ? data.capturedAt.value : this.capturedAt,
      imageFilePath: data.imageFilePath.present
          ? data.imageFilePath.value
          : this.imageFilePath,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
      rawVisionResponse: data.rawVisionResponse.present
          ? data.rawVisionResponse.value
          : this.rawVisionResponse,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CaptureSession(')
          ..write('id: $id, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('imageFilePath: $imageFilePath, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('rawVisionResponse: $rawVisionResponse')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, capturedAt, imageFilePath, syncStatus, syncError, rawVisionResponse);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CaptureSession &&
          other.id == this.id &&
          other.capturedAt == this.capturedAt &&
          other.imageFilePath == this.imageFilePath &&
          other.syncStatus == this.syncStatus &&
          other.syncError == this.syncError &&
          other.rawVisionResponse == this.rawVisionResponse);
}

class CaptureSessionsCompanion extends UpdateCompanion<CaptureSession> {
  final Value<String> id;
  final Value<DateTime> capturedAt;
  final Value<String> imageFilePath;
  final Value<String> syncStatus;
  final Value<String?> syncError;
  final Value<String?> rawVisionResponse;
  final Value<int> rowid;
  const CaptureSessionsCompanion({
    this.id = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.imageFilePath = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.rawVisionResponse = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CaptureSessionsCompanion.insert({
    required String id,
    this.capturedAt = const Value.absent(),
    required String imageFilePath,
    required String syncStatus,
    this.syncError = const Value.absent(),
    this.rawVisionResponse = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        imageFilePath = Value(imageFilePath),
        syncStatus = Value(syncStatus);
  static Insertable<CaptureSession> custom({
    Expression<String>? id,
    Expression<DateTime>? capturedAt,
    Expression<String>? imageFilePath,
    Expression<String>? syncStatus,
    Expression<String>? syncError,
    Expression<String>? rawVisionResponse,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (imageFilePath != null) 'image_file_path': imageFilePath,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncError != null) 'sync_error': syncError,
      if (rawVisionResponse != null) 'raw_vision_response': rawVisionResponse,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CaptureSessionsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? capturedAt,
      Value<String>? imageFilePath,
      Value<String>? syncStatus,
      Value<String?>? syncError,
      Value<String?>? rawVisionResponse,
      Value<int>? rowid}) {
    return CaptureSessionsCompanion(
      id: id ?? this.id,
      capturedAt: capturedAt ?? this.capturedAt,
      imageFilePath: imageFilePath ?? this.imageFilePath,
      syncStatus: syncStatus ?? this.syncStatus,
      syncError: syncError ?? this.syncError,
      rawVisionResponse: rawVisionResponse ?? this.rawVisionResponse,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (imageFilePath.present) {
      map['image_file_path'] = Variable<String>(imageFilePath.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    if (rawVisionResponse.present) {
      map['raw_vision_response'] = Variable<String>(rawVisionResponse.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CaptureSessionsCompanion(')
          ..write('id: $id, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('imageFilePath: $imageFilePath, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('rawVisionResponse: $rawVisionResponse, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ParsedItemsTable extends ParsedItems
    with TableInfo<$ParsedItemsTable, ParsedItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ParsedItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES capture_sessions (id) ON DELETE CASCADE'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<String> dueDate = GeneratedColumn<String>(
      'due_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dueTimeMeta =
      const VerificationMeta('dueTime');
  @override
  late final GeneratedColumn<String> dueTime = GeneratedColumn<String>(
      'due_time', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
      'priority', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _parentProjectMeta =
      const VerificationMeta('parentProject');
  @override
  late final GeneratedColumn<String> parentProject = GeneratedColumn<String>(
      'parent_project', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _confidenceMeta =
      const VerificationMeta('confidence');
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
      'confidence', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _externalIdMeta =
      const VerificationMeta('externalId');
  @override
  late final GeneratedColumn<String> externalId = GeneratedColumn<String>(
      'external_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sessionId,
        type,
        content,
        tags,
        dueDate,
        dueTime,
        priority,
        location,
        parentProject,
        status,
        confidence,
        note,
        externalId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parsed_items';
  @override
  VerificationContext validateIntegrity(Insertable<ParsedItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('due_time')) {
      context.handle(_dueTimeMeta,
          dueTime.isAcceptableOrUnknown(data['due_time']!, _dueTimeMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    }
    if (data.containsKey('parent_project')) {
      context.handle(
          _parentProjectMeta,
          parentProject.isAcceptableOrUnknown(
              data['parent_project']!, _parentProjectMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
          _confidenceMeta,
          confidence.isAcceptableOrUnknown(
              data['confidence']!, _confidenceMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('external_id')) {
      context.handle(
          _externalIdMeta,
          externalId.isAcceptableOrUnknown(
              data['external_id']!, _externalIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ParsedItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ParsedItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags']),
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}due_date']),
      dueTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}due_time']),
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}priority'])!,
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location']),
      parentProject: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_project']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      confidence: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}confidence']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      externalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}external_id']),
    );
  }

  @override
  $ParsedItemsTable createAlias(String alias) {
    return $ParsedItemsTable(attachedDatabase, alias);
  }
}

class ParsedItem extends DataClass implements Insertable<ParsedItem> {
  final String id;
  final String sessionId;
  final String type;
  final String content;
  final String? tags;
  final String? dueDate;
  final String? dueTime;
  final String priority;
  final String? location;
  final String? parentProject;
  final String status;
  final double? confidence;
  final String? note;
  final String? externalId;
  const ParsedItem(
      {required this.id,
      required this.sessionId,
      required this.type,
      required this.content,
      this.tags,
      this.dueDate,
      this.dueTime,
      required this.priority,
      this.location,
      this.parentProject,
      required this.status,
      this.confidence,
      this.note,
      this.externalId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['type'] = Variable<String>(type);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<String>(dueDate);
    }
    if (!nullToAbsent || dueTime != null) {
      map['due_time'] = Variable<String>(dueTime);
    }
    map['priority'] = Variable<String>(priority);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || parentProject != null) {
      map['parent_project'] = Variable<String>(parentProject);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || externalId != null) {
      map['external_id'] = Variable<String>(externalId);
    }
    return map;
  }

  ParsedItemsCompanion toCompanion(bool nullToAbsent) {
    return ParsedItemsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      type: Value(type),
      content: Value(content),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      dueTime: dueTime == null && nullToAbsent
          ? const Value.absent()
          : Value(dueTime),
      priority: Value(priority),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      parentProject: parentProject == null && nullToAbsent
          ? const Value.absent()
          : Value(parentProject),
      status: Value(status),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      externalId: externalId == null && nullToAbsent
          ? const Value.absent()
          : Value(externalId),
    );
  }

  factory ParsedItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ParsedItem(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      type: serializer.fromJson<String>(json['type']),
      content: serializer.fromJson<String>(json['content']),
      tags: serializer.fromJson<String?>(json['tags']),
      dueDate: serializer.fromJson<String?>(json['dueDate']),
      dueTime: serializer.fromJson<String?>(json['dueTime']),
      priority: serializer.fromJson<String>(json['priority']),
      location: serializer.fromJson<String?>(json['location']),
      parentProject: serializer.fromJson<String?>(json['parentProject']),
      status: serializer.fromJson<String>(json['status']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      note: serializer.fromJson<String?>(json['note']),
      externalId: serializer.fromJson<String?>(json['externalId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'type': serializer.toJson<String>(type),
      'content': serializer.toJson<String>(content),
      'tags': serializer.toJson<String?>(tags),
      'dueDate': serializer.toJson<String?>(dueDate),
      'dueTime': serializer.toJson<String?>(dueTime),
      'priority': serializer.toJson<String>(priority),
      'location': serializer.toJson<String?>(location),
      'parentProject': serializer.toJson<String?>(parentProject),
      'status': serializer.toJson<String>(status),
      'confidence': serializer.toJson<double?>(confidence),
      'note': serializer.toJson<String?>(note),
      'externalId': serializer.toJson<String?>(externalId),
    };
  }

  ParsedItem copyWith(
          {String? id,
          String? sessionId,
          String? type,
          String? content,
          Value<String?> tags = const Value.absent(),
          Value<String?> dueDate = const Value.absent(),
          Value<String?> dueTime = const Value.absent(),
          String? priority,
          Value<String?> location = const Value.absent(),
          Value<String?> parentProject = const Value.absent(),
          String? status,
          Value<double?> confidence = const Value.absent(),
          Value<String?> note = const Value.absent(),
          Value<String?> externalId = const Value.absent()}) =>
      ParsedItem(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        type: type ?? this.type,
        content: content ?? this.content,
        tags: tags.present ? tags.value : this.tags,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        dueTime: dueTime.present ? dueTime.value : this.dueTime,
        priority: priority ?? this.priority,
        location: location.present ? location.value : this.location,
        parentProject:
            parentProject.present ? parentProject.value : this.parentProject,
        status: status ?? this.status,
        confidence: confidence.present ? confidence.value : this.confidence,
        note: note.present ? note.value : this.note,
        externalId: externalId.present ? externalId.value : this.externalId,
      );
  ParsedItem copyWithCompanion(ParsedItemsCompanion data) {
    return ParsedItem(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      type: data.type.present ? data.type.value : this.type,
      content: data.content.present ? data.content.value : this.content,
      tags: data.tags.present ? data.tags.value : this.tags,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      dueTime: data.dueTime.present ? data.dueTime.value : this.dueTime,
      priority: data.priority.present ? data.priority.value : this.priority,
      location: data.location.present ? data.location.value : this.location,
      parentProject: data.parentProject.present
          ? data.parentProject.value
          : this.parentProject,
      status: data.status.present ? data.status.value : this.status,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
      note: data.note.present ? data.note.value : this.note,
      externalId:
          data.externalId.present ? data.externalId.value : this.externalId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ParsedItem(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('type: $type, ')
          ..write('content: $content, ')
          ..write('tags: $tags, ')
          ..write('dueDate: $dueDate, ')
          ..write('dueTime: $dueTime, ')
          ..write('priority: $priority, ')
          ..write('location: $location, ')
          ..write('parentProject: $parentProject, ')
          ..write('status: $status, ')
          ..write('confidence: $confidence, ')
          ..write('note: $note, ')
          ..write('externalId: $externalId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      sessionId,
      type,
      content,
      tags,
      dueDate,
      dueTime,
      priority,
      location,
      parentProject,
      status,
      confidence,
      note,
      externalId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ParsedItem &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.type == this.type &&
          other.content == this.content &&
          other.tags == this.tags &&
          other.dueDate == this.dueDate &&
          other.dueTime == this.dueTime &&
          other.priority == this.priority &&
          other.location == this.location &&
          other.parentProject == this.parentProject &&
          other.status == this.status &&
          other.confidence == this.confidence &&
          other.note == this.note &&
          other.externalId == this.externalId);
}

class ParsedItemsCompanion extends UpdateCompanion<ParsedItem> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> type;
  final Value<String> content;
  final Value<String?> tags;
  final Value<String?> dueDate;
  final Value<String?> dueTime;
  final Value<String> priority;
  final Value<String?> location;
  final Value<String?> parentProject;
  final Value<String> status;
  final Value<double?> confidence;
  final Value<String?> note;
  final Value<String?> externalId;
  final Value<int> rowid;
  const ParsedItemsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.type = const Value.absent(),
    this.content = const Value.absent(),
    this.tags = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.dueTime = const Value.absent(),
    this.priority = const Value.absent(),
    this.location = const Value.absent(),
    this.parentProject = const Value.absent(),
    this.status = const Value.absent(),
    this.confidence = const Value.absent(),
    this.note = const Value.absent(),
    this.externalId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ParsedItemsCompanion.insert({
    required String id,
    required String sessionId,
    required String type,
    required String content,
    this.tags = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.dueTime = const Value.absent(),
    required String priority,
    this.location = const Value.absent(),
    this.parentProject = const Value.absent(),
    required String status,
    this.confidence = const Value.absent(),
    this.note = const Value.absent(),
    this.externalId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sessionId = Value(sessionId),
        type = Value(type),
        content = Value(content),
        priority = Value(priority),
        status = Value(status);
  static Insertable<ParsedItem> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? type,
    Expression<String>? content,
    Expression<String>? tags,
    Expression<String>? dueDate,
    Expression<String>? dueTime,
    Expression<String>? priority,
    Expression<String>? location,
    Expression<String>? parentProject,
    Expression<String>? status,
    Expression<double>? confidence,
    Expression<String>? note,
    Expression<String>? externalId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (type != null) 'type': type,
      if (content != null) 'content': content,
      if (tags != null) 'tags': tags,
      if (dueDate != null) 'due_date': dueDate,
      if (dueTime != null) 'due_time': dueTime,
      if (priority != null) 'priority': priority,
      if (location != null) 'location': location,
      if (parentProject != null) 'parent_project': parentProject,
      if (status != null) 'status': status,
      if (confidence != null) 'confidence': confidence,
      if (note != null) 'note': note,
      if (externalId != null) 'external_id': externalId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ParsedItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? sessionId,
      Value<String>? type,
      Value<String>? content,
      Value<String?>? tags,
      Value<String?>? dueDate,
      Value<String?>? dueTime,
      Value<String>? priority,
      Value<String?>? location,
      Value<String?>? parentProject,
      Value<String>? status,
      Value<double?>? confidence,
      Value<String?>? note,
      Value<String?>? externalId,
      Value<int>? rowid}) {
    return ParsedItemsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      type: type ?? this.type,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      priority: priority ?? this.priority,
      location: location ?? this.location,
      parentProject: parentProject ?? this.parentProject,
      status: status ?? this.status,
      confidence: confidence ?? this.confidence,
      note: note ?? this.note,
      externalId: externalId ?? this.externalId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(dueDate.value);
    }
    if (dueTime.present) {
      map['due_time'] = Variable<String>(dueTime.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (parentProject.present) {
      map['parent_project'] = Variable<String>(parentProject.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (externalId.present) {
      map['external_id'] = Variable<String>(externalId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ParsedItemsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('type: $type, ')
          ..write('content: $content, ')
          ..write('tags: $tags, ')
          ..write('dueDate: $dueDate, ')
          ..write('dueTime: $dueTime, ')
          ..write('priority: $priority, ')
          ..write('location: $location, ')
          ..write('parentProject: $parentProject, ')
          ..write('status: $status, ')
          ..write('confidence: $confidence, ')
          ..write('note: $note, ')
          ..write('externalId: $externalId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $CaptureSessionsTable captureSessions =
      $CaptureSessionsTable(this);
  late final $ParsedItemsTable parsedItems = $ParsedItemsTable(this);
  late final TaskDao taskDao = TaskDao(this as AppDatabase);
  late final CaptureSessionDao captureSessionDao =
      CaptureSessionDao(this as AppDatabase);
  late final ParsedItemDao parsedItemDao = ParsedItemDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [tasks, captureSessions, parsedItems];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('capture_sessions',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('parsed_items', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  required String key,
  required String title,
  required String category,
  required String description,
  required String image,
  required String periority,
  required String startTime,
  required String endTime,
  required String date,
  required String show,
  required String status,
  Value<int> rowid,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<String> key,
  Value<String> title,
  Value<String> category,
  Value<String> description,
  Value<String> image,
  Value<String> periority,
  Value<String> startTime,
  Value<String> endTime,
  Value<String> date,
  Value<String> show,
  Value<String> status,
  Value<int> rowid,
});

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get image => $composableBuilder(
      column: $table.image, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get periority => $composableBuilder(
      column: $table.periority, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get show => $composableBuilder(
      column: $table.show, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get image => $composableBuilder(
      column: $table.image, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get periority => $composableBuilder(
      column: $table.periority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get show => $composableBuilder(
      column: $table.show, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get image =>
      $composableBuilder(column: $table.image, builder: (column) => column);

  GeneratedColumn<String> get periority =>
      $composableBuilder(column: $table.periority, builder: (column) => column);

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get show =>
      $composableBuilder(column: $table.show, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$TasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TasksTable,
    Task,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
    Task,
    PrefetchHooks Function()> {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> image = const Value.absent(),
            Value<String> periority = const Value.absent(),
            Value<String> startTime = const Value.absent(),
            Value<String> endTime = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<String> show = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion(
            key: key,
            title: title,
            category: category,
            description: description,
            image: image,
            periority: periority,
            startTime: startTime,
            endTime: endTime,
            date: date,
            show: show,
            status: status,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String title,
            required String category,
            required String description,
            required String image,
            required String periority,
            required String startTime,
            required String endTime,
            required String date,
            required String show,
            required String status,
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion.insert(
            key: key,
            title: title,
            category: category,
            description: description,
            image: image,
            periority: periority,
            startTime: startTime,
            endTime: endTime,
            date: date,
            show: show,
            status: status,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TasksTable,
    Task,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
    Task,
    PrefetchHooks Function()>;
typedef $$CaptureSessionsTableCreateCompanionBuilder = CaptureSessionsCompanion
    Function({
  required String id,
  Value<DateTime> capturedAt,
  required String imageFilePath,
  required String syncStatus,
  Value<String?> syncError,
  Value<String?> rawVisionResponse,
  Value<int> rowid,
});
typedef $$CaptureSessionsTableUpdateCompanionBuilder = CaptureSessionsCompanion
    Function({
  Value<String> id,
  Value<DateTime> capturedAt,
  Value<String> imageFilePath,
  Value<String> syncStatus,
  Value<String?> syncError,
  Value<String?> rawVisionResponse,
  Value<int> rowid,
});

final class $$CaptureSessionsTableReferences extends BaseReferences<
    _$AppDatabase, $CaptureSessionsTable, CaptureSession> {
  $$CaptureSessionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ParsedItemsTable, List<ParsedItem>>
      _parsedItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.parsedItems,
              aliasName: $_aliasNameGenerator(
                  db.captureSessions.id, db.parsedItems.sessionId));

  $$ParsedItemsTableProcessedTableManager get parsedItemsRefs {
    final manager = $$ParsedItemsTableTableManager($_db, $_db.parsedItems)
        .filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_parsedItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CaptureSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $CaptureSessionsTable> {
  $$CaptureSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageFilePath => $composableBuilder(
      column: $table.imageFilePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncError => $composableBuilder(
      column: $table.syncError, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawVisionResponse => $composableBuilder(
      column: $table.rawVisionResponse,
      builder: (column) => ColumnFilters(column));

  Expression<bool> parsedItemsRefs(
      Expression<bool> Function($$ParsedItemsTableFilterComposer f) f) {
    final $$ParsedItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.parsedItems,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParsedItemsTableFilterComposer(
              $db: $db,
              $table: $db.parsedItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CaptureSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CaptureSessionsTable> {
  $$CaptureSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageFilePath => $composableBuilder(
      column: $table.imageFilePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncError => $composableBuilder(
      column: $table.syncError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawVisionResponse => $composableBuilder(
      column: $table.rawVisionResponse,
      builder: (column) => ColumnOrderings(column));
}

class $$CaptureSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CaptureSessionsTable> {
  $$CaptureSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => column);

  GeneratedColumn<String> get imageFilePath => $composableBuilder(
      column: $table.imageFilePath, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);

  GeneratedColumn<String> get rawVisionResponse => $composableBuilder(
      column: $table.rawVisionResponse, builder: (column) => column);

  Expression<T> parsedItemsRefs<T extends Object>(
      Expression<T> Function($$ParsedItemsTableAnnotationComposer a) f) {
    final $$ParsedItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.parsedItems,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ParsedItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.parsedItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CaptureSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CaptureSessionsTable,
    CaptureSession,
    $$CaptureSessionsTableFilterComposer,
    $$CaptureSessionsTableOrderingComposer,
    $$CaptureSessionsTableAnnotationComposer,
    $$CaptureSessionsTableCreateCompanionBuilder,
    $$CaptureSessionsTableUpdateCompanionBuilder,
    (CaptureSession, $$CaptureSessionsTableReferences),
    CaptureSession,
    PrefetchHooks Function({bool parsedItemsRefs})> {
  $$CaptureSessionsTableTableManager(
      _$AppDatabase db, $CaptureSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CaptureSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CaptureSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CaptureSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> capturedAt = const Value.absent(),
            Value<String> imageFilePath = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String?> syncError = const Value.absent(),
            Value<String?> rawVisionResponse = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CaptureSessionsCompanion(
            id: id,
            capturedAt: capturedAt,
            imageFilePath: imageFilePath,
            syncStatus: syncStatus,
            syncError: syncError,
            rawVisionResponse: rawVisionResponse,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime> capturedAt = const Value.absent(),
            required String imageFilePath,
            required String syncStatus,
            Value<String?> syncError = const Value.absent(),
            Value<String?> rawVisionResponse = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CaptureSessionsCompanion.insert(
            id: id,
            capturedAt: capturedAt,
            imageFilePath: imageFilePath,
            syncStatus: syncStatus,
            syncError: syncError,
            rawVisionResponse: rawVisionResponse,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CaptureSessionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({parsedItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (parsedItemsRefs) db.parsedItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (parsedItemsRefs)
                    await $_getPrefetchedData<CaptureSession, $CaptureSessionsTable,
                            ParsedItem>(
                        currentTable: table,
                        referencedTable: $$CaptureSessionsTableReferences
                            ._parsedItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CaptureSessionsTableReferences(db, table, p0)
                                .parsedItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.sessionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CaptureSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CaptureSessionsTable,
    CaptureSession,
    $$CaptureSessionsTableFilterComposer,
    $$CaptureSessionsTableOrderingComposer,
    $$CaptureSessionsTableAnnotationComposer,
    $$CaptureSessionsTableCreateCompanionBuilder,
    $$CaptureSessionsTableUpdateCompanionBuilder,
    (CaptureSession, $$CaptureSessionsTableReferences),
    CaptureSession,
    PrefetchHooks Function({bool parsedItemsRefs})>;
typedef $$ParsedItemsTableCreateCompanionBuilder = ParsedItemsCompanion
    Function({
  required String id,
  required String sessionId,
  required String type,
  required String content,
  Value<String?> tags,
  Value<String?> dueDate,
  Value<String?> dueTime,
  required String priority,
  Value<String?> location,
  Value<String?> parentProject,
  required String status,
  Value<double?> confidence,
  Value<String?> note,
  Value<String?> externalId,
  Value<int> rowid,
});
typedef $$ParsedItemsTableUpdateCompanionBuilder = ParsedItemsCompanion
    Function({
  Value<String> id,
  Value<String> sessionId,
  Value<String> type,
  Value<String> content,
  Value<String?> tags,
  Value<String?> dueDate,
  Value<String?> dueTime,
  Value<String> priority,
  Value<String?> location,
  Value<String?> parentProject,
  Value<String> status,
  Value<double?> confidence,
  Value<String?> note,
  Value<String?> externalId,
  Value<int> rowid,
});

final class $$ParsedItemsTableReferences
    extends BaseReferences<_$AppDatabase, $ParsedItemsTable, ParsedItem> {
  $$ParsedItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CaptureSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.captureSessions.createAlias($_aliasNameGenerator(
          db.parsedItems.sessionId, db.captureSessions.id));

  $$CaptureSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager =
        $$CaptureSessionsTableTableManager($_db, $_db.captureSessions)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ParsedItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ParsedItemsTable> {
  $$ParsedItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dueTime => $composableBuilder(
      column: $table.dueTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentProject => $composableBuilder(
      column: $table.parentProject, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get externalId => $composableBuilder(
      column: $table.externalId, builder: (column) => ColumnFilters(column));

  $$CaptureSessionsTableFilterComposer get sessionId {
    final $$CaptureSessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.captureSessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CaptureSessionsTableFilterComposer(
              $db: $db,
              $table: $db.captureSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ParsedItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ParsedItemsTable> {
  $$ParsedItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dueTime => $composableBuilder(
      column: $table.dueTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentProject => $composableBuilder(
      column: $table.parentProject,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get externalId => $composableBuilder(
      column: $table.externalId, builder: (column) => ColumnOrderings(column));

  $$CaptureSessionsTableOrderingComposer get sessionId {
    final $$CaptureSessionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.captureSessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CaptureSessionsTableOrderingComposer(
              $db: $db,
              $table: $db.captureSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ParsedItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ParsedItemsTable> {
  $$ParsedItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get dueTime =>
      $composableBuilder(column: $table.dueTime, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get parentProject => $composableBuilder(
      column: $table.parentProject, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get externalId => $composableBuilder(
      column: $table.externalId, builder: (column) => column);

  $$CaptureSessionsTableAnnotationComposer get sessionId {
    final $$CaptureSessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.captureSessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CaptureSessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.captureSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ParsedItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ParsedItemsTable,
    ParsedItem,
    $$ParsedItemsTableFilterComposer,
    $$ParsedItemsTableOrderingComposer,
    $$ParsedItemsTableAnnotationComposer,
    $$ParsedItemsTableCreateCompanionBuilder,
    $$ParsedItemsTableUpdateCompanionBuilder,
    (ParsedItem, $$ParsedItemsTableReferences),
    ParsedItem,
    PrefetchHooks Function({bool sessionId})> {
  $$ParsedItemsTableTableManager(_$AppDatabase db, $ParsedItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ParsedItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ParsedItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ParsedItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sessionId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String?> tags = const Value.absent(),
            Value<String?> dueDate = const Value.absent(),
            Value<String?> dueTime = const Value.absent(),
            Value<String> priority = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<String?> parentProject = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<double?> confidence = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<String?> externalId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ParsedItemsCompanion(
            id: id,
            sessionId: sessionId,
            type: type,
            content: content,
            tags: tags,
            dueDate: dueDate,
            dueTime: dueTime,
            priority: priority,
            location: location,
            parentProject: parentProject,
            status: status,
            confidence: confidence,
            note: note,
            externalId: externalId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sessionId,
            required String type,
            required String content,
            Value<String?> tags = const Value.absent(),
            Value<String?> dueDate = const Value.absent(),
            Value<String?> dueTime = const Value.absent(),
            required String priority,
            Value<String?> location = const Value.absent(),
            Value<String?> parentProject = const Value.absent(),
            required String status,
            Value<double?> confidence = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<String?> externalId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ParsedItemsCompanion.insert(
            id: id,
            sessionId: sessionId,
            type: type,
            content: content,
            tags: tags,
            dueDate: dueDate,
            dueTime: dueTime,
            priority: priority,
            location: location,
            parentProject: parentProject,
            status: status,
            confidence: confidence,
            note: note,
            externalId: externalId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ParsedItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (sessionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sessionId,
                    referencedTable:
                        $$ParsedItemsTableReferences._sessionIdTable(db),
                    referencedColumn:
                        $$ParsedItemsTableReferences._sessionIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ParsedItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ParsedItemsTable,
    ParsedItem,
    $$ParsedItemsTableFilterComposer,
    $$ParsedItemsTableOrderingComposer,
    $$ParsedItemsTableAnnotationComposer,
    $$ParsedItemsTableCreateCompanionBuilder,
    $$ParsedItemsTableUpdateCompanionBuilder,
    (ParsedItem, $$ParsedItemsTableReferences),
    ParsedItem,
    PrefetchHooks Function({bool sessionId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$CaptureSessionsTableTableManager get captureSessions =>
      $$CaptureSessionsTableTableManager(_db, _db.captureSessions);
  $$ParsedItemsTableTableManager get parsedItems =>
      $$ParsedItemsTableTableManager(_db, _db.parsedItems);
}

mixin _$TaskDaoMixin on DatabaseAccessor<AppDatabase> {
  $TasksTable get tasks => attachedDatabase.tasks;
}
mixin _$CaptureSessionDaoMixin on DatabaseAccessor<AppDatabase> {
  $CaptureSessionsTable get captureSessions => attachedDatabase.captureSessions;
}
mixin _$ParsedItemDaoMixin on DatabaseAccessor<AppDatabase> {
  $CaptureSessionsTable get captureSessions => attachedDatabase.captureSessions;
  $ParsedItemsTable get parsedItems => attachedDatabase.parsedItems;
}
