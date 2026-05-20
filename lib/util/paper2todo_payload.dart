import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Wire format shared with paper2todo's `Tasks2TodoService`. Every paper2todo
/// share payload starts with [sentinel] on its own line, followed by JSON.
/// This class is the receiving-side mirror of that emitter.
class Paper2TodoPayload {
  static const String sentinel = 'PAPER2TODO_V1';

  final String sessionId;
  final DateTime capturedAt;
  final List<Paper2TodoItem> items;

  Paper2TodoPayload({
    required this.sessionId,
    required this.capturedAt,
    required this.items,
  });

  /// Returns null if [raw] isn't a paper2todo payload. Throws on malformed
  /// JSON after the sentinel — callers should catch and surface to the user.
  static Paper2TodoPayload? tryDecode(String raw) {
    final trimmed = raw.trimLeft();
    if (!trimmed.startsWith(sentinel)) return null;

    // Strip the sentinel line and anything before the JSON body.
    final newlineIdx = trimmed.indexOf('\n');
    if (newlineIdx < 0) {
      throw const FormatException('Paper2Todo payload missing JSON body');
    }
    final body = trimmed.substring(newlineIdx + 1).trim();
    final Map<String, dynamic> root =
        jsonDecode(body) as Map<String, dynamic>;

    final session = (root['session'] as Map<String, dynamic>?) ?? const {};
    final String sessionId = (session['id'] as String?) ??
        DateTime.now().microsecondsSinceEpoch.toString();
    final DateTime capturedAt = _parseDate(session['capturedAt'] as String?) ??
        DateTime.now().toUtc();

    final List<dynamic> rawItems = (root['items'] as List<dynamic>?) ?? const [];
    final items = rawItems
        .whereType<Map<String, dynamic>>()
        .map(Paper2TodoItem.fromJson)
        .toList();

    return Paper2TodoPayload(
      sessionId: sessionId,
      capturedAt: capturedAt,
      items: items,
    );
  }

  static DateTime? _parseDate(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    try {
      return DateTime.parse(iso);
    } catch (e) {
      debugPrint('Paper2TodoPayload: bad capturedAt $iso: $e');
      return null;
    }
  }
}

/// Mirror of paper2todo's `ParsedItem`, decoded from the share payload.
/// Field types match exactly what gets persisted in tasks2todo's
/// `ParsedItems` Drift table — date/time stay as strings here so the import
/// is a direct column-by-column copy.
class Paper2TodoItem {
  final String id;
  final String type; // task | subtask | project | note
  final String content;
  final List<String> tags;
  final String? dueDate; // ISO yyyy-MM-dd
  final String? dueTime; // HH:mm
  final String priority; // none | low | medium | high
  final String? location;
  final String? parentProject;
  final String status; // pending | completed | deferred
  final double? confidence;
  final String? note;

  Paper2TodoItem({
    required this.id,
    required this.type,
    required this.content,
    required this.tags,
    this.dueDate,
    this.dueTime,
    required this.priority,
    this.location,
    this.parentProject,
    required this.status,
    this.confidence,
    this.note,
  });

  factory Paper2TodoItem.fromJson(Map<String, dynamic> json) {
    return Paper2TodoItem(
      id: (json['id'] as String?) ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      type: (json['type'] as String?) ?? 'task',
      content: (json['content'] as String?) ?? '',
      tags: ((json['tags'] as List<dynamic>?) ?? const [])
          .whereType<String>()
          .toList(),
      // dueDate comes over as full ISO timestamp; we keep only the date part
      // to match what tasks2todo's UI expects (yyyy-MM-dd).
      dueDate: _datePart(json['dueDate'] as String?),
      dueTime: json['dueTime'] as String?,
      priority: (json['priority'] as String?) ?? 'none',
      location: json['location'] as String?,
      parentProject: json['parentProject'] as String?,
      status: (json['status'] as String?) ?? 'pending',
      confidence: (json['confidence'] as num?)?.toDouble(),
      note: json['note'] as String?,
    );
  }

  static String? _datePart(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    final tIdx = iso.indexOf('T');
    return tIdx > 0 ? iso.substring(0, tIdx) : iso;
  }
}
