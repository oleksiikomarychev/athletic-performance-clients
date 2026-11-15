import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/providers/chat_provider.dart';
import 'package:workout_app/widgets/instrument_modal.dart';

import 'mass_edit_tool_widget.dart';

class ScheduleShiftToolWidget extends ConsumerWidget {
  const ScheduleShiftToolWidget({super.key, required this.payload});

  final Map<String, dynamic> payload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mode = payload['mode']?.toString();
    final isPreview = mode == 'preview';

    final summaryRaw = payload['summary'];
    final summary = summaryRaw is Map<String, dynamic>
        ? summaryRaw
        : const <String, dynamic>{};

    final workoutsShifted =
        summary['workouts_shifted'] ?? summary['affected_count'];
    final days = payload['days'] ?? summary['days'];
    final actionType =
        (payload['action_type'] ?? summary['action_type'] ?? 'shift')
            .toString();
    final fromDate = payload['from_date']?.toString();
    final toDate = payload['to_date']?.toString();
    final onlyFuture = payload['only_future'] == true;
    final statusIn = payload['status_in'];

    final theme = Theme.of(context);
    final instrument = InstrumentTheme.of(context);
    final accent = isPreview
        ? instrument.workingAura
        : instrument.executionAccent;

    final headerPills = <Widget>[];
    if (workoutsShifted != null) {
      headerPills.add(
        InstrumentStatusPill(
          label: l10n.workoutsShifted(workoutsShifted.toString()),
          color: accent,
        ),
      );
    }
    if (days != null) {
      final numDays = days is num ? days.toInt() : int.tryParse(days.toString());
      final sign = (numDays ?? 0) > 0 ? '+' : '';
      headerPills.add(
        InstrumentStatusPill(
          label: l10n.shiftDays(sign, (numDays ?? days).toString()),
          color: instrument.moderateEffortColor,
        ),
      );
    }

    final filterLines = <String>[];
    if (fromDate != null && fromDate.isNotEmpty) {
      filterLines.add(l10n.startingFrom(fromDate));
    }
    if (toDate != null && toDate.isNotEmpty) {
      filterLines.add(l10n.upToDate(toDate));
    }
    if (actionType == 'set_rest') {
      filterLines.add(l10n.modeChangeIntervals);
    } else {
      filterLines.add(l10n.modeScheduleShift);
    }
    if (onlyFuture) {
      filterLines.add(l10n.onlyFutureWorkouts);
    }
    if (statusIn is List && statusIn.isNotEmpty) {
      filterLines.add(l10n.statuses(statusIn.join(', ')));
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (headerPills.isNotEmpty)
          Wrap(spacing: 8, runSpacing: 6, children: headerPills),
        if (filterLines.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            l10n.shiftParameters.toUpperCase(),
            style: InstrumentTheme.microLabel(context, color: accent),
          ),
          const SizedBox(height: 4),
          ...filterLines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: theme.textTheme.bodySmall),
                  Expanded(
                    child: Text(
                      line,
                      style: InstrumentTheme.tabular(
                        theme.textTheme.bodySmall ?? const TextStyle(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );

    final List<Widget> actions = [];
    final command = payload['schedule_shift_command'];
    if (isPreview && command is Map<String, dynamic>) {
      actions.add(
        InstrumentActionButton(
          label: l10n.apply,
          icon: Icons.check_rounded,
          variant: InstrumentActionVariant.primary,
          accentColor: instrument.workingAura,
          onPressed: () {
            ref
                .read(chatControllerProvider.notifier)
                .applyScheduleShiftFromPreview(payload);
          },
        ),
      );
    }

    final titleText = isPreview
        ? l10n.scheduleShiftPreviewTitle
        : l10n.scheduleShiftTitle;

    return ToolResultCard(
      title: titleText,
      icon: Icons.calendar_today_rounded,
      content: content,
      actions: actions,
      isPreview: isPreview,
    );
  }
}
