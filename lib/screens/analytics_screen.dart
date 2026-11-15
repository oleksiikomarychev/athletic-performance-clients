import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/services/plan_service.dart';
import 'package:workout_app/services/service_locator.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/error_message.dart';
import 'package:workout_app/widgets/loading_indicator.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';

/// Analysis Mode screen implementing Chart-First Surface, collapsed Date Range bar,
/// reactive Data Point Picker chips, and Honest Discrete `fl_chart` charts.
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;
  bool _datePickerExpanded = false;

  final List<String> _metrics = const [
    'volume',
    'effort',
    'kpsh',
    'reps',
    '1rm',
  ];
  String _metricX = 'volume';
  String _metricY = 'volume';

  bool _loadingPlan = true;
  bool _loading = false;
  String? _error;
  int? _planId;
  String? _planName;

  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _loadActivePlan();
  }

  Future<void> _loadActivePlan() async {
    setState(() {
      _loadingPlan = true;
      _error = null;
    });
    try {
      final ps = PlanService(apiClient: ref.read(apiClientProvider));
      final ap = await ps.getActivePlan();
      if (!mounted) return;
      setState(() {
        _planId = ap?.id;
        _planName = ap?.calendarPlan.name;
        _loadingPlan = false;
      });
      if (_planId != null) {
        await _fetch();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingPlan = false;
        _error = AppLocalizations.of(context).errorLoadingActivePlan;
      });
    }
  }

  Future<Map<String, dynamic>> _buildChatContext() async {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    return <String, dynamic>{
      'v': 1,
      'app': 'WorkoutApp',
      'screen': 'analytics',
      'role': 'athlete',
      'metric_x': _metricX,
      'metric_y': _metricY,
      'date_from': _rangeStart?.toIso8601String(),
      'date_to': _rangeEnd?.toIso8601String(),
      'timestamp': nowIso,
      'entities': <String, dynamic>{
        'active_plan': _planId != null
            ? {'id': _planId, 'name': _planName}
            : null,
      },
    };
  }

  Future<void> _fetch() async {
    if (_planId == null) {
      setState(() => _error = AppLocalizations.of(context).activePlanNotFound);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final svc = ref.read(analyticsServiceProvider);
      final res = await svc.fetchMetrics(
        planId: _planId!,
        metricX: _metricX,
        metricY: _metricY,
        dateFrom: _rangeStart,
        dateTo: _rangeEnd,
      );
      if (!mounted) return;
      setState(() {
        _data = res;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = AppLocalizations.of(context).errorLoadingData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final df = DateFormat('dd.MM.yyyy', locale);

    return AssistantChatHost(
      contextBuilder: _buildChatContext,
      builder: (context, openChat) {
        return Scaffold(
          appBar: PrimaryAppBar(
            title: l10n.analyticsPlanTitle(_planName ?? ''),
            onTitleTap: openChat,
          ),
          body: RefreshIndicator(
            onRefresh: _loadActivePlan,
            child: _buildBody(l10n, locale, df),
          ),
        );
      },
    );
  }

  Widget _buildBody(AppLocalizations l10n, String locale, DateFormat df) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dimensions = UiDimensions.of(context);

    if (_loadingPlan) {
      return const LoadingIndicator();
    }

    if (_error != null && _planId == null) {
      return ErrorMessage(message: _error!, onRetry: _loadActivePlan);
    }

    final rangeLabel = (_rangeStart != null && _rangeEnd != null)
        ? '${df.format(_rangeStart!)} — ${df.format(_rangeEnd!)}'
        : (_rangeStart != null
              ? '${df.format(_rangeStart!)} — …'
              : 'All sessions');

    final isTrendMode = _metricX == _metricY;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(dimensions.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(dimensions.cardPadding),
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
                    Container(
                      width: 36,
                      height: 36,
                      decoration: InstrumentTheme.cardDecoration(
                        context,
                        color: colors.surfaceContainerHigh,
                        radius: 10,
                      ),
                      child: Icon(
                        Icons.date_range_outlined,
                        color: colors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'DATE RANGE',
                            style: InstrumentTheme.microLabel(context),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            rangeLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: InstrumentTheme.tabular(
                              theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ) ??
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_rangeStart != null || _rangeEnd != null)
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: IconButton(
                          tooltip: 'Reset dates',
                          style: IconButton.styleFrom(
                            minimumSize: const Size(48, 48),
                            tapTargetSize: MaterialTapTargetSize.padded,
                          ),
                          onPressed: () {
                            setState(() {
                              _rangeStart = null;
                              _rangeEnd = null;
                            });
                            _fetch();
                          },
                          icon: const Icon(Icons.close, size: 18),
                        ),
                      ),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton(
                        tooltip: _datePickerExpanded
                            ? 'Collapse calendar'
                            : 'Select date range',
                        style: IconButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          tapTargetSize: MaterialTapTargetSize.padded,
                        ),
                        onPressed: () => setState(
                          () => _datePickerExpanded = !_datePickerExpanded,
                        ),
                        icon: AnimatedRotation(
                          duration: const Duration(milliseconds: 200),
                          turns: _datePickerExpanded ? 0.5 : 0,
                          child: const Icon(Icons.keyboard_arrow_down_rounded),
                        ),
                      ),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: _datePickerExpanded
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: TableCalendar<dynamic>(
                            firstDay: DateTime.utc(2020, 1, 1),
                            lastDay: DateTime.utc(2100, 12, 31),
                            focusedDay: _focusedDay,
                            calendarFormat: CalendarFormat.month,
                            availableCalendarFormats: const {
                              CalendarFormat.month: 'Month',
                            },
                            headerStyle: const HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                            ),
                            locale: locale,
                            rangeSelectionMode: _rangeSelectionMode,
                            rangeStartDay: _rangeStart,
                            rangeEndDay: _rangeEnd,
                            onRangeSelected: (start, end, focusedDay) {
                              setState(() {
                                _focusedDay = focusedDay;
                                _rangeStart = start;
                                _rangeEnd = end;
                                _rangeSelectionMode =
                                    RangeSelectionMode.toggledOn;
                              });
                              if (start != null && end != null) {
                                _fetch();
                              }
                            },
                            onPageChanged: (fd) => _focusedDay = fd,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          SizedBox(height: dimensions.sectionGap),
          Container(
            padding: EdgeInsets.all(dimensions.cardPadding),
            decoration: InstrumentTheme.cardDecoration(
              context,
              color: colors.surfaceContainerLow,
              radius: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isTrendMode
                            ? 'PRIMARY METRIC (TREND)'
                            : '${l10n.axisY.toUpperCase()} VS ${l10n.axisX.toUpperCase()}',
                        style: InstrumentTheme.microLabel(context),
                      ),
                    ),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton(
                        tooltip: l10n.showChart,
                        style: IconButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          tapTargetSize: MaterialTapTargetSize.padded,
                        ),
                        onPressed: _loading ? null : _fetch,
                        icon: Icon(
                          Icons.refresh_rounded,
                          size: 20,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final m in _metrics)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(_metricLabel(m)),
                            selected: _metricY == m,
                            onSelected: (_) {
                              setState(() {
                                if (isTrendMode) {
                                  _metricX = m;
                                }
                                _metricY = m;
                              });
                              _fetch();
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${l10n.axisX.toUpperCase()} (TIMELINE / CORRELATION)',
                  style: InstrumentTheme.microLabel(context),
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: const Text('Trend'),
                          selected: _metricX == _metricY,
                          onSelected: (_) {
                            setState(() => _metricX = _metricY);
                            _fetch();
                          },
                        ),
                      ),
                      for (final m in _metrics)
                        if (m != _metricY)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(_metricLabel(m)),
                              selected: _metricX == m,
                              onSelected: (_) {
                                setState(() => _metricX = m);
                                _fetch();
                              },
                            ),
                          ),
                    ],
                  ),
                ),
                SizedBox(height: dimensions.sectionGap),
                if (_loading)
                  const SizedBox(height: 280, child: LoadingIndicator())
                else if (_error != null && _data == null)
                  ErrorMessage(message: _error!, onRetry: _fetch)
                else if (_data == null)
                  SizedBox(
                    height: 220,
                    child: Center(
                      child: Text(
                        l10n.selectRangeAndMetrics,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 340,
                    padding: const EdgeInsets.all(12),
                    decoration: InstrumentTheme.cardDecoration(
                      context,
                      color: colors.surfaceContainerLowest,
                      borderColor: colors.outlineVariant.withValues(alpha: 0.4),
                      radius: 12,
                    ),
                    child: _buildChartArea(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _metricLabel(String m) {
    final l10n = AppLocalizations.of(context);
    switch (m) {
      case 'volume':
        return l10n.metricVolumeKg;
      case 'effort':
        return l10n.metricEffortRpe;
      case 'kpsh':
        return l10n.metricKpsh;
      case 'reps':
        return l10n.metricReps;
      case '1rm':
        return l10n.metricOneRm;
      default:
        return m;
    }
  }

  Widget _buildChartArea() {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).languageCode;
    if (_data == null) {
      return Center(child: Text(l10n.selectRangeAndMetrics));
    }
    final items = List<Map<String, dynamic>>.from(_data!["items"] ?? const []);
    final oneRm = List<Map<String, dynamic>>.from(_data!["one_rm"] ?? const []);
    final mx = _metricX;
    final my = _metricY;

    final axisStyle = InstrumentTheme.tabular(
      theme.textTheme.labelSmall?.copyWith(
            fontSize: 10,
            color: scheme.onSurfaceVariant,
          ) ??
          TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
    );

    if (mx == my) {
      final is1rm = mx == '1rm';
      final points = <FlSpot>[];
      final List<DateTime> dates = [];
      final Map<String, double> dayValues = {};

      if (is1rm) {
        for (final e in oneRm) {
          final dstr = e['date'] as String?;
          final v = (e['value'] as num?)?.toDouble();
          if (dstr == null || v == null || !v.isFinite) continue;
          dayValues[dstr] = v;
        }
      } else {
        for (final it in items) {
          final dstr = it['date'] as String?;
          if (dstr == null) continue;
          final val = (it['values']?[mx] as num?)?.toDouble();
          if (val == null || !val.isFinite) continue;
          dayValues[dstr] = val;
        }
      }

      final sorted = dayValues.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      for (var i = 0; i < sorted.length; i++) {
        dates.add(DateTime.parse(sorted[i].key));
        points.add(FlSpot(i.toDouble(), sorted[i].value));
      }
      if (points.isEmpty) {
        return Center(child: Text(l10n.noDataForSelectedMetrics));
      }
      return LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: scheme.outlineVariant.withValues(alpha: 0.3),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= dates.length) return const SizedBox();
                  final step = dates.length > 6 ? (dates.length / 6).ceil() : 1;
                  if (idx % step != 0) return const SizedBox();
                  final d = dates[idx];
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      DateFormat('dd.MM', locale).format(d),
                      style: axisStyle,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (value, meta) => SideTitleWidget(
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
                  final idx = spot.x.toInt();
                  final dateLabel = (idx >= 0 && idx < dates.length)
                      ? DateFormat('dd.MM', locale).format(dates[idx])
                      : '';
                  return LineTooltipItem(
                    '$dateLabel: ${spot.y.toStringAsFixed(1)}',
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
          lineBarsData: [
            LineChartBarData(
              spots: points,
              isCurved: false,
              barWidth: 2.5,
              color: scheme.primary,
              dotData: FlDotData(
                show: true,
                getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                  radius: 4.0,
                  color: scheme.primary,
                  strokeColor: scheme.surfaceContainerLowest,
                  strokeWidth: 1.5,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: scheme.primary.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
      );
    }

    final scatters = <ScatterSpot>[];
    for (final it in items) {
      final vx = (it['values']?[mx] as num?)?.toDouble();
      double? vy;
      if (my == '1rm') {
        final dstr = it['date'] as String?;
        if (dstr != null) {
          final match = oneRm.firstWhere(
            (e) => e['date'] == dstr,
            orElse: () => const {},
          );
          vy = (match['value'] as num?)?.toDouble();
        }
      } else {
        vy = (it['values']?[my] as num?)?.toDouble();
      }
      if (vx != null && vy != null && vx.isFinite && vy.isFinite) {
        scatters.add(
          ScatterSpot(
            vx,
            vy,
            dotPainter: FlDotCirclePainter(
              color: scheme.primary,
              strokeColor: scheme.surfaceContainerLowest,
              strokeWidth: 1.5,
              radius: 4.5,
            ),
          ),
        );
      }
    }
    if (scatters.isEmpty) {
      return Center(child: Text(l10n.noDataForSelectedMetrics));
    }

    return ScatterChart(
      ScatterChartData(
        scatterSpots: scatters,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: scheme.outlineVariant.withValues(alpha: 0.3),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                child: Text(value.toStringAsFixed(1), style: axisStyle),
              ),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => SideTitleWidget(
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
}
