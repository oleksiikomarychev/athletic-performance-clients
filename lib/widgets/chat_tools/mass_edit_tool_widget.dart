import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/providers/chat_provider.dart';
import 'package:workout_app/providers/target_data_providers.dart';
import 'package:workout_app/widgets/instrument_modal.dart';

class ToolResultCard extends ConsumerWidget {
  const ToolResultCard({
    super.key,
    required this.title,
    required this.icon,
    required this.content,
    this.actions,
    this.isPreview = false,
  });

  final String title;
  final IconData icon;
  final Widget content;
  final List<Widget>? actions;
  final bool isPreview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final accent = isPreview
        ? instrument.workingAura
        : instrument.executionAccent;
    final hairline =
        (isDark ? instrument.hairlineBorder : scheme.outlineVariant)
            .withValues(alpha: isDark ? 0.85 : 0.55);

    return Container(
      decoration: InstrumentTheme.instrumentCardDecoration(
        context,
        accentColor: accent,
        radius: 20,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                Icon(icon, size: 18, color: accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isPreview ? 'TOOL PREVIEW' : 'TOOL APPLIED',
                        style: InstrumentTheme.microLabel(
                          context,
                          color: accent,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: hairline),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: content,
          ),
          Container(height: 1, color: hairline),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                InstrumentActionButton(
                  label: l10n.hide,
                  icon: Icons.close_rounded,
                  variant: InstrumentActionVariant.secondary,
                  onPressed: () {
                    ref
                        .read(chatControllerProvider.notifier)
                        .clearMassEditResult();
                  },
                ),
                if (actions != null) ...actions!,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MassEditToolWidget extends ConsumerWidget {
  const MassEditToolWidget({super.key, required this.payload});

  final Map<String, dynamic> payload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mode = payload['mode']?.toString();
    final isPreview = mode == 'preview';
    final exerciseNameMap = ref.watch(exerciseDefinitionNameMapProvider);

    final summaryRaw = payload['summary'];
    final summary = summaryRaw is Map<String, dynamic>
        ? summaryRaw
        : <String, dynamic>{};
    final commandRaw = payload['mass_edit_command'];
    final command = commandRaw is Map<String, dynamic>
        ? commandRaw
        : <String, dynamic>{};
    final filterRaw = command['filter'];
    final filter = filterRaw is Map<String, dynamic>
        ? filterRaw
        : <String, dynamic>{};
    final actionsRaw = command['actions'];
    final actions = actionsRaw is Map<String, dynamic>
        ? actionsRaw
        : <String, dynamic>{};

    final workoutsMatched =
        summary['workouts_matched'] ?? summary['workouts_shifted'];
    final setsMatched = summary['sets_matched'];
    final setsModified = summary['sets_modified'];

    final dynamic setsCount = isPreview
        ? (setsMatched ?? setsModified)
        : (setsModified ?? setsMatched);

    final filterLines = <String>[];
    final onlyFuture = filter['only_future'] == true;
    final scheduledFrom = filter['scheduled_from']?.toString();
    final scheduledTo = filter['scheduled_to']?.toString();
    final statusIn = filter['status_in'];
    final exerciseIds = filter['exercise_definition_ids'];

    if (onlyFuture) filterLines.add(l10n.onlyFutureWorkouts);
    if (scheduledFrom != null && scheduledFrom.isNotEmpty) {
      filterLines.add(l10n.dateNotEarlierThan(scheduledFrom));
    }
    if (scheduledTo != null && scheduledTo.isNotEmpty) {
      filterLines.add(l10n.dateNotLaterThan(scheduledTo));
    }
    if (statusIn is List && statusIn.isNotEmpty) {
      filterLines.add(l10n.statuses(statusIn.join(', ')));
    }

    if (exerciseIds is List && exerciseIds.isNotEmpty) {
      final names = <String>[];
      for (final rawId in exerciseIds) {
        final id = rawId is num
            ? rawId.toInt()
            : int.tryParse(rawId.toString());
        if (id == null) continue;
        final name = exerciseNameMap[id];
        if (name != null && name.isNotEmpty) {
          names.add('$name (ID $id)');
        } else {
          names.add('ID $id');
        }
      }
      if (names.isNotEmpty) {
        filterLines.add(l10n.exercises(names.join(', ')));
      }
    }

    final actionLines = <String>[];
    void addActionLine(String key, String Function(num v) textBuilder) {
      final raw = actions[key];
      if (raw is num) {
        actionLines.add(textBuilder(raw));
      }
    }

    addActionLine('set_intensity', (v) => l10n.setIntensity(v.toString()));
    addActionLine(
      'increase_intensity_by',
      (v) => l10n.increaseIntensityBy(v.toString()),
    );
    addActionLine(
      'decrease_intensity_by',
      (v) => l10n.decreaseIntensityBy(v.toString()),
    );
    addActionLine('set_volume', (v) => l10n.setVolume(v.toStringAsFixed(0)));
    addActionLine(
      'increase_volume_by',
      (v) => l10n.increaseVolumeBy(v.toStringAsFixed(0)),
    );
    addActionLine(
      'decrease_volume_by',
      (v) => l10n.decreaseVolumeBy(v.toStringAsFixed(0)),
    );
    addActionLine('set_weight', (v) => l10n.setWeight(v.toString()));
    addActionLine(
      'increase_weight_by',
      (v) => l10n.increaseWeightBy(v.toString()),
    );
    addActionLine(
      'decrease_weight_by',
      (v) => l10n.decreaseWeightBy(v.toString()),
    );
    addActionLine('set_effort', (v) => l10n.setEffort(v.toString()));
    addActionLine(
      'increase_effort_by',
      (v) => l10n.increaseEffortBy(v.toString()),
    );
    addActionLine(
      'decrease_effort_by',
      (v) => l10n.decreaseEffortBy(v.toString()),
    );

    if (actions['clamp_non_negative'] == true) {
      actionLines.add(l10n.clampNonNegative);
    }

    final replaceId = actions['replace_exercise_definition_id_to'];
    if (replaceId is num) {
      final id = replaceId.toInt();
      final name = exerciseNameMap[id];
      if (name != null && name.isNotEmpty) {
        actionLines.add(l10n.replaceExerciseTo(name, id.toString()));
      } else {
        actionLines.add(l10n.replaceExerciseTo('', id.toString()));
      }
    }
    final replaceName = actions['replace_exercise_name_to']?.toString();
    if (replaceName != null && replaceName.isNotEmpty) {
      actionLines.add(l10n.renameExerciseTo(replaceName));
    }

    final addInstances = actions['add_exercise_instances'];
    if (addInstances is List && addInstances.isNotEmpty) {
      actionLines.add(l10n.addNewExercises(addInstances.length.toString()));
    }

    final theme = Theme.of(context);
    final instrument = InstrumentTheme.of(context);
    final accent = isPreview
        ? instrument.workingAura
        : instrument.executionAccent;

    final titleText = isPreview
        ? l10n.massEditPreviewTitle
        : l10n.massEditAppliedTitle;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (workoutsMatched != null || setsCount != null)
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (workoutsMatched != null)
                InstrumentStatusPill(
                  label: l10n.massEditToolWorkoutsMatched(
                    workoutsMatched.toString(),
                  ),
                  color: accent,
                ),
              if (setsCount != null)
                InstrumentStatusPill(
                  label: isPreview
                      ? l10n.massEditToolSetsToBeModified(setsCount.toString())
                      : l10n.massEditToolSetsModified(setsCount.toString()),
                  color: instrument.moderateEffortColor,
                ),
            ],
          ),
        if (filterLines.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            l10n.filter.toUpperCase(),
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
        if (actionLines.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            l10n.changes.toUpperCase(),
            style: InstrumentTheme.microLabel(context, color: accent),
          ),
          const SizedBox(height: 4),
          ...actionLines.map(
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

    final List<Widget> actionsList = [];
    if (isPreview && command.isNotEmpty) {
      actionsList.add(
        InstrumentActionButton(
          label: l10n.apply,
          icon: Icons.check_rounded,
          variant: InstrumentActionVariant.primary,
          accentColor: instrument.workingAura,
          onPressed: () {
            ref
                .read(chatControllerProvider.notifier)
                .applyMassEditFromPreview(payload);
          },
        ),
      );
    }

    return ToolResultCard(
      title: titleText,
      icon: Icons.auto_fix_high_rounded,
      content: content,
      actions: actionsList,
      isPreview: isPreview,
    );
  }
}
