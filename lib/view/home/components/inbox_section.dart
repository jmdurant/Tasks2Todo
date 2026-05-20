import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/data/local/database/app_database.dart' as drift_db;
import 'package:todo/db_helper/db_helper.dart';
import 'package:todo/model/task_model.dart';
import 'package:todo/util/paper2todo_payload.dart';
import 'package:todo/util/utils.dart';
import 'package:todo/view_model/controller/home_controller.dart';

/// Renders the paper2todo capture inbox: every parsed item that hasn't been
/// promoted into the Tasks table yet, with Accept / Reject actions and a
/// project mapping dropdown that defaults to the AI's guess when it matches
/// an existing tasks2todo project.
class InboxSection extends StatelessWidget {
  const InboxSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final DbHelper db = DbHelper();

    return StreamBuilder<List<drift_db.ParsedItem>>(
      key: const ValueKey('inboxEntry'),
      stream: db.watchInboxItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data ?? const <drift_db.ParsedItem>[];
        if (items.isEmpty) {
          return _EmptyInbox(scheme: scheme, db: db);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InboxHeader(count: items.length, db: db, items: items),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _InboxItemCard(
                  item: items[index],
                  db: db,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyInbox extends StatelessWidget {
  const _EmptyInbox({required this.scheme, required this.db});
  final ColorScheme scheme;
  final DbHelper db;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.move_to_inbox_outlined,
                size: 64, color: scheme.onSurfaceVariant.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              'Inbox is empty',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Captures from Paper2Todo land here for review before they become tasks.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => _injectTestCapture(context, db),
                icon: const Icon(Icons.bug_report_outlined, size: 18),
                label: const Text('Inject test capture'),
              ),
              const SizedBox(height: 6),
              Text(
                'Debug only — simulates a paper2todo share payload.',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Inserts a synthetic paper2todo payload so the Accept/Reject flow can be
/// exercised without two physical devices wired together. Only compiled in
/// debug builds.
Future<void> _injectTestCapture(BuildContext context, DbHelper db) async {
  final now = DateTime.now();
  final sessionId = 'debug-${now.microsecondsSinceEpoch}';
  final tomorrow = now.add(const Duration(days: 1));
  String fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  final payload = Paper2TodoPayload(
    sessionId: sessionId,
    capturedAt: now,
    items: <Paper2TodoItem>[
      // High-confidence, AI-suggested project that doesn't exist yet — the
      // card should show the "AI suggested: Kitchen Reno" chip with [Use it].
      Paper2TodoItem(
        id: '$sessionId-1',
        type: 'task',
        content: 'Buy bathroom tiles',
        tags: ['errands', 'shopping'],
        dueDate: fmt(tomorrow),
        dueTime: '14:00',
        priority: 'medium',
        location: 'Home Depot',
        parentProject: 'Kitchen Reno',
        status: 'pending',
        confidence: 0.92,
        note: 'Get the matte finish',
      ),
      // Medium confidence, no project guess — dropdown defaults to Inbox.
      Paper2TodoItem(
        id: '$sessionId-2',
        type: 'task',
        content: 'Call contractor about countertops',
        tags: ['phone'],
        priority: 'high',
        parentProject: null,
        status: 'pending',
        confidence: 0.78,
      ),
      // Low confidence, deferred — exercises the red confidence badge.
      Paper2TodoItem(
        id: '$sessionId-3',
        type: 'task',
        content: 'Look into smart oven options',
        tags: const [],
        priority: 'low',
        parentProject: 'Kitchen Reno',
        status: 'deferred',
        confidence: 0.55,
      ),
      // Subtask under the same project.
      Paper2TodoItem(
        id: '$sessionId-4',
        type: 'subtask',
        content: 'Ask about warranty terms',
        tags: const [],
        priority: 'none',
        parentProject: 'Kitchen Reno',
        status: 'pending',
        confidence: 0.88,
      ),
    ],
  );

  await db.insertPaper2TodoCapture(payload);
  if (!context.mounted) return;
  Utils.showSnackBar(
    'Injected',
    'Added a synthetic Paper2Todo capture with ${payload.items.length} items',
    const Icon(Icons.science_outlined, color: Colors.white),
  );
}

class _InboxHeader extends StatefulWidget {
  const _InboxHeader({
    required this.count,
    required this.db,
    required this.items,
  });

  final int count;
  final DbHelper db;
  final List<drift_db.ParsedItem> items;

  @override
  State<_InboxHeader> createState() => _InboxHeaderState();
}

class _InboxHeaderState extends State<_InboxHeader> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Icons.move_to_inbox, color: scheme.primary, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${widget.count} pending',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
          ),
        ),
        TextButton.icon(
          onPressed: _busy ? null : _acceptAll,
          icon: _busy
              ? SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: scheme.primary,
                  ),
                )
              : const Icon(Icons.done_all, size: 18),
          label: const Text('Accept all'),
        ),
      ],
    );
  }

  Future<void> _acceptAll() async {
    setState(() => _busy = true);
    final HomeController home = Get.find<HomeController>();
    final projects = home.projects.toList();

    int promoted = 0;
    for (final item in widget.items) {
      final project = _resolveProject(item.parentProject, projects);
      final task = _parsedItemToTaskModel(item, project);
      await widget.db.insert(task);
      await widget.db.markInboxItemPromoted(item.id, task.key!);
      promoted++;
    }

    try {
      home.getTasks();
    } catch (_) {}

    if (!mounted) return;
    setState(() => _busy = false);
    Utils.showSnackBar(
      'Promoted',
      'Moved $promoted item${promoted == 1 ? '' : 's'} into projects',
      const Icon(Icons.done_all, color: Colors.white),
    );
  }
}

