import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:workout_app/config/constants/theme_constants.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/responsive.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/models/applied_calendar_plan.dart';
import 'package:workout_app/models/plan_analytics.dart';
import 'package:workout_app/models/workout.dart';
import 'package:workout_app/providers/ambient_environment_provider.dart';
import 'package:workout_app/providers/interface_maker_provider.dart';
import 'package:workout_app/providers/plan_providers.dart';
import 'package:workout_app/screens/calendar_plans_screen.dart';
import 'package:workout_app/screens/user_profile_screen.dart';
import 'package:workout_app/screens/workout_detail_screen.dart';
import 'package:workout_app/services/logger_service.dart';
import 'package:workout_app/services/plan_service.dart';
import 'package:workout_app/services/service_locator.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/empty_state.dart';
import 'package:workout_app/widgets/error_message.dart';
import 'package:workout_app/widgets/instrument_metric_matrix.dart';
import 'package:workout_app/widgets/interface_maker_sheet.dart';
import 'package:workout_app/widgets/loading_indicator.dart';
import 'package:workout_app/widgets/plan_analytics_chart.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';
import 'package:workout_app/widgets/responsive_container.dart';

final _planServiceProvider = Provider<PlanService>(
  (ref) => PlanService(apiClient: ref.watch(apiClientProvider)),
);

final activePlanWorkoutsProvider = FutureProvider<List<Workout>>((ref) async {
  final plan = ref.watch(activeAppliedPlanSWRProvider).value;
  if (plan == null) return [];
  final workoutSvc = ref.watch(workoutServiceProvider);
  final list = await workoutSvc.getWorkoutsByAppliedPlan(plan.id);
  list.sort((a, b) {
    final ai = a.planOrderIndex ?? 1 << 30;
    final bi = b.planOrderIndex ?? 1 << 30;
    return ai.compareTo(bi);
  });
  return list;
});

final activePlanAnalyticsProvider = FutureProvider<PlanAnalyticsResponse?>((
  ref,
) async {
  final plan = ref.watch(activeAppliedPlanSWRProvider).value;
  if (plan == null) return null;
  final svc = ref.watch(_planServiceProvider);
  return await svc.getAppliedPlanAnalytics(plan.id, groupBy: 'order');
});

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

final workoutsByDayProvider = Provider<Map<DateTime, List<Workout>>>((ref) {
  final asyncList = ref.watch(activePlanWorkoutsProvider);
  if (!asyncList.hasValue) return const {};
  final map = <DateTime, List<Workout>>{};
  for (final w in asyncList.value ?? const <Workout>[]) {
    final dt = w.scheduledFor?.toLocal();
    if (dt == null) continue;
    final key = _dateOnly(dt);
    (map[key] ??= <Workout>[]).add(w);
  }
  return map;
});

class ActivePlanScreen extends ConsumerStatefulWidget {
  const ActivePlanScreen({super.key});

  @override
  ConsumerState<ActivePlanScreen> createState() => _ActivePlanScreenState();
}

class _ActivePlanScreenState extends ConsumerState<ActivePlanScreen> {
  final _logger = LoggerService('ActivePlanScreen');
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _manualDaySelection = false;
  ProviderSubscription<AsyncValue<List<Workout>>>? _workoutsSub;

  String _metricX = 'effort_avg';
  String _metricY = 'effort_avg';
  MetricSlot? _selectedMatrixSlot;
  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;
  bool _chartExpanded = false;

  void _updateState(VoidCallback fn) => setState(fn);

