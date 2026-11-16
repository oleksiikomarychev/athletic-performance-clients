import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/providers/target_data_providers.dart';
import 'package:workout_app/widgets/instrument_modal.dart';

class TriggerBuilder extends ConsumerStatefulWidget {
  final Map<String, dynamic> initial;
  final ValueChanged<Map<String, dynamic>> onChanged;
  const TriggerBuilder({
    super.key,
    required this.initial,
    required this.onChanged,
  });

  @override
  ConsumerState<TriggerBuilder> createState() => _TriggerBuilderState();
}

class _TriggerBuilderState extends ConsumerState<TriggerBuilder> {
  late String _metric;
  final Set<int> _selectedExerciseIds = {};

  @override
  void initState() {
    super.initState();
    _metric = (widget.initial['metric'] ?? '').toString();

    if (widget.initial['exercise_id'] is int) {
      _selectedExerciseIds.add(widget.initial['exercise_id'] as int);
    }
    if (widget.initial['exercise_ids'] is List) {
      for (final e in (widget.initial['exercise_ids'] as List)) {
        final id = int.tryParse(e.toString());
        if (id != null) _selectedExerciseIds.add(id);
      }
    }
  }

  void _emit() {
    final map = <String, dynamic>{'metric': _metric};
    if (_selectedExerciseIds.isNotEmpty) {
      map['exercise_ids'] = _selectedExerciseIds.toList();
    }
    widget.onChanged(map);
  }

  String? _metricTooltip(String metric, AppLocalizations l10n) {
    switch (metric) {
      case 'Readiness_Score':
        return l10n.macroTriggerHelpReadiness;
      case 'RPE_Session':
        return l10n.macroTriggerHelpSessionRpe;
      case 'Total_Reps':
        return l10n.macroTriggerHelpReps;
      case 'e1RM':
        return l10n.macroTriggerHelpE1rm;
      case 'Performance_Trend':
        return l10n.macroTriggerHelpTrend;
      case 'RPE_Delta_From_Plan':
        return l10n.macroTriggerHelpRpeDelta;
      case 'Reps_Delta_From_Plan':
        return l10n.macroTriggerHelpRepsDelta;
    }
    return null;
  }

  String _metricHelp(String metric, AppLocalizations l10n) {
    switch (metric) {
      case 'Readiness_Score':
        return l10n.macroTriggerHintReadiness;
      case 'RPE_Session':
        return l10n.macroTriggerHintSessionRpe;
      case 'Total_Reps':
        return l10n.macroTriggerHintReps;
      case 'e1RM':
        return l10n.macroTriggerHintE1rm;
      case 'Performance_Trend':
        return l10n.macroTriggerHintTrend;
      case 'RPE_Delta_From_Plan':
        return l10n.macroTriggerHintRpeDelta;
      case 'Reps_Delta_From_Plan':
        return l10n.macroTriggerHintRepsDelta;
    }
    return '';
  }

  bool get _metricNeedsExercises =>
      _metric == 'Total_Reps' ||
      _metric == 'e1RM' ||
      _metric == 'Performance_Trend' ||
      _metric == 'RPE_Delta_From_Plan' ||
      _metric == 'Reps_Delta_From_Plan';

