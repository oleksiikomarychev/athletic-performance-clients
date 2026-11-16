import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/models/exercise_definition.dart';
import 'package:workout_app/providers/exercise_pagination_provider.dart';
import 'package:workout_app/providers/target_data_providers.dart';
import 'package:workout_app/screens/exercise_detail_screen.dart';
import 'package:workout_app/src/widgets/snack_utils.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/empty_state.dart';
import 'package:workout_app/widgets/instrument_modal.dart';
import 'package:workout_app/widgets/interface_maker_sheet.dart';
import 'package:workout_app/widgets/loading_indicator.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';

class ExerciseListScreen extends ConsumerStatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  ConsumerState<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends ConsumerState<ExerciseListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _equipmentController = TextEditingController();

  List<String> _muscleGroups = [];
  String? _selectedMuscleGroup;
  bool _loadingMuscles = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadMuscleGroups();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(paginatedExercisesProvider.notifier).refresh();
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(paginatedExercisesProvider.notifier).loadMore(
        muscleGroups: _selectedMuscleGroup != null
            ? [_selectedMuscleGroup!]
            : null,
      );
    }
  }

  Future<void> _loadMuscleGroups() async {
    setState(() => _loadingMuscles = true);
    try {
      final svc = ref.read(exerciseServiceProvider);
      final muscles = await svc.getMuscles();
      final groups = muscles.map((m) => m.group).toSet().toList()..sort();
      if (!mounted) return;
      setState(() {
        _muscleGroups = groups.cast<String>();
        if (_selectedMuscleGroup != null &&
            !_muscleGroups.contains(_selectedMuscleGroup)) {
          _selectedMuscleGroup = null;
        }
      });
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        showAppSnackBar(
          context,
          l10n.exerciseListErrorLoadingMuscleGroups(e.toString()),
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingMuscles = false);
      }
    }
  }

  void _onMuscleGroupChanged(String? group) {
    setState(() => _selectedMuscleGroup = group);
    ref.read(paginatedExercisesProvider.notifier).refresh(
      muscleGroups: group != null ? [group] : null,
    );
  }

  Future<void> _showAddExerciseDialog() async {
    final l10n = AppLocalizations.of(context);
    _clearForm();
    String? dialogGroup = _selectedMuscleGroup;

    final submitted = await showInstrumentDialog<bool>(
      context: context,
      eyebrow: l10n.catalogEntryEyebrow,
      title: l10n.exerciseListAddExerciseTitle,
      content: StatefulBuilder(
        builder: (context, setModalState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: InstrumentTheme.inputDecoration(
                  context,
                  labelText: l10n.exerciseListNameLabel,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: dialogGroup,
                isExpanded: true,
                decoration: InstrumentTheme.inputDecoration(
                  context,
                  labelText: l10n.exerciseListMuscleGroupLabel,
                ),
                hint: _loadingMuscles
                    ? Text(l10n.exerciseListLoading)
                    : Text(l10n.exerciseListSelectGroup),
                items: _muscleGroups
                    .map(
                      (g) => DropdownMenuItem<String>(
                        value: g,
                        child: Text(g),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  setModalState(() => dialogGroup = v);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _equipmentController,
                decoration: InstrumentTheme.inputDecoration(
                  context,
                  labelText: l10n.exerciseListEquipmentLabel,
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        InstrumentActionButton(
          label: l10n.cancel,
          variant: InstrumentActionVariant.secondary,
          onPressed: () => Navigator.pop(context, false),
        ),
        InstrumentActionButton(
          label: l10n.exerciseListAddExerciseTitle,
          icon: Icons.add_rounded,
          onPressed: () {
            if (_nameController.text.trim().isEmpty) {
              showAppSnackBar(
                context,
                l10n.exerciseListEnterExerciseName,
                isError: true,
              );
              return;
            }
            if (_muscleGroups.isNotEmpty &&
                (dialogGroup == null || dialogGroup!.isEmpty)) {
              showAppSnackBar(
                context,
                l10n.exerciseListSelectMuscleGroupSnack,
                isError: true,
              );
              return;
            }
            Navigator.pop(context, true);
          },
        ),
      ],
    );

    if (submitted == true && mounted) {
      await _addExercise(dialogGroup);
    }
  }

  void _clearForm() {
    _nameController.clear();
    _equipmentController.clear();
  }

  Future<void> _addExercise(String? selectedGroup) async {
    final l10n = AppLocalizations.of(context);
    try {
      final exerciseService = ref.read(exerciseServiceProvider);
      final exercise = ExerciseDefinition(
        name: _nameController.text.trim(),
        muscleGroup: selectedGroup,
        equipment: _equipmentController.text.trim().isEmpty
            ? null
            : _equipmentController.text.trim(),
      );
      await exerciseService.createExerciseDefinition(exercise);
      if (!mounted) return;
      if (selectedGroup != null && selectedGroup != _selectedMuscleGroup) {
        setState(() => _selectedMuscleGroup = selectedGroup);
      }
      ref.read(paginatedExercisesProvider.notifier).refresh(
        muscleGroups: _selectedMuscleGroup != null
            ? [_selectedMuscleGroup!]
            : null,
      );
    } catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          l10n.exerciseListErrorGeneric(e.toString()),
          isError: true,
        );
      }
    }
  }

  Future<void> _confirmAndDeleteExercise(
    ExerciseDefinition exercise,
    AppLocalizations l10n,
  ) async {
    if (exercise.id == null) return;
    final instrument = InstrumentTheme.of(context);
    final confirm = await showInstrumentDialog<bool>(
      context: context,
      eyebrow: l10n.destructiveActionEyebrow,
      title: l10n.exerciseListDeleteExerciseTitle,
      message: l10n.exerciseListDeleteExerciseBody,
      accentColor: instrument.peakEffortColor,
      actions: [
        InstrumentActionButton(
          label: l10n.cancel,
          variant: InstrumentActionVariant.secondary,
          onPressed: () => Navigator.pop(context, false),
        ),
        InstrumentActionButton(
          label: l10n.exerciseListDelete,
          variant: InstrumentActionVariant.destructive,
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );

    if (confirm == true && mounted) {
      try {
        final exerciseService = ref.read(exerciseServiceProvider);
        await exerciseService.deleteExerciseDefinition(exercise.id!);
        if (!mounted) return;
        ref.read(paginatedExercisesProvider.notifier).refresh(
          muscleGroups: _selectedMuscleGroup != null
              ? [_selectedMuscleGroup!]
              : null,
        );
      } catch (e) {
        if (mounted) {
          showAppSnackBar(
            context,
            l10n.exerciseListErrorDeleting(e.toString()),
            isError: true,
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _equipmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final exercisesState = ref.watch(paginatedExercisesProvider);

    return AssistantChatHost(
      contextBuilder: () async => {
        'screen': 'exercise_list',
        'entities': {
          'selected_muscle_group': _selectedMuscleGroup,
          'exercises_count': exercisesState.exercises.length,
        },
      },
      builder: (context, openChat) {
        final topInset = AmbientScaffoldShell.topContentInset(context);
        final bottomInset = AmbientScaffoldShell.bottomContentInset(context);

        return AmbientScaffoldShell(
          appBar: PrimaryAppBar(
            title: l10n.exerciseListTitle,
            onTitleTap: openChat,
            showBack: true,
            actions: [
              IconButton(
                onPressed: _showAddExerciseDialog,
                icon: const Icon(Icons.add_rounded),
                tooltip: l10n.exerciseListAddExerciseTitle,
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              ref.read(paginatedExercisesProvider.notifier).refresh(
                muscleGroups: _selectedMuscleGroup != null
                    ? [_selectedMuscleGroup!]
                    : null,
              );
            },
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                0,
                topInset + 8,
                0,
                bottomInset + 28,
              ),
              children: [
                if (_muscleGroups.isNotEmpty) ...[
                  CanvasPillStrip(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    items: [
                      CanvasPillItem(
                        label: l10n.allLabel,
                        selected: _selectedMuscleGroup == null,
                        onTap: () => _onMuscleGroupChanged(null),
                      ),
                      for (final group in _muscleGroups)
                        CanvasPillItem(
                          label: group,
                          selected: _selectedMuscleGroup == group,
                          onTap: () => _onMuscleGroupChanged(group),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildListBody(context, exercisesState, l10n),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListBody(
    BuildContext context,
    PaginatedExercisesState state,
    AppLocalizations l10n,
  ) {
    if (state.exercises.isEmpty && state.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: LoadingIndicator(),
      );
    }

    if (state.exercises.isEmpty && !state.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: EmptyState(
          icon: Icons.fitness_center_rounded,
          title: l10n.exerciseListEmpty,
          description: l10n.tryChangingFilterOrAddExercise,
          action: InstrumentActionButton(
            label: l10n.exerciseListAddExerciseTitle,
            icon: Icons.add_rounded,
            onPressed: _showAddExerciseDialog,
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: InstrumentTheme.instrumentCardDecoration(context),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedMuscleGroup != null
                                ? 'FILTER · ${_selectedMuscleGroup!.toUpperCase()}'
                                : 'EXERCISE CATALOG · ${state.exercises.length}',
                            style: InstrumentTheme.microLabel(
                              context,
                              color: instrument.workingAura,
                            ).copyWith(
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.exerciseListTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 1, color: instrument.hairlineBorder),
              for (int i = 0; i < state.exercises.length; i++) ...[
                if (i > 0)
                  Container(height: 1, color: instrument.hairlineBorder),
                _ExerciseCatalogRow(
                  exercise: state.exercises[i],
                  l10n: l10n,
                  onTap: state.exercises[i].id != null
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ExerciseDetailScreen(
                                exerciseId: state.exercises[i].id!,
                              ),
                            ),
                          );
                        }
                      : null,
                  onDelete: () =>
                      _confirmAndDeleteExercise(state.exercises[i], l10n),
                ),
              ],
            ],
          ),
        ),
        if (state.isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: LoadingIndicator(),
          ),
        if (state.exercises.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              'Loaded ${state.exercises.length} exercises',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
      ],
    );
  }
}

class _ExerciseCatalogRow extends StatelessWidget {
  final ExerciseDefinition exercise;
  final AppLocalizations l10n;
  final VoidCallback? onTap;
  final VoidCallback onDelete;

  const _ExerciseCatalogRow({
    required this.exercise,
    required this.l10n,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);

    final metaParts = <String>[
      if (exercise.muscleGroup != null && exercise.muscleGroup!.isNotEmpty)
        l10n.exerciseListMuscleGroupPrefix(exercise.muscleGroup!),
      if (exercise.equipment != null && exercise.equipment!.isNotEmpty)
        l10n.exerciseListEquipmentPrefix(exercise.equipment!),
    ];

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (metaParts.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        metaParts.join(' · '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                child: IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: instrument.peakEffortColor,
                  ),
                  tooltip: l10n.exerciseListDelete,
                  onPressed: onDelete,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
