import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:todo/config/app_config.dart';
import 'package:todo/db_helper/db_helper.dart';
import 'package:todo/model/task_model.dart';

/// Result of a sync run, surfaced to the UI.
class SyncResult {
  SyncResult({
    required this.pushed,
    required this.pulled,
    this.error,
  });
  final int pushed;
  final int pulled;
  final String? error;

  bool get ok => error == null;
}

/// Phase 1 Firebase sync: a manual, last-write-wins reconcile of the local
/// Tasks table against `Tasks/{uid}` in Realtime Database.
///
/// Design notes:
///  * Drift remains the source of truth the UI reads. This service mirrors.
///  * Conflict resolution is last-write-wins by `updatedAt` (epoch millis).
///  * Deletes propagate as tombstones (`deleted: true`) so a removal on one
///    device isn't resurrected by another device's push.
///  * No live listeners yet — this is the manual "Sync now" round-trip.
///    Phase 2 adds push-on-change + RTDB child listeners.
class SyncService {
  SyncService._();
  static final SyncService instance = SyncService._();

  final DbHelper _db = DbHelper();

  bool get _enabled => AppConfig.firebaseAvailable;

  DatabaseReference? _tasksRef() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return FirebaseDatabase.instance.ref('Tasks').child(user.uid);
  }

  /// One-shot reconcile. Pulls the remote node, applies anything newer than
  /// local, then pushes every local row that's newer than (or missing from)
  /// the remote snapshot we just read.
  Future<SyncResult> syncNow() async {
    if (!_enabled) {
      return SyncResult(pushed: 0, pulled: 0, error: 'Firebase not enabled');
    }
    final ref = _tasksRef();
    if (ref == null) {
      return SyncResult(pushed: 0, pulled: 0, error: 'Not signed in');
    }

    try {
      // 1. Snapshot the remote node once.
      final snapshot = await ref.get();
      final Map<String, TaskModel> remoteByKey = _parseRemote(snapshot);

      // 2. Pull: apply remote rows that beat local.
      int pulled = 0;
      for (final remote in remoteByKey.values) {
        final changed = await _db.applyRemoteTask(remote);
        if (changed) pulled++;
      }

      // 3. Push: any local row newer than (or absent from) the remote
      //    snapshot gets written up. Tombstones included.
      int pushed = 0;
      final localRows = await _db.getAllTasksForSync();
      final Map<String, Object?> updates = {};
      for (final local in localRows) {
        final key = local.key;
        if (key == null) continue;
        final remote = remoteByKey[key];
        final localTs = local.updatedAt ?? 0;
        final remoteTs = remote?.updatedAt ?? -1;
        if (localTs > remoteTs) {
          updates[key] = local.toSyncJson();
          pushed++;
        }
      }
      if (updates.isNotEmpty) {
        await ref.update(updates);
      }

      debugPrint('SyncService: pulled $pulled, pushed $pushed');
      return SyncResult(pushed: pushed, pulled: pulled);
    } catch (e, st) {
      debugPrint('SyncService: sync failed: $e\n$st');
      return SyncResult(pushed: 0, pulled: 0, error: e.toString());
    }
  }

  Map<String, TaskModel> _parseRemote(DataSnapshot snapshot) {
    final result = <String, TaskModel>{};
    if (snapshot.value == null) return result;
    final raw = snapshot.value;
    if (raw is! Map) return result;
    raw.forEach((key, value) {
      if (value is! Map) return;
      try {
        final json = Map<String, dynamic>.from(value);
        // RTDB may strip the key field; ensure it's present.
        json['key'] ??= key.toString();
        result[key.toString()] = TaskModel.fromSyncJson(json);
      } catch (e) {
        debugPrint('SyncService: skipping malformed remote row $key: $e');
      }
    });
    return result;
  }
}
