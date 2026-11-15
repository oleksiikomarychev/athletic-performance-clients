import 'package:flutter/material.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/models/calendar_plan.dart';

/// Plan Passport card aligned with the Adaptive Training Instrument design system.
/// Displays technical plan metadata cleanly with tabular numerals and hairline borders.
class CalendarPlanCard extends StatelessWidget {
  final CalendarPlan plan;
  final VoidCallback onTap;

  const CalendarPlanCard({super.key, required this.plan, required this.onTap});

  static const _goalLabels = {
    'strength': 'Strength',
    'hypertrophy': 'Muscle growth',
    'strength_hypertrophy': 'Strength & muscle',
    'strength_powerlifting': 'Powerlifting',
    'recomposition': 'Body recomposition',
    'general_fitness': 'General fitness',
  };

  static const _levelLabels = {
    'novice': 'Beginner',
    'beginner': 'Beginner',
    'intermediate': 'Intermediate',
    'advanced': 'Advanced',
    'elite': 'Elite',
    'novice_to_intermediate': 'Beginner–intermediate',
    'beginner-intermediate': 'Beginner–intermediate',
    'intermediate-advanced': 'Intermediate–advanced',
  };

  String? _label(String? value, Map<String, String> labels) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    final label = labels[trimmed.toLowerCase()];
    if (label != null) return label;
    final readable = trimmed.replaceAll('_', ' ');
    return '${readable[0].toUpperCase()}${readable.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dimensions = UiDimensions.of(context);
    final goal = _label(plan.primaryGoal, _goalLabels);
    final level = _label(plan.intendedExperienceLevel, _levelLabels);
    final metrics = <Widget>[
      if ((plan.intendedFrequencyPerWeek ?? 0) > 0)
        _PlanMetric(
          icon: Icons.fitness_center_outlined,
          label: '${plan.intendedFrequencyPerWeek}×/week',
        ),
      if ((plan.sessionDurationTargetMin ?? 0) > 0)
        Tooltip(
          message: 'Target session length',
          child: _PlanMetric(
            icon: Icons.schedule_outlined,
            label: '${plan.sessionDurationTargetMin} min/session',
          ),
        ),
      if (plan.durationWeeks > 0)
        _PlanMetric(
          icon: Icons.calendar_today_outlined,
          label:
              '${plan.durationWeeks} ${plan.durationWeeks == 1 ? 'week' : 'weeks'}',
        ),
    ];

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: InstrumentTheme.cardDecoration(
          context,
          color: colors.surfaceContainerLow,
          borderColor: plan.isActive
              ? colors.primary.withValues(alpha: 0.45)
              : null,
          borderWidth: plan.isActive ? 1.5 : 1.0,
          radius: 14,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: dimensions.cardPadding + 2,
                vertical: dimensions.cardPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (plan.isActive)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.primary.withValues(
                                      alpha: 0.14,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'ACTIVE',
                                    style: InstrumentTheme.microLabel(
                                      context,
                                      color: colors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            Text(
                              plan.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right,
                        color: colors.onSurfaceVariant,
                        size: 20,
                      ),
                    ],
                  ),
                  if (goal != null || level != null) ...[
                    const SizedBox(height: 6),
                    Text.rich(
                      TextSpan(
                        children: [
                          if (goal != null)
                            TextSpan(
                              text: goal,
                              style: TextStyle(
                                color: colors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (goal != null && level != null)
                            const TextSpan(text: ' · '),
                          if (level != null) TextSpan(text: level),
                        ],
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (metrics.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: InstrumentTheme.cardDecoration(
                        context,
                        color: colors.surfaceContainerHighest.withValues(
                          alpha: 0.45,
                        ),
                        borderColor: colors.outlineVariant.withValues(
                          alpha: 0.3,
                        ),
                        radius: 10,
                      ),
                      child: Wrap(spacing: 12, runSpacing: 5, children: metrics),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanMetric extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PlanMetric({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            style: InstrumentTheme.tabular(
              theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ) ??
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
