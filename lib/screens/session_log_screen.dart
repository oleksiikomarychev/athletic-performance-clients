import 'package:flutter/material.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:workout_app/models/workout_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_app/models/workout.dart';
import 'package:workout_app/models/exercise_instance.dart';
import 'package:workout_app/models/exercise_set_dto.dart';
import 'package:workout_app/services/service_locator.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';

class SessionLogScreen extends ConsumerStatefulWidget {
  final WorkoutSession session;
  const SessionLogScreen({super.key, required this.session});

  @override
  ConsumerState<SessionLogScreen> createState() => _SessionLogScreenState();
}

class _SessionLogScreenState extends ConsumerState<SessionLogScreen> {
  Workout? _workout;
  bool _loading = true;
  Map<int, Set<int>> _completedByInstance = {};

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '-';
    return DateFormat('yyyy-MM-dd HH:mm').format(dt.toLocal());
  }

  @override
  void initState() {
    super.initState();
    _parseProgress(widget.session.progress);
    _loadWorkout();
  }

  void _parseProgress(Map<String, dynamic> progress) {
    _completedByInstance.clear();
    final completed = progress['completed'];
    if (completed is Map) {
      completed.forEach((k, v) {
        final instId = int.tryParse(k.toString());
        if (instId == null) return;
        final setIds = <int>{};
        if (v is List) {
          for (final x in v) {
            final sid = x is int ? x : int.tryParse(x.toString());
            if (sid != null) setIds.add(sid);
          }
        }
        _completedByInstance[instId] = setIds;
      });
    }
  }

  Future<void> _loadWorkout() async {
    setState(() => _loading = true);
    try {
      final svc = ref.read(workoutServiceProvider);
      final w = await svc.getWorkoutWithDetails(widget.session.workoutId);

      final instances = w.exerciseInstances;
      final ids = instances.map((e) => e.exerciseListId).toSet().toList();
      if (ids.isNotEmpty) {
        final exSvc = ref.read(exerciseServiceProvider);
        final defs = await exSvc.getExercisesByIds(ids);
        final defMap = {for (final d in defs) d.id: d};
        final withNames = instances
            .map(
              (inst) => inst.copyWith(
                exerciseDefinition: defMap[inst.exerciseListId],
              ),
            )
            .toList();
        if (!mounted) return;
        setState(() {
          _workout = w.copyWith(exerciseInstances: withNames);
        });
        return;
      }
      if (!mounted) return;
      setState(() {
        _workout = w;
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;

    return AssistantChatHost(
      builder: (context, openChat) {
        final l10n = AppLocalizations.of(context);
        return Scaffold(
          appBar: PrimaryAppBar(
            title: l10n.sessionNumberTitle('${session.id ?? '-'}'),
            onTitleTap: openChat,
          ),
          body: ListView(
            padding: EdgeInsets.all(UiDimensions.of(context).pagePadding),
            children: [
              Container(
                padding: EdgeInsets.all(UiDimensions.of(context).cardPadding),
                decoration: InstrumentTheme.cardDecoration(
                  context,
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  radius: 14,
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      label: l10n.workoutIdUpperLabel,
                      value: session.workoutId.toString(),
                    ),
                    _InfoRow(
                      label: l10n.statusUpperLabel,
                      value: session.status.toUpperCase(),
                    ),
                    _InfoRow(
                      label: l10n.startedUpperLabel,
                      value: _fmtDate(session.startedAt),
                    ),
                    _InfoRow(
                      label: l10n.finishedUpperLabel,
                      value: _fmtDate(session.finishedAt),
                    ),
                    _InfoRow(
                      label: l10n.durationUpperLabel,
                      value: '${session.durationSeconds ?? 0} s',
                    ),
                  ],
                ),
              ),
              SizedBox(height: UiDimensions.of(context).sectionGap),
              Text(
                'EXERCISES & SETS',
                style: InstrumentTheme.microLabel(context),
              ),
              const SizedBox(height: 8),
              if (_loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_workout == null || _workout!.exerciseInstances.isEmpty)
                Text(l10n.noExerciseDataForWorkout)
              else
                ..._workout!.exerciseInstances.map(_buildInstanceCard),
              SizedBox(height: UiDimensions.of(context).sectionGap),
              Text(
                'RAW PROGRESS',
                style: InstrumentTheme.microLabel(context),
              ),
              const SizedBox(height: 4),
              Text(
                'Diagnostics only: JSON with a "completed" key, where keys are exercise instance IDs and values are arrays of completed set IDs. Used to highlight sets above.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: InstrumentTheme.cardDecoration(
                  context,
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  radius: 12,
                ),
                child: Text(
                  session.progress.toString(),
                  style: InstrumentTheme.tabular(
                    Theme.of(context).textTheme.bodySmall ?? const TextStyle(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInstanceCard(ExerciseInstance instance) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final name =
        instance.exerciseDefinition?.name ??
        'Exercise #${instance.id ?? instance.exerciseListId}';
    final completed = _completedByInstance[instance.id ?? -1] ?? const <int>{};
    final sets = instance.sets;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.all(UiDimensions.of(context).cardPadding),
      decoration: InstrumentTheme.cardDecoration(
        context,
        color: colors.surfaceContainerLow,
        radius: 14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fitness_center, color: colors.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (sets.isNotEmpty)
                Text(
                  '${sets.length} SET${sets.length == 1 ? '' : 'S'}',
                  style: InstrumentTheme.tabular(
                    InstrumentTheme.microLabel(context),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (sets.isEmpty)
            Text(
              'No sets',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in sets)
                  _SetChip(set: s, completed: completed.contains(s.id)),
              ],
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: InstrumentTheme.microLabel(context)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: InstrumentTheme.tabular(
                theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ) ??
                    const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetChip extends StatelessWidget {
  final ExerciseSetDto set;
  final bool completed;
  const _SetChip({required this.set, required this.completed});

  @override
  Widget build(BuildContext context) {
    final text = _formatSet(set);
    final scheme = Theme.of(context).colorScheme;
    final instrument = InstrumentTheme.of(context);
    final bg = completed
        ? Color.alphaBlend(
            instrument.successColor.withValues(alpha: 0.14),
            scheme.surfaceContainerLow,
          )
        : scheme.surfaceContainerHighest.withValues(alpha: 0.45);
    final border = completed
        ? instrument.successColor.withValues(alpha: 0.55)
        : scheme.outlineVariant.withValues(alpha: 0.45);
    final icon = completed ? Icons.check_circle : Icons.radio_button_unchecked;
    final iconColor = completed
        ? instrument.successColor
        : scheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: InstrumentTheme.cardDecoration(
        context,
        color: bg,
        borderColor: border,
        radius: 10,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: InstrumentTheme.tabular(
              (Theme.of(context).textTheme.bodySmall ?? const TextStyle())
                  .copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatSet(ExerciseSetDto s) {
    final reps = s.reps;
    final weight = s.weight;
    final rpe = s.rpe;
    final parts = <String>[];
    parts.add('${reps}×${_trimDouble(weight)}kg');
    if (rpe != null) parts.add('RPE ${_trimDouble(rpe)}');
    return parts.join(' · ');
  }

  String _trimDouble(double v) {
    return (v % 1 == 0) ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
  }
}