/// Resolves an AI-suggested project against the user's real project list.
/// Returns the matched project name if found (case-insensitive), else 'Inbox'.
/// Shared by single-Accept and Accept-All so behavior matches.
String _resolveProject(String? aiGuess, List<drift_db.Project> projects) {
  final guess = aiGuess?.trim();
  if (guess == null || guess.isEmpty) return 'Inbox';
  if (guess.toLowerCase() == 'inbox') return 'Inbox';
  for (final p in projects) {
    if (p.name.toLowerCase() == guess.toLowerCase()) return p.name;
  }
  return 'Inbox';
}

/// Converts a ParsedItem (paper2todo wire format) into a TaskModel ready to
/// be persisted in tasks2todo's Tasks table.
TaskModel _parsedItemToTaskModel(
    drift_db.ParsedItem item, String selectedProject) {
  final now = DateTime.now();
  final key = now.microsecondsSinceEpoch.toString();

  String priority;
  switch (item.priority) {
    case 'high':
      priority = 'High';
      break;
    case 'medium':
      priority = 'Medium';
      break;
    case 'low':
      priority = 'Low';
      break;
    default:
      priority = 'Low';
  }

  final status = item.status == 'completed' ? 'complete' : 'unComplete';

  final description = <String>[
    if (item.location != null && item.location!.trim().isNotEmpty)
      'Location: ${item.location!.trim()}',
    if (item.note != null && item.note!.trim().isNotEmpty) item.note!.trim(),
  ].join('\n');

  return TaskModel(
    key: key,
    title: item.content,
    category: selectedProject,
    description: description,
    image: '',
    priority: priority,
    startTime: _convertTimeFromIso(item.dueTime),
    endTime: _convertTimeFromIso(item.dueTime),
    date: _convertDateFromIso(item.dueDate),
    show: 'yes',
    status: status,
    tags: item.tags,
  );
}

String _convertDateFromIso(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  final parts = raw.split('-');
  if (parts.length != 3) return '';
  return '${parts[2]}/${parts[1]}/${parts[0]}';
}