  Future<void> _openExercisePicker() async {
    final l10n = AppLocalizations.of(context);
    final defs = await ref.read(exerciseDefinitionsProvider.future);
    if (!mounted) return;

    final temp = <int>{..._selectedExerciseIds};
    String searchQuery = '';

    final confirmed = await showInstrumentBottomSheet<bool>(
      context: context,
      eyebrow: 'TRIGGER SCOPE',
      title: l10n.planDetailSelectExercises,
      heightFactor: 0.85,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            final theme = Theme.of(ctx);
            final scheme = theme.colorScheme;
            final instrument = InstrumentTheme.of(ctx);
            final filtered = defs
                .where(
                  (d) =>
                      d.name.toLowerCase().contains(searchQuery.toLowerCase()),
                )
                .toList();

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  decoration: InstrumentTheme.inputDecoration(
                    ctx,
                    hintText: l10n.search,
                    prefixIcon: const Icon(Icons.search_rounded),
                  ),
                  onChanged: (v) => setLocal(() => searchQuery = v),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: (MediaQuery.sizeOf(ctx).height * 0.45)
                        .clamp(180.0, 380.0),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => Container(
                      height: 1,
                      color: instrument.hairlineBorder,
                    ),
                    itemBuilder: (ctx, idx) {
                      final def = filtered[idx];
                      final id = def.id;
                      if (id == null) return const SizedBox.shrink();
                      final sel = temp.contains(id);
                      return InkWell(
                        onTap: () {
                          setLocal(() {
                            if (sel) {
                              temp.remove(id);
                            } else {
                              temp.add(id);
                            }
                          });
                        },
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 52),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        def.name,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: sel
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: sel
                                              ? instrument.workingAura
                                              : scheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        l10n.idPrefix(id.toString()),
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                          fontFeatures: const [
                                            FontFeature.tabularFigures(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  sel
                                      ? Icons.check_circle_rounded
                                      : Icons.circle_outlined,
                                  size: 20,
                                  color: sel
                                      ? instrument.workingAura
                                      : scheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    InstrumentActionButton(
                      label: l10n.cancel,
                      variant: InstrumentActionVariant.secondary,
                      onPressed: () => Navigator.of(ctx).pop(false),
                    ),
                    InstrumentActionButton(
                      label: l10n.done,
                      variant: InstrumentActionVariant.primary,
                      onPressed: () => Navigator.of(ctx).pop(true),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true && mounted) {
      setState(() {
        _selectedExerciseIds
          ..clear()
          ..addAll(temp);
      });
      _emit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final defsAsync = ref.watch(exerciseDefinitionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _metric.isEmpty ? null : _metric,
          isExpanded: true,
          items: [
            DropdownMenuItem(
              value: 'Readiness_Score',
              child: Text(l10n.macroTriggerMetricReadiness),
            ),
            DropdownMenuItem(
              value: 'RPE_Session',
              child: Text(l10n.macroTriggerMetricRpeSession),
            ),
            DropdownMenuItem(
              value: 'Total_Reps',
              child: Text(l10n.macroTriggerMetricTotalReps),
            ),
            DropdownMenuItem(
              value: 'e1RM',
              child: Text(l10n.macroTriggerMetricE1rm),
            ),
            DropdownMenuItem(
              value: 'Performance_Trend',
              child: Text(l10n.macroTriggerMetricPerformanceTrend),
            ),
            DropdownMenuItem(
              value: 'RPE_Delta_From_Plan',
              child: Text(l10n.macroTriggerMetricRpeDelta),
            ),
            DropdownMenuItem(
              value: 'Reps_Delta_From_Plan',
              child: Text(l10n.macroTriggerMetricRepsDelta),
            ),
          ],
          decoration: InstrumentTheme.inputDecoration(
            context,
            labelText: l10n.macroTriggerMetricLabel,
          ),
          onChanged: (v) {
            setState(() => _metric = v ?? '');
            _emit();
          },
          validator: (v) => (v == null || v.isEmpty) ? l10n.fieldRequired : null,
        ),
        if (_metric.isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _metricTooltip(_metric, l10n) ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _metricHelp(_metric, l10n),
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
        if (_metricNeedsExercises) ...[
          const SizedBox(height: 12),
          Text(
            l10n.macroTriggerSelectExercisesHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              InstrumentActionButton(
                label: l10n.planDetailSelectExercises,
                icon: Icons.list_alt_rounded,
                variant: InstrumentActionVariant.secondary,
                loading: defsAsync.isLoading,
                onPressed: defsAsync.isLoading ? null : _openExercisePicker,
              ),
            ],
          ),
          if (_selectedExerciseIds.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedExerciseIds
                  .map(
                    (id) => InstrumentSelectablePill(
                      label: l10n.idPrefix(id.toString()),
                      selected: true,
                      bordered: false,
                      accentColor: instrument.workingAura,
                      icon: Icons.close_rounded,
                      onTap: () {
                        setState(() => _selectedExerciseIds.remove(id));
                        _emit();
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ],
    );
  }
}
