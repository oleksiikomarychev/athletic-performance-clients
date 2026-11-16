import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/l10n/app_localizations.dart';

class PlanAnalyticsPoint {
  final int order;
  final String label;
  final Map<String, double> values;
  final Map<String, double>? actualValues;

  const PlanAnalyticsPoint({
    required this.order,
    required this.label,
    required this.values,
    this.actualValues,
  });
}

class PlanAnalyticsLineSeries {
  final String metric;
  final String? name;
  final Color color;
  final bool useActual;

  const PlanAnalyticsLineSeries({
    required this.metric,
    this.name,
    required this.color,
    this.useActual = false,
  });
}

class PlanAnalyticsScatterSeries {
  final String metricX;
  final String metricY;
  final String? name;
  final Color color;
  final bool useActual;

  const PlanAnalyticsScatterSeries({
    required this.metricX,
    required this.metricY,
    this.name,
    required this.color,
    this.useActual = false,
  });
}

/// Honest discrete analytical chart for workout plan & execution series.
/// Preserves zero values (0 != null), renders straight segments with explicit
/// session markers, and visually distinguishes Planned vs Actual series.
class PlanAnalyticsChart extends StatelessWidget {
  final List<PlanAnalyticsPoint> points;
  final String metricX;
  final String metricY;
  final List<PlanAnalyticsLineSeries>? lineSeries;
  final List<PlanAnalyticsScatterSeries>? scatterSeries;
  final int? bottomLabelModulo;
  final bool showScatterAxisTitles;
  final String emptyText;
  final bool bleedMode;
  final Color? accentColor;

  const PlanAnalyticsChart({
    super.key,
    required this.points,
    required this.metricX,
    required this.metricY,
    this.lineSeries,
    this.scatterSeries,
    this.bottomLabelModulo,
    this.showScatterAxisTitles = true,
    this.emptyText = 'No data for plan',
    this.bleedMode = false,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return Center(child: Text(emptyText));
    }

    final multi = lineSeries != null && lineSeries!.isNotEmpty;
    if (multi) {
      return _buildMultiLineChart(context);
    }

    final multiScatter = scatterSeries != null && scatterSeries!.isNotEmpty;
    if (multiScatter) {
      return _buildMultiScatterChart(context);
    }

    if (metricX == metricY) {
      return _buildLineChart(context);
    }
    return _buildScatterChart(context);
  }