String _convertTimeFromIso(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  final parts = raw.split(':');
  if (parts.length < 2) return '';
  final h24 = int.tryParse(parts[0]);
  final m = parts[1].length >= 2 ? parts[1].substring(0, 2) : parts[1];
  if (h24 == null) return '';
  final period = h24 >= 12 ? 'PM' : 'AM';
  final h12 = h24 == 0 ? 12 : (h24 > 12 ? h24 - 12 : h24);
  final hh = h12.toString().padLeft(2, '0');
  return '$hh:$m:$period';
}

class _InboxItemCard extends StatefulWidget {
  const _InboxItemCard({required this.item, required this.db});
  final drift_db.ParsedItem item;
  final DbHelper db;

  @override
  State<_InboxItemCard> createState() => _InboxItemCardState();
}

class _InboxItemCardState extends State<_InboxItemCard> {
  late String _selectedProject;
  bool _busy = false;
  late final HomeController _home;

  @override
  void initState() {
    super.initState();
    _home = Get.find<HomeController>();
    _selectedProject = _resolveInitialProject(_home.projects);
  }

  /// Picks the dropdown's initial value: AI guess if it matches an existing
  /// project (case-insensitive), otherwise Inbox.
  String _resolveInitialProject(List<drift_db.Project> projects) =>
      _resolveProject(widget.item.parentProject, projects);

