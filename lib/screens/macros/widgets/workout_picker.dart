import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/models/workout.dart';
import 'package:workout_app/providers/plan_providers.dart';
import 'package:workout_app/services/api_client.dart';
import 'package:workout_app/services/workout_service.dart';
import 'package:workout_app/widgets/instrument_modal.dart';
import 'package:workout_app/widgets/loading_indicator.dart';

class PickedWorkout {
  final int id;
  final String name;
  final int? planOrderIndex;
  const PickedWorkout({
    required this.id,
    required this.name,
    this.planOrderIndex,
  });
}

Future<PickedWorkout?> showWorkoutPickerBottomSheet(
  BuildContext context,
  WidgetRef ref,
) async {
  final l10n = AppLocalizations.of(context);
  return showInstrumentBottomSheet<PickedWorkout>(
    context: context,
    eyebrow: 'PLAN TIMELINE',
    title: l10n.macroWorkoutPickerTitle,
    heightFactor: 0.88,
    builder: (_) => const _WorkoutPickerSheet(),
  );
}

class _WorkoutPickerSheet extends ConsumerStatefulWidget {
  const _WorkoutPickerSheet();

  @override
  ConsumerState<_WorkoutPickerSheet> createState() =>
      _WorkoutPickerSheetState();
}

class _WorkoutPickerSheetState extends ConsumerState<_WorkoutPickerSheet> {
  late final WorkoutService _ws;
  DateTime? _selectedDay;
  List<Workout> _workouts = const [];
  bool _loading = true;
  String? _error;
  int? _selectedWorkoutId;
  String? _selectedWorkoutName;
  int? _selectedPlanOrderIndex;

