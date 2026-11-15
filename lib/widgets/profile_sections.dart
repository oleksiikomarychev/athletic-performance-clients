import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/models/user_stats.dart';
import 'package:workout_app/models/workout_session.dart';
import 'package:workout_app/providers/interface_maker_provider.dart';
import 'package:workout_app/widgets/activity_heatmap_colors.dart';
import 'package:workout_app/widgets/instrument_metric_matrix.dart';

class ProfileStatsRow extends StatelessWidget {
  final UserStats stats;
  final EdgeInsetsGeometry? padding;

  const ProfileStatsRow({
    super.key,
    required this.stats,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final instrument = InstrumentTheme.of(context);
    final dims = UiDimensions.of(context);

    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: dims.pagePadding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
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
                  'PROFILE TELEMETRY',
                  style: InstrumentTheme.microLabel(context),
                ),
                const SizedBox(height: 10),
                InstrumentMetricMatrix(
                  cells: [
                    InstrumentMetricCellData(
                      slot: MetricSlot.setsCount,
                      label: l10n.statsTotalWorkouts.toUpperCase(),
                      value: '${stats.totalWorkouts}',
                      valueColor: instrument.workingAura,
                    ),
                    InstrumentMetricCellData(
                      slot: MetricSlot.tonnage,
                      label: l10n.statsVolumeKg.toUpperCase(),
                      value: stats.totalVolume.toStringAsFixed(0),
                    ),
                    InstrumentMetricCellData(
                      slot: MetricSlot.frequencyPerWeek,
                      label: l10n.statsActiveDays.toUpperCase(),
                      value: '${stats.activeDays}',
                      valueColor: instrument.successColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileActivitySection extends StatelessWidget {
  final UserStats stats;
  final EdgeInsetsGeometry? padding;

  const ProfileActivitySection({
    super.key,
    required this.stats,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dims = UiDimensions.of(context);

    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: dims.pagePadding),
      child: Container(
        decoration: InstrumentTheme.instrumentCardDecoration(
          context,
          radius: 22,
        ),
        padding: EdgeInsets.all(dims.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.activityTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Text(
                  l10n.lastWeeks(stats.weeks),
                  style: InstrumentTheme.tabular(
                    (theme.textTheme.bodySmall ?? const TextStyle()).copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  l10n.maxKgPerDay(stats.maxDayVolume.toStringAsFixed(0)),
                  style: InstrumentTheme.tabular(
                    (theme.textTheme.bodySmall ?? const TextStyle()).copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _ActivityGrid(
              activityMap: stats.activityMap,
              maxVolume: stats.maxDayVolume,
              weeks: stats.weeks,
            ),
            const SizedBox(height: 10),
            _ActivityLegend(),
          ],
        ),
      ),
    );
  }
}

class _ActivityGrid extends StatelessWidget {
  final Map<DateTime, DayActivity> activityMap;
  final double maxVolume;
  final int weeks;

  const _ActivityGrid({
    required this.activityMap,
    required this.maxVolume,
    required this.weeks,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final scheme = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final endDate = DateTime(today.year, today.month, today.day);
    final endWeekStart = endDate.subtract(Duration(days: endDate.weekday - 1));
    final startWeekStart = endWeekStart.subtract(
      Duration(days: (weeks - 1) * 7),
    );

    final columns = <List<DateTime>>[];
    for (int w = 0; w < weeks; w++) {
      final weekStart = startWeekStart.add(Duration(days: w * 7));
      columns.add(List.generate(7, (d) => weekStart.add(Duration(days: d))));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columns.map((weekDays) {
          String label = '';
          for (final d in weekDays) {
            if (d.day == 1) {
              label = DateFormat('MMM').format(d);
              break;
            }
          }
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 12,
                  child: Text(
                    label,
                    style: InstrumentTheme.tabular(
                      TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    textAlign: TextAlign.center,
                    softWrap: false,
                  ),
                ),
                const SizedBox(height: 6),
                for (final date in weekDays)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Builder(
                      builder: (_) {
                        final day = DateTime(date.year, date.month, date.day);
                        final dayActivity = _getActivityForDate(
                          activityMap,
                          day,
                        );
                        final volume = dayActivity?.volume ?? 0;
                        final color = ActivityHeatmapColors.forVolume(
                          context,
                          volume,
                          maxVolume,
                        );
                        return Tooltip(
                          message: dayActivity != null
                              ? '${DateFormat('MMM d', locale).format(date)}\n${l10n.sessionsCount(dayActivity.sessionCount)}\n${volume.toStringAsFixed(0)} kg'
                              : '${DateFormat('MMM d', locale).format(date)}\n${l10n.noActivity}',
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  DayActivity? _getActivityForDate(
    Map<DateTime, DayActivity> map,
    DateTime date,
  ) {
    for (final entry in map.entries) {
      final d = entry.key;
      if (d.year == date.year && d.month == date.month && d.day == date.day) {
        return entry.value;
      }
    }
    return null;
  }
}

class _ActivityLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = ActivityHeatmapColors.palette(context);
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.less,
          style: TextStyle(fontSize: 10, color: onSurfaceVariant),
        ),
        const SizedBox(width: 4),
        for (var i = 0; i < colors.length; i++) ...[
          if (i > 0) const SizedBox(width: 2),
          _LegendBox(colors[i]),
        ],
        const SizedBox(width: 4),
        Text(
          l10n.more,
          style: TextStyle(fontSize: 10, color: onSurfaceVariant),
        ),
      ],
    );
  }
}

class _LegendBox extends StatelessWidget {
  final Color color;
  const _LegendBox(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class ProfileCompletedWorkoutsSection extends StatelessWidget {
  final List<WorkoutSession> sessions;
  final EdgeInsetsGeometry? padding;
  final void Function(WorkoutSession session)? onSessionTap;

  const ProfileCompletedWorkoutsSection({
    super.key,
    required this.sessions,
    this.padding,
    this.onSessionTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final dims = UiDimensions.of(context);

    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: dims.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: instrument.workingAura,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.completedWorkoutsTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (sessions.isEmpty)
            Container(
              decoration: InstrumentTheme.instrumentCardDecoration(
                context,
                radius: 18,
              ),
              padding: EdgeInsets.all(dims.cardPadding),
              child: Text(
                l10n.noCompletedWorkoutsYet,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            )
          else
            Column(
              children: sessions
                  .map((s) => _WorkoutCard(session: s, onTap: onSessionTap))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final WorkoutSession session;
  final void Function(WorkoutSession session)? onTap;

  const _WorkoutCard({required this.session, this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd');
    final workoutCode = 'WO${session.workoutId}';
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: InstrumentTheme.instrumentCardDecoration(
        context,
        radius: 18,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap != null ? () => onTap!(session) : null,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Text(
                  workoutCode,
                  style: InstrumentTheme.tabular(
                    InstrumentTheme.microLabel(
                      context,
                      color: instrument.workingAura,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    dateFormat.format(session.startedAt),
                    style: InstrumentTheme.tabular(
                      (theme.textTheme.bodyMedium ?? const TextStyle())
                          .copyWith(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
                Icon(
                  Icons.check_circle,
                  color: instrument.successColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