  String _mapSlotToActivePlanMetric(MetricSlot slot) {
    switch (slot) {
      case MetricSlot.peakIntensity:
      case MetricSlot.e1rm:
        return 'intensity_avg';
      case MetricSlot.peakRpe:
      case MetricSlot.avgRpe:
        return 'effort_avg';
      case MetricSlot.tonnage:
      case MetricSlot.kpsh:
      case MetricSlot.density:
        return 'volume_sum';
      case MetricSlot.setsCount:
      case MetricSlot.durationWeeks:
      case MetricSlot.frequencyPerWeek:
        return 'sets_count';
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _dateOnly(DateTime.now());
    _focusedDay = _selectedDay!;

    _workoutsSub = ref.listenManual<AsyncValue<List<Workout>>>(
      activePlanWorkoutsProvider,
      (previous, next) {
        final list = next.valueOrNull;
        if (list == null || !mounted) return;
        _maybeAutoSelectDayFromWorkouts(list);
      },
    );
  }

  @override
  void dispose() {
    _workoutsSub?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(activeAppliedPlanSWRProvider);
    final analyticsAsync = ref.watch(activePlanAnalyticsProvider);
    final eventsByDay = ref.watch(workoutsByDayProvider);
    final interfaceConfig = ref.watch(interfaceMakerProvider);
    final instrument = InstrumentTheme.of(context);
    final dimensions = UiDimensions.of(context);

    final activePlan = planAsync.valueOrNull;
    final env = activePlan != null
        ? TrainingEnvironmentData.fromPlan(activePlan.calendarPlan)
        : const TrainingEnvironmentData.idle();
    final accent = env.accentColor(instrument);

    return AssistantChatHost(
      initialMessage:
          'Opening assistant from ActivePlanScreen. Use the provided structured v1 context to understand the current plan and selected day.',
      contextBuilder: _buildChatContext,
      builder: (context, openChat) {
        final l10n = AppLocalizations.of(context);
        return AmbientScaffoldShell(
          environment: env,
          appBar: PrimaryAppBar.main(
            title: l10n.activePlanTitle,
            onTitleTap: openChat,
            actions: [
              IconButton(
                tooltip: l10n.profile,
                icon: const Icon(Icons.account_circle_outlined),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const UserProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(activeAppliedPlanSWRProvider);
              ref.invalidate(activePlanAnalyticsProvider);
              ref.invalidate(activePlanWorkoutsProvider);
            },
            child: planAsync.when(
              loading: () => const LoadingIndicator(),
              error: (error, stack) => Padding(
                padding: EdgeInsets.only(
                  top: AmbientScaffoldShell.topContentInset(context),
                ),
                child: ErrorMessage(
                  message: 'Failed to load active plan: $error',
                  onRetry: () => ref.invalidate(activeAppliedPlanSWRProvider),
                ),
              ),
              data: (plan) {
                if (plan == null) {
                  return Padding(
                    padding: EdgeInsets.only(
                      top: AmbientScaffoldShell.topContentInset(context),
                    ),
                    child: EmptyState(
                      icon: Icons.fitness_center,
                      title: l10n.activePlanEmptyTitle,
                      description: l10n.activePlanEmptyDescription,
                      action: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const CalendarPlansScreen(),
                            ),
                          );
                        },
                        child: Text(l10n.activePlanSelectPlan),
                      ),
                    ),
                  );
                }

                final isWide = Responsive.isWide(context);
                final showBriefing = interfaceConfig.isModuleVisible(
                  LayoutModule.commandBriefing,
                );

                String calendarHorizonLabel() {
                  switch (_calendarFormat) {
                    case CalendarFormat.week:
                      return l10n.horizon1Week;
                    case CalendarFormat.twoWeeks:
                      return l10n.horizon2Weeks;
                    case CalendarFormat.month:
                      return l10n.horizonMonth;
                  }
                }

                void cycleCalendarHorizon() {
                  setState(() {
                    _calendarFormat = switch (_calendarFormat) {
                      CalendarFormat.twoWeeks => CalendarFormat.month,
                      CalendarFormat.month => CalendarFormat.week,
                      CalendarFormat.week => CalendarFormat.twoWeeks,
                    };
                  });
                }

                Widget buildModule(LayoutModule module) {
                  switch (module) {
                    case LayoutModule.variantOrHorizonStrip:
                      return Padding(
                        padding: EdgeInsets.only(bottom: dimensions.sectionGap),
                        child: CanvasPillStrip(
                          padding: EdgeInsets.symmetric(
                            horizontal: dimensions.pagePadding,
                          ),
                          items: [
                            CanvasPillItem(
                              label: InterfacePreset.powerlifter.localizedLabel(l10n),
                              selected: interfaceConfig.preset ==
                                  InterfacePreset.powerlifter,
                              accentColor: accent,
                              onTap: () => ref
                                  .read(interfaceMakerProvider.notifier)
                                  .applyPreset(InterfacePreset.powerlifter),
                            ),
                            CanvasPillItem(
                              label: InterfacePreset.volume.localizedLabel(l10n),
                              selected: interfaceConfig.preset ==
                                  InterfacePreset.volume,
                              accentColor: accent,
                              onTap: () => ref
                                  .read(interfaceMakerProvider.notifier)
                                  .applyPreset(InterfacePreset.volume),
                            ),
                            CanvasPillItem(
                              label: InterfacePreset.minimalist.localizedLabel(l10n),
                              selected: interfaceConfig.preset ==
                                  InterfacePreset.minimalist,
                              accentColor: accent,
                              onTap: () => ref
                                  .read(interfaceMakerProvider.notifier)
                                  .applyPreset(InterfacePreset.minimalist),
                            ),
                            CanvasPillItem(
                              label: l10n.horizonChipLabel(calendarHorizonLabel()),
                              icon: Icons.date_range_outlined,
                              onTap: cycleCalendarHorizon,
                            ),
                            CanvasPillItem(
                              label: l10n.gridPillLabel,
                              icon: Icons.grid_view_rounded,
                              onTap: () => InterfaceMakerSheet.show(context),
                            ),
                          ],
                        ),
                      );
                    case LayoutModule.commandBriefing:
                      return const SizedBox.shrink();
                    case LayoutModule.primaryTelemetry:
                      return Padding(
                        padding: EdgeInsets.only(bottom: dimensions.sectionGap),
                        child: _buildAnalyticsAsyncSection(
                          analyticsAsync,
                          plan: plan,
                          env: env,
                          interfaceConfig: interfaceConfig,
                          showBriefing: showBriefing,
                        ),
                      );
                    case LayoutModule.scheduleOrLibrary:
                      if (isWide) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: dimensions.pagePadding,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: _buildCalendarModule(
                                  eventsByDay,
                                  accent: accent,
                                  embeddedSchedule: false,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 5,
                                child: _buildStandaloneScheduleCard(eventsByDay),
                              ),
                            ],
                          ),
                        );
                      }
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: dimensions.pagePadding,
                        ),
                        child: _buildCalendarModule(
                          eventsByDay,
                          accent: accent,
                          embeddedSchedule: true,
                        ),
                      );
                  }
                }

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                    top: AmbientScaffoldShell.topContentInset(context),
                    bottom: AmbientScaffoldShell.bottomContentInset(context),
                  ),
                  child: ResponsiveContainer(
                    maxWidth: Breakpoints.maxContentWidthWide,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final module in interfaceConfig.visibleModules)
                          buildModule(module),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _buildChatContext() async {
    try {
      final plan = await ref.read(activeAppliedPlanSWRProvider.future);
      final nowIso = DateTime.now().toUtc().toIso8601String();
      final selectionDate = (_selectedDay ?? _dateOnly(DateTime.now()))
          .toIso8601String()
          .split('T')
          .first;

      final base = <String, dynamic>{
        'v': 1,
        'app': 'WorkoutApp',
        'screen': 'active_plan',
        'role': 'athlete',
        'timestamp': nowIso,
        'default_mass_edit_target': 'applied',
        'entities': <String, dynamic>{},
        'selection': <String, dynamic>{'date': selectionDate},
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
      } else {
        entities['active_applied_plan'] = null;
      }

      final workouts = await ref.read(activePlanWorkoutsProvider.future);
      final autocomplete = <String, dynamic>{};

      if (workouts.isNotEmpty) {
        final items = <Map<String, dynamic>>[];
        for (final w in workouts) {
          final idx = w.planOrderIndex;
          if (idx == null) continue;
          final alias = '/workout_${idx + 1}';
          items.add({'alias': alias, 'name': w.name, 'plan_order_index': idx});
        }
        if (items.isNotEmpty) {
          autocomplete['workouts'] = items;
        }
      }

      final exSvc = ref.read(exerciseServiceProvider);
      final defs = await exSvc.getExerciseDefinitions();
      if (defs.isNotEmpty) {
        final items = <Map<String, dynamic>>[];
        for (final d in defs) {
          if (d.name.isEmpty) continue;
          final alias = '/${d.name}';
          items.add({'alias': alias, 'name': d.name, 'id': d.id});
        }
        if (items.isNotEmpty) {
          autocomplete['exercises'] = items;
        }
      }

      if (autocomplete.isNotEmpty) {
        base['autocomplete'] = autocomplete;
      }

      return base;
    } catch (e, st) {
      _logger.e('Failed to build assistant context', e, st);
      return <String, dynamic>{
        'v': 1,
        'app': 'WorkoutApp',
        'screen': 'active_plan',
        'role': 'athlete',
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'error': e.toString(),
      };
    }
  }

  void _maybeAutoSelectDayFromWorkouts(
    List<Workout> workouts, {
    bool force = false,
  }) {
    final today = _dateOnly(DateTime.now());
    final current = _dateOnly(_selectedDay ?? today);

    final currentWorkouts = workouts.where((w) {
      final dt = w.scheduledFor?.toLocal();
      if (dt == null) return false;
      return _dateOnly(dt) == current;
    }).toList();

    final hasPendingOnCurrent = currentWorkouts.any((w) => !w.isCompleted);

    final shouldAuto =
        force ||
        (!_manualDaySelection &&
            (currentWorkouts.isEmpty || !hasPendingOnCurrent)) ||
        (current.isBefore(today) && !hasPendingOnCurrent);
    if (!shouldAuto) return;

    final upcoming = workouts.where((w) {
      final dt = w.scheduledFor?.toLocal();
      if (dt == null) return false;
      if (_dateOnly(dt).isBefore(today)) return false;
      return !w.isCompleted;
    }).toList();

    upcoming.sort((a, b) {
      final da = _dateOnly(a.scheduledFor!.toLocal());
      final db = _dateOnly(b.scheduledFor!.toLocal());
      final cmp = da.compareTo(db);
      if (cmp != 0) return cmp;
      final ai = a.planOrderIndex ?? 1 << 30;
      final bi = b.planOrderIndex ?? 1 << 30;
      return ai.compareTo(bi);
    });

    if (upcoming.isEmpty) return;

    final desired = _dateOnly(upcoming.first.scheduledFor!.toLocal());
    if (_selectedDay != null && isSameDay(desired, _selectedDay)) return;
    if (!mounted) return;
    setState(() {
      _selectedDay = desired;
      _focusedDay = desired;
    });
  }

  Future<void> _refreshAfterWorkoutChange() async {
    ref.invalidate(activePlanWorkoutsProvider);
    ref.invalidate(activePlanAnalyticsProvider);
    try {
      final list = await ref.read(activePlanWorkoutsProvider.future);
      if (!mounted) return;
      _maybeAutoSelectDayFromWorkouts(list);
    } catch (_) {}
  }

  Widget _buildAnalyticsAsyncSection(
    AsyncValue<PlanAnalyticsResponse?> analyticsAsync, {
    required AppliedCalendarPlan plan,
    required TrainingEnvironmentData env,
    required InterfaceConfig interfaceConfig,
    required bool showBriefing,
  }) {
    final dimensions = UiDimensions.of(context);
    final instrument = InstrumentTheme.of(context);
    final accent = env.accentColor(instrument);
    return analyticsAsync.when(
      loading: () => Container(
        margin: EdgeInsets.symmetric(horizontal: dimensions.pagePadding),
        height: 220,
        decoration: InstrumentTheme.instrumentCardDecoration(
          context,
          accentColor: accent,
          radius: 22,
        ),
        child: const LoadingIndicator(),
      ),
      error: (error, stack) => Container(
        margin: EdgeInsets.symmetric(horizontal: dimensions.pagePadding),
        height: 220,
        decoration: InstrumentTheme.instrumentCardDecoration(
          context,
          accentColor: Theme.of(context).colorScheme.error,
          radius: 22,
        ),
        child: ErrorMessage(
          message: 'Failed to load analytics: $error',
          onRetry: () => ref.invalidate(activePlanAnalyticsProvider),
        ),
      ),
      data: (resp) {
        final points = _mapAnalyticsResponse(resp);
        final totals = resp?.totals;
        return _buildActiveAnalyticsSection(
          points,
          totals: totals,
          plan: plan,
          env: env,
          interfaceConfig: interfaceConfig,
          showBriefing: showBriefing,
        );
      },
    );
  }

  Widget _buildCalendarModule(
    Map<DateTime, List<Workout>> eventsByDay, {
    required Color accent,
    required bool embeddedSchedule,
  }) {
    final dimensions = UiDimensions.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hairline = (isDark ? instrument.hairlineBorder : colors.outlineVariant)
        .withValues(alpha: isDark ? 0.85 : 0.55);

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: InstrumentTheme.instrumentCardDecoration(
          context,
          accentColor: accent,
          radius: 22,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Text(
                AppLocalizations.of(context).activePlanMicrocycleCalendarHeader,
                style: InstrumentTheme.microLabel(
                  context,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                dimensions.rowGap,
                0,
                dimensions.rowGap,
                dimensions.rowGap,
              ),
              child: TableCalendar<Workout>(
                rowHeight: dimensions.calendarRowHeight,
                firstDay: DateTime.utc(2018, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                focusedDay: _focusedDay,
                startingDayOfWeek: StartingDayOfWeek.monday,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: (day) =>
                    eventsByDay[_dateOnly(day)] ?? const <Workout>[],
                calendarFormat: _calendarFormat,
                onFormatChanged: (format) =>
                    setState(() => _calendarFormat = format),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _manualDaySelection = true;
                    _selectedDay = _dateOnly(selectedDay);
                    _focusedDay = focusedDay;
                  });
                  _openDaySheet();
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isEmpty) return const SizedBox.shrink();
                    final List<Workout> list = events.cast<Workout>();
                    final counts = _statusCounts(list);
                    return Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (counts.completed > 0)
                            _dot(instrument.successColor),
                          if (counts.inProgress > 0) _dot(colors.primary),
                          if (counts.planned > 0) _dot(colors.error),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            if (embeddedSchedule) ...[
              Container(height: 1, color: hairline),
              _buildDayHeaderContent(),
              _buildDayListContent(eventsByDay, hairline: hairline),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStandaloneScheduleCard(
    Map<DateTime, List<Workout>> eventsByDay,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hairline = (isDark ? instrument.hairlineBorder : colors.outlineVariant)
        .withValues(alpha: isDark ? 0.85 : 0.55);

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: InstrumentTheme.instrumentCardDecoration(
          context,
          radius: 22,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDayHeaderContent(),
            Container(height: 1, color: hairline),
            _buildDayListContent(eventsByDay, hairline: hairline),
          ],
        ),
      ),
    );
  }

  Widget _buildDayHeaderContent() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final day = _selectedDay ?? _dateOnly(DateTime.now());
    final title = DateFormat('EEEE, MMM d, yyyy').format(day);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context).activePlanDayLabel,
                  style: InstrumentTheme.microLabel(
                    context,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _openDaySheet,
            style: TextButton.styleFrom(
              minimumSize: const Size(48, 48),
              tapTargetSize: MaterialTapTargetSize.padded,
            ),
            child: Text(AppLocalizations.of(context).actionView),
          ),
        ],
      ),
    );
  }

  Widget _buildDayListContent(
    Map<DateTime, List<Workout>> eventsByDay, {
    required Color hairline,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final day = _selectedDay ?? _dateOnly(DateTime.now());
    final workouts = eventsByDay[day] ?? const <Workout>[];
    if (workouts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
        child: Text(
          AppLocalizations.of(context).activePlanNoWorkoutsSelectedDay,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < workouts.length; i++) ...[
          _buildScheduleRow(workouts[i]),
          if (i < workouts.length - 1) Container(height: 1, color: hairline),
        ],
      ],
    );
  }

  Widget _buildScheduleRow(Workout w) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final st = _statusOf(w);
    return InkWell(
      onTap: () async {
        if (w.id != null) {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => WorkoutDetailScreen(workoutId: w.id!),
            ),
          );
          if (!mounted) return;
          await _refreshAfterWorkoutChange();
        }
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: st.dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    w.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _timeOrDate(w),
                    style: InstrumentTheme.tabular(
                      theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ) ??
                          const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              st.label.toUpperCase(),
              style: InstrumentTheme.microLabel(context, color: st.dotColor),
            ),
          ],
        ),
      ),
    );
  }

  void _openDaySheet() {
    final eventsByDay = ref.read(workoutsByDayProvider);
    final day = _selectedDay ?? _dateOnly(DateTime.now());
    final workouts = eventsByDay[day] ?? const <Workout>[];
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(UiDimensions.of(ctx).pagePadding, 8, UiDimensions.of(ctx).pagePadding, UiDimensions.of(ctx).cardPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  DateFormat('EEEE, MMM d, yyyy').format(day),
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: 8),
                if (workouts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(AppLocalizations.of(context).noWorkouts),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (ctx, i) {
                        final w = workouts[i];
                        final st = _statusOf(w);
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: st.dotColor,
                            radius: 6,
                          ),
                          title: Text(w.name),
                          subtitle: Text(_timeOrDate(w)),
                          trailing: IconButton(
                            icon: const Icon(Icons.open_in_new),
                            onPressed: () async {
                              if (w.id != null) {
                                await Navigator.of(ctx).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        WorkoutDetailScreen(workoutId: w.id!),
                                  ),
                                );
                                if (!mounted) return;
                                await _refreshAfterWorkoutChange();
                              }
                            },
                          ),
                          onTap: () async {
                            if (w.id != null) {
                              await Navigator.of(ctx).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      WorkoutDetailScreen(workoutId: w.id!),
                                ),
                              );
                              if (!mounted) return;
                              await _refreshAfterWorkoutChange();
                            }
                          },
                        );
                      },
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemCount: workouts.length,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _timeOrDate(Workout w) {
    final dt = w.scheduledFor?.toLocal();
    if (dt == null) return 'Unscheduled';
    return DateFormat('MMM d, yyyy – HH:mm').format(dt);
  }

  _StatusView _statusOf(Workout w) {
    final completed =
        (w.status?.toLowerCase() == 'completed') || (w.completedAt != null);
    final inProgress = (w.startedAt != null) && (w.completedAt == null);
    if (completed) {
      return _StatusView(
        'Completed',
        Theme.of(context).colorScheme.tertiaryContainer,
        Theme.of(context).colorScheme.onTertiaryContainer,
        Theme.of(context).colorScheme.tertiary,
      );
    } else if (inProgress) {
      return _StatusView(
        'In Progress',
        Theme.of(context).colorScheme.primaryContainer,
        Theme.of(context).colorScheme.onPrimaryContainer,
        Theme.of(context).colorScheme.primary,
      );
    } else {
      return _StatusView(
        'Planned',
        Theme.of(context).colorScheme.errorContainer,
        Theme.of(context).colorScheme.onErrorContainer,
        Theme.of(context).colorScheme.error,
      );
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
      if (completedB)
        c++;
      else if (inProgressB)
        i++;
      else
        p++;
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

extension _APAnalytics on _ActivePlanScreenState {
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

  List<InstrumentMetricCellData> _buildActivePlanMatrixCells({
    required List<MetricSlot> slots,
    required Map<String, double>? totals,
    required AppliedCalendarPlan plan,
    required Color accent,
  }) {
    String fmtNum(double? v, {String suffix = '', int decimals = 0}) {
      if (v == null || !v.isFinite) return '—';
      final numStr = decimals == 0
          ? v.round().toString()
          : v.toStringAsFixed(decimals);
      return '$numStr$suffix';
    }

    final setsTotal = totals?['sets_count'];
    final volTotal = totals?['volume_sum'];
    final intensityAvg = totals?['intensity_avg'];
    final effortAvg = totals?['effort_avg'];

    final l10n = AppLocalizations.of(context);
    return slots.map((slot) {
      switch (slot) {
        case MetricSlot.peakIntensity:
          return InstrumentMetricCellData(
            slot: slot,
            label: l10n.metricAvgIntensityShort,
            value: fmtNum(intensityAvg, suffix: '%'),
            valueColor: intensityAvg != null ? accent : null,
          );
        case MetricSlot.e1rm:
          return InstrumentMetricCellData(
            slot: slot,
            label: l10n.metricCompletedShort,
            value: plan.adherencePct != null
                ? '${plan.adherencePct!.round()}%'
                : '—',
          );
        case MetricSlot.peakRpe:
        case MetricSlot.avgRpe:
          return InstrumentMetricCellData(
            slot: slot,
            label: l10n.metricAvgRpeShort,
            value: effortAvg != null
                ? 'RPE ${effortAvg.toStringAsFixed(1)}'
                : '—',
          );
        case MetricSlot.tonnage:
        case MetricSlot.kpsh:
          return InstrumentMetricCellData(
            slot: slot,
            label: l10n.metricRepsShort,
            value: fmtNum(volTotal),
          );
        case MetricSlot.setsCount:
          return InstrumentMetricCellData(
            slot: slot,
            label: l10n.metricSetsShort,
            value: fmtNum(setsTotal),
          );
        case MetricSlot.density:
          return InstrumentMetricCellData(
            slot: slot,
            label: l10n.metricSessionsShort,
            value:
                '${plan.actualSessionsCompleted}/${plan.plannedSessionsTotal}',
          );
        case MetricSlot.durationWeeks:
          return InstrumentMetricCellData(
            slot: slot,
            value: '${plan.calendarPlan.durationWeeks} wk',
          );
        case MetricSlot.frequencyPerWeek:
          final freq = plan.calendarPlan.intendedFrequencyPerWeek;
          return InstrumentMetricCellData(
            slot: slot,
            value: freq != null ? '$freq×/wk' : '—',
          );
      }
    }).toList(growable: false);
  }

  Widget _buildActiveAnalyticsSection(
    List<PlanAnalyticsPoint> analytics, {
    Map<String, double>? totals,
    required AppliedCalendarPlan plan,
    required TrainingEnvironmentData env,
    required InterfaceConfig interfaceConfig,
    required bool showBriefing,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dimensions = UiDimensions.of(context);
    final instrument = InstrumentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = env.accentColor(instrument);
    final hairline = (isDark ? instrument.hairlineBorder : colors.outlineVariant)
        .withValues(alpha: isDark ? 0.85 : 0.55);

    final cells = _buildActivePlanMatrixCells(
      slots: interfaceConfig.slots,
      totals: totals,
      plan: plan,
      accent: accent,
    );
    final MetricSlot activeSlot =
        _selectedMatrixSlot != null &&
                interfaceConfig.slots.contains(_selectedMatrixSlot)
            ? _selectedMatrixSlot!
            : (interfaceConfig.slots.isNotEmpty
                ? interfaceConfig.slots.first
                : MetricSlot.avgRpe);

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: dimensions.pagePadding),
        decoration: InstrumentTheme.instrumentCardDecoration(
          context,
          accentColor: accent,
          radius: 22,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'ACTIVE PLAN · ${(plan.adherencePct ?? 0).round()}% ADHERENCE',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: InstrumentTheme.tabular(
                            InstrumentTheme.microLabel(
                              context,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        env.localizedBadgeLabel(AppLocalizations.of(context)),
                        style: InstrumentTheme.microLabel(
                          context,
                          color: accent,
                        ),
                      ),
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: IconButton(
                          tooltip: _chartExpanded
                              ? AppLocalizations.of(context).tooltipCollapseChart
                              : AppLocalizations.of(context).tooltipExpandChart,
                          style: IconButton.styleFrom(
                            minimumSize: const Size(48, 48),
                            tapTargetSize: MaterialTapTargetSize.padded,
                          ),
                          onPressed: () =>
                              _updateState(() => _chartExpanded = !_chartExpanded),
                          icon: Icon(
                            _chartExpanded
                                ? Icons.unfold_less
                                : Icons.unfold_more,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    plan.calendarPlan.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  if (showBriefing) ...[
                    const SizedBox(height: 4),
                    Text(
                      env.localizedBriefing(
                        AppLocalizations.of(context),
                        snarky: interfaceConfig.snarkyVoice,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (interfaceConfig.showChart) ...[
              Padding(
                padding: EdgeInsets.zero,
                child: SizedBox(
                  height: _chartExpanded ? 210 : 148,
                  child: PlanAnalyticsChart(
                    points: analytics,
                    metricX: _metricX,
                    metricY: _metricY,
                    bleedMode: true,
                    accentColor: accent,
                    emptyText: AppLocalizations.of(context).activePlanNoData,
                    showScatterAxisTitles: false,
                  ),
                ),
              ),
            ],
            Container(height: 1, color: hairline),
            InstrumentMetricMatrix(
              cells: cells,
              selectedSlot: activeSlot,
              accentColor: accent,
              onSelectSlot: (slot) {
                final mapped = _mapSlotToActivePlanMetric(slot);
                _updateState(() {
                  _selectedMatrixSlot = slot;
                  _metricX = mapped;
                  _metricY = mapped;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusView {
  final String label;
  final Color background;
  final Color textColor;
  final Color dotColor;
  const _StatusView(this.label, this.background, this.textColor, this.dotColor);
}

extension _WorkoutGuards on Workout {
  bool get isCompleted =>
      (status?.toLowerCase() == 'completed') || (completedAt != null);
}
