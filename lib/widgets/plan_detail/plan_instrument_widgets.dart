import 'package:flutter/material.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/models/calendar_plan.dart';
import 'package:workout_app/models/calendar_plan_summary.dart';
import 'package:workout_app/providers/ambient_environment_provider.dart';
import 'package:workout_app/providers/interface_maker_provider.dart';
import 'package:workout_app/widgets/instrument_metric_matrix.dart';
import 'package:workout_app/widgets/interface_maker_sheet.dart';

/// Self-contained single-contour Telemetry Passport & Wave Card for a [CalendarPlan].
///
/// Enforces `Max Border Depth = 1`: only the outer card container carries a `1px`
/// border. Inside, the optional [chartSlot] spans bleed-to-edge horizontally
/// (`EdgeInsets.zero`), followed by a `1px` hairline metadata strip and the bare
/// 4-column [InstrumentMetricMatrix] (`Data Point Picker`).
class PlanPassportCard extends StatelessWidget {
  final CalendarPlan plan;
  final bool adoptersLoading;
  final String? adoptersError;
  final int? adoptersCount;
  final bool updatingPublic;
  final ValueChanged<bool> onPublicChanged;
  final TrainingEnvironmentData? environment;
  final bool snarkyVoice;
  final bool showBriefing;
  final Widget? chartSlot;
  final List<InstrumentMetricCellData>? metricCells;
  final MetricSlot? selectedSlot;
  final ValueChanged<MetricSlot>? onSelectSlot;

  const PlanPassportCard({
    super.key,
    required this.plan,
    required this.adoptersLoading,
    required this.adoptersError,
    required this.adoptersCount,
    required this.updatingPublic,
    required this.onPublicChanged,
    this.environment,
    this.snarkyVoice = false,
    this.showBriefing = true,
    this.chartSlot,
    this.metricCells,
    this.selectedSlot,
    this.onSelectSlot,
  });

  String _formatGoal(String raw) {
    const labels = {
      'strength': 'Strength',
      'hypertrophy': 'Muscle growth',
      'strength_hypertrophy': 'Strength & muscle',
      'strength_powerlifting': 'Powerlifting',
      'recomposition': 'Body recomposition',
      'general_fitness': 'General fitness',
    };
    final key = raw.trim().toLowerCase();
    return labels[key] ?? raw.replaceAll('_', ' ');
  }

