import 'dart:io';

import 'package:drift/drift.dart' as drift show Value;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pencil_field/pencil_field.dart';

import '../../data/local/database/app_database.dart';
import '../../db_helper/db_helper.dart';
import '../../util/task_parser.dart';
import '../../util/utils.dart';
import '../../view_model/controller/home_controller.dart';

enum QuickEntryInputMode { text, stylus }

class QuickEntryView extends StatefulWidget {
  const QuickEntryView({super.key});

  @override
  State<QuickEntryView> createState() => _QuickEntryViewState();
}

class _QuickEntryViewState extends State<QuickEntryView> {
  final controller = Get.find<HomeController>();
  late final TextEditingController textController;
  final PencilFieldController pencilController = PencilFieldController();
  final DbHelper db = DbHelper();
  bool isProcessing = false;
  QuickEntryInputMode inputMode = QuickEntryInputMode.text;
  PencilDrawing? lastDrawing;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  Future<void> _processEntry() async {
    if (inputMode == QuickEntryInputMode.text) {
      await _processTextEntry();
    } else {
      await _processStylusEntry();
    }
  }

  Future<void> _processTextEntry() async {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    if (textController.text.isEmpty) {
      Utils.showSnackBar(
        'Add something',
        'Type a few lines before processing.',
        const Icon(Icons.info_outline),
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      final parsedTasks = TaskParser.parseQuickEntry(
        textController.text,
        defaultProject: 'Inbox',
      );
      final taskModels = TaskParser.convertToTaskModels(parsedTasks);

      for (var task in taskModels) {
        await db.insert(task);
      }

      await controller.getTasks();
      textController.clear();
      controller.barIndex.value = 0;

      Utils.showSnackBar(
        'Success',
        'Created ${taskModels.length} task${taskModels.length > 1 ? 's' : ''}',
        Icon(Icons.check_circle, color: scheme.secondary),
      );
    } catch (e) {
      Utils.showSnackBar(
        'Error',
        'Failed to process tasks: $e',
        Icon(Icons.error, color: scheme.error),
      );
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  Future<void> _processStylusEntry() async {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    if ((lastDrawing == null || lastDrawing!.strokeCount == 0) &&
        pencilController.drawing.strokeCount == 0) {
      Utils.showSnackBar(
        'Nothing captured',
        'Use the stylus to jot down something first.',
        const Icon(Icons.edit),
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      final image = pencilController.drawingAsImage(
        backgroundColor: scheme.surface,
      );
      final bytes = await image.toPNG();
      if (bytes == null) {
        throw Exception('Unable to export drawing.');
      }

      final Directory docs = await getApplicationDocumentsDirectory();
      final Directory folder =
          Directory(p.join(docs.path, 'stylus_entries'))..createSync(recursive: true);
      final String filePath = p.join(
        folder.path,
        'stylus_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      await db.captureSessions.upsertSession(
        CaptureSessionsCompanion(
          id: drift.Value(DateTime.now().microsecondsSinceEpoch.toString()),
          capturedAt: drift.Value(DateTime.now()),
          imageFilePath: drift.Value(filePath),
          syncStatus: const drift.Value('pending'),
          syncError: const drift.Value(null),
          rawVisionResponse: const drift.Value(null),
        ),
      );

      pencilController.clear();
      setState(() {
        lastDrawing = PencilDrawing();
      });

      Utils.showSnackBar(
        'Saved',
        'Stylus entry captured for later processing.',
        Icon(Icons.brush, color: scheme.secondary),
      );
    } catch (e) {
      Utils.showSnackBar(
        'Error',
        'Could not save stylus entry: $e',
        Icon(Icons.error, color: scheme.error),
      );
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: inputMode == QuickEntryInputMode.text
                  ? _buildTextEntry(context, scheme)
                  : _buildStylusEntry(context, scheme),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildModeToggle(context),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: isProcessing ? null : _processEntry,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isProcessing
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: scheme.onPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            inputMode == QuickEntryInputMode.text
                                ? 'Process Tasks'
                                : 'Save Entry',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ToggleButtons(
        isSelected: [
          inputMode == QuickEntryInputMode.text,
          inputMode == QuickEntryInputMode.stylus
        ],
        onPressed: (index) {
          setState(() {
            inputMode = QuickEntryInputMode.values[index];
          });
        },
        borderRadius: BorderRadius.circular(12),
        fillColor: scheme.primary.withValues(alpha: 0.15),
        selectedColor: scheme.primary,
        constraints: const BoxConstraints(minHeight: 48, minWidth: 56),
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.keyboard, size: 22),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.gesture, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildTextEntry(BuildContext context, ColorScheme scheme) {
    return Container(
      key: const ValueKey('textEntry'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: textController,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: scheme.onSurface,
            ),
        decoration: InputDecoration(
          hintText: '+ Project Name\n'
              '[ ] Task  [x] Done  [>] Deferred\n\n'
              '@tag   > date   ~ time   ^ place\n'
              '!  !!  !!!   : note   # ref\n'
              '// comment line\n\n'
              'Example:\n'
              '+ Kitchen Reno\n'
              '[ ] Buy tiles @errands > Sat ~ 2pm !!\n'
              '[ ] Call contractor ^ office @phone\n'
              '[x] Measure countertops : done yesterday',
          hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildStylusEntry(BuildContext context, ColorScheme scheme) {
    return Column(
      key: const ValueKey('stylusEntry'),
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: scheme.surfaceContainerHighest,
                child: PencilField(
                  controller: pencilController,
                  pencilPaint: PencilPaint(
                    strokeWidth: 3,
                    color: scheme.onSurface,
                  ),
                  onPencilDrawingChanged: (drawing) {
                    setState(() {
                      lastDrawing = drawing;
                    });
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Use a stylus for best results.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            TextButton.icon(
              onPressed: () {
                pencilController.clear();
                setState(() {
                  lastDrawing = PencilDrawing();
                });
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear'),
            ),
          ],
        ),
      ],
    );
  }

}
