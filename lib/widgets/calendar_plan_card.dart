import 'package:flutter/material.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/models/calendar_plan.dart';

/// A compact comparison summary. The whole card opens the plan's details.
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

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colors.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: dimensions.cardPadding + 3,
            vertical: dimensions.cardPadding + 1,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      plan.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: colors.onSurfaceVariant,
                    size: 18,
                  ),
                ],
              ),
              if (goal != null || level != null) ...[
                const SizedBox(height: 5),
                Text.rich(
                  TextSpan(
                    children: [
                      if (goal != null)
                        TextSpan(
                          text: goal,
                          style: TextStyle(color: colors.primary),
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
                const SizedBox(height: 7),
                Wrap(spacing: 12, runSpacing: 5, children: metrics),
              ],
            ],
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
        Icon(icon, size: 12, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
