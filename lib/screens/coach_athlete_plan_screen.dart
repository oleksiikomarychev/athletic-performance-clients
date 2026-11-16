import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/models/applied_calendar_plan.dart';
import 'package:workout_app/models/exercise_definition.dart';
import 'package:workout_app/models/exercise_instance.dart';
import 'package:workout_app/models/exercise_set_dto.dart';
import 'package:workout_app/models/plan_analytics.dart';
import 'package:workout_app/models/workout.dart';
import 'package:workout_app/providers/ambient_environment_provider.dart';
import 'package:workout_app/providers/coach_plan_providers.dart';
import 'package:workout_app/providers/interface_maker_provider.dart';
import 'package:workout_app/services/service_locator.dart';
import 'package:workout_app/src/widgets/snack_utils.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/instrument_metric_matrix.dart';
import 'package:workout_app/widgets/instrument_modal.dart';
import 'package:workout_app/widgets/plan_analytics_chart.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';

class CoachAthletePlanScreen extends ConsumerStatefulWidget {
  final String athleteId;
  final String? athleteName;

  const CoachAthletePlanScreen({
    super.key,
    required this.athleteId,
    this.athleteName,
  });

  @override
  ConsumerState<CoachAthletePlanScreen> createState() =>
      _CoachAthletePlanScreenState();
}

