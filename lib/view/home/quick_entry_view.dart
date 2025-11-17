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
  String selectedProject = 'Inbox';

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
        defaultProject: selectedProject,
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
      final drawing =
          lastDrawing ?? PencilDrawing.from(pencilDrawing: pencilController.drawing);
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
          Text(
            'Quick Entry',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
          ),
          const SizedBox(height: 8),
          _buildProjectPicker(context, scheme),
          const SizedBox(height: 8),
          Text(
            inputMode == QuickEntryInputMode.text
                ? 'Type or paste your tasks here. We\'ll process them later.'
                : 'Use your stylus to jot a note. We\'ll save the drawing for review.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          _buildModeToggle(context),
          const SizedBox(height: 16),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: inputMode == QuickEntryInputMode.text
                  ? _buildTextEntry(context, scheme)
                  : _buildStylusEntry(context, scheme),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isProcessing ? null : _processEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isProcessing
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: scheme.onPrimary,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      inputMode == QuickEntryInputMode.text
                          ? 'Process Tasks'
                          : 'Save Stylus Entry',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: scheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectPicker(BuildContext context, ColorScheme scheme) {
    return Obx(() {
      final projectNames = <String>[
        'Inbox',
        ...controller.projects.map((p) => p.name).whereType<String>(),
      ];
      if (!projectNames.contains(selectedProject)) {
        selectedProject = projectNames.first;
      }

      return Card(
        color: scheme.surfaceVariant.withOpacity(0.4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.folder_open, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<String>(
                  value: selectedProject,
                  isExpanded: true,
                  underline: const SizedBox(),
                  dropdownColor: scheme.surface,
                  icon: Icon(Icons.arrow_drop_down, color: scheme.onSurfaceVariant),
                  items: projectNames
                      .map((name) => DropdownMenuItem<String>(
                            value: name,
                            child: Text(
                              name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: scheme.onSurface),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedProject = value;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: () => _showCreateProjectDialog(context, scheme),
                icon: const Icon(Icons.add),
                label: const Text('Add project'),
              )
            ],
          ),
        ),
      );
    });
  }

  Widget _buildModeToggle(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceVariant.withOpacity(.4),
        borderRadius: BorderRadius.circular(16),
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
        borderRadius: BorderRadius.circular(16),
        fillColor: scheme.primary.withOpacity(.15),
        selectedColor: scheme.primary,
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.keyboard),
                SizedBox(width: 8),
                Text('Typing'),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.gesture),
                SizedBox(width: 8),
                Text('Stylus'),
              ],
            ),
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
        color: scheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outline.withOpacity(0.2),
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
          hintText: 'Quick Entry Syntax:\n\n'
              '+ Project Name\n'
              '[ ] Todo item\n'
              '[x] Completed item\n'
              '[>] Deferred item\n\n'
              'Metadata:\n'
              '@tag - Context (@phone, @errands)\n'
              '> date - Due date (> Fri, > tomorrow)\n'
              '~ time - Time (~ 9am, ~ 14:00)\n'
              '^ place - Location (^ Home Depot)\n'
              '! or !! or !!! - Priority\n'
              ': text - Note\n\n'
              'Example:\n'
              '+ Kitchen Reno\n'
              '[ ] Buy tiles ^ Home Depot @errands !!\n'
              '  > Sat ~ 2pm : Check stock first\n'
              '[x] Measure countertops',
          hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant.withOpacity(0.5),
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
              border: Border.all(color: scheme.outline.withOpacity(.2)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: scheme.surfaceVariant,
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

  Future<void> _showCreateProjectDialog(
      BuildContext context, ColorScheme scheme) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController =
        TextEditingController();
    Color selectedColor = scheme.primary;
    final palette = [
      scheme.primary,
      scheme.secondary,
      scheme.tertiary,
      scheme.primaryContainer,
      scheme.secondaryContainer,
      scheme.tertiaryContainer,
    ];

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, dialogSetState) {
          return AlertDialog(
            title: const Text('New Project'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    decoration:
                        const InputDecoration(labelText: 'Description (optional)'),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Color',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: palette
                        .map(
                          (color) => GestureDetector(
                            onTap: () => dialogSetState(() => selectedColor = color),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selectedColor == color
                                      ? scheme.onPrimary
                                      : scheme.outlineVariant,
                                  width: selectedColor == color ? 2 : 1,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final description = descriptionController.text.trim();
                  if (name.isEmpty) {
                    Get.snackbar(
                      'Name required',
                      'Please provide a project name.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: scheme.errorContainer,
                      colorText: scheme.onErrorContainer,
                    );
                    return;
                  }
                  await controller.createProject(
                    name: name,
                    description: description.isEmpty ? null : description,
                    color: selectedColor,
                  );
                  if (mounted) {
                    setState(() {
                      selectedProject = name;
                    });
                    Navigator.of(ctx).pop();
                  }
                  Get.snackbar(
                    'Project added',
                    '"$name" is ready for tasks.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: scheme.primaryContainer,
                    colorText: scheme.onPrimaryContainer,
                  );
                },
                child: const Text('Create'),
              ),
            ],
          );
        });
      },
    );
  }
}
