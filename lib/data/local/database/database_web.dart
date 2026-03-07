import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:sqlite3/wasm.dart';

LazyDatabase openConnection() {
  return LazyDatabase(() async {
    final sqlite3 = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
    final fs = await IndexedDbFileSystem.open(dbName: 'paper2todo_db');
    sqlite3.registerVirtualFileSystem(fs, makeDefault: true);
    return WasmDatabase(
      sqlite3: sqlite3,
      path: 'paper2todo_db.sqlite',
    );
  });
}
