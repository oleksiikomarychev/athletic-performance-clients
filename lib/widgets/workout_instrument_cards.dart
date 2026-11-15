import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workout_app/config/rpe_table.dart' as rpe_table;
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/models/exercise_instance.dart';
import 'package:workout_app/models/exercise_set_dto.dart';
import 'package:workout_app/models/workout.dart';
import 'package:workout_app/providers/ambient_environment_provider.dart';
import 'package:workout_app/providers/interface_maker_provider.dart';
import 'package:workout_app/widgets/instrument_metric_matrix.dart';

/// Self-contained Blueprint A hero telemetry card for the active plan's next workout.
///
/// Enforces `Max Border Depth = 1`: only the outer card container carries a `1px`
/// border. Contains an internal eyebrow + ambient status dot/badge, bold title
/// + CTA, optional reactive CARROT briefing, bleed-to-edge session spark-wave,
/// hairline divider, and bare 4-column [InstrumentMetricMatrix].
class WorkoutHeroInstrumentCard extends StatefulWidget {
  final Workout? workout;
  final VoidCallback? onOpenWorkout;
  final VoidCallback onOpenPlan;
  final TrainingEnvironmentData? environment;
  final List<MetricSlot> slots;
  final MetricSlot? selectedSlot;
  final ValueChanged<MetricSlot>? onSelectSlot;
  final bool showChart;
  final bool showBriefing;
  final bool snarkyVoice;

  const WorkoutHeroInstrumentCard({
    super.key,
    required this.workout,
    required this.onOpenWorkout,
    required this.onOpenPlan,
    this.environment,
    this.slots = const [
      MetricSlot.peakIntensity,
      MetricSlot.e1rm,
      MetricSlot.peakRpe,
      MetricSlot.kpsh,
    ],
    this.selectedSlot,
    this.onSelectSlot,
    this.showChart = true,
    this.showBriefing = true,
    this.snarkyVoice = false,
  });

  @override
  State<WorkoutHeroInstrumentCard> createState() =>
      _WorkoutHeroInstrumentCardState();
}

class _WorkoutHeroInstrumentCardState extends State<WorkoutHeroInstrumentCard> {
  MetricSlot? _internalSlot;

