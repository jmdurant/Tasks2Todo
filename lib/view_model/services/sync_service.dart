import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:todo/config/app_config.dart';
import 'package:todo/db_helper/db_helper.dart';
import 'package:todo/model/task_model.dart';
import 'package:todo/view_model/controller/home_controller.dart';

/// Result of a manual sync run, surfaced to the UI.
class SyncResult {
  SyncResult({required this.pushed, required this.pulled, this.error});
  final int pushed;
  final int pulled;
  final String? error;
  bool get ok => error == null;
}

/// Firebase task sync.
///
/// Phase 1: manual [syncNow] reconcile.
/// Phase 2: [startLiveSync] keeps Drift and `Tasks/{uid}` in step in real
/// time — a Drift watcher pushes local edits/deletes, and RTDB child
/// listeners pull remote changes.
///
/// Conflict resolution is last-write-wins by `updatedAt`. Deletes propagate
/// as tombstones. Drift stays the source of truth the UI reads.
///
/// **Echo-loop guard.** [_lastSynced] tracks, per task key, the `updatedAt`
/// we last reconciled in either direction. The push side skips a row whose
/// `updatedAt` isn't strictly greater than `_lastSynced[key]`; the pull side
/// sets `_lastSynced[key]` to the remote timestamp *before* writing to Drift.
/// So a pulled change can't bounce back out, and a pushed change can't bounce
/// back in.
class SyncService {
  SyncService._();
  static final SyncService instance = SyncService._();

  final DbHelper _db = DbHelper();
  final Map<String, int> _lastSynced = <String, int>{};

  StreamSubscription<List<TaskModel>>? _localSub;
  final List<StreamSubscription<DatabaseEvent>> _remoteSubs = [];
  bool _live = false;

  /// Tombstones older than this are GC'd on sync start. Generous so every
  /// device has had a chance to observe the delete first.
  static const Duration _tombstoneTtl = Duration(days: 30);

  bool get isLive => _live;
  bool get _enabled => AppConfig.firebaseAvailable;

