import 'package:flutter/material.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/models/calendar_plan.dart';
import 'package:workout_app/models/mesocycle.dart';
import 'package:workout_app/models/microcycle.dart';
import 'package:workout_app/models/plan_schedule.dart';
import 'package:workout_app/services/api_client.dart';
import 'package:workout_app/services/mesocycle_service.dart';
import 'package:workout_app/models/exercise_definition.dart';
import 'package:workout_app/screens/exercise_selection_screen.dart';
import 'package:workout_app/screens/plan_microcycle_editor.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/mode_value_control.dart';
import 'package:workout_app/screens/macros/macros_list_screen.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';
import 'package:workout_app/config/rpe_table.dart' as rpe_table;

class _MicroDiff {
  final int id;
  final String name;
  final int totalSets;
  final int changedSets;
  final int changedIntensity;
  final int changedEffort;
  final int changedVolume;

  const _MicroDiff({
    required this.id,
    required this.name,
    required this.totalSets,
    required this.changedSets,
    required this.changedIntensity,
    required this.changedEffort,
    required this.changedVolume,
  });
}

enum RecalcTarget { auto, intensity, effort, reps }
enum FixStrategy { none, fixReps, fixIntensity }

class PlanEditorScreen extends StatefulWidget {
  final CalendarPlan plan;

  const PlanEditorScreen({super.key, required this.plan});

  @override
  State<PlanEditorScreen> createState() => _PlanEditorScreenState();
}

