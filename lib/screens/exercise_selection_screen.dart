import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/services/service_locator.dart';
import 'package:workout_app/src/widgets/snack_utils.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/empty_state.dart';
import 'package:workout_app/widgets/interface_maker_sheet.dart';
import 'package:workout_app/widgets/loading_indicator.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';

import '../models/exercise_definition.dart';

class ExerciseSelectionScreen extends ConsumerStatefulWidget {
  const ExerciseSelectionScreen({super.key});

  @override
  ConsumerState<ExerciseSelectionScreen> createState() =>
      _ExerciseSelectionScreenState();
}

class _ExerciseSelectionScreenState
    extends ConsumerState<ExerciseSelectionScreen> {
  List<ExerciseDefinition> _exercises = [];
  List<ExerciseDefinition> _filteredExercises = [];
  List<String> _muscleGroups = [];
  String? _selectedMuscleGroup;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExercises();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    try {
      final exerciseService = ref.read(exerciseServiceProvider);
      final exercises = await exerciseService.getExerciseDefinitions();
      if (!mounted) return;
      final groups = exercises
          .map((e) => e.muscleGroup?.trim())
          .whereType<String>()
          .where((g) => g.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      setState(() {
        _exercises = exercises;
        _muscleGroups = groups;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showAppSnackBar(
        context,
        AppLocalizations.of(context).exerciseLoadError(e.toString()),
        isError: true,
      );
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredExercises = _exercises.where((exercise) {
        if (_selectedMuscleGroup != null &&
            exercise.muscleGroup != _selectedMuscleGroup) {
          return false;
        }
        if (query.isEmpty) return true;
        return exercise.name.toLowerCase().contains(query) ||
            (exercise.muscleGroup?.toLowerCase().contains(query) ?? false) ||
            (exercise.equipment?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AssistantChatHost(
      contextBuilder: () async => {
        'screen': 'exercise_selection',
        'entities': {'filtered_count': _filteredExercises.length},
      },
      builder: (context, openChat) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final instrument = InstrumentTheme.of(context);
        final topInset = AmbientScaffoldShell.topContentInset(context);
        final bottomInset = AmbientScaffoldShell.bottomContentInset(context);

        final l10n = AppLocalizations.of(context);
        return AmbientScaffoldShell(
          appBar: PrimaryAppBar(
            title: l10n.exerciseSelectTitle,
            onTitleTap: openChat,
            showBack: true,
          ),
          body: _isLoading
              ? Padding(
                  padding: EdgeInsets.only(top: topInset, bottom: bottomInset),
                  child: const LoadingIndicator(),
                )
              : ListView(
                  padding: EdgeInsets.fromLTRB(
                    0,
                    topInset + 8,
                    0,
                    bottomInset + 24,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _searchController,
                        decoration: InstrumentTheme.inputDecoration(
                          context,
                          labelText: l10n.exerciseSearchLabel,
                          prefixIcon: const Icon(Icons.search_rounded),
                        ),
                      ),
                    ),
                    if (_muscleGroups.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      CanvasPillStrip(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        items: [
                          CanvasPillItem(
                            label: l10n.filterAll,
                            selected: _selectedMuscleGroup == null,
                            onTap: () {
                              _selectedMuscleGroup = null;
                              _applyFilters();
                            },
                          ),
                          for (final g in _muscleGroups)
                            CanvasPillItem(
                              label: g,
                              selected: _selectedMuscleGroup == g,
                              onTap: () {
                                _selectedMuscleGroup = g;
                                _applyFilters();
                              },
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _filteredExercises.isEmpty
                          ? EmptyState(
                              icon: Icons.search_off_rounded,
                              title: l10n.exerciseEmptyTitle,
                              description: l10n.exerciseEmptyDescription,
                            )
                          : Container(
                              decoration:
                                  InstrumentTheme.instrumentCardDecoration(
                                    context,
                                  ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      12,
                                      16,
                                      10,
                                    ),
                                    child: Text(
                                      'DIRECTORY · ${_filteredExercises.length}',
                                      style: InstrumentTheme.microLabel(context)
                                          .copyWith(
                                            fontFeatures: const [
                                              FontFeature.tabularFigures(),
                                            ],
                                          ),
                                    ),
                                  ),
                                  Container(
                                    height: 1,
                                    color: instrument.hairlineBorder,
                                  ),
                                  for (
                                    int i = 0;
                                    i < _filteredExercises.length;
                                    i++
                                  ) ...[
                                    if (i > 0)
                                      Container(
                                        height: 1,
                                        color: instrument.hairlineBorder,
                                      ),
                                    _SelectableExerciseRow(
                                      exercise: _filteredExercises[i],
                                      subtitleColor: scheme.onSurfaceVariant,
                                      onTap: () => Navigator.of(
                                        context,
                                      ).pop(_filteredExercises[i]),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _SelectableExerciseRow extends StatelessWidget {
  final ExerciseDefinition exercise;
  final Color subtitleColor;
  final VoidCallback onTap;

  const _SelectableExerciseRow({
    required this.exercise,
    required this.subtitleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final meta = <String>[
      if (exercise.muscleGroup != null)
        l10n.exerciseMuscleGroupMeta(exercise.muscleGroup!),
      if (exercise.equipment != null)
        l10n.exerciseEquipmentMeta(exercise.equipment!),
    ];

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        meta.join(' · '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: subtitleColor),
            ],
          ),
        ),
      ),
    );
  }
}