  List<InstrumentMetricCellData> _defaultCells(
    CalendarPlan plan,
    AppLocalizations l10n,
  ) {
    final adoptedText = adoptersLoading
        ? '…'
        : (adoptersError != null ? '—' : '${adoptersCount ?? 0}');
    final microCount = plan.mesocycles.fold<int>(
      0,
      (sum, m) => sum + m.microcycles.length,
    );
    return [
      InstrumentMetricCellData(
        slot: MetricSlot.durationWeeks,
        value: '${plan.durationWeeks} wk',
      ),
      InstrumentMetricCellData(
        slot: MetricSlot.frequencyPerWeek,
        value: plan.intendedFrequencyPerWeek != null
            ? '${plan.intendedFrequencyPerWeek}×/wk'
            : '—',
      ),
      InstrumentMetricCellData(
        slot: MetricSlot.setsCount,
        label: l10n.metricMicrocyclesShort,
        value: microCount > 0
            ? '$microCount'
            : (plan.sessionDurationTargetMin != null
                  ? '${plan.sessionDurationTargetMin}m'
                  : '—'),
      ),
      InstrumentMetricCellData(
        slot: MetricSlot.kpsh,
        label: l10n.metricAppliedShort,
        value: adoptedText,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final env = environment ?? TrainingEnvironmentData.fromPlan(plan);
    final accent = plan.isActive
        ? env.accentColor(instrument)
        : env.accentColor(instrument);
    final hairline = (isDark
            ? instrument.hairlineBorder
            : colors.outlineVariant)
        .withValues(alpha: isDark ? 0.85 : 0.55);

    final String adoptedText = adoptersLoading
        ? '…'
        : (adoptersError != null ? '—' : '${adoptersCount ?? 0}');
    final String? startStr = plan.startDate?.toLocal().toString().split(' ')[0];
    final String? endStr = plan.endDate?.toLocal().toString().split(' ')[0];

    final eyebrowParts = <String>[
      plan.isActive ? 'ACTIVE MESOCYCLE' : 'PLAN TEMPLATE',
      '${plan.durationWeeks} WK',
      if (plan.intendedFrequencyPerWeek != null)
        '${plan.intendedFrequencyPerWeek}×/WK',
    ];

    final metadataFragments = <String>[
      'Applied $adoptedText',
      if (plan.primaryGoal != null && plan.primaryGoal!.isNotEmpty)
        _formatGoal(plan.primaryGoal!),
      if (plan.intendedExperienceLevel != null &&
          plan.intendedExperienceLevel!.isNotEmpty)
        plan.intendedExperienceLevel!.replaceAll('_', ' '),
      if (plan.sessionDurationTargetMin != null)
        '${plan.sessionDurationTargetMin} min',
      if (startStr != null && endStr != null)
        '$startStr → $endStr'
      else if (startStr != null)
        'Start $startStr'
      else if (endStr != null)
        'End $endStr',
      if (plan.nutritionPlan != null) 'Nutrition',
    ];

    final equipmentList = plan.requiredEquipment ?? const <String>[];
    final l10n = AppLocalizations.of(context);
    final cells = metricCells ?? _defaultCells(plan, l10n);

    return ClipRRect(
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          eyebrowParts.join(' · '),
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                            env.localizedBadgeLabel(l10n),
                            style: InstrumentTheme.microLabel(
                              context,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    plan.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  if (showBriefing) ...[
                    const SizedBox(height: 5),
                    Text(
                      env.localizedBriefing(l10n, snarky: snarkyVoice),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                  if (adoptersError != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      adoptersError!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (chartSlot != null) ...[
              Padding(
                padding: EdgeInsets.zero,
                child: chartSlot!,
              ),
              Container(height: 1, color: hairline),
            ] else
              Container(height: 1, color: hairline),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (equipmentList.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 14,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            equipmentList.join(' · '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    metadataFragments.join(' · '),
                    style: InstrumentTheme.tabular(
                      theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ) ??
                          TextStyle(
                            fontSize: 11,
                            color: colors.onSurfaceVariant,
                          ),
                    ),
                  ),
                  if (plan.notes != null && plan.notes!.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      plan.notes!.trim(),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Public template',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                        if (updatingPublic)
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        Switch.adaptive(
                          value: plan.isPublic,
                          onChanged: updatingPublic ? null : onPublicChanged,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: hairline),
            InstrumentMetricMatrix(
              cells: cells,
              selectedSlot: selectedSlot,
              onSelectSlot: onSelectSlot,
              accentColor: accent,
            ),
          ],
        ),
      ),
    );
  }
}

/// Canvas-level floating pill strip for switching between Original & forked
/// Plan Variants, plus optional trailing action/filter pills.
///
/// Zero outer card border — sits directly on the ambient canvas.
class PlanVariantsBar extends StatelessWidget {
  final int currentPlanId;
  final int rootPlanId;
  final List<CalendarPlanSummary> variants;
  final bool isLoading;
  final String? errorText;
  final VoidCallback onSelectOriginal;
  final ValueChanged<CalendarPlanSummary> onSelectVariant;
  final VoidCallback onCreateVariant;
  final List<CanvasPillItem> extraPills;
  final EdgeInsetsGeometry padding;

  const PlanVariantsBar({
    super.key,
    required this.currentPlanId,
    required this.rootPlanId,
    required this.variants,
    required this.isLoading,
    required this.errorText,
    required this.onSelectOriginal,
    required this.onSelectVariant,
    required this.onCreateVariant,
    this.extraPills = const [],
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);

    final origId = variants
        .firstWhere(
          (v) => v.isOriginal,
          orElse: () => CalendarPlanSummary(
            id: rootPlanId,
            name: '',
            durationWeeks: 0,
            isActive: true,
            rootPlanId: rootPlanId,
            isOriginal: true,
          ),
        )
        .id;

    if (isLoading) {
      return Padding(
        padding: padding,
        child: const LinearProgressIndicator(minHeight: 2),
      );
    }

    if (errorText != null) {
      return Padding(
        padding: padding,
        child: Text(
          errorText!,
          style: theme.textTheme.bodySmall?.copyWith(color: colors.error),
        ),
      );
    }

    final l10n = AppLocalizations.of(context);
    final items = <CanvasPillItem>[
      CanvasPillItem(
        label: l10n.planVariantOriginal,
        icon: Icons.star_rounded,
        selected: currentPlanId == origId,
        accentColor: instrument.moderateEffortColor,
        onTap: onSelectOriginal,
      ),
      ...variants
          .where((v) => !v.isOriginal)
          .map(
            (v) => CanvasPillItem(
              label: v.name,
              icon: Icons.fork_right,
              selected: v.id == currentPlanId,
              onTap: () {
                if (v.id != currentPlanId) {
                  onSelectVariant(v);
                }
              },
            ),
          ),
      CanvasPillItem(
        label: l10n.planVariantAdd,
        icon: Icons.add,
        onTap: onCreateVariant,
      ),
      ...extraPills,
    ];

    return CanvasPillStrip(items: items, padding: padding);
  }
}

/// Legacy single-contour collapsible shell preserved for existing component tests.
class PlanAnalyticsInstrumentShell extends StatelessWidget {
  final bool expanded;
  final String pointsSummaryText;
  final VoidCallback onToggleExpanded;
  final Widget expandedChild;

  const PlanAnalyticsInstrumentShell({
    super.key,
    required this.expanded,
    required this.pointsSummaryText,
    required this.onToggleExpanded,
    required this.expandedChild,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: InstrumentTheme.instrumentCardDecoration(
        context,
        radius: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: colors.primary,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context).planAnalyticsTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      pointsSummaryText,
                      style: InstrumentTheme.tabular(
                        InstrumentTheme.microLabel(context),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  tooltip: expanded
                      ? AppLocalizations.of(context).tooltipCollapse
                      : AppLocalizations.of(context).tooltipExpand,
                  style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    tapTargetSize: MaterialTapTargetSize.padded,
                    visualDensity: VisualDensity.standard,
                  ),
                  icon: AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: expanded ? 0 : 0.5,
                    child: const Icon(Icons.keyboard_arrow_up_rounded),
                  ),
                  onPressed: onToggleExpanded,
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: expandedChild,
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
          ),
        ],
      ),
    );
  }
}