class _PlanEditorScreenState extends State<PlanEditorScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  final Set<int> _selectedMicrocycleIds = {};
  bool _batchSaving = false;
  late final MesocycleService _mesoService;

  @override
  void initState() {
    super.initState();
    _mesoService = MesocycleService(apiClient: ApiClient());
    _searchCtrl.addListener(() {
      setState(() {
        _query = _searchCtrl.text.trim().toLowerCase();
      });
    });
  }

  Future<void> _openMassReplaceDialog() async {
    if (_selectedMicrocycleIds.isEmpty) return;


    final idToMicro = <int, Microcycle>{};
    for (final meso in widget.plan.mesocycles) {
      for (final micro in meso.microcycles) {
        if (_selectedMicrocycleIds.contains(micro.id)) {
          idToMicro[micro.id] = micro;
        }
      }
    }


    final Map<int, String> unique = {};
    final Map<int, int> counts = {};
    for (final micro in idToMicro.values) {
      for (final w in micro.planWorkouts) {
        for (final ex in w.exercises) {
          unique[ex.exerciseDefinitionId] = ex.exerciseName;
          counts[ex.exerciseDefinitionId] = (counts[ex.exerciseDefinitionId] ?? 0) + 1;
        }
      }
    }

    final exerciseIdsSorted = unique.keys.toList()..sort((a, b) => unique[a]!.toLowerCase().compareTo(unique[b]!.toLowerCase()));

    final TextEditingController dayCtrl = TextEditingController();
    Set<int> selectedSources = exerciseIdsSorted.toSet();
    ExerciseDefinition? target;
    String? error;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final l10n = AppLocalizations.of(ctx);
          return AlertDialog(
            title: Text(l10n.planEditorMassReplaceTitle),
            content: SizedBox(
              width: (MediaQuery.sizeOf(ctx).width - 96).clamp(0.0, 440.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      TextButton.icon(
                          onPressed: () async {
                            final res = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ExerciseSelectionScreen(),
                              ),
                            );
                            if (res is ExerciseDefinition) {
                              setState(() => target = res);
                            }
                          },
                          icon: const Icon(Icons.search),
                          label: Text(
                            target == null
                                ? l10n.planEditorChooseTarget
                                : l10n.planEditorTargetPrefix(target!.name),
                          ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            if (selectedSources.length == exerciseIdsSorted.length) {
                              selectedSources.clear();
                            } else {
                              selectedSources = exerciseIdsSorted.toSet();
                            }
                          });
                        },
                        child: Text(
                          selectedSources.length == exerciseIdsSorted.length
                              ? l10n.planEditorClearAll
                              : l10n.planEditorSelectAll,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: (MediaQuery.sizeOf(ctx).height -
                            MediaQuery.viewInsetsOf(ctx).bottom -
                            320)
                        .clamp(100.0, 260.0),
                    child: Scrollbar(
                      child: ListView(
                        children: exerciseIdsSorted.map((id) => CheckboxListTile(
                          dense: true,
                          value: selectedSources.contains(id),
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                selectedSources.add(id);
                              } else {
                                selectedSources.remove(id);
                              }
                            });
                          },
                          title: Text(unique[id] ?? l10n.planEditorExerciseIdFallback(id)),
                          subtitle: Text(l10n.planEditorOccurrences(counts[id] ?? 0)),
                          controlAffinity: ListTileControlAffinity.leading,
                        )).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: dayCtrl,
                    decoration: InputDecoration(labelText: l10n.planEditorDayFilterLabel),
                    keyboardType: TextInputType.number,
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l10n.cancel)),
              FilledButton(
                onPressed: () async {
                  final dayIndex = int.tryParse(dayCtrl.text);
                  if (target == null) {
                    setState(() => error = l10n.planEditorSelectTargetError);
                    return;
                  }
                  if (selectedSources.isEmpty) {
                    setState(() => error = l10n.planEditorSelectSourceError);
                    return;
                  }
                  Navigator.of(ctx).pop();
                  await _previewAndMaybeApplyReplace(
                    sourceExerciseIds: selectedSources,
                    target: target!,
                    dayIndex: dayIndex,
                  );
                },
                child: Text(l10n.planEditorPreview),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _previewAndMaybeApplyReplace({
    required Set<int> sourceExerciseIds,
    required ExerciseDefinition target,
    int? dayIndex,
  }) async {
    if (_selectedMicrocycleIds.isEmpty) return;
    List<int> validIds = const [];
    try {
      validIds = await _mesoService.validateMicrocycles(_selectedMicrocycleIds.toList());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).planEditorRightsCheckUnavailable(e.toString()),
            ),
          ),
        );
      }
      validIds = _selectedMicrocycleIds.toList();
    }

    if (validIds.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).planEditorNoAccessibleMicrocycles,
            ),
          ),
        );
      }
      return;
    }

    final idToMicro = <int, Microcycle>{};
    for (final meso in widget.plan.mesocycles) {
      for (final micro in meso.microcycles) {
        idToMicro[micro.id] = micro;
      }
    }

    final diffs = <Map<String, dynamic>>[];
    int totalEx = 0, totalSets = 0;
    for (final id in validIds) {
      final micro = idToMicro[id];
      if (micro == null) continue;
      final d = _simulateReplaceDiff(micro, sourceExerciseIds: sourceExerciseIds, dayIndex: dayIndex);
      if ((d['ex'] ?? 0) > 0) {
        diffs.add({'name': micro.name, 'ex': d['ex'], 'sets': d['sets']});
        totalEx += d['ex'] as int;
        totalSets += d['sets'] as int;
      }
    }

    if (totalEx == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).planEditorNoExercisesToReplace),
          ),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx);
        return AlertDialog(
          title: Text(l10n.planEditorPreviewReplaceTitle),
          content: SizedBox(
            width: (MediaQuery.sizeOf(ctx).width - 96).clamp(0.0, 440.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.planEditorPreviewTarget(target.name)),
                Text(l10n.planEditorPreviewTotals(totalEx, totalSets)),
                const SizedBox(height: 8),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: diffs.map((e) => ListTile(
                        dense: true,
                        title: Text(e['name'] as String),
                        subtitle: Text(
                          l10n.planEditorPreviewMicroStats(e['ex'] as int, e['sets'] as int),
                        ),
                      )).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.cancel)),
            FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l10n.apply)),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _applyMassReplace(sourceExerciseIds: sourceExerciseIds, target: target, dayIndex: dayIndex);
    }
  }

  Map<String, int> _simulateReplaceDiff(
    Microcycle micro, {
    required Set<int> sourceExerciseIds,
    int? dayIndex,
  }) {
    int exCount = 0, setCount = 0;
    for (final w in micro.planWorkouts) {
      if (dayIndex != null) {
        final label = w.dayLabel.trim().toLowerCase();
        int? d;
        if (label.startsWith('day ')) {
          d = int.tryParse(label.substring(4).trim());
        }
        d ??= (w.orderIndex + 1);
        if (d != dayIndex) continue;
      }
      for (final ex in w.exercises) {
        if (sourceExerciseIds.contains(ex.exerciseDefinitionId)) {
          exCount += 1;
          setCount += ex.sets.length;
        }
      }
    }
    return {'ex': exCount, 'sets': setCount};
  }

  Future<void> _applyMassReplace({
    required Set<int> sourceExerciseIds,
    required ExerciseDefinition target,
    int? dayIndex,
  }) async {
    if (_selectedMicrocycleIds.isEmpty) return;
    setState(() => _batchSaving = true);
    try {
      final validIds = await _mesoService.validateMicrocycles(_selectedMicrocycleIds.toList());

      final idToMicro = <int, Microcycle>{};
      for (final meso in widget.plan.mesocycles) {
        for (final micro in meso.microcycles) {
          idToMicro[micro.id] = micro;
        }
      }

      int success = 0, failed = 0;
      for (final id in validIds) {
        final micro = idToMicro[id];
        if (micro == null) { failed++; continue; }

        bool changed = false;
        for (int wi = 0; wi < micro.planWorkouts.length; wi++) {
          final w = micro.planWorkouts[wi];
          if (dayIndex != null) {
            final label = w.dayLabel.trim().toLowerCase();
            int? d;
            if (label.startsWith('day ')) {
              d = int.tryParse(label.substring(4).trim());
            }
            d ??= (w.orderIndex + 1);
            if (d != dayIndex) {
              continue;
            }
          }
          final newExercises = <PlanExercise>[];
          for (final ex in w.exercises) {
            if (sourceExerciseIds.contains(ex.exerciseDefinitionId)) {
              newExercises.add(PlanExercise(
                id: ex.id,
                exerciseDefinitionId: target.id ?? ex.exerciseDefinitionId,
                exerciseName: target.name,
                orderIndex: ex.orderIndex,
                planWorkoutId: ex.planWorkoutId,
                sets: ex.sets,
              ));
              changed = true;
            } else {
              newExercises.add(ex);
            }
          }
          micro.planWorkouts[wi] = PlanWorkout(
            id: w.id,
            microcycleId: w.microcycleId,
            dayLabel: w.dayLabel,
            orderIndex: w.orderIndex,
            exercises: newExercises,
          );
        }

        if (!changed) continue;

        final schedule = _toSchedule(micro);
        try {
          await _mesoService.updateMicrocycle(id, MicrocycleUpdateDto(
            name: micro.name,
            daysCount: micro.daysCount,
            schedule: schedule,
          ));
          success++;
        } catch (_) {
          failed++;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).planEditorApplyReplaceResult(success, failed),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _batchSaving = false);
    }
  }

  int? _nearestRepsForIntensity(int intensity, int desired) {
    int? best;
    int bestDelta = 1 << 30;
    for (int rpe = 10; rpe >= 4; rpe--) {
      final reps = rpe_table.RpeTable.getReps(intensity, rpe);
      if (reps == null) continue;
      final d = (reps - desired).abs();
      if (d < bestDelta) { bestDelta = d; best = reps; }
    }
    return best;
  }

  Map<String, int> _simulateDiff(
    Microcycle micro, {
    String? intensityMode,
    double? intensityValue,
    String? effortMode,
    double? effortValue,
    String? volumeMode,
    double? volumeValue,
    Set<int>? exerciseIds,
    int? dayIndex,
    String? recalcTarget,
    String? fixStrategy,
  }) {
    int total = 0, changed = 0, ci = 0, ce = 0, cv = 0, invalid = 0;
    int? _applyInt(int? orig, String? mode, double? val) {
      if (mode == null || val == null) return orig;
      if (mode == 'set') return val.round();
      if (mode == 'offset') {
        if (orig == null) return orig;
        return (orig + val).round();
      }
      if (mode == 'scale') {
        if (orig == null) return orig;
        return (orig * val).round();
      }
      return orig;
    }
    int? _clampIntensity(int? v) => v == null ? null : v.clamp(0, 100);
    int? _clampEffort(int? v) => v == null ? null : v.clamp(4, 10);
    int? _clampVolume(int? v) => v == null ? null : (v < 1 ? 1 : v);
    for (final w in micro.planWorkouts) {
      if (dayIndex != null) {
        final label = w.dayLabel.trim().toLowerCase();
        int? d;
        if (label.startsWith('day ')) {
          d = int.tryParse(label.substring(4).trim());
        }
        d ??= (w.orderIndex + 1);
        if (d != dayIndex) continue;
      }
      for (final ex in w.exercises) {
        if (exerciseIds != null) {
          if (exerciseIds.isEmpty || !exerciseIds.contains(ex.exerciseDefinitionId)) {
            continue;
          }
        }
        for (final s in ex.sets) {
          total += 1;
          int? ni = _clampIntensity(_applyInt(s.intensity, intensityMode, intensityValue));
          int? ne = _clampEffort(_applyInt(s.effort, effortMode, effortValue));
          int? nv = _clampVolume(_applyInt(s.volume, volumeMode, volumeValue));

          String? target = recalcTarget;
          if (target == null || target == 'auto') {
            final bool chI = ni != s.intensity;
            final bool chE = ne != s.effort;
            final bool chV = nv != s.volume;
            if ((chI || chE) && !chV) {
              target = 'reps';
            } else if (chV && !(chI || chE)) {
              target = 'intensity';
            } else if (chI && chV && !chE) {
              target = 'rpe';
            } else {
              target = null;
            }
          }

          if (target == 'reps') {
            if (ni != null && ne != null) {
              final r = rpe_table.RpeTable.getReps(ni, ne);
              if (r != null) {
                nv = _clampVolume(r);
              } else {
                invalid += 1;
              }
            }
          } else if (target == 'rpe') {
            if (ni != null && nv != null) {
              final rpe = rpe_table.RpeTable.getRpe(ni, nv);
              if (rpe != null) {
                ne = _clampEffort(rpe);
              } else {

                invalid += 1;
                final strategy = fixStrategy ?? 'none';
                if (strategy == 'fixReps') {
                  final fixed = _nearestRepsForIntensity(ni, nv);
                  if (fixed != null) {
                    nv = _clampVolume(fixed);
                    final rpe2 = rpe_table.RpeTable.getRpe(ni, nv!);
                    if (rpe2 != null) ne = _clampEffort(rpe2);
                  }
                } else if (strategy == 'fixIntensity') {
                  final ii = rpe_table.RpeTable.getIntensity(nv, 10);
                  if (ii != null) {
                    ni = _clampIntensity(ii);
                    final rpe2 = rpe_table.RpeTable.getRpe(ni!, nv);
                    if (rpe2 != null) ne = _clampEffort(rpe2);
                  }
                }
              }
            }
          } else if (target == 'intensity') {
            if (nv != null && ne != null) {
              final ii = rpe_table.RpeTable.getIntensity(nv, ne);
              if (ii != null) {
                ni = _clampIntensity(ii);
              } else {
                invalid += 1;
              }
            }
          }

          bool any = false;
          if (ni != s.intensity) { ci += 1; any = true; }
          if (ne != s.effort) { ce += 1; any = true; }
          if (nv != s.volume) { cv += 1; any = true; }
          if (any) changed += 1;
        }
      }
    }
    return {'total': total, 'changed': changed, 'i': ci, 'e': ce, 'v': cv, 'invalid': invalid};
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _microHasMatch(Microcycle micro) {
    if (_query.isEmpty) return true;
    for (final w in micro.planWorkouts) {
      for (final ex in w.exercises) {
        if (ex.exerciseName.toLowerCase().contains(_query)) return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dimensions = UiDimensions.of(context);

    return AssistantChatHost(
      contextBuilder: () async => {
        'screen': 'plan_editor',
        'entities': {
          'calendar_plan_id': plan.id,
          'plan_name': plan.name,
          'mesocycles_count': plan.mesocycles.length,
          'selected_microcycles': _selectedMicrocycleIds.toList(),
          if (_query.isNotEmpty) 'search_query': _query,
        },
      },
      builder: (context, openChat) {
        final l10n = AppLocalizations.of(context);
        return Scaffold(
          appBar: PrimaryAppBar(
            title: l10n.planEditorTitle(plan.name),
            onTitleTap: openChat,
            actions: [
              SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  tooltip: l10n.planEditorMacros,
                  style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    tapTargetSize: MaterialTapTargetSize.padded,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MacrosListScreen(calendarPlanId: plan.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.auto_fix_high),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.all(dimensions.densePagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchCtrl,
                  decoration: InstrumentTheme.inputDecoration(
                    context,
                    hintText: l10n.planEditorSearchHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: l10n.actionClear,
                            style: IconButton.styleFrom(
                              minimumSize: const Size(48, 48),
                              tapTargetSize: MaterialTapTargetSize.padded,
                            ),
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                          ),
                  ),
                ),
                if (_selectedMicrocycleIds.isNotEmpty) ...[
                  SizedBox(height: dimensions.rowGap),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: dimensions.cardPadding,
                      vertical: 8,
                    ),
                    decoration: InstrumentTheme.cardDecoration(
                      context,
                      color: colors.primaryContainer.withValues(alpha: 0.35),
                      borderColor: colors.primary.withValues(alpha: 0.45),
                      radius: 12,
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          l10n.planEditorSelectedCount(_selectedMicrocycleIds.length.toString()),
                          style: InstrumentTheme.tabular(
                            InstrumentTheme.microLabel(
                              context,
                              color: colors.primary,
                            ),
                          ),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: _batchSaving ? null : _openMassEditDialog,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(48, 48),
                            tapTargetSize: MaterialTapTargetSize.padded,
                          ),
                          icon: _batchSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.tune, size: 18),
                          label: Text(l10n.planEditorBulkShort),
                        ),
                        FilledButton.tonalIcon(
                          onPressed:
                              _batchSaving ? null : _openMassReplaceDialog,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(48, 48),
                            tapTargetSize: MaterialTapTargetSize.padded,
                          ),
                          icon: const Icon(Icons.swap_horiz, size: 18),
                          label: Text(l10n.planEditorReplace),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: dimensions.rowGap),
                Text(
                  l10n.planEditorMesocyclesCount(plan.mesocycles.length.toString()),
                  style: InstrumentTheme.tabular(
                    InstrumentTheme.microLabel(context),
                  ),
                ),
                SizedBox(height: dimensions.rowGap),
                Expanded(
                  child: ListView.separated(
                    itemCount: plan.mesocycles.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(height: dimensions.rowGap),
                    itemBuilder: (context, index) {
                      final meso = plan.mesocycles[index];
                      final filtered =
                          meso.microcycles.where(_microHasMatch).toList();
                      if (filtered.isEmpty) return const SizedBox.shrink();
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
                          title: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      meso.name,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      l10n.planEditorMicrocyclesCount(filtered.length.toString()),
                                      style: InstrumentTheme.tabular(
                                        InstrumentTheme.microLabel(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 48,
                                height: 48,
                                child: IconButton(
                                  tooltip: l10n.planEditorDeleteMesocycleTooltip,
                                  style: IconButton.styleFrom(
                                    minimumSize: const Size(48, 48),
                                    tapTargetSize:
                                        MaterialTapTargetSize.padded,
                                  ),
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: colors.error,
                                  ),
                                  onPressed: () =>
                                      _confirmDeleteMesocycle(meso),
                                ),
                              ),
                            ],
                          ),
                          children: filtered.map((micro) {
                            final selected =
                                _selectedMicrocycleIds.contains(micro.id);
                            return Container(
                              margin: EdgeInsets.only(top: dimensions.rowGap),
                              decoration: InstrumentTheme.cardDecoration(
                                context,
                                color: selected
                                    ? colors.primaryContainer
                                        .withValues(alpha: 0.25)
                                    : colors.surfaceContainerHighest
                                        .withValues(alpha: 0.4),
                                borderColor: selected
                                    ? colors.primary.withValues(alpha: 0.55)
                                    : null,
                                radius: 10,
                              ),
                              child: CheckboxListTile(
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                value: selected,
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked == true) {
                                      _selectedMicrocycleIds.add(micro.id);
                                    } else {
                                      _selectedMicrocycleIds.remove(micro.id);
                                    }
                                  });
                                },
                                title: Text(
                                  micro.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  l10n.planEditorMicroDays(micro.daysCount ?? 0),
                                  style: InstrumentTheme.tabular(
                                    theme.textTheme.bodySmall ??
                                        const TextStyle(fontSize: 12),
                                  ),
                                ),
                                secondary: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 48,
                                      height: 48,
                                      child: IconButton(
                                        tooltip: l10n.planEditorEditMicrocycleTooltip,
                                        style: IconButton.styleFrom(
                                          minimumSize: const Size(48, 48),
                                          tapTargetSize:
                                              MaterialTapTargetSize.padded,
                                        ),
                                        icon: const Icon(Icons.chevron_right),
                                        onPressed: () =>
                                            _openMicrocycleEditor(meso, micro),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 48,
                                      height: 48,
                                      child: IconButton(
                                        tooltip: l10n.planEditorDeleteMicrocycleTooltip,
                                        style: IconButton.styleFrom(
                                          minimumSize: const Size(48, 48),
                                          tapTargetSize:
                                              MaterialTapTargetSize.padded,
                                        ),
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: colors.error,
                                        ),
                                        onPressed: () =>
                                            _confirmDeleteMicrocycle(
                                                meso, micro),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openMicrocycleEditor(
    Mesocycle meso,
    Microcycle micro,
  ) async {
    final changed = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanMicrocycleEditor(microcycle: micro),
      ),
    );
    if (!mounted) return;
    if (changed == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).planEditorChangesSaved)),
      );
    } else if (changed is Map<String, dynamic> && changed['deletedId'] != null) {
      final int did = (changed['deletedId'] as num).toInt();
      setState(() {
        meso.microcycles.removeWhere((mc) => mc.id == did);
        _selectedMicrocycleIds.remove(did);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).planEditorMicrocycleDeleted)),
      );
    }
  }

  Future<void> _confirmDeleteMesocycle(Mesocycle meso) async {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.planEditorDeleteMesocycleTitle),
        content: Text(
          l10n.planEditorDeleteMesocycleBody(meso.name),
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
      await _mesoService.deleteMesocycle(meso.id);
      if (mounted) {
        setState(() {
          widget.plan.mesocycles.removeWhere((m) => m.id == meso.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.planEditorMesocycleDeleted)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.planEditorDeleteFailed(e.toString()))),
        );
      }
    }
  }

  Future<void> _confirmDeleteMicrocycle(
    Mesocycle meso,
    Microcycle micro,
  ) async {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.planEditorDeleteMicrocycleTitle),
        content: Text(
          l10n.planEditorDeleteMicrocycleBody(micro.name),
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
      await _mesoService.deleteMicrocycle(micro.id);
      if (mounted) {
        setState(() {
          meso.microcycles.removeWhere((mc) => mc.id == micro.id);
          _selectedMicrocycleIds.remove(micro.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.planEditorMicrocycleDeleted)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.planEditorDeleteFailed(e.toString()))),
        );
      }
    }
  }

  Future<void> _openMassEditDialog() async {

    bool intensityEnabled = false;
    bool effortEnabled = false;
    bool volumeEnabled = false;
    ModeValue intensityMV = ModeValue(mode: ParamMode.set, value: 60.0);
    ModeValue effortMV = ModeValue(mode: ParamMode.set, value: 8.0);
    ModeValue volumeMV = ModeValue(mode: ParamMode.set, value: 8.0);
    RecalcTarget recalcTarget = RecalcTarget.auto;
    final dayCtrl = TextEditingController();


    final Map<int, String> unique = {};
    final Map<int, int> counts = {};
    for (final meso in widget.plan.mesocycles) {
      for (final micro in meso.microcycles) {
        for (final w in micro.planWorkouts) {
          for (final ex in w.exercises) {
            unique[ex.exerciseDefinitionId] = ex.exerciseName;
            counts[ex.exerciseDefinitionId] = (counts[ex.exerciseDefinitionId] ?? 0) + 1;
          }
        }
      }
    }
    final exerciseIdsSorted = unique.keys.toList()
      ..sort((a, b) => (unique[a] ?? '').toLowerCase().compareTo((unique[b] ?? '').toLowerCase()));
    Set<int> selectedExerciseIds = exerciseIdsSorted.toSet();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final l10n = AppLocalizations.of(ctx);
          return AlertDialog(
            title: Text(l10n.planEditorMassEditTitle),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ModeValueControl(
                    label: l10n.planEditorIntensity,
                    enabled: intensityEnabled,
                    onEnabledChanged: (v) => setState(() { intensityEnabled = v; }),
                    value: intensityMV,
                    onChanged: (mv) => setState(() { intensityMV = mv; }),
                    allowedModes: const [ParamMode.set, ParamMode.offset, ParamMode.scale],
                    modeTitles: {
                      ParamMode.set: l10n.planEditorModeSet,
                      ParamMode.offset: l10n.planEditorModeOffset,
                      ParamMode.scale: l10n.planEditorModeScale,
                    },
                    displayTextBuilder: (m, v) {
                      if (m == ParamMode.scale) return v.toStringAsFixed(2);
                      return '${v.toStringAsFixed((v % 1 == 0) ? 0 : 1)}%';
                    },
                    stepForMode: (m) {
                      switch (m) {
                        case ParamMode.set: return 1.0;
                        case ParamMode.offset: return 2.5;
                        case ParamMode.scale: return 0.01;
                      }
                    },
                    setMin: 0,
                    setMax: 100,
                    scaleMin: 0.01,
                  ),
                  const SizedBox(height: 8),
                  ModeValueControl(
                    label: 'RPE',
                    enabled: effortEnabled,
                    onEnabledChanged: (v) => setState(() { effortEnabled = v; }),
                    value: effortMV,
                    onChanged: (mv) => setState(() { effortMV = mv; }),
                    allowedModes: const [ParamMode.set, ParamMode.offset],
                    modeTitles: {
                      ParamMode.set: l10n.planEditorModeSet,
                      ParamMode.offset: l10n.planEditorModeOffset,
                    },
                    displayTextBuilder: (m, v) => v.toStringAsFixed(0),
                    stepForMode: (m) => 1.0,
                    setMin: 4,
                    setMax: 10,
                  ),
                  const SizedBox(height: 8),
                  ModeValueControl(
                    label: l10n.planEditorReps,
                    enabled: volumeEnabled,
                    onEnabledChanged: (v) => setState(() { volumeEnabled = v; }),
                    value: volumeMV,
                    onChanged: (mv) => setState(() { volumeMV = mv; }),
                    allowedModes: const [ParamMode.set, ParamMode.offset, ParamMode.scale],
                    modeTitles: {
                      ParamMode.set: l10n.planEditorModeSet,
                      ParamMode.offset: l10n.planEditorModeOffset,
                      ParamMode.scale: l10n.planEditorModeScale,
                    },
                    displayTextBuilder: (m, v) => m == ParamMode.scale ? v.toStringAsFixed(2) : v.toStringAsFixed(0),
                    stepForMode: (m) {
                      switch (m) {
                        case ParamMode.set: return 1.0;
                        case ParamMode.offset: return 1.0;
                        case ParamMode.scale: return 0.05;
                      }
                    },
                    setMin: 1,
                    setMax: null,
                    scaleMin: 0.01,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<RecalcTarget>(
                    initialValue: recalcTarget,
                    items: [
                      DropdownMenuItem(value: RecalcTarget.auto, child: Text(l10n.planEditorRecalcAuto)),
                      DropdownMenuItem(value: RecalcTarget.reps, child: Text(l10n.planEditorRecalcReps)),
                      DropdownMenuItem(value: RecalcTarget.effort, child: Text(l10n.planEditorRecalcEffort)),
                      DropdownMenuItem(value: RecalcTarget.intensity, child: Text(l10n.planEditorRecalcIntensity)),
                    ],
                    onChanged: (v) => setState(() { recalcTarget = v ?? RecalcTarget.auto; }),
                  ),
                  if (recalcTarget == RecalcTarget.auto) ...[
                    const SizedBox(height: 6),
                    Builder(
                      builder: (innerCtx) {
                        final chI = intensityEnabled;
                        final chE = effortEnabled;
                        final chV = volumeEnabled;
                        String t;
                        if ((chI || chE) && !chV) {
                          t = l10n.planEditorAutoRecalcReps;
                        } else if (chV && !(chI || chE)) {
                          t = l10n.planEditorAutoRecalcIntensity;
                        } else if (chI && chV && !chE) {
                          t = l10n.planEditorAutoRecalcRpe;
                        } else {
                          t = l10n.planEditorAutoRecalcNone;
                        }
                        return Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Theme.of(innerCtx).hintColor),
                            const SizedBox(width: 6),
                            Expanded(child: Text(t)),
                          ],
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: Text(l10n.planEditorFilterExercisesOptional)),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            if (selectedExerciseIds.length == exerciseIdsSorted.length) {
                              selectedExerciseIds.clear();
                            } else {
                              selectedExerciseIds = exerciseIdsSorted.toSet();
                            }
                          });
                        },
                        child: Text(
                          selectedExerciseIds.length == exerciseIdsSorted.length
                              ? l10n.planEditorClearAll
                              : l10n.planEditorSelectAll,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 220,
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        primary: false,
                        child: Column(
                          children: exerciseIdsSorted.map((id) => CheckboxListTile(
                            dense: true,
                            value: selectedExerciseIds.contains(id),
                            onChanged: (v) {
                              setState(() {
                                if (v == true) {
                                  selectedExerciseIds.add(id);
                                } else {
                                  selectedExerciseIds.remove(id);
                                }
                              });
                            },
                            title: Text(unique[id] ?? l10n.planEditorExerciseIdFallback(id)),
                            subtitle: Text(l10n.planEditorOccurrences(counts[id] ?? 0)),
                            controlAffinity: ListTileControlAffinity.leading,
                          )).toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: dayCtrl,
                    decoration: InputDecoration(labelText: l10n.planEditorDayFilterLabel),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.planEditorMassEditWarning),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.cancel)),
              FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l10n.apply)),
            ],
          );
        },
      ),
    );

    if (confirmed != true) return;
    final dayIndex = int.tryParse(dayCtrl.text);
    String? mapMode(ParamMode m) {
      switch (m) {
        case ParamMode.set: return 'set';
        case ParamMode.offset: return 'offset';
        case ParamMode.scale: return 'scale';
      }
    }
    final String recalcTargetStr = () {
      switch (recalcTarget) {
        case RecalcTarget.auto: return 'auto';
        case RecalcTarget.intensity: return 'intensity';
        case RecalcTarget.effort: return 'rpe';
        case RecalcTarget.reps: return 'reps';
      }
    }();
    await _previewAndMaybeApply(
      intensityMode: intensityEnabled ? mapMode(intensityMV.mode) : null,
      intensityValue: intensityEnabled ? intensityMV.value : null,
      effortMode: effortEnabled ? mapMode(effortMV.mode) : null,
      effortValue: effortEnabled ? effortMV.value : null,
      volumeMode: volumeEnabled ? mapMode(volumeMV.mode) : null,
      volumeValue: volumeEnabled ? volumeMV.value : null,
      exerciseIds: selectedExerciseIds,
      dayIndex: dayIndex,
      recalcTarget: recalcTargetStr,
    );
  }

  Future<void> _previewAndMaybeApply({
    String? intensityMode,
    double? intensityValue,
    String? effortMode,
    double? effortValue,
    String? volumeMode,
    double? volumeValue,
    Set<int>? exerciseIds,
    int? dayIndex,
    String? recalcTarget,
    String? fixStrategy,
  }) async {
    if (_selectedMicrocycleIds.isEmpty) return;

    final validIds = await _mesoService.validateMicrocycles(_selectedMicrocycleIds.toList());


    final idToMicro = <int, Microcycle>{};
    for (final meso in widget.plan.mesocycles) {
      for (final micro in meso.microcycles) {
        idToMicro[micro.id] = micro;
      }
    }


    var diffs = <_MicroDiff>[];
    int sumTotal = 0, sumChanged = 0, sumI = 0, sumE = 0, sumV = 0, sumInvalid = 0;
    void recompute() {
      diffs = <_MicroDiff>[];
      sumTotal = 0; sumChanged = 0; sumI = 0; sumE = 0; sumV = 0; sumInvalid = 0;
      for (final id in validIds) {
        final micro = idToMicro[id];
        if (micro == null) continue;
        final d = _simulateDiff(
          micro,
          intensityMode: intensityMode,
          intensityValue: intensityValue,
          effortMode: effortMode,
          effortValue: effortValue,
          volumeMode: volumeMode,
          volumeValue: volumeValue,
          exerciseIds: exerciseIds,
          dayIndex: dayIndex,
          recalcTarget: recalcTarget,
          fixStrategy: fixStrategy,
        );
        diffs.add(_MicroDiff(
          id: id,
          name: micro.name,
          totalSets: d['total'] ?? 0,
          changedSets: d['changed'] ?? 0,
          changedIntensity: d['i'] ?? 0,
          changedEffort: d['e'] ?? 0,
          changedVolume: d['v'] ?? 0,
        ));
        sumTotal += d['total'] ?? 0;
        sumChanged += d['changed'] ?? 0;
        sumI += d['i'] ?? 0;
        sumE += d['e'] ?? 0;
        sumV += d['v'] ?? 0;
        sumInvalid += d['invalid'] ?? 0;
      }
    }
    recompute();

    if (sumChanged == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).planEditorNoChanges)),
        );
      }
      return;
    }

    FixStrategy localFix = () {
      switch (fixStrategy) {
        case 'fixReps': return FixStrategy.fixReps;
        case 'fixIntensity': return FixStrategy.fixIntensity;
        default: return FixStrategy.none;
      }
    }();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final l10n = AppLocalizations.of(ctx);
          return AlertDialog(
            title: Text(l10n.planEditorMassEditPreviewTitle),
            content: SizedBox(
              width: (MediaQuery.sizeOf(ctx).width - 96).clamp(0.0, 460.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Text(l10n.planEditorMicrocyclesCountPlain(diffs.length.toString())),
                      Text(l10n.planEditorMismatchesCount(sumInvalid.toString())),
                    ],
                  ),
                  Text(l10n.planEditorChangedSets(sumChanged.toString(), sumTotal.toString())),
                  Text(l10n.planEditorDeltaSummary(sumE.toString(), sumI.toString(), sumV.toString())),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<FixStrategy>(
                    initialValue: localFix,
                    items: [
                      DropdownMenuItem(value: FixStrategy.none, child: Text(l10n.planEditorFixNone)),
                      DropdownMenuItem(value: FixStrategy.fixReps, child: Text(l10n.planEditorFixReps)),
                      DropdownMenuItem(value: FixStrategy.fixIntensity, child: Text(l10n.planEditorFixIntensity)),
                    ],
                    onChanged: (v) {
                      localFix = v ?? FixStrategy.none;
                      fixStrategy = () {
                        switch (localFix) {
                          case FixStrategy.fixReps: return 'fixReps';
                          case FixStrategy.fixIntensity: return 'fixIntensity';
                          case FixStrategy.none: return 'none';
                        }
                      }();
                      setState(() { recompute(); });
                    },
                  ),
                  const SizedBox(height: 6),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: diffs.map((d) => ListTile(
                          dense: true,
                          title: Text(d.name),
                          subtitle: Text(
                            l10n.planEditorPreviewMicroDiff(
                              d.changedSets.toString(),
                              d.totalSets.toString(),
                              d.changedIntensity.toString(),
                              d.changedEffort.toString(),
                              d.changedVolume.toString(),
                            ),
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.cancel)),
              FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l10n.apply)),
            ],
          );
        },
      ),
    );

    if (confirmed == true) {
      await _applyMassEdits(
        intensityMode: intensityMode,
        intensityValue: intensityValue,
        effortMode: effortMode,
        effortValue: effortValue,
        volumeMode: volumeMode,
        volumeValue: volumeValue,
        exerciseIds: exerciseIds,
        dayIndex: dayIndex,
        recalcTarget: recalcTarget,
        fixStrategy: fixStrategy,
      );
    }
  }

  Future<void> _applyMassEdits({
    String? intensityMode,
    double? intensityValue,
    String? effortMode,
    double? effortValue,
    String? volumeMode,
    double? volumeValue,
    Set<int>? exerciseIds,
    int? dayIndex,
    String? recalcTarget,
    String? fixStrategy,
  }) async {
    if (_selectedMicrocycleIds.isEmpty) return;
    setState(() => _batchSaving = true);
    try {
      List<int> validIds;
      try {
        validIds = await _mesoService.validateMicrocycles(_selectedMicrocycleIds.toList());
        final invalidCount = _selectedMicrocycleIds.length - validIds.length;
        if (invalidCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).planEditorSkipNoRights(invalidCount)),
            ),
          );
        }
      } catch (e) {
        validIds = _selectedMicrocycleIds.toList();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).planEditorRightsCheckUnavailableApplyAll(e.toString()),
            ),
          ),
        );
      }


      final idToMicro = <int, Microcycle>{};
      for (final meso in widget.plan.mesocycles) {
        for (final micro in meso.microcycles) {
          idToMicro[micro.id] = micro;
        }
      }

      int success = 0;
      int failed = 0;
      for (final id in validIds) {
        final micro = idToMicro[id];
        if (micro == null) { failed++; continue; }


        final changed = _applySetParamsToMicro(
          micro,
          intensityMode: intensityMode,
          intensityValue: intensityValue,
          effortMode: effortMode,
          effortValue: effortValue,
          volumeMode: volumeMode,
          volumeValue: volumeValue,
          exerciseIds: exerciseIds,
          dayIndex: dayIndex,
          recalcTarget: recalcTarget,
          fixStrategy: fixStrategy,
        );
        if (!changed) { continue; }

        final schedule = _toSchedule(micro);
        try {
          await _mesoService.updateMicrocycle(id, MicrocycleUpdateDto(
            name: micro.name,
            daysCount: micro.daysCount,
            schedule: schedule,
          ));
          success++;
        } catch (_) {
          failed++;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).planEditorMassEditsResult(success, failed),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _batchSaving = false);
    }
  }

  bool _applySetParamsToMicro(
    Microcycle micro, {
    String? intensityMode,
    double? intensityValue,
    String? effortMode,
    double? effortValue,
    String? volumeMode,
    double? volumeValue,
    Set<int>? exerciseIds,
    int? dayIndex,
    String? recalcTarget,
    String? fixStrategy,
  }) {
    bool changed = false;
    int? _applyInt(int? orig, String? mode, double? val) {
      if (mode == null || val == null) return orig;
      if (mode == 'set') return val.round();
      if (mode == 'offset') {
        if (orig == null) return orig;
        return (orig + val).round();
      }
      if (mode == 'scale') {
        if (orig == null) return orig;
        return (orig * val).round();
      }
      return orig;
    }
    int? _clampIntensity(int? v) => v == null ? null : v.clamp(0, 100);
    int? _clampEffort(int? v) => v == null ? null : v.clamp(4, 10);
    int? _clampVolume(int? v) => v == null ? null : (v < 1 ? 1 : v);
    for (int wi = 0; wi < micro.planWorkouts.length; wi++) {
      final w = micro.planWorkouts[wi];

      if (dayIndex != null) {
        final label = w.dayLabel.trim().toLowerCase();
        int? d;
        if (label.startsWith('day ')) {
          d = int.tryParse(label.substring(4).trim());
        }
        d ??= (w.orderIndex + 1);
        if (d != dayIndex) {
          continue;
        }
      }
      final newExercises = <PlanExercise>[];
      for (final ex in w.exercises) {
        if (exerciseIds != null) {
          if (exerciseIds.isEmpty || !exerciseIds.contains(ex.exerciseDefinitionId)) {
            newExercises.add(ex);
            continue;
          }
        }
        final newSets = <PlanSet>[];
        for (final s in ex.sets) {
          int? ni = _clampIntensity(_applyInt(s.intensity, intensityMode, intensityValue));
          int? ne = _clampEffort(_applyInt(s.effort, effortMode, effortValue));
          int? nv = _clampVolume(_applyInt(s.volume, volumeMode, volumeValue));

          String? target = recalcTarget;
          if (target == null || target == 'auto') {
            final bool chI = ni != s.intensity;
            final bool chE = ne != s.effort;
            final bool chV = nv != s.volume;
            if ((chI || chE) && !chV) {
              target = 'reps';
            } else if (chV && !(chI || chE)) {
              target = 'intensity';
            } else if (chI && chV && !chE) {
              target = 'rpe';
            } else {
              target = null;
            }
          }

          if (target == 'reps') {
            if (ni != null && ne != null) {
              final r = rpe_table.RpeTable.getReps(ni, ne);
              if (r != null) nv = _clampVolume(r);
            }
          } else if (target == 'rpe') {
            if (ni != null && nv != null) {
              final rpe = rpe_table.RpeTable.getRpe(ni, nv);
              if (rpe != null) {
                ne = _clampEffort(rpe);
              } else {
                final strategy = fixStrategy ?? 'none';
                if (strategy == 'fixReps') {
                  final fixed = _nearestRepsForIntensity(ni, nv);
                  if (fixed != null) {
                    nv = _clampVolume(fixed);
                    final rpe2 = rpe_table.RpeTable.getRpe(ni, nv!);
                    if (rpe2 != null) ne = _clampEffort(rpe2);
                  }
                } else if (strategy == 'fixIntensity') {
                  final ii = rpe_table.RpeTable.getIntensity(nv, 10);
                  if (ii != null) {
                    ni = _clampIntensity(ii);
                    final rpe2 = rpe_table.RpeTable.getRpe(ni!, nv);
                    if (rpe2 != null) ne = _clampEffort(rpe2);
                  }
                }
              }
            }
          } else if (target == 'intensity') {
            if (nv != null && ne != null) {
              final ii = rpe_table.RpeTable.getIntensity(nv, ne);
              if (ii != null) ni = _clampIntensity(ii);
            }
          }

          final ns = PlanSet(
            id: s.id,
            orderIndex: s.orderIndex,
            intensity: ni,
            effort: ne,
            volume: nv,
            planExerciseId: s.planExerciseId,
          );
          if (ns.intensity != s.intensity || ns.effort != s.effort || ns.volume != s.volume) {
            changed = true;
          }
          newSets.add(ns);
        }
        newExercises.add(PlanExercise(
          id: ex.id,
          exerciseDefinitionId: ex.exerciseDefinitionId,
          exerciseName: ex.exerciseName,
          orderIndex: ex.orderIndex,
          planWorkoutId: ex.planWorkoutId,
          sets: newSets,
        ));
      }
      micro.planWorkouts[wi] = PlanWorkout(
        id: w.id,
        microcycleId: w.microcycleId,
        dayLabel: w.dayLabel,
        orderIndex: w.orderIndex,
        exercises: newExercises,
      );
    }
    return changed;
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
        final sets = ex.sets.map((s) => ParamsSets(
          intensity: s.intensity?.toDouble(),
          effort: s.effort?.toDouble(),
          volume: s.volume?.toDouble(),
        )).toList();
        items.add(ExerciseScheduleItemDto(id: 0, exerciseId: ex.exerciseDefinitionId, sets: sets, name: ex.exerciseName, exercises: const []));
      }
      if (items.isNotEmpty) {
        map[key] = items;
      }
    }
    return map;
  }
}