  DatabaseReference? _tasksRef() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return FirebaseDatabase.instance.ref('Tasks').child(user.uid);
  }

  // ─── Manual reconcile (Phase 1) ────────────────────────────────────────

  Future<SyncResult> syncNow() async {
    if (!_enabled) {
      return SyncResult(pushed: 0, pulled: 0, error: 'Firebase not enabled');
    }
    final ref = _tasksRef();
    if (ref == null) {
      return SyncResult(pushed: 0, pulled: 0, error: 'Not signed in');
    }

    try {
      final snapshot = await ref.get();
      final Map<String, TaskModel> remoteByKey = _parseRemote(snapshot);

      int pulled = 0;
      for (final remote in remoteByKey.values) {
        _rememberSynced(remote.key!, remote.updatedAt ?? 0);
        final changed = await _db.applyRemoteTask(remote);
        if (changed) pulled++;
      }

      int pushed = 0;
      final localRows = await _db.getAllTasksForSync();
      final Map<String, Object?> updates = {};
      for (final local in localRows) {
        final key = local.key;
        if (key == null) continue;
        final localTs = local.updatedAt ?? 0;
        final remoteTs = remoteByKey[key]?.updatedAt ?? -1;
        if (localTs > remoteTs) {
          updates[key] = local.toSyncJson();
          _rememberSynced(key, localTs);
          pushed++;
        } else {
          // Already reconciled — record so live push won't re-send it.
          _rememberSynced(key, localTs > remoteTs ? localTs : remoteTs);
        }
      }
      if (updates.isNotEmpty) {
        await ref.update(updates);
      }

      debugPrint('SyncService: reconcile pulled $pulled, pushed $pushed');
      return SyncResult(pushed: pushed, pulled: pulled);
    } catch (e, st) {
      debugPrint('SyncService: sync failed: $e\n$st');
      return SyncResult(pushed: 0, pulled: 0, error: e.toString());
    }
  }

  // ─── Live sync (Phase 2) ───────────────────────────────────────────────

  /// Brings Drift and RTDB into step, then keeps them live. Idempotent —
  /// calling it while already live restarts cleanly. No-op when Firebase is
  /// disabled or the user is signed out.
  Future<void> startLiveSync() async {
    if (!_enabled) return;
    final ref = _tasksRef();
    if (ref == null) return;

    await stopLiveSync();

    // GC old tombstones before establishing the baseline so we don't keep
    // re-reconciling long-dead rows.
    final cutoff =
        DateTime.now().subtract(_tombstoneTtl).millisecondsSinceEpoch;
    await _db.pruneTombstones(cutoff);

    // Baseline reconcile populates _lastSynced for every key.
    await syncNow();

    // Push side: react to local edits/deletes.
    _localSub = _db.watchAllTasksForSync().listen(
          _onLocalChanged,
          onError: (Object e) => debugPrint('SyncService: local watch error: $e'),
        );

    // Pull side: react to remote changes. onChildAdded fires for existing
    // children on subscribe too, but applyRemoteTask is idempotent (LWW) and
    // the _lastSynced guard skips no-ops.
    void onRemoteEvent(DatabaseEvent event) => _onRemoteChild(event);
    _remoteSubs.add(ref.onChildAdded.listen(onRemoteEvent,
        onError: (Object e) => debugPrint('SyncService: onChildAdded error: $e')));
    _remoteSubs.add(ref.onChildChanged.listen(onRemoteEvent,
        onError: (Object e) =>
            debugPrint('SyncService: onChildChanged error: $e')));
    // onChildRemoved means a hard delete happened on another device (e.g.
    // its tombstone GC). We don't resurrect; just drop our local copy too.
    _remoteSubs.add(ref.onChildRemoved.listen(_onRemoteRemoved,
        onError: (Object e) =>
            debugPrint('SyncService: onChildRemoved error: $e')));

    _live = true;
    debugPrint('SyncService: live sync started');
  }

  Future<void> stopLiveSync() async {
    await _localSub?.cancel();
    _localSub = null;
    for (final sub in _remoteSubs) {
      await sub.cancel();
    }
    _remoteSubs.clear();
    _live = false;
  }

  Future<void> _onLocalChanged(List<TaskModel> rows) async {
    final ref = _tasksRef();
    if (ref == null) return;
    final Map<String, Object?> updates = {};
    for (final row in rows) {
      final key = row.key;
      if (key == null) continue;
      final ts = row.updatedAt ?? 0;
      if (ts > (_lastSynced[key] ?? -1)) {
        updates[key] = row.toSyncJson();
        _rememberSynced(key, ts);
      }
    }
    if (updates.isEmpty) return;
    try {
      await ref.update(updates);
      debugPrint('SyncService: pushed ${updates.length} local change(s)');
    } catch (e) {
      debugPrint('SyncService: live push failed: $e');
    }
  }

  Future<void> _onRemoteChild(DatabaseEvent event) async {
    final key = event.snapshot.key;
    final value = event.snapshot.value;
    if (key == null || value is! Map) return;
    final TaskModel remote;
    try {
      final json = Map<String, dynamic>.from(value);
      json['key'] ??= key;
      remote = TaskModel.fromSyncJson(json);
    } catch (e) {
      debugPrint('SyncService: bad remote child $key: $e');
      return;
    }
    final remoteTs = remote.updatedAt ?? 0;
    if (remoteTs <= (_lastSynced[key] ?? -1)) return; // echo / stale

    // Set the guard BEFORE writing so the local watcher that fires after the
    // Drift write doesn't bounce this back out to RTDB.
    _rememberSynced(key, remoteTs);
    final changed = await _db.applyRemoteTask(remote);
    if (changed) {
      _refreshUi();
      debugPrint('SyncService: applied remote change $key');
    }
  }

  Future<void> _onRemoteRemoved(DatabaseEvent event) async {
    final key = event.snapshot.key;
    if (key == null) return;
    // A remote hard-delete: tombstone the local row so it disappears from the
    // UI. Use a fresh timestamp so the guard records it.
    final now = DateTime.now().millisecondsSinceEpoch;
    _rememberSynced(key, now);
    await _db.applyRemoteTask(TaskModel(
      key: key,
      title: '',
      category: 'Inbox',
      description: '',
      image: '',
      priority: 'Low',
      startTime: '',
      endTime: '',
      date: '',
      show: 'yes',
      status: 'unComplete',
      updatedAt: now,
      deleted: true,
    ));
    _refreshUi();
  }

  void _rememberSynced(String key, int ts) {
    final current = _lastSynced[key] ?? -1;
    if (ts > current) _lastSynced[key] = ts;
  }

  void _refreshUi() {
    try {
      Get.find<HomeController>().getTasks();
    } catch (_) {
      // Controller not registered (e.g. during early startup) — the Projects
      // stream and the next getTasks() pick changes up regardless.
    }
  }

  Map<String, TaskModel> _parseRemote(DataSnapshot snapshot) {
    final result = <String, TaskModel>{};
    final raw = snapshot.value;
    if (raw is! Map) return result;
    raw.forEach((key, value) {
      if (value is! Map) return;
      try {
        final json = Map<String, dynamic>.from(value);
        json['key'] ??= key.toString();
        result[key.toString()] = TaskModel.fromSyncJson(json);
      } catch (e) {
        debugPrint('SyncService: skipping malformed remote row $key: $e');
      }
    });
    return result;
  }
}
