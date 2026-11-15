import 'package:flutter/material.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:workout_app/config/constants/app_constants.dart';
import 'package:workout_app/services/logger_service.dart';
import 'package:workout_app/services/exercise_service.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/empty_state.dart';
import 'package:workout_app/widgets/error_message.dart';
import 'package:workout_app/widgets/loading_indicator.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';
import 'package:workout_app/models/exercise_definition.dart';
import 'package:workout_app/services/service_locator.dart';
import 'package:workout_app/models/muscle_info.dart';
import 'exercise_detail_screen.dart';

class ExercisesScreen extends ConsumerStatefulWidget {
  const ExercisesScreen({super.key});

  @override
  ConsumerState<ExercisesScreen> createState() => _ExercisesScreenState();
}

class ExercisesNotifier
    extends StateNotifier<AsyncValue<List<ExerciseDefinition>>> {
  final ExerciseService _exerciseService;

  ExercisesNotifier(this._exerciseService) : super(const AsyncValue.loading()) {
    loadExercises();
  }

  Future<void> loadExercises() async {
    state = const AsyncValue.loading();
    try {
      final exercises = await _exerciseService.getExerciseDefinitions();
      state = AsyncValue.data(exercises);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}

class _TagAutocomplete extends StatefulWidget {
  final List<String> allOptions;
  final void Function(String label) onSelected;
  final Set<String> exclude;
  final List<String> selectedLabels;
  final void Function(String label) onDeleted;

  const _TagAutocomplete({
    required this.allOptions,
    required this.onSelected,
    required this.selectedLabels,
    required this.onDeleted,
    this.exclude = const <String>{},
  });

  @override
  State<_TagAutocomplete> createState() => _TagAutocompleteState();
}

class _TagAutocompleteState extends State<_TagAutocomplete> {
  final TextEditingController _controller = TextEditingController();
  TextEditingController? _fieldController;
  FocusNode? _fieldFocus;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      displayStringForOption: (opt) => opt,
      optionsBuilder: (TextEditingValue textEditingValue) {
        final q = textEditingValue.text.trim().toLowerCase();
        final base = widget.allOptions.where(
          (o) => !widget.exclude.contains(o),
        );
        if (q.isEmpty) return base.take(20);
        return base.where((o) => o.toLowerCase().contains(q)).take(20);
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        _controller.value = controller.value;
        _fieldController = controller;
        _fieldFocus = focusNode;

        focusNode.addListener(() {
          if (focusNode.hasFocus) {
            controller.value = controller.value.copyWith(
              text: '${controller.text} ',
            );
            controller.value = controller.value.copyWith(
              text: controller.text.isNotEmpty
                  ? controller.text.trimRight()
                  : '',
            );
          }
        });

        return SizedBox(
          width: double.infinity,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Add muscle tag',
              hintText: 'Type to search...',
              border: OutlineInputBorder(),
              isDense: false,
              contentPadding: EdgeInsets.fromLTRB(12, 20, 12, 12),
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final l in widget.selectedLabels)
                  Chip(
                    label: Text(l),
                    onDeleted: () => widget.onDeleted(l),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 80,
                    maxWidth: 260,
                  ),
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration.collapsed(
                      hintText: 'Type to search...',
                    ),
                    onSubmitted: (value) {
                      final label = value.trim();
                      if (label.isEmpty) return;

                      final lower = label.toLowerCase();
                      final match = widget.allOptions.firstWhere(
                        (o) => o.toLowerCase() == lower,
                        orElse: () => '',
                      );
                      if (match.isNotEmpty) {
                        widget.onSelected(match);
                        controller.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
      onSelected: (String selection) {
        widget.onSelected(selection);
        _controller.clear();
        _fieldController?.clear();

        if (_fieldFocus != null) {
          Future.microtask(() => _fieldFocus!.requestFocus());
        }
      },
    );
  }
}

final exercisesNotifierProvider =
    StateNotifierProvider<
      ExercisesNotifier,
      AsyncValue<List<ExerciseDefinition>>
    >((ref) {
      final exerciseService = ref.watch(exerciseServiceProvider);
      return ExercisesNotifier(exerciseService);
    });

class _ExercisesScreenState extends ConsumerState<ExercisesScreen> {
  final LoggerService _logger = LoggerService('ExercisesScreen');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _equipmentController = TextEditingController();
  String? _movementType;
  String? _region;

  bool _showOnlyMainExercises = false;

  Future<void> _uploadExerciseImage(ExerciseDefinition exercise) async {
    final id = exercise.id;
    if (id == null) return;

    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['png', 'jpg', 'jpeg', 'gif'],
        allowMultiple: false,
        withData: true,
      );
      final file = picked?.files.single;
      if (file == null) return;

      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to read selected file bytes')),
        );
        return;
      }

      final name = file.name.isNotEmpty ? file.name : 'image';
      final lower = name.toLowerCase();
      MediaType? contentType;
      final isGif = lower.endsWith('.gif');
      if (lower.endsWith('.png')) {
        contentType = MediaType('image', 'png');
      } else if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
        contentType = MediaType('image', 'jpeg');
      } else if (isGif) {
        contentType = MediaType('image', 'gif');
      }

      if (!mounted) return;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final service = ref.read(exerciseServiceProvider);
      if (isGif) {
        await service.uploadExerciseGif(
          exerciseId: id,
          bytes: bytes,
          filename: name,
          contentType: contentType,
        );
      } else {
        await service.uploadExerciseImage(
          exerciseId: id,
          bytes: bytes,
          filename: name,
          contentType: contentType,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      await ref.read(exercisesNotifierProvider.notifier).loadExercises();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isGif ? 'GIF uploaded' : 'Image uploaded')),
      );
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).maybePop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }
  }

  String? _selectedMuscleGroup;
  Future<List<String>>? _groupsFuture;

  Future<List<MuscleInfo>>? _musclesFuture;
  List<MuscleInfo> _muscles = const [];

  final Set<String> _selectedTargetKeys = <String>{};
  final Set<String> _selectedSynergistKeys = <String>{};

  final Set<String> _selectedEquipment = <String>{};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exercisesNotifierProvider.notifier).loadExercises();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _equipmentController.dispose();
    super.dispose();
  }

  Future<List<String>> _loadMuscleGroups() async {
    final service = ref.read(exerciseServiceProvider);
    final muscles = await service.getMuscles();
    final groups = muscles.map((m) => m.group).toSet().toList()..sort();
    return groups.cast<String>();
  }

  Future<void> _showExerciseDialog({ExerciseDefinition? initial}) async {
    _nameController.text = initial?.name ?? '';
    _selectedMuscleGroup = initial?.muscleGroup;
    _equipmentController.text = initial?.equipment ?? '';
    _movementType = initial?.movementType;
    _region = initial?.region;
    _selectedTargetKeys
      ..clear()
      ..addAll(initial?.targetMuscles ?? const <String>[]);
    _selectedSynergistKeys
      ..clear()
      ..addAll(initial?.synergistMuscles ?? const <String>[]);

    _selectedEquipment
      ..clear()
      ..addAll(
        (initial?.equipment ?? '')
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty),
      );

    final service = ref.read(exerciseServiceProvider);
    final isEdit = initial?.id != null;

    _groupsFuture = _loadMuscleGroups();

    try {
      _muscles = (await service.getMuscles()).cast<MuscleInfo>();
    } catch (e) {
      _muscles = [];
    }
    _musclesFuture = Future.value(_muscles);

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Exercise' : 'Create Exercise'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 8),
                FutureBuilder<List<String>>(
                  future: _groupsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Muscle group'),
                        subtitle: Text('Loading...'),
                      );
                    }
                    if (snapshot.hasError) {
                      final colors = Theme.of(context).colorScheme;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Muscle group',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Failed to load groups: ${snapshot.error}',
                            style: TextStyle(color: colors.error),
                          ),
                        ],
                      );
                    }
                    final groups = snapshot.data ?? const <String>[];
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedMuscleGroup,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Muscle group',
                      ),
                      hint: const Text('Select group'),
                      items: groups
                          .map(
                            (g) => DropdownMenuItem<String>(
                              value: g,
                              child: Text(g),
                            ),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setDialogState(() => _selectedMuscleGroup = val),
                    );
                  },
                ),
                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Target muscles',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 4),
                FutureBuilder<List<MuscleInfo>>(
                  future: _musclesFuture,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const LinearProgressIndicator(minHeight: 2);
                    }
                    if (snap.hasError) {
                      return Text(
                        'Failed to load muscles: ${snap.error}',
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      );
                    }
                    final muscles = snap.data ?? const <MuscleInfo>[];
                    final selectedLabels =
                        _selectedTargetKeys
                            .map(
                              (k) => _muscles
                                  .firstWhere(
                                    (m) => m.key == k,
                                    orElse: () =>
                                        MuscleInfo(key: k, label: k, group: ''),
                                  )
                                  .label,
                            )
                            .toList()
                          ..sort();
                    return _TagAutocomplete(
                      allOptions: muscles.map((m) => m.label).toList(),
                      selectedLabels: selectedLabels,
                      onDeleted: (label) => setDialogState(() {
                        final key = _muscles
                            .firstWhere(
                              (m) => m.label == label,
                              orElse: () =>
                                  MuscleInfo(key: '', label: '', group: ''),
                            )
                            .key;
                        if (key.isNotEmpty) _selectedTargetKeys.remove(key);
                      }),
                      exclude: _selectedTargetKeys
                          .map(
                            (k) => _muscles
                                .firstWhere(
                                  (m) => m.key == k,
                                  orElse: () =>
                                      MuscleInfo(key: k, label: k, group: ''),
                                )
                                .label,
                          )
                          .toSet(),
                      onSelected: (label) => setDialogState(() {
                        final normalized = label.trim().toLowerCase();
                        final key = muscles
                            .firstWhere(
                              (m) => m.label.trim().toLowerCase() == normalized,
                              orElse: () =>
                                  MuscleInfo(key: '', label: '', group: ''),
                            )
                            .key;
                        if (key.isNotEmpty) _selectedTargetKeys.add(key);
                      }),
                    );
                  },
                ),
                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Synergist muscles',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 4),
                FutureBuilder<List<MuscleInfo>>(
                  future: _musclesFuture,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const LinearProgressIndicator(minHeight: 2);
                    }
                    if (snap.hasError) {
                      return Text(
                        'Failed to load muscles: ${snap.error}',
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      );
                    }
                    final muscles = snap.data ?? const <MuscleInfo>[];
                    final selectedLabels =
                        _selectedSynergistKeys
                            .map(
                              (k) => _muscles
                                  .firstWhere(
                                    (m) => m.key == k,
                                    orElse: () =>
                                        MuscleInfo(key: k, label: k, group: ''),
                                  )
                                  .label,
                            )
                            .toList()
                          ..sort();
                    return _TagAutocomplete(
                      allOptions: muscles.map((m) => m.label).toList(),
                      selectedLabels: selectedLabels,
                      onDeleted: (label) => setDialogState(() {
                        final key = _muscles
                            .firstWhere(
                              (m) => m.label == label,
                              orElse: () =>
                                  MuscleInfo(key: '', label: '', group: ''),
                            )
                            .key;
                        if (key.isNotEmpty) _selectedSynergistKeys.remove(key);
                      }),
                      exclude: _selectedSynergistKeys
                          .map(
                            (k) => _muscles
                                .firstWhere(
                                  (m) => m.key == k,
                                  orElse: () =>
                                      MuscleInfo(key: k, label: k, group: ''),
                                )
                                .label,
                          )
                          .toSet(),
                      onSelected: (label) => setDialogState(() {
                        final normalized = label.trim().toLowerCase();
                        final key = muscles
                            .firstWhere(
                              (m) => m.label.trim().toLowerCase() == normalized,
                              orElse: () =>
                                  MuscleInfo(key: '', label: '', group: ''),
                            )
                            .key;
                        if (key.isNotEmpty) _selectedSynergistKeys.add(key);
                      }),
                    );
                  },
                ),
                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Equipment',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 4),
                _TagAutocomplete(
                  allOptions: AppConstants.exerciseEquipment,
                  selectedLabels: _selectedEquipment.toList()..sort(),
                  onDeleted: (label) => setDialogState(() {
                    _selectedEquipment.remove(label);
                  }),
                  exclude: _selectedEquipment,
                  onSelected: (label) => setDialogState(() {
                    _selectedEquipment.add(label);
                  }),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _movementType,
                  decoration: const InputDecoration(labelText: 'Movement type'),
                  items: const [
                    DropdownMenuItem(
                      value: 'compound',
                      child: Text('Compound'),
                    ),
                    DropdownMenuItem(
                      value: 'isolation',
                      child: Text('Isolation'),
                    ),
                  ],
                  onChanged: (val) => setDialogState(() => _movementType = val),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _region,
                  decoration: const InputDecoration(labelText: 'Region'),
                  items: const [
                    DropdownMenuItem(value: 'upper', child: Text('Upper')),
                    DropdownMenuItem(value: 'lower', child: Text('Lower')),
                  ],
                  onChanged: (val) => setDialogState(() => _region = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                if (name.isEmpty) return;
                final payload = ExerciseDefinition(
                  id: initial?.id,
                  name: name,
                  muscleGroup:
                      (_selectedMuscleGroup == null ||
                          _selectedMuscleGroup!.isEmpty)
                      ? null
                      : _selectedMuscleGroup,
                  equipment: _selectedEquipment.isEmpty
                      ? null
                      : _selectedEquipment.join(', '),
                  targetMuscles: _selectedTargetKeys.isEmpty
                      ? null
                      : _selectedTargetKeys.toList(),
                  synergistMuscles: _selectedSynergistKeys.isEmpty
                      ? null
                      : _selectedSynergistKeys.toList(),
                  movementType: _movementType,
                  region: _region,
                );
                try {
                  if (isEdit) {
                    await service.updateExerciseDefinition(payload);
                  } else {
                    await service.createExerciseDefinition(payload);
                  }
                  if (!mounted) return;
                  Navigator.of(ctx).pop();
                  await ref
                      .read(exercisesNotifierProvider.notifier)
                      .loadExercises();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to ${isEdit ? 'update' : 'create'} exercise: $e',
                      ),
                    ),
                  );
                }
              },
              child: Text(isEdit ? 'Save' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dimensions = UiDimensions.of(context);

    return AssistantChatHost(
      contextBuilder: () async => {
        'screen': 'exercises',
        'entities': {'show_only_main_exercises': _showOnlyMainExercises},
      },
      builder: (context, openChat) {
        return Scaffold(
          appBar: PrimaryAppBar(
            title: 'Exercises',
            onTitleTap: openChat,
          ),
          body: Consumer(
            builder: (context, ref, child) {
              final exercisesState = ref.watch(exercisesNotifierProvider);

              return exercisesState.when(
                loading: () => const LoadingIndicator(),
                error: (error, stackTrace) {
                  _logger.e('Error loading exercises: $error\n$stackTrace');
                  return ErrorMessage(
                    message: 'Error loading exercises: $error',
                    onRetry: () {
                      final _ = ref.refresh(exercisesNotifierProvider);
                    },
                  );
                },
                data: (exercises) {
                  if (exercises.isEmpty) {
                    return EmptyState(
                      icon: Icons.fitness_center,
                      title: 'No Exercises',
                      description: 'No exercises found. Add your first exercise!',
                      action: ElevatedButton.icon(
                        onPressed: () {
                          final _ = ref.refresh(exercisesNotifierProvider);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                    );
                  }

                  final displayedExercises = _showOnlyMainExercises
                      ? exercises
                            .where(
                              (e) =>
                                  e.rootExerciseId == null ||
                                  e.rootExerciseId == e.id,
                            )
                            .toList()
                      : exercises;

                  return RefreshIndicator(
                    onRefresh: () async {
                      final _ = ref.refresh(exercisesNotifierProvider);
                      await ref
                          .read(exercisesNotifierProvider.notifier)
                          .loadExercises();
                    },
                    child: ListView.separated(
                      padding: EdgeInsets.all(dimensions.pagePadding),
                      itemCount: displayedExercises.length + 1,
                      separatorBuilder: (_, __) =>
                          SizedBox(height: dimensions.rowGap),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Container(
                            decoration: InstrumentTheme.cardDecoration(
                              context,
                              color: colors.surfaceContainerLow,
                              radius: 14,
                            ),
                            child: SwitchListTile(
                              title: Text(
                                'Show only main exercises',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: const Text(
                                'Hide variants (exercises with root_exercise_id) in the list',
                              ),
                              value: _showOnlyMainExercises,
                              onChanged: (v) {
                                setState(() => _showOnlyMainExercises = v);
                              },
                            ),
                          );
                        }

                        final exercise = displayedExercises[index - 1];
                        return _buildExerciseInstrumentCard(
                          context,
                          exercise,
                          dimensions,
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showExerciseDialog(),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildExerciseInstrumentCard(
    BuildContext context,
    ExerciseDefinition exercise,
    UiDimensions dimensions,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: InstrumentTheme.cardDecoration(
        context,
        color: colors.surfaceContainerLow,
        radius: 14,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            if (exercise.id == null) return;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    ExerciseDetailScreen(exerciseId: exercise.id!),
              ),
            );
          },
          onLongPress: () => _showExerciseDialog(initial: exercise),
          child: Padding(
            padding: EdgeInsets.all(dimensions.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: InstrumentTheme.cardDecoration(
                        context,
                        color: colors.surfaceContainerHigh,
                        radius: 10,
                      ),
                      child: Icon(
                        Icons.fitness_center,
                        size: 18,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${exercise.muscleGroup ?? 'No muscle group'} • ${exercise.equipment ?? 'No equipment'}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton(
                        tooltip: 'Upload Image',
                        style: IconButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          tapTargetSize: MaterialTapTargetSize.padded,
                        ),
                        icon: const Icon(Icons.upload, size: 20),
                        onPressed: () => _uploadExerciseImage(exercise),
                      ),
                    ),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton(
                        tooltip: 'Edit',
                        style: IconButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          tapTargetSize: MaterialTapTargetSize.padded,
                        ),
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () =>
                            _showExerciseDialog(initial: exercise),
                      ),
                    ),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton(
                        tooltip: 'Delete',
                        style: IconButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          tapTargetSize: MaterialTapTargetSize.padded,
                        ),
                        icon: Icon(
                          Icons.delete_outline,
                          color: colors.error,
                          size: 20,
                        ),
                        onPressed: () => _confirmDeleteExercise(exercise),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteExercise(ExerciseDefinition exercise) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete exercise?'),
        content: Text('Are you sure you want to delete "${exercise.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ref
          .read(exerciseServiceProvider)
          .deleteExerciseDefinition(exercise.id!);
      if (!mounted) return;
      await ref.read(exercisesNotifierProvider.notifier).loadExercises();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete exercise: $e')),
      );
    }
  }
}
