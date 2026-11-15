import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_app/config/constants/route_names.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/responsive.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/models/crm_analytics.dart';
import 'package:workout_app/providers/ambient_environment_provider.dart';
import 'package:workout_app/providers/interface_maker_provider.dart';
import 'package:workout_app/screens/coach_athlete_plan_screen.dart';
import 'package:workout_app/services/service_locator.dart' as sl;
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/instrument_metric_matrix.dart';
import 'package:workout_app/widgets/instrument_modal.dart';
import 'package:workout_app/widgets/interface_maker_sheet.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';
import 'package:workout_app/widgets/responsive_container.dart';

final coachAthletesAnalyticsProvider =
    FutureProvider<CoachAthletesAnalyticsModel>((ref) async {
      final svc = ref.watch(sl.crmAnalyticsServiceProvider);
      return svc.getMyAthletesAnalytics();
    });

final athleteDisplayNameProvider =
    FutureProvider.family<String, String>((ref, athleteId) async {
      final profileService = ref.watch(sl.profileServiceProvider);
      try {
        final profile = await profileService.fetchProfileById(athleteId);
        final displayName = profile.displayName;
        if (displayName != null && displayName.trim().isNotEmpty) {
          return displayName;
        }
      } catch (_) {}
      return athleteId;
    });

final segmentFilterProvider = StateProvider<String?>((_) => null);
final minSessionsPerWeekProvider = StateProvider<double>((_) => 0);
final minPlanAdherenceProvider = StateProvider<double>((_) => 0);
final sortOptionProvider = StateProvider<_CoachAthleteSort>(
  (_) => _CoachAthleteSort.recentlyActive,
);

enum _CoachAthleteSort { recentlyActive, sessionsPerWeek, planAdherence }

class CoachAthletesScreen extends ConsumerWidget {
  const CoachAthletesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(coachAthletesAnalyticsProvider);
    final segmentFilter = ref.watch(segmentFilterProvider);
    final minSessions = ref.watch(minSessionsPerWeekProvider);
    final minAdherence = ref.watch(minPlanAdherenceProvider);
    final sortOption = ref.watch(sortOptionProvider);
    final env = ref.watch(activeTrainingEnvironmentProvider(null));
    final instrument = InstrumentTheme.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dims = UiDimensions.of(context);

    const segments = ['top_performer', 'on_track', 'at_risk', 'new'];

