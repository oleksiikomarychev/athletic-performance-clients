import 'package:flutter/material.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/models/workout_session.dart';

/// Instrument-styled card summarizing a training session with tabular timestamps,
/// duration, completed set count, and semantic active/done status badge.
class SessionInstrumentCard extends StatelessWidget {
  final WorkoutSession session;
  final VoidCallback? onTap;

  const SessionInstrumentCard({super.key, required this.session, this.onTap});

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  static int _countCompletedSets(WorkoutSession session) {
    final completed = session.progress['completed'];
    int count = 0;
    if (completed is Map) {
      for (final value in completed.values) {
        if (value is List) {
          count += value.length;
        }
      }
    }
    return count;
  }

  static String _formatDate(DateTime? dt) =>
      dt == null ? '—' : _dateFormat.format(dt.toLocal());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final dimensions = UiDimensions.of(context);

    final statusColor = session.isActive
        ? instrument.moderateEffortColor
        : instrument.successColor;
    final completedSets = _countCompletedSets(session);

    final content = Container(
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
              Expanded(
                child: Text(
                  'SESSION #${session.id ?? '-'}',
                  style: InstrumentTheme.tabular(
                    theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ) ??
                        const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.45),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      session.isActive ? Icons.play_arrow_rounded : Icons.check,
                      size: 13,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      session.status.toUpperCase(),
                      style: InstrumentTheme.microLabel(
                        context,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
              ],
            ],
          ),
          SizedBox(height: dimensions.rowGap),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: InstrumentTheme.cardDecoration(
              context,
              color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
              radius: 10,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _MetricCell(
                        label: AppLocalizations.of(context).sessionStartedHeader,
                        value: _formatDate(session.startedAt),
                      ),
                    ),
                    SizedBox(width: dimensions.rowGap),
                    Expanded(
                      child: _MetricCell(
                        label: AppLocalizations.of(context).sessionFinishedHeader,
                        value: _formatDate(session.finishedAt),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _MetricCell(
                        label: AppLocalizations.of(context).sessionDurationHeader,
                        value: '${session.durationSeconds ?? 0} s',
                      ),
                    ),
                    SizedBox(width: dimensions.rowGap),
                    Expanded(
                      child: _MetricCell(
                        label: AppLocalizations.of(context).sessionCompletedSetsHeader,
                        value: '$completedSets',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return content;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: content,
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  final String label;
  final String value;

  const _MetricCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: InstrumentTheme.microLabel(context)),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: InstrumentTheme.tabular(
            theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700) ??
                const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
