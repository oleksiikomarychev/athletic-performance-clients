import 'package:flutter/material.dart';
import 'package:workout_app/config/constants/theme_constants.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/models/workout.dart';

class WorkoutStatusView {
  final String label;
  final Color background;
  final Color textColor;
  final Color dotColor;

  const WorkoutStatusView({
    required this.label,
    required this.background,
    required this.textColor,
    required this.dotColor,
  });
}

WorkoutStatusView workoutStatusView(BuildContext context, Workout workout) {
  final l10n = AppLocalizations.of(context);
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final status = (workout.status ?? '').toLowerCase();
  final isCancelled = status == 'cancelled' || status == 'canceled' || status == 'dropped';
  final completed = (status == 'completed') || (workout.completedAt != null && !isCancelled);
  final inProgress = (workout.startedAt != null) && (workout.completedAt == null) && !isCancelled;
  if (completed) {
    final color = isDark ? Colors.green.shade300 : Colors.green;
    return WorkoutStatusView(
      label: l10n.statusCompleted,
      background: isDark
          ? Color.alphaBlend(color.withValues(alpha: 0.16), theme.colorScheme.surfaceContainerLow)
          : const Color(0xFFEFF8F2),
      textColor: color,
      dotColor: color,
    );
  } else if (inProgress) {
    return WorkoutStatusView(
      label: l10n.statusInProgress,
      background: isDark ? theme.colorScheme.primaryContainer : const Color(0xFFEAEFFF),
      textColor: isDark ? theme.colorScheme.onPrimaryContainer : AppColors.primary,
      dotColor: isDark ? theme.colorScheme.primary : AppColors.primary,
    );
  } else if (isCancelled) {
    final color = isDark ? theme.colorScheme.error : Colors.redAccent;
    return WorkoutStatusView(
      label: l10n.statusCancelled,
      background: isDark ? theme.colorScheme.errorContainer : const Color(0xFFFFEBEE),
      textColor: isDark ? theme.colorScheme.onErrorContainer : color,
      dotColor: color,
    );
  } else {
    final color = isDark ? theme.colorScheme.error : Colors.redAccent;
    return WorkoutStatusView(
      label: l10n.statusPlannedLabel,
      background: isDark ? theme.colorScheme.errorContainer : const Color(0xFFFFEBEE),
      textColor: isDark ? theme.colorScheme.onErrorContainer : color,
      dotColor: color,
    );
  }
}

class WorkoutStatusCounts {
  final int planned;
  final int inProgress;
  final int completed;

  const WorkoutStatusCounts({required this.planned, required this.inProgress, required this.completed});
}

WorkoutStatusCounts workoutStatusCounts(BuildContext context, List<Workout> workouts) {
  int planned = 0;
  int inProgress = 0;
  int completed = 0;
  for (final w in workouts) {
    final status = workoutStatusView(context, w);
    if (status.label == 'Completed') {
      completed++;
    } else if (status.label == 'In Progress') {
      inProgress++;
    } else {
      planned++;
    }
  }
  return WorkoutStatusCounts(planned: planned, inProgress: inProgress, completed: completed);
}

Widget workoutStatusDot(Color color) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 1.5),
    width: 6,
    height: 6,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