  @override
  void initState() {
    super.initState();
    _ws = WorkoutService(apiClient: ApiClient());
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final plan = await ref.read(activeAppliedPlanSWRProvider.future);
      final id = plan?.id;
      if (id == null) {
        setState(() {
          _loading = false;
          _workouts = const [];
          _error = AppLocalizations.of(context).workoutPickerActivePlanNotFound;
        });
        return;
      }
      final items = await _ws.getWorkoutsByAppliedPlan(id);
      items.sort((a, b) {
        final da = a.scheduledFor ?? DateTime.fromMillisecondsSinceEpoch(0);
        final db = b.scheduledFor ?? DateTime.fromMillisecondsSinceEpoch(0);
        return da.compareTo(db);
      });
      setState(() {
        _workouts = items;
        _loading = false;
        _selectedDay =
            items
                .firstWhere(
                  (w) => w.scheduledFor != null,
                  orElse: () => items.isNotEmpty
                      ? items.first
                      : const Workout(name: 'Workout', id: null),
                )
                .scheduledFor ??
            DateTime.now();
        _selectedWorkoutId = null;
        _selectedWorkoutName = null;
        _selectedPlanOrderIndex = null;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Iterable<Workout> _workoutsForDay(DateTime day) {
    final y = day.year, m = day.month, d = day.day;
    return _workouts.where((w) {
      final s = w.scheduledFor;
      if (s == null) return false;
      return s.year == y && s.month == m && s.day == d;
    });
  }

  Future<void> _openListPicker(AppLocalizations l10n) async {
    final res = await showInstrumentDialog<PickedWorkout>(
      context: context,
      eyebrow: 'ALL SESSIONS',
      title: l10n.macroWorkoutPickerTitle,
      content: _WorkoutListBody(workouts: _workouts),
      actionsBuilder: (ctx) => [
        InstrumentActionButton(
          label: l10n.cancel,
          variant: InstrumentActionVariant.secondary,
          onPressed: () => Navigator.of(ctx).pop(),
        ),
      ],
    );
    if (!mounted || res == null) return;
    setState(() {
      _selectedWorkoutId = res.id;
      _selectedWorkoutName = res.name;
      _selectedPlanOrderIndex = res.planOrderIndex;
      final w = _workouts.firstWhere(
        (e) => e.id == res.id,
        orElse: () => const Workout(name: 'Workout'),
      );
      if (w.scheduledFor != null) {
        _selectedDay = DateTime(
          w.scheduledFor!.year,
          w.scheduledFor!.month,
          w.scheduledFor!.day,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: LoadingIndicator()),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: instrument.peakEffortColor,
              ),
            ),
            const SizedBox(height: 12),
            InstrumentActionButton(
              label: l10n.refresh,
              variant: InstrumentActionVariant.secondary,
              expanded: true,
              onPressed: _load,
            ),
          ],
        ),
      );
    }

    if (_workouts.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.macroWorkoutPickerNoWorkouts),
          const SizedBox(height: 12),
          InstrumentActionButton(
            label: l10n.refresh,
            expanded: true,
            onPressed: _load,
          ),
        ],
      );
    }

    final day = _selectedDay ?? DateTime.now();
    final dayWorkouts = _workoutsForDay(day).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? InstrumentPalette.obsidianSlotHigh.withValues(alpha: 0.72)
                : scheme.surfaceContainerHigh.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(6),
          child: CalendarDatePicker(
            key: ValueKey(day.toIso8601String()),
            initialDate: day,
            firstDate:
                _workouts.first.scheduledFor?.subtract(
                  const Duration(days: 31),
                ) ??
                DateTime.now().subtract(const Duration(days: 365)),
            lastDate:
                _workouts.last.scheduledFor?.add(const Duration(days: 31)) ??
                DateTime.now().add(const Duration(days: 365)),
            onDateChanged: (d) => setState(() {
              _selectedDay = d;
              _selectedWorkoutId = null;
              _selectedWorkoutName = null;
            }),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.macroWorkoutPickerWorkoutsOnDate.toUpperCase(),
          style: InstrumentTheme.microLabel(context),
        ),
        const SizedBox(height: 6),
        if (dayWorkouts.isEmpty)
          Text(
            l10n.macroWorkoutPickerNoWorkoutsOnDate,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          )
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: dayWorkouts.length,
              separatorBuilder: (_, __) => Container(
                height: 1,
                color: instrument.hairlineBorder,
              ),
              itemBuilder: (_, i) {
                final w = dayWorkouts[i];
                final when = w.scheduledFor != null
                    ? DateFormat('d MMM, HH:mm').format(w.scheduledFor!)
                    : l10n.noDate;
                final sel = _selectedWorkoutId == w.id;
                return InkWell(
                  onTap: () {
                    if (w.id != null) {
                      setState(() {
                        _selectedWorkoutId = w.id;
                        _selectedWorkoutName = w.name;
                        _selectedPlanOrderIndex = w.planOrderIndex;
                        if (w.scheduledFor != null) {
                          _selectedDay = DateTime(
                            w.scheduledFor!.year,
                            w.scheduledFor!.month,
                            w.scheduledFor!.day,
                          );
                        }
                      });
                    }
                  },
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 52),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  w.name,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: sel
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: sel
                                        ? instrument.workingAura
                                        : scheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  when,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (sel)
                            Icon(
                              Icons.check_circle_rounded,
                              size: 20,
                              color: instrument.workingAura,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 12),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          spacing: 8,
          runSpacing: 8,
          children: [
            Text(
              l10n.macroWorkoutPickerOrSelectFromList,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            InstrumentActionButton(
              label: l10n.macroWorkoutPickerList,
              icon: Icons.list_rounded,
              variant: InstrumentActionVariant.secondary,
              onPressed: () => _openListPicker(l10n),
            ),
          ],
        ),
        const SizedBox(height: 14),
        InstrumentActionButton(
          label: l10n.done,
          expanded: true,
          onPressed: (_selectedWorkoutId == null)
              ? null
              : () => Navigator.of(context).pop(
                  PickedWorkout(
                    id: _selectedWorkoutId!,
                    name: _selectedWorkoutName ?? '',
                    planOrderIndex: _selectedPlanOrderIndex,
                  ),
                ),
        ),
      ],
    );
  }
}

class _WorkoutListBody extends StatelessWidget {
  final List<Workout> workouts;
  const _WorkoutListBody({required this.workouts});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 340),
      child: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: workouts.length,
          separatorBuilder: (_, __) => Container(
            height: 1,
            color: instrument.hairlineBorder,
          ),
          itemBuilder: (_, i) {
            final w = workouts[i];
            final when = w.scheduledFor != null
                ? DateFormat('d MMM, HH:mm').format(w.scheduledFor!)
                : l10n.noDate;
            return InkWell(
              onTap: () {
                if (w.id != null) {
                  Navigator.of(context).pop(
                    PickedWorkout(
                      id: w.id!,
                      name: w.name,
                      planOrderIndex: w.planOrderIndex,
                    ),
                  );
                }
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 52),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        w.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        when,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
