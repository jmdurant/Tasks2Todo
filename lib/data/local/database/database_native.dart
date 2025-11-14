import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

LazyDatabase openConnection() {
  return LazyDatabase(() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File(p.join(directory.path, 'paper2todo.db'));
    return NativeDatabase.createInBackground(file);
  });
}
