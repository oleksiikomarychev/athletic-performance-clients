import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/models/exercise_definition.dart';
import 'package:workout_app/providers/target_data_providers.dart';

class MacroHumanPreview extends ConsumerWidget {
  final Map<String, dynamic> trigger;
  final Map<String, dynamic> condition;
  final Map<String, dynamic> action;
  final Map<String, dynamic> duration;
  const MacroHumanPreview({
    super.key,
    required this.trigger,
    required this.condition,
    required this.action,
    required this.duration,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final defs = ref.watch(exerciseDefinitionsProvider).maybeWhen(
          data: (d) => d,
          orElse: () => const <ExerciseDefinition>[],
        );
    final nameMap = <int, String>{
      for (final e in defs)
        if (e.id != null) e.id!: e.name,
    };
    final l10n = AppLocalizations.of(context);
    final main = _mainSentence(nameMap, defs, l10n);
    final details = _detailsEntries(nameMap, defs, l10n);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          main,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < details.length; i++) ...[
          Container(height: 1, color: instrument.hairlineBorder),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  details[i].key,
                  style: InstrumentTheme.microLabel(
                    context,
                    color: instrument.deloadAura,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  details[i].value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _metricName(String? m, AppLocalizations l10n) {
    switch (m) {
      case 'Readiness_Score':
        return l10n.macroMetricReadiness;
      case 'RPE_Session':
        return l10n.macroMetricSessionRpe;
      case 'Total_Reps':
        return l10n.macroMetricReps;
      case 'e1RM':
        return l10n.macroMetricE1rm;
      case 'Performance_Trend':
        return l10n.macroMetricTrend;
      case 'RPE_Delta_From_Plan':
        return l10n.macroMetricRpeDelta;
      case 'Reps_Delta_From_Plan':
        return l10n.macroMetricRepsDelta;
    }
    return l10n.macroMetricFallback;
  }

  String _targetFromTrigger(Map<int, String> names, AppLocalizations l10n) {
    final ids = <int>[];
    final src = trigger['exercise_ids'];
    if (src is List) {
      for (final e in src) {
        final id = int.tryParse(e.toString());
        if (id != null) ids.add(id);
      }
    } else if (trigger['exercise_id'] != null) {
      final id = int.tryParse(trigger['exercise_id'].toString());
      if (id != null) ids.add(id);
    }
    if (ids.isEmpty) return l10n.macroTriggerAllExercises;
    final namesList = ids.map((id) => names[id] ?? 'ID $id').toList();
    return l10n.macroTriggerForExercises(namesList.join(', '));
  }

  String _relationWord(String r, AppLocalizations l10n) {
    switch (r) {
      case '>=':
        return l10n.macroOpGte;
      case '<=':
        return l10n.macroOpLte;
      case '==':
        return l10n.macroOpEq;
      case '!=':
        return l10n.macroOpNeq;
      case '>':
        return l10n.macroOpGt;
      case '<':
        return l10n.macroOpLt;
      case 'in_range':
        return l10n.macroOpInRange;
      case 'not_in_range':
        return l10n.macroOpOutOfRange;
    }
    return r;
  }

  String _unitForMetric(String? m, AppLocalizations l10n) {
    if (m == 'e1RM') return l10n.normUnitKg;
    return '';
  }

  String _conditionPhrase(AppLocalizations l10n) {
    final op = (condition['op'] ?? '').toString();
    if (op.isEmpty) return l10n.macroCondNotSet;
    final metric = trigger['metric']?.toString();
    final unit = _unitForMetric(metric, l10n);
    if (op == 'in_range' || op == 'not_in_range') {
      final vals =
          (condition['range'] as List?) ??
          (condition['values'] as List?) ??
          const [];
      if (vals.length >= 2) {
        final a = vals[0].toString();
        final b = vals[1].toString();
        final su = unit.isEmpty ? '' : ' $unit';
        return op == 'in_range'
            ? l10n.macroCondInRangeValues(a, b, su)
            : l10n.macroCondOutOfRangeValues(a, b, su);
      }
      return op == 'in_range' ? l10n.macroCondInRange : l10n.macroCondOutOfRange;
    }
    if (op == 'stagnates_for') {
      final n = condition['n']?.toString();
      final e = condition['epsilon_percent']?.toString();
      if (n != null && e != null) {
        return l10n.macroCondStagnatesValues(e, n);
      }
      return l10n.macroCondStagnates;
    }
    if (op == 'deviates_from_avg') {
      final n = condition['n']?.toString();
      final v = condition['value_percent']?.toString();
      final d = (condition['direction'] ?? '').toString();
      final dirLabel = d == 'positive'
          ? l10n.macroCondDirPositive
          : d == 'negative'
              ? l10n.macroCondDirNegative
              : d;
      final dir = d.isEmpty ? '' : l10n.macroCondDirSuffix(dirLabel);
      if (n != null && v != null) {
        return l10n.macroCondDeviatesValues(dir, n, v);
      }
      return l10n.macroCondDeviates;
    }
    if (op == 'holds_for') {
      final rel = _relationWord(
        (condition['relation'] ?? '').toString(),
        l10n,
      );
      final values =
          (condition['range'] as List?) ??
          (condition['values'] as List?) ??
          const [];
      final val = values.length >= 2
          ? '${values[0]}–${values[1]}'
          : (condition['value'] ?? '').toString();
      final su = unit.isEmpty ? '' : ' $unit';
      final n = (condition['n'] ?? '').toString();
      if (rel.isNotEmpty && val.isNotEmpty && n.isNotEmpty) {
        return l10n.macroCondHoldsWorkouts(n, rel, su, val);
      }
      return l10n.macroCondHoldsWorkoutsGeneric;
    }
    if (op == 'holds_for_sets') {
      final rel = _relationWord(
        (condition['relation'] ?? '').toString(),
        l10n,
      );
      final val = (condition['value'] ?? '').toString();
      final su = unit.isEmpty ? '' : ' $unit';
      final n = (condition['n_sets'] ?? '').toString();
      if (rel.isNotEmpty && val.isNotEmpty && n.isNotEmpty) {
        return l10n.macroCondHoldsSets(n, rel, su, val);
      }
      return l10n.macroCondHoldsSetsGeneric;
    }
    final v = (condition['value'] ?? '').toString();
    final su = unit.isEmpty ? '' : ' $unit';
    if (op == '>') return l10n.macroCondSimpleGt(su, v);
    if (op == '<') return l10n.macroCondSimpleLt(su, v);
    if (op == '=') return l10n.macroCondSimpleEq(su, v);
    if (op == '!=') return l10n.macroCondSimpleNeq(su, v);
    return l10n.macroCondSet;
  }

  String _actionTarget(
    Map<int, String> names,
    List<ExerciseDefinition> defs,
    AppLocalizations l10n,
  ) {
    final t = (action['target'] as Map?)?.cast<String, dynamic>();
    if (t == null) return l10n.macroActionTargetAll;
    if (t['exercise_ids'] is List) {
      final ids = <int>[];
      for (final e in (t['exercise_ids'] as List)) {
        final id = int.tryParse(e.toString());
        if (id != null) ids.add(id);
      }
      if (ids.isEmpty) return l10n.macroActionTargetAll;
      final list = ids.map((id) => names[id] ?? 'ID $id').toList();
      return l10n.macroActionTargetExercises(list.join(', '));
    }
    if (t['selector'] is Map) {
      final sel = (t['selector'] as Map).cast<String, dynamic>();
      final val = (sel['value'] as Map?)?.cast<String, dynamic>() ?? const {};
      final parts = <String>[];
      void add(String k) {
        final v = val[k];
        if (v is String && v.isNotEmpty) parts.add('$k: $v');
        if (v is List && v.isNotEmpty) parts.add('$k: ${v.join(', ')}');
      }

      add('movement_type');
      add('region');
      add('muscle_group');
      add('equipment');
      if (parts.isEmpty) return l10n.macroActionTargetAll;
      final examples = <String>[];
      bool matches(ExerciseDefinition d) {
        bool ok = true;
        bool check(String key, String? val) {
          final want = val?.toLowerCase();
          if (want == null || want.isEmpty) return true;
          final actual = (d.toJson()[key] as String?)?.toLowerCase();
          return actual != null && actual.isNotEmpty && actual == want;
        }

        bool checkList(String key, List list) {
          if (list.isEmpty) return true;
          final actual = (d.toJson()[key] as String?)?.toLowerCase();
          if (actual == null || actual.isEmpty) return false;
          return list.map((e) => e.toString().toLowerCase()).contains(actual);
        }

        final mt = val['movement_type'];
        final rg = val['region'];
        final mg = val['muscle_group'];
        final eq = val['equipment'];
        if (mt is String) ok = ok && check('movement_type', mt);
        if (mt is List) ok = ok && checkList('movement_type', mt);
        if (rg is String) ok = ok && check('region', rg);
        if (rg is List) ok = ok && checkList('region', rg);
        if (mg is String) ok = ok && check('muscle_group', mg);
        if (mg is List) ok = ok && checkList('muscle_group', mg);
        if (eq is String) ok = ok && check('equipment', eq);
        if (eq is List) ok = ok && checkList('equipment', eq);
        return ok;
      }

      for (final d in defs) {
        if (examples.length >= 3) break;
        if (matches(d)) {
          final nm = d.name.trim();
          if (nm.isNotEmpty) examples.add(nm);
        }
      }
      final base = l10n.macroActionTargetTags(parts.join(', '));
      if (examples.isEmpty) return base;
      return l10n.macroActionTargetTagsExamples(base, examples.join(', '));
    }
    return l10n.macroActionTargetAll;
  }

  String _actionPhrase(
    Map<int, String> names,
    List<ExerciseDefinition> defs,
    AppLocalizations l10n,
  ) {
    final type = (action['type'] ?? '').toString();
    final params =
        (action['params'] as Map?)?.cast<String, dynamic>() ?? const {};
    final mode = (params['mode'] ?? '').toString();
    final valStr = (params['value'] ?? '').toString();
    final v = double.tryParse(valStr);
    if (type == 'Inject_Mesocycle') {
      final buf = <String>[];
      String base = l10n.macroInjectMesoBase;
      if (mode == 'by_Template') {
        final tid = params['template_id'];
        if (tid != null && tid.toString().isNotEmpty) {
          base = l10n.macroInjectMesoTemplate(base, tid.toString());
        }
      } else if (mode == 'Create_Inline') {
        final weeks = params['duration_weeks'];
        final dim = params['days_in_microcycle'];
        final restDays = (params['rest_days'] as List?)
                ?.map((e) => int.tryParse(e.toString()) ?? -1)
                .where((e) => e > 0)
                .toList() ??
            const <int>[];
        final focus =
            (params['default_focus_tags'] as Map?)?.cast<String, dynamic>() ??
                const {};
        final parts = <String>[];
        if (weeks != null) parts.add(l10n.macroInjectWeeks(weeks.toString()));
        if (dim != null) parts.add(l10n.macroInjectMicroDays(dim.toString()));
        if (restDays.isNotEmpty) {
          parts.add(l10n.macroInjectRestDays(restDays.join(', ')));
        }
        if (focus.isNotEmpty) {
          final tagParts = <String>[];
          void add(String k) {
            final fv = focus[k];
            if (fv is String && fv.isNotEmpty) tagParts.add('$k: $fv');
            if (fv is List && fv.isNotEmpty) tagParts.add('$k: ${fv.join(', ')}');
          }

          add('movement_type');
          add('region');
          add('muscle_group');
          add('equipment');
          if (tagParts.isNotEmpty) {
            parts.add(l10n.macroInjectFocus(tagParts.join(', ')));
          }
        }
        if (parts.isNotEmpty) base = '$base (${parts.join('; ')})';
      }
      final placement =
          (params['placement'] as Map?)?.cast<String, dynamic>() ?? const {};
      final pmode = (placement['mode'] ?? '').toString();
      if (pmode == 'Append_To_End') buf.add(l10n.macroInjectAppendEnd);
      if (pmode == 'Insert_After_Workout') {
        final wid = placement['workout_id'];
        if (wid != null) {
          buf.add(l10n.macroInjectAfterWorkoutId(wid.toString()));
        } else {
          buf.add(l10n.macroInjectAfterSelectedWorkout);
        }
      }
      if (pmode == 'Insert_After_Mesocycle') {
        final midx = placement['mesocycle_index'];
        if (midx != null) {
          buf.add(l10n.macroInjectAfterMesoIdx(midx.toString()));
        } else {
          buf.add(l10n.macroInjectAfterSelectedMeso);
        }
      }
      final conflict = (params['on_conflict'] ?? '').toString();
      if (conflict.isNotEmpty) {
        final ctext = conflict == 'Replace_Planned'
            ? l10n.macroConflictReplace
            : conflict == 'Shift_Forward'
                ? l10n.macroConflictShift
                : conflict == 'Skip_On_Conflict'
                    ? l10n.macroConflictSkip
                    : conflict;
        buf.add(l10n.macroConflictPrefix(ctext));
      }
      final tail = buf.isEmpty ? '' : ' ${buf.join(', ')}';
      return base + tail;
    }
    final target = _actionTarget(names, defs, l10n);
    if (type == 'Adjust_Load' && mode == 'by_Percent' && v != null) {
      final abs = v.abs().toString().replaceAll('-', '');
      return v < 0
          ? l10n.macroActDecreaseWeightPct(abs, target)
          : l10n.macroActIncreaseWeightPct(abs, target);
    }
    if (type == 'Adjust_Load' && mode == 'to_Target' && valStr.isNotEmpty) {
      return l10n.macroActAdjustWeightRpe(valStr, target);
    }
    if (type == 'Adjust_Reps' && mode == 'by_Value' && v != null) {
      final abs = v.abs().toString().replaceAll('-', '');
      return v < 0
          ? l10n.macroActDecreaseReps(abs, target)
          : l10n.macroActIncreaseReps(abs, target);
    }
    if (type == 'Adjust_Reps' && mode == 'to_Target' && valStr.isNotEmpty) {
      return l10n.macroActAdjustRepsRpe(valStr, target);
    }
    if (type == 'Adjust_Sets' && mode == 'by_Value' && v != null) {
      final abs = v.abs().toString().replaceAll('-', '');
      return v < 0
          ? l10n.macroActRemoveSets(abs, target)
          : l10n.macroActAddSets(abs, target);
    }
    return l10n.macroActFallback(target);
  }

  String _durationPhrase(AppLocalizations l10n) {
    final scope = (duration['scope'] ?? '').toString();
    final count = int.tryParse((duration['count'] ?? '1').toString()) ?? 1;
    if (scope == 'Next_N_Workouts') return l10n.macroDurNextWorkouts(count);
    if (scope == 'Until_Last_Workout') return l10n.macroDurUntilLast;
    if (scope == 'Until_End_Of_Mesocycle') return l10n.macroDurUntilEndMeso;
    if (scope == 'Until_End_Of_Microcycle') return l10n.macroDurUntilEndMicro;
    if (scope == 'Until_Workout') {
      final wid = duration['workout_id'];
      if (wid != null) return l10n.macroDurUntilWorkoutId(wid.toString());
      return l10n.macroDurUntilSelectedWorkout;
    }
    return '';
  }

  String _mainSentence(
    Map<int, String> names,
    List<ExerciseDefinition> defs,
    AppLocalizations l10n,
  ) {
    final metric = _metricName(trigger['metric']?.toString(), l10n);
    final trg = _targetFromTrigger(names, l10n);
    final cond = _conditionPhrase(l10n);
    final act = _actionPhrase(names, defs, l10n);
    final dur = _durationPhrase(l10n);
    if (trigger.isEmpty && condition.isEmpty && action.isEmpty) {
      return l10n.macroPreviewEmpty;
    }
    final parts = <String>[];
    parts.add(l10n.macroPreviewSentence(metric, trg, cond, act));
    if (dur.isNotEmpty) parts.add(dur);
    return '${parts.join(' ')}.';
  }

  List<MapEntry<String, String>> _detailsEntries(
    Map<int, String> names,
    List<ExerciseDefinition> defs,
    AppLocalizations l10n,
  ) {
    final metric = _metricName(trigger['metric']?.toString(), l10n);
    final trg = _targetFromTrigger(names, l10n);
    final cond = _conditionPhrase(l10n);
    final act = _actionPhrase(names, defs, l10n);
    final dur = _durationPhrase(l10n);
    return [
      MapEntry(l10n.macroLabelMetric, metric),
      MapEntry(l10n.macroLabelTrigger, trg),
      MapEntry(l10n.macroLabelCondition, cond),
      MapEntry(l10n.macroLabelAction, act),
      if (dur.isNotEmpty) MapEntry(l10n.macroLabelDuration, dur),
    ];
  }
}
