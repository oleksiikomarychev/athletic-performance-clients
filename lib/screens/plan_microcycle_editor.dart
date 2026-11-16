import 'package:flutter/material.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'dart:async';
import 'package:workout_app/models/microcycle.dart';
import 'package:workout_app/models/plan_schedule.dart';
import 'package:workout_app/services/api_client.dart';
import 'package:workout_app/services/mesocycle_service.dart';
import 'package:workout_app/models/exercise_definition.dart';
import 'package:workout_app/screens/exercise_selection_screen.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';

class PlanMicrocycleEditor extends StatefulWidget {
  final Microcycle microcycle;

  const PlanMicrocycleEditor({super.key, required this.microcycle});

  @override
  State<PlanMicrocycleEditor> createState() => _PlanMicrocycleEditorState();
}

class _PlanMicrocycleEditorState extends State<PlanMicrocycleEditor> {
  late Microcycle _editing;
  bool _saving = false;
  String? _error;
  bool _dirty = false;
  Timer? _autosaveTimer;
  static const _autosaveDelay = Duration(milliseconds: 1200);

  late final MesocycleService _mesoService;

  @override
  void initState() {
    super.initState();
    _editing = widget.microcycle;
    _mesoService = MesocycleService(apiClient: ApiClient());
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    super.dispose();
  }

  void _markDirtyAndScheduleSave() {
    _dirty = true;
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(_autosaveDelay, () {
      if (mounted && _dirty && !_saving) {
        _save();
      }
    });
  }

