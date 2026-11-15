import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';

import '../../models/workout.dart';

class WorkoutHeader extends StatelessWidget {
  final Workout? workout;

  const WorkoutHeader({super.key, this.workout});

  @override
  Widget build(BuildContext context) {
    final w = workout;
    if (w == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final scheduled = w.scheduledFor != null
        ? DateFormat('yMMMd · HH:mm').format(w.scheduledFor!.toLocal())
        : null;

    return Container(
      decoration: InstrumentTheme.instrumentCardDecoration(
        context,
        accentColor: instrument.workingAura,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text(
                w.status?.toUpperCase() ?? 'WORKOUT',
                style: InstrumentTheme.microLabel(
                  context,
                  color: instrument.workingAura,
                ),
              ),
              if (scheduled != null)
                Text(
                  scheduled,
                  style: InstrumentTheme.microLabel(context).copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            w.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${w.exerciseInstances.length} exercises',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