  bool _isAiSuggestionUnknown(List<drift_db.Project> projects) {
    final guess = widget.item.parentProject?.trim();
    if (guess == null || guess.isEmpty) return false;
    if (guess.toLowerCase() == 'inbox') return false;
    return !projects.any((p) => p.name.toLowerCase() == guess.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Obx(() {
      final projects = _home.projects;
      final available = <String>['Inbox', ...projects.map((p) => p.name)];
      // If the project list updates such that our selection isn't valid,
      // recover gracefully.
      if (!available.contains(_selectedProject)) {
        _selectedProject = 'Inbox';
      }
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleRow(scheme),
            const SizedBox(height: 8),
            _buildMetaRow(scheme),
            const SizedBox(height: 12),
            _buildProjectPicker(scheme, available, projects),
            const SizedBox(height: 12),
            _buildActionsRow(scheme),
          ],
        ),
      );
    });
  }

  Widget _buildTitleRow(ColorScheme scheme) {
    final confidence = widget.item.confidence;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            widget.item.content.isEmpty ? '(Untitled)' : widget.item.content,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
          ),
        ),
        if (confidence != null) ...[
          const SizedBox(width: 8),
          _confidenceBadge(scheme, confidence),
        ],
      ],
    );
  }

  Widget _confidenceBadge(ColorScheme scheme, double confidence) {
    final pct = (confidence * 100).round();
    Color color = scheme.primary;
    if (confidence < 0.7) {
      color = scheme.error;
    } else if (confidence < 0.85) {
      color = scheme.tertiary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$pct%',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildMetaRow(ColorScheme scheme) {
    final chips = <Widget>[];
    if (widget.item.dueDate != null && widget.item.dueDate!.isNotEmpty) {
      chips.add(_chip(scheme, Icons.calendar_today, widget.item.dueDate!));
    }
    if (widget.item.dueTime != null && widget.item.dueTime!.isNotEmpty) {
      chips.add(_chip(scheme, Icons.schedule, widget.item.dueTime!));
    }
    if (widget.item.priority != 'none' && widget.item.priority.isNotEmpty) {
      chips.add(_chip(scheme, Icons.flag_outlined,
          widget.item.priority[0].toUpperCase() + widget.item.priority.substring(1)));
    }
    final String tagsRaw = widget.item.tags ?? '';
    if (tagsRaw.isNotEmpty) {
      for (final tag in tagsRaw.split(',').where((t) => t.trim().isNotEmpty)) {
        chips.add(_chip(scheme, Icons.tag, tag.trim()));
      }
    }
    if (widget.item.location != null && widget.item.location!.trim().isNotEmpty) {
      chips.add(_chip(scheme, Icons.place_outlined, widget.item.location!.trim()));
    }
    if (widget.item.note != null && widget.item.note!.trim().isNotEmpty) {
      chips.add(_chip(scheme, Icons.sticky_note_2_outlined,
          widget.item.note!.trim(),
          flex: true));
    }
    if (chips.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 6, runSpacing: 6, children: chips);
  }

  Widget _chip(ColorScheme scheme, IconData icon, String label,
      {bool flex = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: scheme.onSurfaceVariant),
          const SizedBox(width: 4),
          if (flex)
            Flexible(child: Text(label, style: _chipStyle(scheme)))
          else
            Text(label, style: _chipStyle(scheme)),
        ],
      ),
    );
  }

  TextStyle? _chipStyle(ColorScheme scheme) =>
      Theme.of(context).textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
          );

  Widget _buildProjectPicker(ColorScheme scheme, List<String> available,
      List<drift_db.Project> projects) {
    final aiUnknown = _isAiSuggestionUnknown(projects);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (aiUnknown)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, size: 14, color: scheme.primary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'AI suggested: ${widget.item.parentProject}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ),
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => _createAndUseSuggestedProject(
                          widget.item.parentProject!.trim()),
                  child: const Text('Use it'),
                ),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedProject,
              isExpanded: true,
              icon: Icon(Icons.unfold_more,
                  size: 18, color: scheme.onSurfaceVariant),
              items: [
                ...available.map(
                  (name) => DropdownMenuItem<String>(
                    value: name,
                    child: Text(name),
                  ),
                ),
                const DropdownMenuItem<String>(
                  value: '__new__',
                  child: Row(
                    children: [
                      Icon(Icons.add, size: 16),
                      SizedBox(width: 6),
                      Text('Create new project…'),
                    ],
                  ),
                ),
              ],
              onChanged: _busy
                  ? null
                  : (value) async {
                      if (value == null) return;
                      if (value == '__new__') {
                        await _promptCreateProject();
                      } else {
                        setState(() => _selectedProject = value);
                      }
                    },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionsRow(ColorScheme scheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: _busy ? null : _reject,
          icon: const Icon(Icons.close, size: 18),
          label: const Text('Reject'),
          style: TextButton.styleFrom(foregroundColor: scheme.error),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: _busy ? null : _accept,
          icon: _busy
              ? SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: scheme.onPrimary,
                  ),
                )
              : const Icon(Icons.check, size: 18),
          label: const Text('Accept'),
        ),
      ],
    );
  }

  Future<void> _promptCreateProject() async {
    final controller = TextEditingController();
    final scheme = Theme.of(context).colorScheme;
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New project'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Project name'),
          onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    await _home.createProject(name: name, color: scheme.primary);
    if (!mounted) return;
    setState(() => _selectedProject = name);
  }

  Future<void> _createAndUseSuggestedProject(String name) async {
    final scheme = Theme.of(context).colorScheme;
    await _home.createProject(name: name, color: scheme.primary);
    if (!mounted) return;
    setState(() => _selectedProject = name);
  }

  Future<void> _reject() async {
    setState(() => _busy = true);
    await widget.db.rejectInboxItem(widget.item.id);
    if (!mounted) return;
    setState(() => _busy = false);
  }

  Future<void> _accept() async {
    setState(() => _busy = true);
    final TaskModel task =
        _parsedItemToTaskModel(widget.item, _selectedProject);
    await widget.db.insert(task);
    await widget.db.markInboxItemPromoted(widget.item.id, task.key!);
    try {
      _home.getTasks();
    } catch (_) {}
    if (!mounted) return;
    setState(() => _busy = false);
    Utils.showSnackBar(
      'Promoted',
      '"${task.title}" moved into $_selectedProject',
      const Icon(Icons.check, color: Colors.white),
    );
  }
}