class _CoachAthletePlanScreenState
    extends ConsumerState<CoachAthletePlanScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = _dateOnly(DateTime.now());

  final List<String> _metrics = const [
    'sets_count',
    'volume_sum',
    'reps_per_set_avg',
    'kilograms_avg',
    'tonnage_sum',
    'one_rm_est_avg',
    'intensity_avg',
    'effort_avg',
  ];
  String _metricX = 'effort_avg';
  String _metricY = 'effort_avg';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final planAsync = ref.watch(coachActivePlanProvider(widget.athleteId));
    final workoutsAsync = ref.watch(
      coachActivePlanWorkoutsProvider(widget.athleteId),
    );
    final eventsByDay = ref.watch(coachWorkoutsByDayProvider(widget.athleteId));
    final analyticsAsync = ref.watch(
      coachActivePlanAnalyticsProvider(widget.athleteId),
    );
    final env = ref.watch(activeTrainingEnvironmentProvider(null));
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dims = UiDimensions.of(context);

    return AssistantChatHost(
      initialMessage:
          'Opening assistant from CoachAthletePlanScreen. Use v1 context to understand the current athlete, their active plan, and selected day.',
      contextBuilder: _buildChatContext,
      builder: (context, openChat) {
        return AmbientScaffoldShell(
          environment: env,
          appBar: PrimaryAppBar(
            title:
                widget.athleteName ??
                l10n.coachAthletePlanTitleFallback(widget.athleteId),
            onTitleTap: openChat,
            actions: [
              PopupMenuButton<String>(
                tooltip: l10n.coachAthletePlanMassEditTooltip,
                icon: const Icon(Icons.more_horiz),
                onSelected: (value) async {
                  if (value == 'mass_edit') {
                    await _openCoachMassEditDialog();
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'mass_edit',
                    child: Text(l10n.coachAthletePlanMassEditMenu),
                  ),
                ],
              ),
            ],
          ),
          body: planAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(
              child: Padding(
                padding: EdgeInsets.all(dims.pagePadding),
                child: Text(
                  l10n.activePlanLoadError(err.toString()),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            data: (plan) {
              if (plan == null) {
                return Center(
                  child: Text(
                    l10n.coachAthletePlanNoActivePlan,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(coachActivePlanProvider(widget.athleteId));
                  ref.invalidate(
                    coachActivePlanWorkoutsProvider(widget.athleteId),
                  );
                  await Future.delayed(const Duration(milliseconds: 200));
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    0,
                    AmbientScaffoldShell.topContentInset(context),
                    0,
                    AmbientScaffoldShell.bottomContentInset(context),
                  ),
                  children: [
                    _buildPlanSummary(plan),
                    const SizedBox(height: 12),
                    _buildAnalyticsSection(analyticsAsync),
                    const SizedBox(height: 12),
                    _buildCalendar(eventsByDay),
                    const SizedBox(height: 14),
                    _buildWorkoutsSection(workoutsAsync, eventsByDay),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsSection(
    AsyncValue<PlanAnalyticsResponse?> analyticsAsync,
  ) {
    final dims = UiDimensions.of(context);
    return analyticsAsync.when(
      loading: () => Padding(
        padding: EdgeInsets.symmetric(horizontal: dims.pagePadding),
        child: Container(
          height: 220,
          decoration: InstrumentTheme.instrumentCardDecoration(
            context,
            radius: 22,
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (err, _) => Padding(
        padding: EdgeInsets.symmetric(horizontal: dims.pagePadding),
        child: Container(
          height: 160,
          decoration: InstrumentTheme.instrumentCardDecoration(
            context,
            radius: 22,
          ),
          padding: EdgeInsets.all(dims.cardPadding),
          child: Center(
            child: Text(
              AppLocalizations.of(
                context,
              ).coachAthletePlanLoadAnalyticsError(err.toString()),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      data: (resp) {
        final points = _mapAnalyticsResponse(resp);
        final totals = resp?.totals;
        return _buildActiveAnalyticsSection(points, totals: totals);
      },
    );
  }

  String _metricLabel(String m, AppLocalizations l10n) {
    switch (m) {
      case 'sets_count':
        return l10n.coachAthletePlanMetricSets;
      case 'volume_sum':
        return l10n.chartMetricRepsTotal;
      case 'reps_per_set_avg':
        return l10n.chartMetricRepsPerSetAvg;
      case 'kilograms_avg':
        return l10n.chartMetricKgAvg;
      case 'tonnage_sum':
        return l10n.chartMetricTonnage;
      case 'one_rm_est_avg':
        return l10n.chartMetricE1rm;
      case 'intensity_avg':
        return l10n.coachAthletePlanMetricIntensity;
      case 'effort_avg':
        return l10n.coachAthletePlanMetricEffort;
      default:
        return m;
    }
  }

  List<PlanAnalyticsPoint> _mapAnalyticsResponse(PlanAnalyticsResponse? resp) {
    if (resp == null) return const [];
    final items = List.of(resp.items);
    items.sort((a, b) {
      final ao = a.orderIndex ?? 1 << 30;
      final bo = b.orderIndex ?? 1 << 30;
      if (ao != bo) return ao.compareTo(bo);
      return a.workoutId.compareTo(b.workoutId);
    });
    int order = 0;
    return items
        .map((item) {
          final label = item.date != null
              ? DateFormat('MMM d').format(item.date!.toLocal())
              : (item.orderIndex != null
                    ? 'Day ${item.orderIndex}'
                    : '#${order + 1}');
          return PlanAnalyticsPoint(
            order: order++,
            label: label,
            values: item.metrics,
            actualValues: item.actualMetrics,
          );
        })
        .toList(growable: false);
  }

  Widget _buildActiveAnalyticsSection(
    List<PlanAnalyticsPoint> analytics, {
    Map<String, double>? totals,
  }) {
    final l10n = AppLocalizations.of(context);
    final dims = UiDimensions.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final hairline =
        (theme.brightness == Brightness.dark
                ? instrument.hairlineBorder
                : scheme.outlineVariant)
            .withValues(alpha: 0.65);

    Widget buildAxisDropdown({
      required String value,
      required String label,
      required ValueChanged<String?> onChanged,
    }) {
      return DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        decoration: InstrumentTheme.inputDecoration(context, labelText: label),
        items: _metrics
            .map(
              (m) => DropdownMenuItem<String>(
                value: m,
                child: Text(
                  _metricLabel(m, l10n),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: dims.pagePadding),
      child: Container(
        decoration: InstrumentTheme.instrumentCardDecoration(
          context,
          accentColor: instrument.workingAura,
          radius: 22,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                dims.cardPadding,
                dims.cardPadding,
                dims.cardPadding,
                12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ANALYTICS · TELEMETRY',
                    style: InstrumentTheme.microLabel(
                      context,
                      color: instrument.workingAura,
                    ),
                  ),
                  const SizedBox(height: 10),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final xDropdown = buildAxisDropdown(
                        value: _metricX,
                        label: l10n.coachAthletePlanAxisX,
                        onChanged: (v) =>
                            setState(() => _metricX = v ?? _metricX),
                      );
                      final yDropdown = buildAxisDropdown(
                        value: _metricY,
                        label: l10n.coachAthletePlanAxisY,
                        onChanged: (v) =>
                            setState(() => _metricY = v ?? _metricY),
                      );
                      if (constraints.maxWidth < 380) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            xDropdown,
                            const SizedBox(height: 10),
                            yDropdown,
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(child: xDropdown),
                          const SizedBox(width: 12),
                          Expanded(child: yDropdown),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 230,
              child: PlanAnalyticsChart(
                points: analytics,
                metricX: _metricX,
                metricY: _metricY,
                emptyText: l10n.coachAthletePlanNoAnalytics,
                showScatterAxisTitles: false,
              ),
            ),
            if (totals != null && totals.isNotEmpty) ...[
              Container(height: 1, color: hairline),
              Padding(
                padding: EdgeInsets.all(dims.cardPadding),
                child: InstrumentMetricMatrix(
                  cells: totals.entries
                      .toList()
                      .asMap()
                      .entries
                      .map(
                        (e) => InstrumentMetricCellData(
                          slot: MetricSlot.values[
                            e.key % MetricSlot.values.length
                          ],
                          label: _metricLabel(e.value.key, l10n).toUpperCase(),
                          value: e.value.value.toStringAsFixed(2),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlanSummary(AppliedCalendarPlan plan) {
    final l10n = AppLocalizations.of(context);
    final dims = UiDimensions.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final hairline =
        (theme.brightness == Brightness.dark
                ? instrument.hairlineBorder
                : scheme.outlineVariant)
            .withValues(alpha: 0.65);

    final adherence = plan.adherencePct;
    final completed = plan.actualSessionsCompleted ?? 0;
    final planned = plan.plannedSessionsTotal ?? 0;
    final status = (plan.status ?? 'active').toLowerCase();

    final Color statusColor = switch (status) {
      'completed' => instrument.successColor,
      'dropped' || 'cancelled' => instrument.peakEffortColor,
      _ => instrument.workingAura,
    };
    final statusLabel = status.isNotEmpty
        ? status.toUpperCase()
        : 'ACTIVE';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: dims.pagePadding),
      child: Container(
        decoration: InstrumentTheme.instrumentCardDecoration(
          context,
          accentColor: statusColor,
          radius: 22,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                dims.cardPadding,
                dims.cardPadding,
                dims.cardPadding,
                12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'COACH PLAN · $statusLabel',
                          style: InstrumentTheme.microLabel(
                            context,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 3),
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    plan.calendarPlan.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.coachAthletePlanPeriod(
                      _formatDate(plan.startDate),
                      _formatDate(plan.endDate),
                    ),
                    style: InstrumentTheme.tabular(
                      (theme.textTheme.bodySmall ?? const TextStyle()).copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (planned > 0) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 6,
                        backgroundColor: scheme.surfaceContainerHighest
                            .withValues(alpha: 0.45),
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                        value: (completed / planned).clamp(0, 1).toDouble(),
                      ),
                    ),
                  ],
                  if (plan.notes?.isNotEmpty == true) ...[
                    const SizedBox(height: 10),
                    Text(
                      l10n.coachAthletePlanNotes(plan.notes!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(height: 1, color: hairline),
            Padding(
              padding: EdgeInsets.all(dims.cardPadding),
              child: InstrumentMetricMatrix(
                cells: [
                  InstrumentMetricCellData(
                    slot: MetricSlot.setsCount,
                    label: AppLocalizations.of(context).sessionsUpperLabel,
                    value: planned > 0 ? '$completed/$planned' : '$completed',
                    valueColor: statusColor,
                  ),
                  InstrumentMetricCellData(
                    slot: MetricSlot.density,
                    label: AppLocalizations.of(context).adherenceUpperLabel,
                    value: adherence != null
                        ? '${adherence.toStringAsFixed(1)}%'
                        : '—',
                  ),
                  InstrumentMetricCellData(
                    slot: MetricSlot.durationWeeks,
                    label: AppLocalizations.of(context).startUpperLabel,
                    value: _formatDate(plan.startDate),
                  ),
                  InstrumentMetricCellData(
                    slot: MetricSlot.kpsh,
                    label: AppLocalizations.of(context).endUpperLabel,
                    value: _formatDate(plan.endDate),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _buildChatContext() async {
    try {
      final plan = await ref.read(
        coachActivePlanProvider(widget.athleteId).future,
      );
      final nowIso = DateTime.now().toUtc().toIso8601String();
      final selectionDate = _selectedDay.toIso8601String().split('T').first;

      final base = <String, dynamic>{
        'v': 1,
        'app': 'WorkoutApp',
        'screen': 'coach_athlete_plan',
        'role': 'coach',
        'timestamp': nowIso,
        'default_mass_edit_target': 'applied',
        'entities': <String, dynamic>{},
        'selection': <String, dynamic>{
          'athlete_id': widget.athleteId,
          'athlete_name': widget.athleteName,
          'date': selectionDate,
        },
      };

      final entities = base['entities'] as Map<String, dynamic>;
      if (plan != null) {
        entities['active_applied_plan'] = {
          'id': plan.id,
          'calendar_plan_id': plan.calendarPlanId,
          'name': plan.calendarPlan.name,
          'status': plan.status ?? 'active',
          'start_date': plan.startDate?.toIso8601String(),
          'end_date': plan.endDate.toIso8601String(),
          'adherence_pct': plan.adherencePct,
          'planned_sessions_total': plan.plannedSessionsTotal,
          'actual_sessions_completed': plan.actualSessionsCompleted,
        };

        entities['calendar_plan'] = {
          'id': plan.calendarPlan.id,
          'name': plan.calendarPlan.name,
          'primary_goal': plan.calendarPlan.primaryGoal,
          'intended_experience_level':
              plan.calendarPlan.intendedExperienceLevel,
          'intended_frequency_per_week':
              plan.calendarPlan.intendedFrequencyPerWeek,
        };
      }

      return base;
    } catch (e) {
      return <String, dynamic>{
        'v': 1,
        'app': 'WorkoutApp',
        'screen': 'coach_athlete_plan',
        'role': 'coach',
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'error': e.toString(),
      };
    }
  }

  Widget _buildCalendar(Map<DateTime, List<Workout>> eventsByDay) {
    final dims = UiDimensions.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: dims.pagePadding),
      child: Container(
        decoration: InstrumentTheme.instrumentCardDecoration(
          context,
          radius: 22,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: TableCalendar<Workout>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: _focusedDay,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarFormat: CalendarFormat.month,
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: InstrumentTheme.tabular(
              (theme.textTheme.titleMedium ?? const TextStyle()).copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: scheme.onSurfaceVariant,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: scheme.onSurfaceVariant,
            ),
          ),
          calendarStyle: CalendarStyle(
            defaultTextStyle: InstrumentTheme.tabular(
              TextStyle(color: scheme.onSurface),
            ),
            weekendTextStyle: InstrumentTheme.tabular(
              TextStyle(color: scheme.onSurfaceVariant),
            ),
            outsideTextStyle: InstrumentTheme.tabular(
              TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.45)),
            ),
            todayDecoration: BoxDecoration(
              color: instrument.workingAura.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: instrument.workingAura,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: InstrumentTheme.tabular(
              TextStyle(
                color: scheme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          eventLoader: (day) => eventsByDay[_dateOnly(day)] ?? const <Workout>[],
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = _dateOnly(selectedDay);
              _focusedDay = focusedDay;
            });
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isEmpty) return const SizedBox.shrink();
              final list = events.cast<Workout>();
              final counts = _statusCounts(list);
              return Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (counts.completed > 0) _dot(instrument.successColor),
                    if (counts.inProgress > 0) _dot(instrument.workingAura),
                    if (counts.planned > 0) _dot(instrument.peakEffortColor),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutsSection(
    AsyncValue<List<Workout>> workoutsAsync,
    Map<DateTime, List<Workout>> eventsByDay,
  ) {
    final selectedList = eventsByDay[_selectedDay] ?? const <Workout>[];
    final title = DateFormat('EEEE, MMM d, yyyy').format(_selectedDay);
    final dims = UiDimensions.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: dims.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: InstrumentTheme.tabular(
                    (theme.textTheme.titleMedium ?? const TextStyle()).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: AppLocalizations.of(context).refresh,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                onPressed: () {
                  ref.invalidate(
                    coachActivePlanWorkoutsProvider(widget.athleteId),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          workoutsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, _) => Padding(
              padding: EdgeInsets.all(dims.cardPadding),
              child: Text(
                AppLocalizations.of(context).activePlanLoadError(err.toString()),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            data: (_) {
              if (selectedList.isEmpty) {
                return Container(
                  decoration: InstrumentTheme.instrumentCardDecoration(
                    context,
                    radius: 20,
                  ),
                  padding: EdgeInsets.all(dims.cardPadding),
                  child: Text(
                    AppLocalizations.of(context).activePlanNoWorkoutsOnDay,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                );
              }
              return Column(
                children: selectedList
                    .map(
                      (w) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildWorkoutTile(w),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutTile(Workout workout) {
    final l10n = AppLocalizations.of(context);
    final dims = UiDimensions.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final hairline =
        (theme.brightness == Brightness.dark
                ? instrument.hairlineBorder
                : scheme.outlineVariant)
            .withValues(alpha: 0.65);
    final statusView = _statusView(workout);

    return Container(
      decoration: InstrumentTheme.instrumentCardDecoration(
        context,
        accentColor: statusView.dotColor,
        radius: 20,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openWorkoutDetails(workout),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                dims.cardPadding,
                dims.cardPadding,
                dims.cardPadding,
                12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _timeOrDate(workout).toUpperCase(),
                          style: InstrumentTheme.tabular(
                            InstrumentTheme.microLabel(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        statusView.label.toUpperCase(),
                        style: InstrumentTheme.microLabel(
                          context,
                          color: statusView.dotColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    workout.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (workout.notes?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      workout.notes!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(height: 1, color: hairline),
            Padding(
              padding: EdgeInsets.fromLTRB(
                dims.cardPadding,
                10,
                dims.cardPadding,
                12,
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  InstrumentActionButton(
                    label: l10n.coachAthletePlanMassEditTooltip,
                    icon: Icons.event,
                    variant: InstrumentActionVariant.secondary,
                    onPressed: workout.id == null
                        ? null
                        : () => _rescheduleWorkout(workout),
                  ),
                  InstrumentActionButton(
                    label: l10n.edit,
                    icon: Icons.edit_note,
                    variant: InstrumentActionVariant.secondary,
                    onPressed: workout.id == null
                        ? null
                        : () => _editWorkoutNotes(workout),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editWorkoutNotes(Workout workout) async {
    if (workout.id == null) return;
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: workout.notes ?? '');
    final String? newNotes = await showInstrumentDialog<String>(
      context: context,
      eyebrow: l10n.workoutNotesEyebrow,
      title: '${l10n.coachAthletePlanNotes('')} ${workout.name}',
      content: TextField(
        controller: controller,
        maxLines: 4,
        decoration: InstrumentTheme.inputDecoration(
          context,
          hintText: l10n.coachAthletePlanWorkoutNotesHint,
        ),
      ),
      actionsBuilder: (ctx) => [
        InstrumentActionButton(
          label: l10n.cancel,
          variant: InstrumentActionVariant.secondary,
          onPressed: () => Navigator.of(ctx).pop(),
        ),
        InstrumentActionButton(
          label: l10n.save,
          variant: InstrumentActionVariant.primary,
          onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
        ),
      ],
    );
    if (newNotes == null) return;
    try {
      final svc = ref.read(crmCoachServiceProvider);
      await svc.updateAthleteWorkout(
        athleteId: widget.athleteId,
        workoutId: workout.id!,
        payload: {'notes': newNotes.isEmpty ? null : newNotes},
      );
      if (mounted) {
        showAppSnackBar(context, l10n.coachAthletePlanWorkoutNotesUpdated);
      }
      ref.invalidate(coachActivePlanWorkoutsProvider(widget.athleteId));
    } catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          l10n.activePlanFailed(e.toString()),
          isError: true,
        );
      }
    }
  }

  Future<void> _rescheduleWorkout(Workout workout) async {
    if (workout.id == null) return;
    final DateTime initial = workout.scheduledFor ?? DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate == null || !mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (pickedTime == null) return;
    final scheduled = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    try {
      final svc = ref.read(crmCoachServiceProvider);
      await svc.updateAthleteWorkout(
        athleteId: widget.athleteId,
        workoutId: workout.id!,
        payload: {'scheduled_for': scheduled.toIso8601String()},
      );
      if (mounted) {
        showAppSnackBar(
          context,
          AppLocalizations.of(context).coachAthletePlanWorkoutRescheduled,
        );
      }
      ref.invalidate(coachActivePlanWorkoutsProvider(widget.athleteId));
    } catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          AppLocalizations.of(context).activePlanFailed(e.toString()),
          isError: true,
        );
      }
    }
  }

  void _openWorkoutDetails(Workout workout) {
    final l10n = AppLocalizations.of(context);
    final exercises = workout.exerciseInstances;
    showInstrumentBottomSheet<void>(
      context: context,
      eyebrow: _timeOrDate(workout),
      title: workout.name,
      headerActions: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          tooltip: l10n.coachAthletePlanAddExercise,
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          onPressed: workout.id == null
              ? null
              : () => _addExerciseInstance(workout),
        ),
      ],
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final scheme = theme.colorScheme;
        final instrument = InstrumentTheme.of(ctx);
        final hairline =
            (theme.brightness == Brightness.dark
                    ? instrument.hairlineBorder
                    : scheme.outlineVariant)
                .withValues(alpha: 0.65);

        if (exercises.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              l10n.coachAthletePlanNoExercises,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < exercises.length; index++) ...[
              if (index > 0) Container(height: 1, color: hairline),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercises[index].exerciseDefinition?.name ??
                                l10n.planEditorExerciseIdFallback(
                                  exercises[index].exerciseListId.toString(),
                                ),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (exercises[index].notes?.isNotEmpty == true) ...[
                            const SizedBox(height: 2),
                            Text(
                              l10n.coachAthletePlanNotes(
                                exercises[index].notes!,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            '${l10n.coachAthletePlanOrder(exercises[index].order?.toString() ?? '-')} · ${l10n.coachAthletePlanSets(exercises[index].sets.length.toString())}',
                            style: InstrumentTheme.tabular(
                              (theme.textTheme.bodySmall ?? const TextStyle())
                                  .copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: l10n.edit,
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                      onPressed: exercises[index].id == null
                          ? null
                          : () => _editExerciseInstance(exercises[index]),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: instrument.peakEffortColor,
                      ),
                      tooltip: l10n.delete,
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                      onPressed: exercises[index].id == null
                          ? null
                          : () => _deleteExerciseInstance(exercises[index]),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _addExerciseInstance(Workout workout) async {
    await _showExerciseEditor(workout: workout);
  }

  Future<void> _deleteExerciseInstance(ExerciseInstance instance) async {
    if (instance.id == null) return;
    final l10n = AppLocalizations.of(context);
    final instrument = InstrumentTheme.of(context);
    final confirm = await showInstrumentDialog<bool>(
      context: context,
      eyebrow: l10n.removeExerciseEyebrow,
      title: l10n.coachAthletePlanDeleteExerciseConfirmTitle,
      message: l10n.coachAthletePlanDeleteExerciseConfirmBody(
        instance.exerciseDefinition?.name ?? '',
      ),
      accentColor: instrument.peakEffortColor,
      actionsBuilder: (ctx) => [
        InstrumentActionButton(
          label: l10n.cancel,
          variant: InstrumentActionVariant.secondary,
          onPressed: () => Navigator.of(ctx).pop(false),
        ),
        InstrumentActionButton(
          label: l10n.delete,
          variant: InstrumentActionVariant.destructive,
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
      ],
    );

    if (confirm != true) return;

    try {
      final svc = ref.read(crmCoachServiceProvider);
      await svc.deleteExerciseInstance(
        athleteId: widget.athleteId,
        instanceId: instance.id!,
      );
      if (mounted) {
        showAppSnackBar(context, l10n.coachAthletePlanExerciseDeleted);
        Navigator.of(context).pop();
        ref.invalidate(coachActivePlanWorkoutsProvider(widget.athleteId));
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          l10n.coachAthletePlanDeleteError(e.toString()),
          isError: true,
        );
      }
    }
  }

  Future<void> _editExerciseInstance(ExerciseInstance instance) async {
    await _showExerciseEditor(instance: instance);
  }

  Future<void> _showExerciseEditor({
    Workout? workout,
    ExerciseInstance? instance,
  }) async {
    final isEdit = instance != null;
    final workoutId = workout?.id ?? instance?.workoutId;
    if (workoutId == null) return;

    List<ExerciseDefinition> definitions = [];
    try {
      definitions = await ref
          .read(exerciseServiceProvider)
          .getExerciseDefinitions();
    } catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          AppLocalizations.of(context).activePlanLoadError(e.toString()),
          isError: true,
        );
      }
      return;
    }

    definitions.sort((a, b) => a.name.compareTo(b.name));

    int? selectedExerciseId =
        instance?.exerciseListId ??
        (definitions.isNotEmpty ? definitions.first.id : null);
    String notes = instance?.notes ?? '';
    int? order = instance?.order;
    final List<ExerciseSetDto> sets = List.from(instance?.sets ?? []);

    if (!isEdit && sets.isEmpty) {
      sets.add(const ExerciseSetDto(reps: 10, weight: 20, effort: 8));
    }

    if (!mounted) return;
    final outerL10n = AppLocalizations.of(context);

    await showInstrumentDialog<void>(
      context: context,
      eyebrow: outerL10n.exerciseEditorEyebrow,
      title: isEdit
          ? outerL10n.coachAthletePlanEditExercise
          : outerL10n.coachAthletePlanAddExercise,
      content: StatefulBuilder(
        builder: (dialogCtx, setState) {
          final l10n = AppLocalizations.of(dialogCtx);
          final theme = Theme.of(dialogCtx);
          final scheme = theme.colorScheme;
          final instrument = InstrumentTheme.of(dialogCtx);
          final isDark = theme.brightness == Brightness.dark;
          final rowFill = isDark
              ? InstrumentPalette.obsidianSlotHigh
              : scheme.surfaceContainerHigh;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<int>(
                initialValue: selectedExerciseId,
                isExpanded: true,
                items: definitions
                    .map(
                      (d) => DropdownMenuItem(
                        value: d.id,
                        child: Text(d.name, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => selectedExerciseId = val),
                decoration: InstrumentTheme.inputDecoration(
                  dialogCtx,
                  labelText: l10n.exerciseName,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: notes,
                decoration: InstrumentTheme.inputDecoration(
                  dialogCtx,
                  labelText: l10n.activePlanNotesLabel,
                ),
                onChanged: (val) => notes = val,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: order?.toString() ?? '',
                decoration: InstrumentTheme.inputDecoration(
                  dialogCtx,
                  labelText: l10n.planEditorDayFilterLabel,
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) => order = int.tryParse(val),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.coachAthletePlanSetsLabel.toUpperCase(),
                    style: InstrumentTheme.microLabel(dialogCtx),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: l10n.coachAthletePlanAddSet,
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    onPressed: () => setState(() {
                      final last = sets.isNotEmpty
                          ? sets.last
                          : const ExerciseSetDto(reps: 10, weight: 20, effort: 8);
                      sets.add(last.copyWith(id: null));
                    }),
                  ),
                ],
              ),
              if (sets.isEmpty)
                Text(
                  l10n.coachAthletePlanNoSets,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              for (var index = 0; index < sets.length; index++) ...[
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: rowFill,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Text(
                            'SET ${index + 1}',
                            style: InstrumentTheme.tabular(
                              InstrumentTheme.microLabel(dialogCtx),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 18,
                              color: instrument.peakEffortColor,
                            ),
                            tooltip: l10n.delete,
                            constraints: const BoxConstraints(
                              minWidth: 48,
                              minHeight: 48,
                            ),
                            onPressed: () => setState(() => sets.removeAt(index)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: sets[index].reps.toString(),
                              decoration: InstrumentTheme.inputDecoration(
                                dialogCtx,
                                labelText: l10n.activePlanRepsLabel,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                              ),
                              style: InstrumentTheme.tabular(
                                theme.textTheme.bodyMedium ?? const TextStyle(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (v) {
                                sets[index] = sets[index].copyWith(
                                  reps: int.tryParse(v) ?? 0,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              initialValue: sets[index].weight.toString(),
                              decoration: InstrumentTheme.inputDecoration(
                                dialogCtx,
                                labelText: 'Kg',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                              ),
                              style: InstrumentTheme.tabular(
                                theme.textTheme.bodyMedium ?? const TextStyle(),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              onChanged: (v) {
                                sets[index] = sets[index].copyWith(
                                  weight: double.tryParse(v)?.toDouble() ?? 0.0,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              initialValue: sets[index].effort.toString(),
                              decoration: InstrumentTheme.inputDecoration(
                                dialogCtx,
                                labelText: l10n.activePlanRpeLabel,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                              ),
                              style: InstrumentTheme.tabular(
                                theme.textTheme.bodyMedium ?? const TextStyle(),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              onChanged: (v) {
                                sets[index] = sets[index].copyWith(
                                  effort: double.tryParse(v) ?? 0.0,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
      actionsBuilder: (ctx) => [
        InstrumentActionButton(
          label: outerL10n.cancel,
          variant: InstrumentActionVariant.secondary,
          onPressed: () => Navigator.of(ctx).pop(),
        ),
        InstrumentActionButton(
          label: outerL10n.save,
          variant: InstrumentActionVariant.primary,
          onPressed: () async {
            if (selectedExerciseId == null) {
              if (mounted) {
                showAppSnackBar(
                  context,
                  outerL10n.exerciseListEmptyNameError,
                  isError: true,
                );
              }
              return;
            }

            if (!isEdit && order == null) {
              final existing =
                  workout?.exerciseInstances ?? const <ExerciseInstance>[];
              int maxOrder = -1;
              for (final inst in existing) {
                final o = inst.order;
                if (o != null && o > maxOrder) {
                  maxOrder = o;
                }
              }
              order = maxOrder + 1;
            }

            try {
              final svc = ref.read(crmCoachServiceProvider);
              final payload = {
                'exercise_list_id': selectedExerciseId,
                'notes': notes.isEmpty ? null : notes,
                if (order != null) 'order': order,
                'sets': sets.map((s) => s.toFormData()).toList(),
              };

              if (isEdit) {
                await svc.updateExerciseInstance(
                  athleteId: widget.athleteId,
                  instanceId: instance.id!,
                  payload: payload,
                );
              } else {
                await svc.createExerciseInstance(
                  athleteId: widget.athleteId,
                  workoutId: workoutId,
                  payload: payload,
                );
              }
              if (mounted) {
                Navigator.of(ctx).pop();
                showAppSnackBar(
                  context,
                  isEdit
                      ? outerL10n.activePlanUpdatedSets(sets.length.toString())
                      : outerL10n.coachAthletePlanAddExercise,
                );
                ref.invalidate(
                  coachActivePlanWorkoutsProvider(widget.athleteId),
                );
                Navigator.of(context).pop();
              }
            } catch (e) {
              if (mounted) {
                showAppSnackBar(
                  context,
                  outerL10n.activePlanFailed(e.toString()),
                  isError: true,
                );
              }
            }
          },
        ),
      ],
    );
  }

  Future<void> _openCoachMassEditDialog() async {
    final allWorkouts = await ref.read(
      coachActivePlanWorkoutsProvider(widget.athleteId).future,
    );
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    if (allWorkouts.isEmpty) {
      showAppSnackBar(
        context,
        l10n.coachAthletePlanMassEditErrorNoWorkouts,
        isError: true,
      );
      return;
    }

    final dayWorkouts = allWorkouts.where((w) {
      final dt = w.scheduledFor;
      if (dt == null) return false;
      return _dateOnly(dt) == _selectedDay;
    }).toList();

    if (dayWorkouts.isEmpty) {
      showAppSnackBar(
        context,
        l10n.coachAthletePlanMassEditErrorNoWorkoutsOnDay,
        isError: true,
      );
      return;
    }

    final workoutNotesCtrl = TextEditingController();
    final exerciseNotesCtrl = TextEditingController();
    bool applyToWorkouts = true;
    bool applyToExercises = false;

    final confirmed = await showInstrumentDialog<bool>(
      context: context,
      eyebrow: DateFormat('dd MMM yyyy').format(_selectedDay).toUpperCase(),
      title: l10n.massEditLabel,
      content: StatefulBuilder(
        builder: (ctx, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InstrumentSelectablePill(
                label: l10n.coachAthletePlanMassEditUpdateWorkouts,
                icon: applyToWorkouts
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                selected: applyToWorkouts,
                bordered: false,
                onTap: () => setState(() => applyToWorkouts = !applyToWorkouts),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: workoutNotesCtrl,
                maxLines: 2,
                decoration: InstrumentTheme.inputDecoration(
                  ctx,
                  hintText: l10n.coachAthletePlanMassEditWorkoutHint,
                ),
              ),
              const SizedBox(height: 14),
              InstrumentSelectablePill(
                label: l10n.coachAthletePlanMassEditUpdateExercises,
                icon: applyToExercises
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                selected: applyToExercises,
                bordered: false,
                onTap: () =>
                    setState(() => applyToExercises = !applyToExercises),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: exerciseNotesCtrl,
                maxLines: 2,
                decoration: InstrumentTheme.inputDecoration(
                  ctx,
                  hintText: l10n.coachAthletePlanMassEditExerciseHint,
                ),
              ),
            ],
          );
        },
      ),
      actionsBuilder: (ctx) => [
        InstrumentActionButton(
          label: l10n.cancel,
          variant: InstrumentActionVariant.secondary,
          onPressed: () => Navigator.of(ctx).pop(false),
        ),
        InstrumentActionButton(
          label: l10n.apply,
          variant: InstrumentActionVariant.primary,
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
      ],
    );

    if (confirmed != true) return;

    final workoutNotes = workoutNotesCtrl.text.trim();
    final exerciseNotes = exerciseNotesCtrl.text.trim();

    final workoutsPayload = <Map<String, dynamic>>[];
    if (applyToWorkouts && workoutNotes.isNotEmpty) {
      for (final w in dayWorkouts) {
        if (w.id == null) continue;
        workoutsPayload.add({
          'workout_id': w.id!,
          'update': {'notes': workoutNotes},
        });
      }
    }

    final exercisePayload = <Map<String, dynamic>>[];
    if (applyToExercises && exerciseNotes.isNotEmpty) {
      for (final w in dayWorkouts) {
        for (final ex in w.exerciseInstances) {
          if (ex.id == null) continue;
          exercisePayload.add({
            'instance_id': ex.id!,
            'update': {'notes': exerciseNotes},
          });
        }
      }
    }

    if (workoutsPayload.isEmpty && exercisePayload.isEmpty) {
      if (mounted) {
        showAppSnackBar(context, l10n.coachAthletePlanMassEditNoChanges);
      }
      return;
    }

    try {
      final svc = ref.read(crmCoachMassEditServiceProvider);
      await svc.massEditWorkouts(
        athleteId: widget.athleteId,
        workouts: workoutsPayload.isEmpty ? null : workoutsPayload,
        exerciseInstances: exercisePayload.isEmpty ? null : exercisePayload,
      );
      if (mounted) {
        showAppSnackBar(context, l10n.coachAthletePlanMassEditApplied);
      }
      ref.invalidate(coachActivePlanWorkoutsProvider(widget.athleteId));
    } catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          l10n.coachAthletePlanMassEditError(e.toString()),
          isError: true,
        );
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _timeOrDate(Workout w) {
    final dt = w.scheduledFor;
    if (dt == null) return AppLocalizations.of(context).noDate;
    return DateFormat('MMM d, HH:mm').format(dt.toLocal());
  }

  _StatusView _statusView(Workout w) {
    final l10n = AppLocalizations.of(context);
    final instrument = InstrumentTheme.of(context);
    final completed =
        (w.status?.toLowerCase() == 'completed') || (w.completedAt != null);
    final inProgress = (w.startedAt != null) && (w.completedAt == null);
    if (completed) {
      return _StatusView(l10n.statusCompleted, instrument.successColor);
    } else if (inProgress) {
      return _StatusView(l10n.statusInProgress, instrument.workingAura);
    } else {
      return _StatusView(l10n.statusPlanned, instrument.peakEffortColor);
    }
  }

  ({int planned, int inProgress, int completed}) _statusCounts(
    List<Workout> list,
  ) {
    int p = 0, i = 0, c = 0;
    for (final w in list) {
      final completedB =
          (w.status?.toLowerCase() == 'completed') || (w.completedAt != null);
      final inProgressB = (w.startedAt != null) && (w.completedAt == null);
      if (completedB) {
        c++;
      } else if (inProgressB) {
        i++;
      } else {
        p++;
      }
    }
    return (planned: p, inProgress: i, completed: c);
  }

  Widget _dot(Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

class _StatusView {
  final String label;
  final Color dotColor;

  const _StatusView(this.label, this.dotColor);
}