  Future<void> _bulkEditExerciseSets({
    required int workoutIdx,
    required int exerciseIdx,
  }) async {
    final intensityCtrl = TextEditingController();
    final effortCtrl = TextEditingController();
    final volumeCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx);
        return AlertDialog(
          title: Text(l10n.microEditorMassEditTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: intensityCtrl,
                decoration: InputDecoration(labelText: l10n.microEditorIntensityOpt),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: effortCtrl,
                decoration: InputDecoration(labelText: l10n.microEditorRpeOpt),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: volumeCtrl,
                decoration: InputDecoration(labelText: l10n.microEditorRepsOpt),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                final intensity = int.tryParse(intensityCtrl.text);
                final effort = int.tryParse(effortCtrl.text);
                final volume = int.tryParse(volumeCtrl.text);
                setState(() {
                  final ex = _editing.planWorkouts[workoutIdx].exercises[exerciseIdx];
                  final newSets = <PlanSet>[];
                  for (final s in ex.sets) {
                    newSets.add(PlanSet(
                      id: s.id,
                      orderIndex: s.orderIndex,
                      intensity: intensity ?? s.intensity,
                      effort: effort ?? s.effort,
                      volume: volume ?? s.volume,
                      planExerciseId: s.planExerciseId,
                    ));
                  }
                  _editing.planWorkouts[workoutIdx].exercises[exerciseIdx] = PlanExercise(
                    id: ex.id,
                    exerciseDefinitionId: ex.exerciseDefinitionId,
                    exerciseName: ex.exerciseName,
                    orderIndex: ex.orderIndex,
                    planWorkoutId: ex.planWorkoutId,
                    sets: newSets,
                  );
                  _markDirtyAndScheduleSave();
                });
                Navigator.of(ctx).pop();
              },
              child: Text(l10n.apply),
            ),
          ],
        );
      },
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final schedule = _toSchedule(_editing);
      await _mesoService.updateMicrocycle(
        _editing.id,
        MicrocycleUpdateDto(
          name: _editing.name,
          daysCount: _editing.daysCount,
          schedule: schedule,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).microEditorSaved)),
      );
      setState(() {
        _dirty = false;
      });
    } catch (e) {
      setState(() {
        _error = AppLocalizations.of(context).microEditorSaveError(e.toString());
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Map<String, List<ExerciseScheduleItemDto>> _toSchedule(Microcycle micro) {

    final map = <String, List<ExerciseScheduleItemDto>>{};
    for (final pw in micro.planWorkouts) {
      final label = pw.dayLabel.trim();
      int? day;
      if (label.toLowerCase().startsWith('day ')) {
        final rest = label.substring(4).trim();
        day = int.tryParse(rest);
      }
      day ??= (pw.orderIndex + 1);
      final key = day.toString();
      final items = <ExerciseScheduleItemDto>[];
      for (final ex in pw.exercises) {
        final sets = ex.sets
            .map((s) => ParamsSets(
                  intensity: s.intensity?.toDouble(),
                  effort: s.effort?.toDouble(),
                  volume: s.volume?.toDouble(),
                ))
            .toList();
        items.add(ExerciseScheduleItemDto(
          id: 0,
          exerciseId: ex.exerciseDefinitionId,
          sets: sets,
          name: '',
          exercises: const [],
        ));
      }
      if (items.isNotEmpty) {
        map[key] = items;
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final dimensions = UiDimensions.of(context);

    return AssistantChatHost(
      contextBuilder: () async => {
        'screen': 'plan_microcycle_editor',
        'entities': {
          'microcycle_id': _editing.id,
          'microcycle_name': _editing.name,
          'workouts_count': _editing.planWorkouts.length,
          'dirty': _dirty,
        },
      },
      builder: (context, openChat) {
        final l10n = AppLocalizations.of(context);
        return Scaffold(
          appBar: PrimaryAppBar(
            title: l10n.microEditorTitle(_editing.name),
            onTitleTap: openChat,
            actions: [
              SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  tooltip: l10n.planEditorDeleteMicrocycleTooltip,
                  style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    tapTargetSize: MaterialTapTargetSize.padded,
                  ),
                  onPressed: _confirmDeleteMicrocycle,
                  icon: Icon(Icons.delete_outline, color: colors.error),
                ),
              ),
              SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  tooltip: l10n.tooltipSave,
                  style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    tapTargetSize: MaterialTapTargetSize.padded,
                  ),
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.all(dimensions.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_dirty)
                  Padding(
                    padding: EdgeInsets.only(bottom: dimensions.rowGap),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: InstrumentTheme.cardDecoration(
                        context,
                        color: instrument.moderateEffortColor.withValues(
                          alpha: 0.12,
                        ),
                        borderColor: instrument.moderateEffortColor.withValues(
                          alpha: 0.45,
                        ),
                        radius: 10,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: instrument.moderateEffortColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.microEditorUnsavedChanges,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: instrument.moderateEffortColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_error != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: dimensions.rowGap),
                    child: Text(
                      _error!,
                      style: TextStyle(color: colors.error),
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    itemCount: _editing.planWorkouts.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(height: dimensions.rowGap),
                    itemBuilder: (context, wIdx) =>
                        _buildWorkoutTile(context, wIdx, dimensions),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWorkoutTile(
    BuildContext context,
    int wIdx,
    UiDimensions dimensions,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final pw = _editing.planWorkouts[wIdx];
    return Container(
      decoration: InstrumentTheme.cardDecoration(
        context,
        color: colors.surfaceContainerLow,
        radius: 14,
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: EdgeInsets.symmetric(
          horizontal: dimensions.cardPadding,
          vertical: 4,
        ),
        childrenPadding: EdgeInsets.fromLTRB(
          dimensions.cardPadding,
          0,
          dimensions.cardPadding,
          dimensions.cardPadding,
        ),
        title: Text(
          pw.dayLabel,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          AppLocalizations.of(context).microEditorWorkoutMeta(
            pw.exercises.length.toString(),
            pw.orderIndex.toString(),
          ),
          style: InstrumentTheme.tabular(InstrumentTheme.microLabel(context)),
        ),
        children: [
          for (int eIdx = 0; eIdx < pw.exercises.length; eIdx++)
            _buildExerciseSection(context, wIdx, eIdx, dimensions),
        ],
      ),
    );
  }

  Widget _buildExerciseSection(
    BuildContext context,
    int wIdx,
    int eIdx,
    UiDimensions dimensions,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final ex = _editing.planWorkouts[wIdx].exercises[eIdx];

    return Container(
      margin: EdgeInsets.only(top: dimensions.rowGap),
      padding: EdgeInsets.all(dimensions.cardPadding),
      decoration: InstrumentTheme.cardDecoration(
        context,
        color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
        radius: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ex.exerciseName,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  tapTargetSize: MaterialTapTargetSize.padded,
                ),
                onPressed: () => _replaceExercise(wIdx, eIdx, ex),
                icon: const Icon(Icons.swap_horiz, size: 18),
                label: Text(AppLocalizations.of(context).planEditorReplace),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  tapTargetSize: MaterialTapTargetSize.padded,
                ),
                onPressed: () => _addSet(wIdx, eIdx, ex),
                icon: const Icon(Icons.add, size: 18),
                label: Text(AppLocalizations.of(context).microEditorSetLabel),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  tapTargetSize: MaterialTapTargetSize.padded,
                ),
                onPressed: () =>
                    _bulkEditExerciseSets(workoutIdx: wIdx, exerciseIdx: eIdx),
                icon: const Icon(Icons.tune, size: 18),
                label: Text(AppLocalizations.of(context).planEditorBulkShort),
              ),
            ],
          ),
          SizedBox(height: dimensions.rowGap),
          for (int sIdx = 0; sIdx < ex.sets.length; sIdx++) ...[
            if (sIdx > 0) SizedBox(height: dimensions.rowGap),
            _buildPlanSetRow(
              context,
              wIdx: wIdx,
              eIdx: eIdx,
              sIdx: sIdx,
              ex: ex,
              set: ex.sets[sIdx],
              dimensions: dimensions,
              instrument: instrument,
              colors: colors,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlanSetRow(
    BuildContext context, {
    required int wIdx,
    required int eIdx,
    required int sIdx,
    required PlanExercise ex,
    required PlanSet set,
    required UiDimensions dimensions,
    required InstrumentTheme instrument,
    required ColorScheme colors,
  }) {
    final rpeAccent = instrument.colorForRpe(set.effort?.toDouble(), colors);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 28,
          child: Text(
            '#${sIdx + 1}',
            style: InstrumentTheme.tabular(
              InstrumentTheme.microLabel(context),
            ),
          ),
        ),
        Expanded(
          child: _buildNumericCell(
            context,
            key: ValueKey('pm-$wIdx-$eIdx-$sIdx-int'),
            initialValue: set.intensity?.toString() ?? '',
            labelText: '%1RM',
            onChanged: (val) => _updateSet(
              wIdx,
              eIdx,
              sIdx,
              intensity: val,
              updateIntensity: true,
            ),
          ),
        ),
        SizedBox(width: dimensions.rowGap),
        Expanded(
          child: _buildNumericCell(
            context,
            key: ValueKey('pm-$wIdx-$eIdx-$sIdx-rpe'),
            initialValue: set.effort?.toString() ?? '',
            labelText: 'RPE',
            accentColor: set.effort != null ? rpeAccent : null,
            onChanged: (val) => _updateSet(
              wIdx,
              eIdx,
              sIdx,
              effort: val,
              updateEffort: true,
            ),
          ),
        ),
        SizedBox(width: dimensions.rowGap),
        Expanded(
          child: _buildNumericCell(
            context,
            key: ValueKey('pm-$wIdx-$eIdx-$sIdx-vol'),
            initialValue: set.volume?.toString() ?? '',
            labelText: AppLocalizations.of(context).planEditorReps,
            onChanged: (val) => _updateSet(
              wIdx,
              eIdx,
              sIdx,
              volume: val,
              updateVolume: true,
            ),
          ),
        ),
        SizedBox(
          width: 48,
          height: 48,
          child: IconButton(
            tooltip: AppLocalizations.of(context).deleteSetTooltip,
            style: IconButton.styleFrom(
              minimumSize: const Size(48, 48),
              tapTargetSize: MaterialTapTargetSize.padded,
            ),
            icon: Icon(Icons.delete_outline, color: colors.error, size: 20),
            onPressed: () {
              setState(() {
                final sets = List<PlanSet>.from(
                  _editing.planWorkouts[wIdx].exercises[eIdx].sets,
                );
                if (sIdx >= 0 && sIdx < sets.length) {
                  sets.removeAt(sIdx);
                  _editing.planWorkouts[wIdx].exercises[eIdx] = PlanExercise(
                    id: ex.id,
                    exerciseDefinitionId: ex.exerciseDefinitionId,
                    exerciseName: ex.exerciseName,
                    orderIndex: ex.orderIndex,
                    planWorkoutId: ex.planWorkoutId,
                    sets: sets,
                  );
                  _markDirtyAndScheduleSave();
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNumericCell(
    BuildContext context, {
    Key? key,
    required String initialValue,
    required String labelText,
    Color? accentColor,
    required ValueChanged<int?> onChanged,
  }) {
    final theme = Theme.of(context);
    final baseDecoration = InstrumentTheme.inputDecoration(
      context,
      labelText: labelText,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    );
    final decoration = accentColor == null
        ? baseDecoration
        : baseDecoration.copyWith(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: accentColor.withValues(alpha: 0.65),
                width: 1.0,
              ),
            ),
          );
    return TextFormField(
      key: key,
      initialValue: initialValue,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: InstrumentTheme.tabular(
        (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
          fontWeight: FontWeight.w700,
          color: accentColor,
        ),
      ),
      decoration: decoration,
      onChanged: (v) => onChanged(int.tryParse(v)),
    );
  }

  void _updateSet(
    int wIdx,
    int eIdx,
    int sIdx, {
    int? intensity,
    bool updateIntensity = false,
    int? effort,
    bool updateEffort = false,
    int? volume,
    bool updateVolume = false,
  }) {
    setState(() {
      final current = _editing.planWorkouts[wIdx].exercises[eIdx].sets[sIdx];
      _editing.planWorkouts[wIdx].exercises[eIdx].sets[sIdx] = PlanSet(
        id: current.id,
        orderIndex: current.orderIndex,
        intensity: updateIntensity ? intensity : current.intensity,
        effort: updateEffort ? effort : current.effort,
        volume: updateVolume ? volume : current.volume,
        planExerciseId: current.planExerciseId,
      );
      _markDirtyAndScheduleSave();
    });
  }

  Future<void> _replaceExercise(int wIdx, int eIdx, PlanExercise ex) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ExerciseSelectionScreen()),
    );
    if (result is ExerciseDefinition && mounted) {
      setState(() {
        _editing.planWorkouts[wIdx].exercises[eIdx] = PlanExercise(
          id: ex.id,
          exerciseDefinitionId: result.id ?? ex.exerciseDefinitionId,
          exerciseName: result.name,
          orderIndex: ex.orderIndex,
          planWorkoutId: ex.planWorkoutId,
          sets: ex.sets,
        );
        _markDirtyAndScheduleSave();
      });
    }
  }

  void _addSet(int wIdx, int eIdx, PlanExercise ex) {
    setState(() {
      final sets = List<PlanSet>.from(
        _editing.planWorkouts[wIdx].exercises[eIdx].sets,
      )..add(const PlanSet(id: 0));
      _editing.planWorkouts[wIdx].exercises[eIdx] = PlanExercise(
        id: ex.id,
        exerciseDefinitionId: ex.exerciseDefinitionId,
        exerciseName: ex.exerciseName,
        orderIndex: ex.orderIndex,
        planWorkoutId: ex.planWorkoutId,
        sets: sets,
      );
      _markDirtyAndScheduleSave();
    });
  }

  Future<void> _confirmDeleteMicrocycle() async {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.planEditorDeleteMicrocycleTitle),
        content: Text(
          l10n.planEditorDeleteMicrocycleBody(_editing.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: colors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _mesoService.deleteMicrocycle(_editing.id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.planEditorMicrocycleDeleted)));
        Navigator.of(context).pop({'deletedId': _editing.id});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.planEditorDeleteFailed(e.toString()))));
      }
    }
  }
}
