import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:drift/web.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:sqlite3/wasm.dart';

LazyDatabase openConnection() {
  return LazyDatabase(() async {
    if (!kReleaseMode) {
      // DDC builds don't fully support sqlite3 WASM yet, fall back to sql.js
      // while developing on web.
      return WebDatabase('paper2todo_db');
    }

    final String wasmAsset =
        kReleaseMode ? 'sqlite3.wasm' : 'sqlite3.debug.wasm';
    final sqlite3 = await WasmSqlite3.loadFromUrl(Uri.parse(wasmAsset));
    final fs = await IndexedDbFileSystem.open(dbName: 'paper2todo_db');
    sqlite3.registerVirtualFileSystem(fs, makeDefault: true);
    return WasmDatabase(
      sqlite3: sqlite3,
      path: 'paper2todo_db.sqlite',
    );
  });
}
