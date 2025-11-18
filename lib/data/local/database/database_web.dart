import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:drift/web.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:sqlite3/wasm.dart';

// Cached database connection for faster subsequent access
QueryExecutor? _cachedExecutor;

/// Preload database connection during app startup for better performance
Future<void> preloadDatabase() async {
  if (_cachedExecutor != null) return;
  _cachedExecutor = await _createConnection();
}

Future<QueryExecutor> _createConnection() async {
  if (!kReleaseMode) {
    // DDC builds don't fully support sqlite3 WASM yet, fall back to sql.js
    // while developing on web.
    return WebDatabase('paper2todo_db');
  }

  final String wasmAsset =
      kReleaseMode ? 'sqlite3.wasm' : 'sqlite3.debug.wasm';

  // Parallelize WASM and IndexedDB loading for faster initialization
  final results = await Future.wait([
    WasmSqlite3.loadFromUrl(Uri.parse(wasmAsset)),
    IndexedDbFileSystem.open(dbName: 'paper2todo_db'),
  ]);

  final sqlite3 = results[0] as WasmSqlite3;
  final fs = results[1] as IndexedDbFileSystem;

  sqlite3.registerVirtualFileSystem(fs, makeDefault: true);
  return WasmDatabase(
    sqlite3: sqlite3,
    path: 'paper2todo_db.sqlite',
  );
}

LazyDatabase openConnection() {
  return LazyDatabase(() async {
    // Return cached connection if available, otherwise create new one
    _cachedExecutor ??= await _createConnection();
    return _cachedExecutor!;
  });
}
