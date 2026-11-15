import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/models/crm_analytics.dart';
import 'package:workout_app/providers/ambient_environment_provider.dart';
import 'package:workout_app/providers/interface_maker_provider.dart';
import 'package:workout_app/services/service_locator.dart' as sl;
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/instrument_metric_matrix.dart';
import 'package:workout_app/widgets/plan_analytics_chart.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';

final athleteDetailedAnalyticsProvider =
    FutureProvider.family<AthleteDetailedAnalyticsModel, String>((
      ref,
      athleteId,
    ) async {
      final svc = ref.watch(sl.crmAnalyticsServiceProvider);
      return svc.getAthleteAnalytics(athleteId: athleteId);
    });

final athleteDetailDisplayNameProvider =
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

class AthleteDetailScreen extends ConsumerWidget {
  final String athleteId;

  const AthleteDetailScreen({super.key, required this.athleteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(athleteDetailedAnalyticsProvider(athleteId));
    final displayNameAsync = ref.watch(
      athleteDetailDisplayNameProvider(athleteId),
    );
    final env = ref.watch(activeTrainingEnvironmentProvider(null));
    final instrument = InstrumentTheme.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dims = UiDimensions.of(context);
    final hairline =
        (theme.brightness == Brightness.dark
                ? instrument.hairlineBorder
                : scheme.outlineVariant)
            .withValues(alpha: 0.65);
    final df = DateFormat('dd.MM.yyyy');

    final headerTitle = displayNameAsync.when(
      data: (name) => name,
      loading: () => 'Athlete',
      error: (_, __) => 'Athlete',
    );

    Future<Map<String, dynamic>> buildChatContext() async {
      final details = asyncData.valueOrNull;
      return <String, dynamic>{
        'v': 1,
        'app': 'WorkoutApp',
        'screen': 'athlete_detail',
        'role': 'coach',
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'selection': <String, dynamic>{
          'athlete_id': athleteId,
          'athlete_name': headerTitle,
        },
        if (details != null)
          'entities': <String, dynamic>{
            'analytics': {
              'sessions_count': details.sessionsCount,
              'total_volume': details.totalVolume,
              'sessions_per_week': details.sessionsPerWeek,
              'plan_adherence': details.planAdherence,
              'avg_intensity': details.avgIntensity,
              'avg_effort': details.avgEffort,
              'active_plan_name': details.activePlanName,
            },
          },
      };
    }

    return AssistantChatHost(
      initialMessage:
          'Открываю ассистента из AthleteDetailScreen. Используй контекст v1 для анализа метрик и тренда атлета.',
      contextBuilder: buildChatContext,
      builder: (context, openChat) {
        return AmbientScaffoldShell(
          environment: env,
          appBar: PrimaryAppBar(
            title: headerTitle,
            showBack: true,
            onTitleTap: openChat,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: () {
                  ref.invalidate(athleteDetailedAnalyticsProvider(athleteId));
                },
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
            data: (details) {
              final cardName = displayNameAsync.when(
                data: (name) => name,
                loading: () => athleteId,
                error: (_, __) => athleteId,
              );
              final adherencePct = details.planAdherence != null
                  ? '${(details.planAdherence! * 100).round()}%'
                  : '—';
              final lastWorkoutText = details.lastWorkoutAt != null
                  ? df.format(details.lastWorkoutAt!.toLocal())
                  : '—';

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(athleteDetailedAnalyticsProvider(athleteId));
                  await ref.read(
                    athleteDetailedAnalyticsProvider(athleteId).future,
                  );
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    dims.pagePadding,
                    AmbientScaffoldShell.topContentInset(context),
                    dims.pagePadding,
                    AmbientScaffoldShell.bottomContentInset(context),
                  ),
                  children: [
                    Container(
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
                                  (details.activePlanName ?? 'ATHLETE TELEMETRY')
                                      .toUpperCase(),
                                  style: InstrumentTheme.microLabel(
                                    context,
                                    color: instrument.workingAura,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  cardName,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (details.daysSinceLastWorkout != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Last workout $lastWorkoutText · ${details.daysSinceLastWorkout}d ago',
                                    style: InstrumentTheme.tabular(
                                      (theme.textTheme.bodySmall ??
                                              const TextStyle())
                                          .copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 210,
                            child: _TrendChart(details: details),
                          ),
                          Container(height: 1, color: hairline),
                          Padding(
                            padding: EdgeInsets.all(dims.cardPadding),
                            child: InstrumentMetricMatrix(
                              cells: [
                                InstrumentMetricCellData(
                                  slot: MetricSlot.setsCount,
                                  label: 'SESSIONS',
                                  value: '${details.sessionsCount}',
                                ),
                                InstrumentMetricCellData(
                                  slot: MetricSlot.tonnage,
                                  label: 'VOLUME',
                                  value:
                                      details.totalVolume?.toStringAsFixed(1) ??
                                      '—',
                                  valueColor: instrument.workingAura,
                                ),
                                InstrumentMetricCellData(
                                  slot: MetricSlot.frequencyPerWeek,
                                  label: 'SESS / WK',
                                  value:
                                      details.sessionsPerWeek?.toStringAsFixed(
                                        1,
                                      ) ??
                                      '—',
                                ),
                                InstrumentMetricCellData(
                                  slot: MetricSlot.density,
                                  label: 'PLAN %',
                                  value: adherencePct,
                                  valueColor: (details.planAdherence ?? 0) >= 0.8
                                      ? instrument.successColor
                                      : null,
                                ),
                              ],
                            ),
                          ),
                          Container(height: 1, color: hairline),
                          Padding(
                            padding: EdgeInsets.all(dims.cardPadding),
                            child: InstrumentMetricMatrix(
                              cells: [
                                InstrumentMetricCellData(
                                  slot: MetricSlot.peakIntensity,
                                  label: 'INTENSITY',
                                  value:
                                      details.avgIntensity?.toStringAsFixed(1) ??
                                      '—',
                                ),
                                InstrumentMetricCellData(
                                  slot: MetricSlot.avgRpe,
                                  label: 'AVG RPE',
                                  value:
                                      details.avgEffort?.toStringAsFixed(1) ??
                                      '—',
                                  valueColor: instrument.colorForRpe(
                                    details.avgEffort,
                                    scheme,
                                  ),
                                ),
                                InstrumentMetricCellData(
                                  slot: MetricSlot.durationWeeks,
                                  label: 'LAST DAY',
                                  value: lastWorkoutText,
                                ),
                                InstrumentMetricCellData(
                                  slot: MetricSlot.kpsh,
                                  label: 'DAYS GAP',
                                  value: details.daysSinceLastWorkout != null
                                      ? '${details.daysSinceLastWorkout}d'
                                      : '—',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (details.effortDistribution != null &&
                        details.effortDistribution!.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Container(
                        decoration: InstrumentTheme.instrumentCardDecoration(
                          context,
                          radius: 22,
                        ),
                        padding: EdgeInsets.all(dims.cardPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EFFORT SPECTRUM · RPE',
                              style: InstrumentTheme.microLabel(context),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 140,
                              child: _RpeMiniChart(
                                distribution: details.effortDistribution,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (details.trend.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Container(
                        decoration: InstrumentTheme.instrumentCardDecoration(
                          context,
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
                                10,
                              ),
                              child: Text(
                                'WEEKLY BREAKDOWN',
                                style: InstrumentTheme.microLabel(context),
                              ),
                            ),
                            for (var i = 0; i < details.trend.length; i++) ...[
                              Container(height: 1, color: hairline),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: dims.cardPadding,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            df.format(
                                              details.trend[i].periodStart,
                                            ),
                                            style: InstrumentTheme.tabular(
                                              (theme.textTheme.titleSmall ??
                                                      const TextStyle())
                                                  .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Sessions: ${details.trend[i].sessionsCount}',
                                            style: InstrumentTheme.tabular(
                                              (theme.textTheme.bodySmall ??
                                                      const TextStyle())
                                                  .copyWith(
                                                    color:
                                                        scheme.onSurfaceVariant,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Vol ${details.trend[i].totalVolume.toStringAsFixed(1)}',
                                      style: InstrumentTheme.tabular(
                                        (theme.textTheme.labelLarge ??
                                                const TextStyle())
                                            .copyWith(
                                              color: instrument.workingAura,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _TrendChart extends StatelessWidget {
  final AthleteDetailedAnalyticsModel details;

  const _TrendChart({required this.details});

  @override
  Widget build(BuildContext context) {
    if (details.trend.isEmpty) {
      return Center(
        child: Text(
          'No trend data',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final df = DateFormat('dd.MM');
    final points = <PlanAnalyticsPoint>[];
    for (var i = 0; i < details.trend.length; i++) {
      final t = details.trend[i];
      points.add(
        PlanAnalyticsPoint(
          order: i,
          label: df.format(t.periodStart),
          values: {
            'total_volume': t.totalVolume,
            'sessions_count': t.sessionsCount.toDouble(),
          },
        ),
      );
    }

    return PlanAnalyticsChart(
      points: points,
      metricX: 'total_volume',
      metricY: 'total_volume',
      bottomLabelModulo: 2,
      emptyText: 'No trend data',
    );
  }
}

class _RpeMiniChart extends StatelessWidget {
  final Map<String, double>? distribution;

  const _RpeMiniChart({required this.distribution});

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
              width: 8,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: 25,
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}%',
                style: InstrumentTheme.tabular(
                  TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
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
                  TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
                ),
              ),
            ),
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }
}