  FlGridData _buildGrid(ColorScheme scheme) {
    final line = FlLine(
      color: scheme.outlineVariant.withValues(alpha: bleedMode ? 0.20 : 0.3),
      strokeWidth: 1,
    );
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      getDrawingHorizontalLine: (_) => line,
    );
  }

  Widget _buildMultiLineChart(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final series = lineSeries ?? const <PlanAnalyticsLineSeries>[];
    final labels = <String>[
      for (var i = 0; i < points.length; i++) points[i].label,
    ];

    final bars = <LineChartBarData>[];
    final barLabels = <String>[];
    final allY = <double>[];

    for (final s in series) {
      final spots = <FlSpot>[];
      for (var i = 0; i < points.length; i++) {
        final p = points[i];
        final source = s.useActual ? (p.actualValues ?? const {}) : p.values;
        final v = source[s.metric];
        if (v != null && v.isFinite) {
          spots.add(FlSpot(i.toDouble(), v));
          allY.add(v);
        }
      }
      if (spots.isEmpty) continue;
      barLabels.add(s.name ?? s.metric);
      bars.add(
        LineChartBarData(
          spots: spots,
          isCurved: false,
          barWidth: s.useActual ? 2.5 : 2.0,
          dashArray: s.useActual ? null : const [5, 4],
          color: s.color,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
              radius: s.useActual ? 4.0 : 3.2,
              color: s.useActual ? s.color : scheme.surfaceContainerLowest,
              strokeWidth: s.useActual ? 1.5 : 2.0,
              strokeColor: s.useActual ? scheme.surfaceContainerLowest : s.color,
            ),
          ),
          belowBarData: BarAreaData(show: false),
        ),
      );
    }

    if (bars.isEmpty) {
      return Center(child: Text(emptyText));
    }

    final (adjustedMin, adjustedMax, yInterval) = _computeBounds(allY);
    final effectiveModulo = math.max(
      1,
      bottomLabelModulo ?? (labels.length / 6).ceil(),
    );

    final axisStyle = InstrumentTheme.tabular(
      theme.textTheme.labelSmall?.copyWith(
            fontSize: 10,
            color: scheme.onSurfaceVariant,
          ) ??
          TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
    );

    return LineChart(
      LineChartData(
        minY: adjustedMin,
        maxY: adjustedMax,
        gridData: _buildGrid(scheme),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= labels.length) {
                  return const SizedBox.shrink();
                }
                if (idx % effectiveModulo != 0) {
                  return const SizedBox.shrink();
                }
                final previousLabelIndex = idx - effectiveModulo;
                if (previousLabelIndex >= 0 &&
                    labels[idx] == labels[previousLabelIndex]) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(labels[idx], style: axisStyle),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: !bleedMode,
              interval: yInterval,
              reservedSize: bleedMode ? 0 : 44,
              getTitlesWidget: bleedMode
                  ? (_, _) => const SizedBox.shrink()
                  : (value, meta) => SideTitleWidget(
                      meta: meta,
                      child: Text(value.toStringAsFixed(0), style: axisStyle),
                    ),
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => scheme.inverseSurface,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final name =
                    (spot.barIndex >= 0 && spot.barIndex < barLabels.length)
                    ? barLabels[spot.barIndex]
                    : '';
                return LineTooltipItem(
                  '$name: ${spot.y.toStringAsFixed(2)}',
                  InstrumentTheme.tabular(
                    TextStyle(
                      color: scheme.onInverseSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: bars,
      ),
    );
  }

  Widget _buildMultiScatterChart(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final series = scatterSeries ?? const <PlanAnalyticsScatterSeries>[];
    final scatterSpots = <ScatterSpot>[];

    for (final s in series) {
      for (final point in points) {
        final source = s.useActual
            ? (point.actualValues ?? const {})
            : point.values;
        final vx = source[s.metricX];
        final vy = source[s.metricY];
        if (vx != null && vy != null && vx.isFinite && vy.isFinite) {
          scatterSpots.add(
            ScatterSpot(
              vx,
              vy,
              dotPainter: FlDotCirclePainter(
                color: s.useActual ? s.color : scheme.surfaceContainerLowest,
                strokeColor: s.useActual ? scheme.surfaceContainerLowest : s.color,
                strokeWidth: s.useActual ? 1.5 : 2.0,
                radius: s.useActual ? 4.5 : 3.8,
              ),
            ),
          );
        }
      }
    }

    if (scatterSpots.isEmpty) {
      return Center(child: Text(emptyText));
    }

    final axisStyle = InstrumentTheme.tabular(
      theme.textTheme.labelSmall?.copyWith(
            fontSize: 10,
            color: scheme.onSurfaceVariant,
          ) ??
          TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
    );

    return ScatterChart(
      ScatterChartData(
        scatterSpots: scatterSpots,
        gridData: _buildGrid(scheme),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: showScatterAxisTitles,
              reservedSize: showScatterAxisTitles ? 28 : 10,
              getTitlesWidget: (value, meta) => !showScatterAxisTitles
                  ? const SizedBox.shrink()
                  : SideTitleWidget(
                      meta: meta,
                      child: Text(value.toStringAsFixed(1), style: axisStyle),
                    ),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: showScatterAxisTitles,
              reservedSize: showScatterAxisTitles ? 40 : 10,
              getTitlesWidget: (value, meta) => !showScatterAxisTitles
                  ? const SizedBox.shrink()
                  : SideTitleWidget(
                      meta: meta,
                      child: Text(value.toStringAsFixed(1), style: axisStyle),
                    ),
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final resolvedAccent = accentColor ?? scheme.primary;
    final plannedColor = scheme.onSurfaceVariant;
    final actualColor = resolvedAccent;

    final spots = <FlSpot>[];
    final actualSpots = <FlSpot>[];
    final labels = <String>[];
    final allY = <double>[];

    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      labels.add(point.label);

      final value = point.values[metricX];
      if (value != null && value.isFinite) {
        spots.add(FlSpot(i.toDouble(), value));
        allY.add(value);
      }

      final actualValue = point.actualValues?[metricX];
      if (actualValue != null && actualValue.isFinite) {
        actualSpots.add(FlSpot(i.toDouble(), actualValue));
        allY.add(actualValue);
      }
    }

    if (spots.isEmpty && actualSpots.isEmpty) {
      return Center(child: Text(emptyText));
    }

    final (adjustedMin, adjustedMax, yInterval) = _computeBounds(allY);
    final effectiveModulo = math.max(
      1,
      bottomLabelModulo ?? (labels.length / 6).ceil(),
    );
    final minVal = allY.reduce(math.min);
    final maxVal = allY.reduce(math.max);

    final bars = <LineChartBarData>[];
    final barSeriesNames = <String>[];
    final singlePlannedWave = bleedMode && actualSpots.isEmpty;
    final plannedStrokeColor = singlePlannedWave ? resolvedAccent : plannedColor;

    if (spots.isNotEmpty) {
      barSeriesNames.add('Planned');
      bars.add(
        LineChartBarData(
          spots: spots,
          isCurved: false,
          barWidth: singlePlannedWave ? 2.2 : 2.0,
          dashArray: const [5, 4],
          color: plannedStrokeColor,
          dotData: FlDotData(
            show: true,
            getDotPainter: (_, _, _, _) => FlDotCirclePainter(
              radius: 3.2,
              color: scheme.surfaceContainerLow,
              strokeColor: plannedStrokeColor,
              strokeWidth: 2.0,
            ),
          ),
          belowBarData: singlePlannedWave
              ? BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      resolvedAccent.withValues(alpha: 0.18),
                      resolvedAccent.withValues(alpha: 0.0),
                    ],
                  ),
                )
              : BarAreaData(show: false),
        ),
      );
    }
    if (actualSpots.isNotEmpty) {
      barSeriesNames.add('Actual');
      bars.add(
        LineChartBarData(
          spots: actualSpots,
          isCurved: false,
          barWidth: 2.5,
          color: actualColor,
          dotData: FlDotData(
            show: true,
            getDotPainter: (_, _, _, _) => FlDotCirclePainter(
              radius: 4.0,
              color: bleedMode ? actualColor : instrument.successColor,
              strokeColor: scheme.surfaceContainerLowest,
              strokeWidth: 1.5,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: bleedMode
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      actualColor.withValues(alpha: 0.22),
                      actualColor.withValues(alpha: 0.0),
                    ],
                  )
                : null,
            color: bleedMode ? null : actualColor.withValues(alpha: 0.08),
          ),
        ),
      );
    }

    final axisStyle = InstrumentTheme.tabular(
      theme.textTheme.labelSmall?.copyWith(
            fontSize: 10,
            color: scheme.onSurfaceVariant,
          ) ??
          TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (bleedMode)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Row(
              children: [
                if (spots.isNotEmpty && actualSpots.isNotEmpty)
                  Expanded(
                    child: _SeriesLegend(
                      plannedColor: plannedColor,
                      actualColor: actualColor,
                    ),
                  )
                else
                  Expanded(
                    child: Text(
                      'PLANNED WAVE',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: InstrumentTheme.microLabel(
                        context,
                        color: resolvedAccent,
                      ),
                    ),
                  ),
                Text(
                  '${_formatCompactStat(minVal)} – ${_formatCompactStat(maxVal)}',
                  style: InstrumentTheme.tabular(
                    InstrumentTheme.microLabel(
                      context,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          )
        else if (spots.isNotEmpty && actualSpots.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _SeriesLegend(
              plannedColor: plannedColor,
              actualColor: instrument.successColor,
            ),
          ),
        Expanded(
          child: LineChart(
            LineChartData(
              minY: adjustedMin,
              maxY: adjustedMax,
              gridData: _buildGrid(scheme),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: bleedMode ? 22 : 24,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= labels.length) {
                        return const SizedBox.shrink();
                      }
                      if (idx % effectiveModulo != 0) {
                        return const SizedBox.shrink();
                      }
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(labels[idx], style: axisStyle),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: !bleedMode,
                    interval: yInterval,
                    reservedSize: bleedMode ? 0 : 44,
                    getTitlesWidget: bleedMode
                        ? (_, _) => const SizedBox.shrink()
                        : (value, meta) => SideTitleWidget(
                            meta: meta,
                            child: Text(
                              value.toStringAsFixed(0),
                              style: axisStyle,
                            ),
                          ),
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => scheme.inverseSurface,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final name =
                          (spot.barIndex >= 0 &&
                              spot.barIndex < barSeriesNames.length)
                          ? barSeriesNames[spot.barIndex]
                          : '';
                      return LineTooltipItem(
                        '$name: ${spot.y.toStringAsFixed(1)}',
                        InstrumentTheme.tabular(
                          TextStyle(
                            color: scheme.onInverseSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              lineBarsData: bars,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScatterChart(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final plannedColor = scheme.onSurfaceVariant;
    final actualColor = scheme.primary;

    final spots = <ScatterSpot>[];
    final actualSpots = <ScatterSpot>[];
    final allX = <double>[];
    final allY = <double>[];

    for (final point in points) {
      final vx = point.values[metricX];
      final vy = point.values[metricY];
      if (vx != null && vy != null && vx.isFinite && vy.isFinite) {
        spots.add(
          ScatterSpot(
            vx,
            vy,
            dotPainter: FlDotCirclePainter(
              color: scheme.surfaceContainerLowest,
              strokeColor: plannedColor,
              strokeWidth: 2.0,
              radius: 3.8,
            ),
          ),
        );
        allX.add(vx);
        allY.add(vy);
      }

      final ax = point.actualValues?[metricX];
      final ay = point.actualValues?[metricY];
      if (ax != null && ay != null && ax.isFinite && ay.isFinite) {
        actualSpots.add(
          ScatterSpot(
            ax,
            ay,
            dotPainter: FlDotCirclePainter(
              color: actualColor,
              strokeColor: scheme.surfaceContainerLowest,
              strokeWidth: 1.5,
              radius: 4.5,
            ),
          ),
        );
        allX.add(ax);
        allY.add(ay);
      }
    }

    if (spots.isEmpty && actualSpots.isEmpty) {
      return Center(child: Text(emptyText));
    }

    final minX = allX.reduce(math.min);
    final maxX = allX.reduce(math.max);
    final minY = allY.reduce(math.min);
    final maxY = allY.reduce(math.max);
    final spanX = maxX - minX;
    final spanY = maxY - minY;
    final xInterval = _computeYInterval(spanX);
    final yInterval = _computeYInterval(spanY);

    final axisStyle = InstrumentTheme.tabular(
      theme.textTheme.labelSmall?.copyWith(
            fontSize: 10,
            color: scheme.onSurfaceVariant,
          ) ??
          TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (spots.isNotEmpty && actualSpots.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _SeriesLegend(
              plannedColor: plannedColor,
              actualColor: actualColor,
            ),
          ),
        Expanded(
          child: ScatterChart(
            ScatterChartData(
              scatterSpots: [...spots, ...actualSpots],
              gridData: _buildGrid(scheme),
              borderData: FlBorderData(show: false),
              minX: minX - xInterval,
              maxX: maxX + xInterval,
              minY: minY - yInterval,
              maxY: maxY + yInterval,
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: showScatterAxisTitles,
                    reservedSize: showScatterAxisTitles ? 28 : 10,
                    getTitlesWidget: (value, meta) => !showScatterAxisTitles
                        ? const SizedBox.shrink()
                        : SideTitleWidget(
                            meta: meta,
                            child: Text(
                              value.toStringAsFixed(1),
                              style: axisStyle,
                            ),
                          ),
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: showScatterAxisTitles,
                    reservedSize: showScatterAxisTitles ? 40 : 10,
                    getTitlesWidget: (value, meta) => !showScatterAxisTitles
                        ? const SizedBox.shrink()
                        : SideTitleWidget(
                            meta: meta,
                            child: Text(
                              value.toStringAsFixed(1),
                              style: axisStyle,
                            ),
                          ),
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  (double, double, double) _computeBounds(List<double> allY) {
    final minY = allY.reduce(math.min);
    final maxY = allY.reduce(math.max);
    final span = maxY - minY;
    final yInterval = _computeYInterval(span);
    final minBound = span == 0
        ? minY - yInterval
        : (minY / yInterval).floor() * yInterval - yInterval;
    final maxBound = span == 0
        ? maxY + yInterval
        : (maxY / yInterval).ceil() * yInterval + yInterval;
    final adjustedMin = minBound == maxBound
        ? minBound
        : math.min(minBound, maxBound);
    final adjustedMax = minBound == maxBound
        ? minBound + yInterval
        : math.max(minBound, maxBound);
    return (adjustedMin, adjustedMax, yInterval);
  }

  double _computeYInterval(double span) {
    if (span == 0) return 1.0;
    final rawInterval = span / 5;
    if (rawInterval < 1) return 1.0;
    final exponent = (math.log(rawInterval) / math.ln10).floor();
    final magnitude = math.pow(10, exponent).toDouble();
    final normalized = rawInterval / magnitude;
    double niceNormalized;
    if (normalized <= 1) {
      niceNormalized = 1;
    } else if (normalized <= 2) {
      niceNormalized = 2;
    } else if (normalized <= 5) {
      niceNormalized = 5;
    } else {
      niceNormalized = 10;
    }
    return niceNormalized * magnitude;
  }

  String _formatCompactStat(double value) {
    if (value == value.roundToDouble()) return value.round().toString();
    return value.toStringAsFixed(1);
  }
}

class _SeriesLegend extends StatelessWidget {
  final Color plannedColor;
  final Color actualColor;

  const _SeriesLegend({required this.plannedColor, required this.actualColor});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        _LegendItem(
          color: plannedColor,
          filled: false,
          label: l10n.plannedUpperLabel,
        ),
        _LegendItem(
          color: actualColor,
          filled: true,
          label: l10n.actualUpperLabel,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final bool filled;
  final String label;

  const _LegendItem({
    required this.color,
    required this.filled,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? color : Colors.transparent,
            border: Border.all(color: color, width: 1.8),
          ),
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: InstrumentTheme.microLabel(context, color: color),
          ),
        ),
      ],
    );
  }
}