  MetricSlot get _activeSlot {
    if (widget.selectedSlot != null &&
        widget.slots.contains(widget.selectedSlot)) {
      return widget.selectedSlot!;
    }
    if (_internalSlot != null && widget.slots.contains(_internalSlot)) {
      return _internalSlot!;
    }
    return widget.slots.isNotEmpty
        ? widget.slots.first
        : MetricSlot.peakIntensity;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dimensions = UiDimensions.of(context);
    final instrument = InstrumentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hairline = (isDark ? instrument.hairlineBorder : scheme.outlineVariant)
        .withValues(alpha: isDark ? 0.85 : 0.55);

    final w = widget.workout;
    final env = widget.environment ??
        (w != null
            ? TrainingEnvironmentData.fromWorkout(w)
            : const TrainingEnvironmentData.idle());
    final accent = env.accentColor(instrument);

    if (w == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: InstrumentTheme.instrumentCardDecoration(
            context,
            accentColor: instrument.successColor,
            radius: 22,
          ),
          padding: EdgeInsets.all(dimensions.cardPadding + 2),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: instrument.successColor.withValues(alpha: 0.14),
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  color: instrument.successColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'NO UPCOMING WORKOUTS',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: InstrumentTheme.microLabel(
                        context,
                        color: instrument.successColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Все запланированные сессии выполнены или план не выбран',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  tooltip: 'Открыть активный план',
                  style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    tapTargetSize: MaterialTapTargetSize.padded,
                  ),
                  onPressed: widget.onOpenPlan,
                  icon: Icon(
                    Icons.calendar_today_outlined,
                    color: scheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final status = (w.status ?? '').toLowerCase();
    final isCancelled =
        status == 'cancelled' || status == 'canceled' || status == 'dropped';
    final statusLabel = isCancelled ? 'CANCELLED' : 'NEXT IN PLAN';
    final statusColor = isCancelled ? scheme.error : accent;

    final scheduled = w.scheduledFor?.toLocal();
    final now = DateTime.now();
    final isToday = scheduled != null &&
        scheduled.year == now.year &&
        scheduled.month == now.month &&
        scheduled.day == now.day;
    final dateLabel = scheduled == null
        ? 'READY'
        : (isToday
            ? 'TODAY'
            : DateFormat('MMM d').format(scheduled).toUpperCase());

    final stats = _computeStats(w);
    final activeSlot = _activeSlot;
    final matrixCells = _buildMatrixCells(
      context: context,
      workout: w,
      stats: stats,
      slots: widget.slots,
      accent: accent,
      instrument: instrument,
      scheme: scheme,
    );
    final sparkSeries = widget.showChart
        ? _buildSparkSeries(w, activeSlot)
        : const <_SparkPoint>[];

    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onOpenWorkout,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: double.infinity,
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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '$statusLabel · $dateLabel',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: InstrumentTheme.tabular(
                                InstrumentTheme.microLabel(
                                  context,
                                  color: statusColor,
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
                          Flexible(
                            child: Text(
                              env.badgeLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: InstrumentTheme.microLabel(
                                context,
                                color: accent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: IconButton(
                              tooltip: 'Открыть календарный план',
                              style: IconButton.styleFrom(
                                minimumSize: const Size(48, 48),
                                tapTargetSize: MaterialTapTargetSize.padded,
                              ),
                              onPressed: widget.onOpenPlan,
                              icon: Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final narrowOrScaled =
                              constraints.maxWidth < 300 || textScale > 1.35;
                          final titleBlock = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                w.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${w.exerciseInstances.length} упр.'
                                '${w.notes?.trim().isNotEmpty == true ? ' · ${w.notes!.trim()}' : ''}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: InstrumentTheme.tabular(
                                  theme.textTheme.bodySmall?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ) ??
                                      const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          );
                          final ctaButton = FilledButton.icon(
                            onPressed: widget.onOpenWorkout,
                            style: FilledButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: _foregroundForAccent(accent),
                              minimumSize: const Size(48, 48),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            icon: const Icon(Icons.play_arrow_rounded, size: 18),
                            label: const Text('Начать'),
                          );

                          if (narrowOrScaled) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                titleBlock,
                                const SizedBox(height: 10),
                                ctaButton,
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(child: titleBlock),
                              const SizedBox(width: 10),
                              ctaButton,
                            ],
                          );
                        },
                      ),
                      if (widget.showBriefing) ...[
                        const SizedBox(height: 8),
                        Text(
                          env.briefing(snarky: widget.snarkyVoice),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (sparkSeries.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.zero,
                    child: _WorkoutSparkWave(
                      points: sparkSeries,
                      slot: activeSlot,
                      accentColor: accent,
                    ),
                  ),
                ],
                Container(height: 1, color: hairline),
                InstrumentMetricMatrix(
                  cells: matrixCells,
                  selectedSlot: activeSlot,
                  accentColor: accent,
                  onSelectSlot: (slot) {
                    setState(() => _internalSlot = slot);
                    widget.onSelectSlot?.call(slot);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Color _foregroundForAccent(Color accent) {
    return accent.computeLuminance() > 0.45 ? const Color(0xFF0A0E14) : Colors.white;
  }

  static List<InstrumentMetricCellData> _buildMatrixCells({
    required BuildContext context,
    required Workout workout,
    required _WorkoutStats stats,
    required List<MetricSlot> slots,
    required Color accent,
    required InstrumentTheme instrument,
    required ColorScheme scheme,
  }) {
    final effectiveSlots = slots.isNotEmpty
        ? slots
        : const [
            MetricSlot.peakIntensity,
            MetricSlot.e1rm,
            MetricSlot.peakRpe,
            MetricSlot.kpsh,
          ];
    final rpeColor = instrument.colorForRpe(stats.avgRpe, scheme);
    return effectiveSlots.map((slot) {
      switch (slot) {
        case MetricSlot.peakIntensity:
          return InstrumentMetricCellData(
            slot: slot,
            value: stats.peakIntensity != null
                ? '${stats.peakIntensity!.round()}%'
                : '—',
            valueColor: stats.peakIntensity != null ? accent : null,
          );
        case MetricSlot.e1rm:
          return InstrumentMetricCellData(
            slot: slot,
            value: stats.peakE1rm != null
                ? '${stats.peakE1rm!.round()} kg'
                : '—',
          );
        case MetricSlot.peakRpe:
          return InstrumentMetricCellData(
            slot: slot,
            value: stats.peakRpe != null
                ? 'RPE ${stats.peakRpe!.toStringAsFixed(1)}'
                : '—',
            valueColor: stats.peakRpe != null ? rpeColor : null,
          );
        case MetricSlot.avgRpe:
          return InstrumentMetricCellData(
            slot: slot,
            value: stats.avgRpe != null
                ? 'RPE ${stats.avgRpe!.toStringAsFixed(1)}'
                : '—',
            valueColor: stats.avgRpe != null ? rpeColor : null,
          );
        case MetricSlot.tonnage:
          return InstrumentMetricCellData(
            slot: slot,
            value: stats.totalVolume > 0
                ? '${_formatNumber(stats.totalVolume)} kg'
                : '—',
          );
        case MetricSlot.kpsh:
          return InstrumentMetricCellData(
            slot: slot,
            value: stats.totalReps > 0 ? '${stats.totalReps}' : '—',
          );
        case MetricSlot.setsCount:
          return InstrumentMetricCellData(
            slot: slot,
            value: stats.totalSets > 0 ? '${stats.totalSets}' : '—',
          );
        case MetricSlot.density:
          final exCount = workout.exerciseInstances.length;
          return InstrumentMetricCellData(
            slot: slot,
            value: exCount > 0 ? '$exCount ex' : '—',
          );
        case MetricSlot.durationWeeks:
          final minutes = workout.durationSeconds != null
              ? (workout.durationSeconds! / 60).round()
              : null;
          return InstrumentMetricCellData(
            slot: slot,
            label: 'ВРЕМЯ',
            value: minutes != null ? '${minutes}m' : '—',
          );
        case MetricSlot.frequencyPerWeek:
          return InstrumentMetricCellData(
            slot: slot,
            label: 'УПР.',
            value: '${workout.exerciseInstances.length}',
          );
      }
    }).toList(growable: false);
  }

  static List<_SparkPoint> _buildSparkSeries(Workout w, MetricSlot slot) {
    final points = <_SparkPoint>[];
    for (int i = 0; i < w.exerciseInstances.length; i++) {
      final ex = w.exerciseInstances[i];
      final rawName = ex.exerciseDefinition?.name.trim();
      final label = (rawName != null && rawName.isNotEmpty)
          ? rawName
          : 'Ex ${i + 1}';
      final val = _exerciseMetricValue(ex, slot);
      if (val != null && val.isFinite) {
        points.add(_SparkPoint(index: i.toDouble(), label: label, value: val));
      }
    }
    return points;
  }

  static double? _exerciseMetricValue(ExerciseInstance ex, MetricSlot slot) {
    if (ex.sets.isEmpty) {
      return slot == MetricSlot.setsCount || slot == MetricSlot.kpsh ? 0.0 : null;
    }
    switch (slot) {
      case MetricSlot.peakIntensity:
        double? peak;
        for (final s in _flattenSets(ex.sets)) {
          if (s.intensity > 0) {
            final v = s.intensity.toDouble();
            peak = peak == null ? v : math.max(peak, v);
          }
        }
        return peak;
      case MetricSlot.e1rm:
        double? best;
        for (final s in _flattenSets(ex.sets)) {
          final e1rm = _estimateSetE1rm(s);
          if (e1rm != null) {
            best = best == null ? e1rm : math.max(best, e1rm);
          }
        }
        return best;
      case MetricSlot.peakRpe:
        double? peak;
        for (final s in _flattenSets(ex.sets)) {
          final r = s.rpeValue;
          if (r != null && r > 0) {
            peak = peak == null ? r : math.max(peak, r);
          }
        }
        return peak;
      case MetricSlot.avgRpe:
        double sum = 0;
        int count = 0;
        for (final s in _flattenSets(ex.sets)) {
          final r = s.rpeValue;
          if (r != null && r > 0) {
            sum += r;
            count++;
          }
        }
        return count > 0 ? sum / count : null;
      case MetricSlot.tonnage:
        double vol = 0;
        for (final s in _flattenSets(ex.sets)) {
          vol += s.weight * s.reps;
        }
        return vol;
      case MetricSlot.kpsh:
        double reps = 0;
        for (final s in _flattenSets(ex.sets)) {
          reps += s.reps;
        }
        return reps;
      case MetricSlot.setsCount:
      case MetricSlot.density:
      case MetricSlot.durationWeeks:
      case MetricSlot.frequencyPerWeek:
        return ex.sets.length.toDouble();
    }
  }

  static Iterable<ExerciseSetDto> _flattenSets(List<ExerciseSetDto> sets) sync* {
    for (final s in sets) {
      if (s.subsets.isNotEmpty) {
        yield* _flattenSets(s.subsets);
      } else {
        yield s;
      }
    }
  }

  static double? _estimateSetE1rm(ExerciseSetDto s) {
    if (s.weight <= 0 || s.reps <= 0) return null;
    final rpe = s.rpeValue;
    if (rpe != null && rpe >= 6.0 && rpe <= 10.0) {
      final pct = rpe_table.RpeTable.getIntensity(s.reps, rpe.round());
      if (pct != null && pct > 0) {
        return s.weight / (pct / 100.0);
      }
    }
    if (s.intensity > 0) {
      return s.weight / (s.intensity / 100.0);
    }
    if (s.reps == 1) return s.weight;
    return s.weight * (1.0 + s.reps / 30.0);
  }

  static _WorkoutStats _computeStats(Workout w) {
    double vol = 0;
    int reps = 0;
    int sets = 0;
    double rpeSum = 0;
    int rpeCount = 0;
    double? peakRpe;
    double? peakIntensity;
    double? peakE1rm;

    for (final inst in w.exerciseInstances) {
      for (final s in _flattenSets(inst.sets)) {
        sets++;
        reps += s.reps;
        vol += s.weight * s.reps;
        final rv = s.rpeValue;
        if (rv != null && rv > 0) {
          rpeSum += rv;
          rpeCount++;
          peakRpe = peakRpe == null ? rv : math.max(peakRpe, rv);
        }
        if (s.intensity > 0) {
          final iv = s.intensity.toDouble();
          peakIntensity = peakIntensity == null ? iv : math.max(peakIntensity, iv);
        }
        final e1rm = _estimateSetE1rm(s);
        if (e1rm != null) {
          peakE1rm = peakE1rm == null ? e1rm : math.max(peakE1rm, e1rm);
        }
      }
    }

    return _WorkoutStats(
      totalVolume: vol,
      totalReps: reps,
      totalSets: sets,
      avgRpe: rpeCount > 0 ? rpeSum / rpeCount : null,
      peakRpe: peakRpe,
      peakIntensity: peakIntensity,
      peakE1rm: peakE1rm,
    );
  }

  static String _formatNumber(double val) {
    final rounded = val.round();
    final str = rounded.toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final revIdx = str.length - i;
      buf.write(str[i]);
      if (revIdx > 1 && revIdx % 3 == 1) {
        buf.write(' ');
      }
    }
    return buf.toString();
  }
}

/// Backwards-compatible alias forwarding into [WorkoutHeroInstrumentCard].
class NextWorkoutInstrumentCard extends StatelessWidget {
  final Workout? workout;
  final VoidCallback? onOpenWorkout;
  final VoidCallback onOpenPlan;
  final TrainingEnvironmentData? environment;
  final List<MetricSlot> slots;
  final bool showChart;
  final bool showBriefing;
  final bool snarkyVoice;

  const NextWorkoutInstrumentCard({
    super.key,
    required this.workout,
    required this.onOpenWorkout,
    required this.onOpenPlan,
    this.environment,
    this.slots = const [
      MetricSlot.peakIntensity,
      MetricSlot.e1rm,
      MetricSlot.peakRpe,
      MetricSlot.kpsh,
    ],
    this.showChart = true,
    this.showBriefing = true,
    this.snarkyVoice = false,
  });

  @override
  Widget build(BuildContext context) {
    return WorkoutHeroInstrumentCard(
      workout: workout,
      onOpenWorkout: onOpenWorkout,
      onOpenPlan: onOpenPlan,
      environment: environment,
      slots: slots,
      showChart: showChart,
      showBriefing: showBriefing,
      snarkyVoice: snarkyVoice,
    );
  }
}

class _SparkPoint {
  final double index;
  final String label;
  final double value;

  const _SparkPoint({
    required this.index,
    required this.label,
    required this.value,
  });
}

class _WorkoutSparkWave extends StatelessWidget {
  final List<_SparkPoint> points;
  final MetricSlot slot;
  final Color accentColor;

  const _WorkoutSparkWave({
    required this.points,
    required this.slot,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final values = points.map((p) => p.value).toList();
    final minVal = values.reduce(math.min);
    final maxVal = values.reduce(math.max);
    final span = maxVal - minVal;
    final pad = span > 0 ? span * 0.18 : (maxVal.abs() * 0.25 + 1.0);
    final adjustedMin = math.max(0.0, minVal - pad);
    final adjustedMax = maxVal + pad;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'SESSION WAVE · ${slot.shortLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: InstrumentTheme.microLabel(
                    context,
                    color: accentColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '${_compactNum(minVal)} – ${_compactNum(maxVal)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: InstrumentTheme.tabular(
                    InstrumentTheme.microLabel(
                      context,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 104,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: points.length == 1 ? 1 : (points.length - 1).toDouble(),
              minY: adjustedMin,
              maxY: adjustedMax,
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: scheme.outlineVariant.withValues(alpha: 0.20),
                  strokeWidth: 1,
                ),
              ),
              titlesData: const FlTitlesData(
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false, reservedSize: 0),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false, reservedSize: 0),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    for (final p in points) FlSpot(p.index, p.value),
                  ],
                  isCurved: false,
                  barWidth: 2.2,
                  color: accentColor,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                      radius: 3.6,
                      color: accentColor,
                      strokeWidth: 1.5,
                      strokeColor: scheme.surfaceContainerLow,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        accentColor.withValues(alpha: 0.20),
                        accentColor.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _compactNum(double v) {
    if (v == v.roundToDouble()) return v.round().toString();
    return v.toStringAsFixed(1);
  }
}

class _WorkoutStats {
  final double totalVolume;
  final int totalReps;
  final int totalSets;
  final double? avgRpe;
  final double? peakRpe;
  final double? peakIntensity;
  final double? peakE1rm;

  const _WorkoutStats({
    required this.totalVolume,
    required this.totalReps,
    required this.totalSets,
    required this.avgRpe,
    required this.peakRpe,
    required this.peakIntensity,
    required this.peakE1rm,
  });
}

/// Self-contained Blueprint A manual workout library module inside a single
/// `1px` outer contour (`Max Border Depth = 1`), with hairline-separated rows
/// and zero external `[Boxed Icon] Section Header`.
class WorkoutLibraryInstrumentModule extends StatelessWidget {
  final List<Workout> workouts;
  final bool isLoading;
  final Object? error;
  final bool isLoadingMore;
  final bool hasMore;
  final VoidCallback onRetry;
  final VoidCallback onCreateWorkout;
  final ValueChanged<Workout> onOpenWorkout;
  final Future<void> Function(Workout workout) onDeleteWorkout;

  const WorkoutLibraryInstrumentModule({
    super.key,
    required this.workouts,
    this.isLoading = false,
    this.error,
    this.isLoadingMore = false,
    this.hasMore = false,
    required this.onRetry,
    required this.onCreateWorkout,
    required this.onOpenWorkout,
    required this.onDeleteWorkout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hairline = (isDark ? instrument.hairlineBorder : scheme.outlineVariant)
        .withValues(alpha: isDark ? 0.85 : 0.55);

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        decoration: InstrumentTheme.instrumentCardDecoration(context, radius: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ЖУРНАЛ СЕССИЙ',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: InstrumentTheme.microLabel(
                            context,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Библиотека',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    onPressed: onCreateWorkout,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Новая'),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: hairline),
            if (isLoading && workouts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (error != null && workouts.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Не удалось загрузить тренировки',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: scheme.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      error.toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: onRetry,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(48, 48),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Повторить'),
                    ),
                  ],
                ),
              )
            else if (workouts.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scheme.surfaceContainerHigh,
                      ),
                      child: Icon(
                        Icons.fitness_center_outlined,
                        size: 18,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Нет ручных сессий',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Нажмите «Новая», чтобы записать свободную тренировку',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              for (int i = 0; i < workouts.length; i++) ...[
                _SessionInstrumentRow(
                  workout: workouts[i],
                  onTap: () => onOpenWorkout(workouts[i]),
                  onDelete: () => onDeleteWorkout(workouts[i]),
                ),
                if (i < workouts.length - 1)
                  Container(height: 1, color: hairline),
              ],
              if (isLoadingMore)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (!hasMore && workouts.isNotEmpty) ...[
                Container(height: 1, color: hairline),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      'ВСЕ СЕССИИ ПОКАЗАНЫ',
                      style: InstrumentTheme.microLabel(
                        context,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _SessionInstrumentRow extends StatelessWidget {
  final Workout workout;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SessionInstrumentRow({
    required this.workout,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);

    final status = (workout.status ?? '').toLowerCase();
    final isDone = status == 'completed' || workout.completedAt != null;
    final accent = isDone ? instrument.successColor : scheme.primary;
    final subtitle = _buildWorkoutSubtitle(workout);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: 0.14),
              ),
              child: Icon(
                isDone ? Icons.check_rounded : Icons.fitness_center_rounded,
                color: accent,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    workout.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: InstrumentTheme.tabular(
                      theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ) ??
                          const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 48,
              height: 48,
              child: IconButton(
                tooltip: 'Удалить тренировку',
                style: IconButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  tapTargetSize: MaterialTapTargetSize.padded,
                ),
                icon: Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: scheme.error,
                ),
                onPressed: onDelete,
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: scheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

String _buildWorkoutSubtitle(Workout workout) {
  final int exerciseCount = workout.exerciseInstances.length;
  final int setCount = workout.exerciseInstances.fold<int>(
    0,
    (sum, ei) => sum + ei.sets.length,
  );
  final double vol = workout.totalVolume;

  final metaParts = <String>[
    if (exerciseCount > 0) '$exerciseCount упр.',
    if (setCount > 0) '$setCount подх.',
    if (vol > 0) '${vol.round()} кг',
    if (exerciseCount == 0 && workout.durationSeconds != null)
      '${(workout.durationSeconds! / 60).round()} мин',
    if (workout.scheduledFor != null)
      DateFormat('MMM d').format(workout.scheduledFor!.toLocal()),
  ];
  return metaParts.isNotEmpty ? metaParts.join(' · ') : 'Ручная сессия';
}

/// Standalone single-contour workout library card kept for component reuse and
/// unit test compatibility (`Max Border Depth = 1`).
class WorkoutLibraryCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const WorkoutLibraryCard({
    super.key,
    required this.workout,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dimensions = UiDimensions.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: math.max(0, dimensions.rowGap - 6)),
          decoration: InstrumentTheme.instrumentCardDecoration(context, radius: 18),
          child: _SessionInstrumentRow(
            workout: workout,
            onTap: onTap,
            onDelete: onDelete,
          ),
        ),
      ),
    );
  }
}