    return AssistantChatHost(
      initialMessage:
          'Открываю ассистента из CoachAthletesScreen. Используй переданный контекст v1, чтобы понимать выбранные фильтры и приоритетных атлетов.',
      contextBuilder: () => _buildCoachAthletesChatContext(ref),
      builder: (context, openChat) {
        return AmbientScaffoldShell(
          environment: env,
          appBar: PrimaryAppBar(
            title: 'My Athletes',
            onTitleTap: openChat,
            actions: [
              IconButton(
                icon: const Icon(Icons.tune),
                tooltip: 'Thresholds & filters',
                onPressed: () => _openThresholdSheet(context),
              ),
            ],
          ),
          body: asyncData.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Padding(
                padding: EdgeInsets.all(dims.pagePadding),
                child: Text(
                  'Error: $error',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            data: (analytics) {
              if (analytics.athletes.isEmpty) {
                return Center(
                  child: Text(
                    'No athletes yet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                );
              }
              final filtered = analytics.athletes.where((a) {
                final segOk = segmentFilter == null || a.segment == segmentFilter;
                final sessOk = (a.sessionsPerWeek ?? 0) >= minSessions;
                final adhOk = (a.planAdherence ?? 0) >= minAdherence;
                return segOk && sessOk && adhOk;
              }).toList();

              filtered.sort((a, b) {
                switch (sortOption) {
                  case _CoachAthleteSort.sessionsPerWeek:
                    return (b.sessionsPerWeek ?? -1).compareTo(
                      a.sessionsPerWeek ?? -1,
                    );
                  case _CoachAthleteSort.planAdherence:
                    return (b.planAdherence ?? -1).compareTo(
                      a.planAdherence ?? -1,
                    );
                  case _CoachAthleteSort.recentlyActive:
                    final aDays = a.daysSinceLastWorkout ?? 9999;
                    final bDays = b.daysSinceLastWorkout ?? 9999;
                    return aDays.compareTo(bDays);
                }
              });

              final avgSess = filtered.isEmpty
                  ? 0.0
                  : filtered
                            .map((a) => a.sessionsPerWeek ?? 0.0)
                            .reduce((a, b) => a + b) /
                        filtered.length;
              final atRiskCount = filtered
                  .where((a) => a.segment == 'at_risk')
                  .length;
              final hasThresholds = minSessions > 0 || minAdherence > 0;

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(coachAthletesAnalyticsProvider);
                  await ref.read(coachAthletesAnalyticsProvider.future);
                },
                child: ResponsiveContainer(
                  maxWidth: Breakpoints.maxContentWidthWide,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      0,
                      AmbientScaffoldShell.topContentInset(context),
                      0,
                      AmbientScaffoldShell.bottomContentInset(context),
                    ),
                    children: [
                      CanvasPillStrip(
                        padding: EdgeInsets.symmetric(
                          horizontal: dims.pagePadding,
                        ),
                        items: [
                          CanvasPillItem(
                            key: const ValueKey('seg_all'),
                            label: 'All segments',
                            selected: segmentFilter == null,
                            onTap: () =>
                                ref.read(segmentFilterProvider.notifier).state =
                                    null,
                          ),
                          for (final seg in segments)
                            CanvasPillItem(
                              key: ValueKey('seg_$seg'),
                              label: seg.replaceAll('_', ' '),
                              selected: segmentFilter == seg,
                              accentColor: seg == 'at_risk'
                                  ? instrument.moderateEffortColor
                                  : instrument.workingAura,
                              onTap: () =>
                                  ref
                                          .read(segmentFilterProvider.notifier)
                                          .state =
                                      seg,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      CanvasPillStrip(
                        padding: EdgeInsets.symmetric(
                          horizontal: dims.pagePadding,
                        ),
                        items: [
                          CanvasPillItem(
                            key: const ValueKey('sort_recent'),
                            label: 'Recently active',
                            icon: Icons.schedule,
                            selected:
                                sortOption == _CoachAthleteSort.recentlyActive,
                            onTap: () =>
                                ref.read(sortOptionProvider.notifier).state =
                                    _CoachAthleteSort.recentlyActive,
                          ),
                          CanvasPillItem(
                            key: const ValueKey('sort_sess'),
                            label: 'Sessions / wk',
                            icon: Icons.repeat,
                            selected:
                                sortOption == _CoachAthleteSort.sessionsPerWeek,
                            onTap: () =>
                                ref.read(sortOptionProvider.notifier).state =
                                    _CoachAthleteSort.sessionsPerWeek,
                          ),
                          CanvasPillItem(
                            key: const ValueKey('sort_adh'),
                            label: 'Adherence',
                            icon: Icons.check_circle_outline,
                            selected:
                                sortOption == _CoachAthleteSort.planAdherence,
                            onTap: () =>
                                ref.read(sortOptionProvider.notifier).state =
                                    _CoachAthleteSort.planAdherence,
                          ),
                          CanvasPillItem(
                            key: const ValueKey('thresholds'),
                            label: hasThresholds
                                ? 'Min ${minSessions.toStringAsFixed(1)}s · ${(minAdherence * 100).round()}%'
                                : 'Thresholds',
                            icon: Icons.tune,
                            selected: hasThresholds,
                            accentColor: instrument.moderateEffortColor,
                            onTap: () => _openThresholdSheet(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: dims.pagePadding,
                        ),
                        child: Container(
                          decoration: InstrumentTheme.instrumentCardDecoration(
                            context,
                            radius: 20,
                          ),
                          padding: EdgeInsets.all(dims.cardPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ROSTER TELEMETRY',
                                style: InstrumentTheme.microLabel(context),
                              ),
                              const SizedBox(height: 10),
                              InstrumentMetricMatrix(
                                cells: [
                                  InstrumentMetricCellData(
                                    slot: MetricSlot.setsCount,
                                    label: 'VISIBLE',
                                    value:
                                        '${filtered.length}/${analytics.athletes.length}',
                                    valueColor: instrument.workingAura,
                                  ),
                                  InstrumentMetricCellData(
                                    slot: MetricSlot.kpsh,
                                    label: 'LINKS',
                                    value: '${analytics.activeLinks}',
                                  ),
                                  InstrumentMetricCellData(
                                    slot: MetricSlot.frequencyPerWeek,
                                    label: 'AVG S / WK',
                                    value: avgSess.toStringAsFixed(1),
                                  ),
                                  InstrumentMetricCellData(
                                    slot: MetricSlot.density,
                                    label: 'AT RISK',
                                    value: '$atRiskCount',
                                    valueColor: atRiskCount > 0
                                        ? instrument.moderateEffortColor
                                        : instrument.successColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final athlete in filtered) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: dims.pagePadding,
                          ),
                          child: _AthleteCard(
                            athlete: athlete,
                            displayNameAsync: ref.watch(
                              athleteDisplayNameProvider(athlete.athleteId),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _openThresholdSheet(BuildContext context) {
    return showInstrumentBottomSheet<void>(
      context: context,
      eyebrow: 'ROSTER FILTERS',
      title: 'Thresholds & thresholds reset',
      builder: (sheetCtx) {
        return Consumer(
          builder: (context, ref, _) {
            final minSessions = ref.watch(minSessionsPerWeekProvider);
            final minAdherence = ref.watch(minPlanAdherenceProvider);
            final instrument = InstrumentTheme.of(context);
            final theme = Theme.of(context);
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Min sessions / week: ${minSessions.toStringAsFixed(1)}',
                  style: InstrumentTheme.tabular(
                    theme.textTheme.titleSmall ?? const TextStyle(),
                  ),
                ),
                Slider(
                  value: minSessions,
                  min: 0,
                  max: 6,
                  divisions: 12,
                  activeColor: instrument.workingAura,
                  label: minSessions.toStringAsFixed(1),
                  onChanged: (value) =>
                      ref.read(minSessionsPerWeekProvider.notifier).state =
                          value,
                ),
                const SizedBox(height: 8),
                Text(
                  'Min adherence: ${(minAdherence * 100).round()}%',
                  style: InstrumentTheme.tabular(
                    theme.textTheme.titleSmall ?? const TextStyle(),
                  ),
                ),
                Slider(
                  value: minAdherence,
                  min: 0,
                  max: 1,
                  divisions: 10,
                  activeColor: instrument.successColor,
                  label: '${(minAdherence * 100).round()}%',
                  onChanged: (value) =>
                      ref.read(minPlanAdherenceProvider.notifier).state = value,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    InstrumentActionButton(
                      label: 'Reset',
                      variant: InstrumentActionVariant.secondary,
                      onPressed: () {
                        ref.read(minSessionsPerWeekProvider.notifier).state = 0;
                        ref.read(minPlanAdherenceProvider.notifier).state = 0;
                      },
                    ),
                    InstrumentActionButton(
                      label: 'Done',
                      variant: InstrumentActionVariant.primary,
                      onPressed: () => Navigator.of(sheetCtx).pop(),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _AthleteCard extends ConsumerWidget {
  final AthleteTrainingSummaryModel athlete;
  final AsyncValue<String> displayNameAsync;

  const _AthleteCard({required this.athlete, required this.displayNameAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = displayNameAsync.when(
      data: (value) => value,
      loading: () => athlete.athleteId,
      error: (_, __) => athlete.athleteId,
    );
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final dims = UiDimensions.of(context);
    final hairline =
        (theme.brightness == Brightness.dark
                ? instrument.hairlineBorder
                : scheme.outlineVariant)
            .withValues(alpha: 0.65);

    final seg = athlete.segment;
    final segAccent = switch (seg) {
      'at_risk' => instrument.moderateEffortColor,
      'top_performer' => instrument.successColor,
      _ => instrument.workingAura,
    };
    final adherence = athlete.planAdherence?.clamp(0.0, 1.0).toDouble();

    return Container(
      decoration: InstrumentTheme.instrumentCardDecoration(
        context,
        accentColor: seg == 'at_risk' ? instrument.moderateEffortColor : null,
        radius: 22,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CoachAthletePlanScreen(
              athleteId: athlete.athleteId,
              athleteName: title,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                dims.cardPadding,
                dims.cardPadding,
                dims.cardPadding - 8,
                10,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (seg ?? 'ATHLETE')
                              .replaceAll('_', ' ')
                              .toUpperCase(),
                          style: InstrumentTheme.microLabel(
                            context,
                            color: segAccent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.insights_outlined,
                      color: instrument.workingAura,
                    ),
                    tooltip: 'View detailed analytics',
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        RouteNames.coachAthleteDetail,
                        arguments: athlete.athleteId,
                      );
                    },
                  ),
                ],
              ),
            ),
            Container(height: 1, color: hairline),
            Padding(
              padding: EdgeInsets.all(dims.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InstrumentMetricMatrix(
                    cells: [
                      InstrumentMetricCellData(
                        slot: MetricSlot.setsCount,
                        label: 'SESSIONS',
                        value: '${athlete.sessionsCount}',
                      ),
                      InstrumentMetricCellData(
                        slot: MetricSlot.frequencyPerWeek,
                        label: 'S / WK',
                        value: (athlete.sessionsPerWeek ?? 0).toStringAsFixed(
                          1,
                        ),
                      ),
                      InstrumentMetricCellData(
                        slot: MetricSlot.density,
                        label: 'PLAN %',
                        value: adherence != null
                            ? '${(adherence * 100).round()}%'
                            : '—',
                        valueColor: adherence != null && adherence >= 0.8
                            ? instrument.successColor
                            : null,
                      ),
                      InstrumentMetricCellData(
                        slot: MetricSlot.avgRpe,
                        label: 'RPE',
                        value: athlete.avgEffort?.toStringAsFixed(1) ?? '—',
                        subValue: athlete.avgIntensity != null
                            ? 'INT ${athlete.avgIntensity!.toStringAsFixed(1)}'
                            : null,
                        valueColor: instrument.colorForRpe(
                          athlete.avgEffort,
                          scheme,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _PlanAdherenceBar(value: athlete.planAdherence),
                  const SizedBox(height: 12),
                  _RpeMiniChart(distribution: athlete.effortDistribution),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanAdherenceBar extends StatelessWidget {
  final double? value;

  const _PlanAdherenceBar({this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final double? percent = value != null
        ? value!.clamp(0.0, 1.0).toDouble()
        : null;
    final fillColor = (percent ?? 0) >= 0.8
        ? instrument.successColor
        : instrument.workingAura;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'PLAN ADHERENCE',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: InstrumentTheme.microLabel(context),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value != null ? '${((percent ?? 0) * 100).round()}%' : 'N/A',
              style: InstrumentTheme.tabular(
                InstrumentTheme.microLabel(context, color: scheme.onSurface),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 6,
            backgroundColor: scheme.surfaceContainerHighest.withValues(
              alpha: 0.45,
            ),
            valueColor: AlwaysStoppedAnimation<Color>(fillColor),
          ),
        ),
      ],
    );
  }
}

class _RpeMiniChart extends StatelessWidget {
  final Map<String, double>? distribution;

  const _RpeMiniChart({this.distribution});

  @override
  Widget build(BuildContext context) {
    final data = distribution;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    if (data == null || data.isEmpty) {
      return Text(
        'No RPE data',
        style: theme.textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      );
    }

    final entries =
        data.entries
            .map((e) => MapEntry(int.tryParse(e.key) ?? 0, e.value))
            .where((e) => e.key > 0)
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));

    final barGroups = <BarChartGroupData>[];
    for (var i = 0; i < entries.length; i++) {
      final rpe = entries[i].key.toDouble();
      barGroups.add(
        BarChartGroupData(
          x: entries[i].key,
          barRods: [
            BarChartRodData(
              toY: entries[i].value * 100,
              color: instrument.colorForRpe(rpe, scheme),
              width: 6,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(3),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('RPE DISTRIBUTION', style: InstrumentTheme.microLabel(context)),
        const SizedBox(height: 8),
        SizedBox(
          height: 132,
          child: BarChart(
            BarChartData(
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 34,
                    interval: 25,
                    getTitlesWidget: (value, meta) => Text(
                      '${value.toInt()}%',
                      style: InstrumentTheme.tabular(
                        TextStyle(
                          fontSize: 10,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: InstrumentTheme.tabular(
                        TextStyle(
                          fontSize: 10,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: barGroups,
            ),
          ),
        ),
      ],
    );
  }
}

Future<Map<String, dynamic>> _buildCoachAthletesChatContext(
  WidgetRef ref,
) async {
  try {
    final analytics = await ref.read(coachAthletesAnalyticsProvider.future);
    final segmentFilter = ref.read(segmentFilterProvider);
    final minSessions = ref.read(minSessionsPerWeekProvider);
    final minAdherence = ref.read(minPlanAdherenceProvider);
    final sortOption = ref.read(sortOptionProvider);

    final nowIso = DateTime.now().toUtc().toIso8601String();
    final segmentCounts = <String, int>{};
    for (final athlete in analytics.athletes) {
      final key = (athlete.segment ?? 'unknown').toLowerCase();
      segmentCounts[key] = (segmentCounts[key] ?? 0) + 1;
    }

    final List<AthleteTrainingSummaryModel> filtered = analytics.athletes.where((
      a,
    ) {
      final segOk = segmentFilter == null || a.segment == segmentFilter;
      final sessOk = (a.sessionsPerWeek ?? 0) >= minSessions;
      final adhOk = (a.planAdherence ?? 0) >= minAdherence;
      return segOk && sessOk && adhOk;
    }).toList();

    filtered.sort((a, b) {
      switch (sortOption) {
        case _CoachAthleteSort.sessionsPerWeek:
          return (b.sessionsPerWeek ?? -1).compareTo(a.sessionsPerWeek ?? -1);
        case _CoachAthleteSort.planAdherence:
          return (b.planAdherence ?? -1).compareTo(a.planAdherence ?? -1);
        case _CoachAthleteSort.recentlyActive:
          final aDays = a.daysSinceLastWorkout ?? 9999;
          final bDays = b.daysSinceLastWorkout ?? 9999;
          return aDays.compareTo(bDays);
      }
    });

    final topAthletes = filtered.take(3).map((athlete) {
      return {
        'athlete_id': athlete.athleteId,
        'segment': athlete.segment,
        'sessions_per_week': athlete.sessionsPerWeek,
        'plan_adherence': athlete.planAdherence,
        'days_since_last_workout': athlete.daysSinceLastWorkout,
        'active_plan_name': athlete.activePlanName,
      };
    }).toList();

    return {
      'v': 1,
      'app': 'WorkoutApp',
      'screen': 'coach_athletes',
      'role': 'coach',
      'timestamp': nowIso,
      'entities': {
        'summary': {
          'total_athletes': analytics.totalAthletes,
          'active_links': analytics.activeLinks,
          'segment_counts': segmentCounts,
        },
        'top_filtered_athletes': topAthletes,
      },
      'selection': {
        'segment_filter': segmentFilter,
        'min_sessions_per_week': minSessions,
        'min_plan_adherence': minAdherence,
        'sort': sortOption.name,
      },
    };
  } catch (e) {
    return {
      'v': 1,
      'app': 'WorkoutApp',
      'screen': 'coach_athletes',
      'role': 'coach',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'error': e.toString(),
    };
  }
}
