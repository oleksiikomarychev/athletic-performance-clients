import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_app/config/api_config.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/providers/macro_context_providers.dart';
import 'package:workout_app/providers/macro_preview_providers.dart';
import 'package:workout_app/services/api_client.dart';
import 'package:workout_app/services/macro_service.dart';
import 'package:workout_app/src/widgets/snack_utils.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/instrument_modal.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';

Future<void> showSessionMacroSuggestion(
  BuildContext context,
  ApiClient api,
  int workoutId,
  int planId,
) async {
  try {
    final endpoint = ApiConfig.macroSuggestionEndpoint(workoutId.toString());
    final suggestion =
        await api.get(endpoint, context: 'MacroSuggestion') as Map?;
    final stored = suggestion?['macro_preview'] as Map?;
    final preview = stored != null && stored['contract_version'] == 2
        ? Map<String, dynamic>.from(stored)
        : await MacroService(
            apiClient: api,
          ).runPreview(appliedPlanId: planId, observationWorkoutId: workoutId);
    final items = (preview['preview'] as List? ?? []).whereType<Map>();
    final inserts = items
        .expand((item) => item['plan_changes'] as List? ?? [])
        .length;
    final patches = items
        .expand((item) => item['patches'] as List? ?? [])
        .length;
    final missing =
        (preview['needs_weight_settings'] as List? ?? []).isNotEmpty;
    if (!context.mounted || (!missing && patches == 0 && inserts == 0)) return;
    final l10n = AppLocalizations.of(context);
    final summary = [
      if (patches > 0) l10n.macroPreviewSetChangesCount(patches),
      if (inserts > 0) l10n.macroPreviewMesoInsertsCount(inserts),
      if (missing) l10n.macroPreviewMissingParamsHint,
    ].join('\n');

    final open = await showInstrumentDialog<bool>(
      context: context,
      eyebrow: l10n.macroSuggestionsEyebrow,
      title: l10n.macroPreviewDialogTitle,
      message: summary,
      actionsBuilder: (dialogContext) {
        final dL10n = AppLocalizations.of(dialogContext);
        return [
          InstrumentActionButton(
            label: dL10n.cancel,
            variant: InstrumentActionVariant.secondary,
            onPressed: () => Navigator.pop(dialogContext, false),
          ),
          InstrumentActionButton(
            label: dL10n.macroPreviewViewChanges,
            variant: InstrumentActionVariant.primary,
            onPressed: () => Navigator.pop(dialogContext, true),
          ),
        ];
      },
    );
    if (open == true && context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => MacrosPreviewScreen(
            appliedPlanId: planId,
            observationWorkoutId: workoutId,
            initialPreview: preview,
          ),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      showAppSnackBar(
        context,
        AppLocalizations.of(context).macroPreviewLoadError(e.toString()),
        isError: true,
      );
    }
  }
}

class MacrosPreviewScreen extends ConsumerStatefulWidget {
  final int appliedPlanId;
  final int? observationWorkoutId;
  final Map<String, dynamic>? initialPreview;
  const MacrosPreviewScreen({
    super.key,
    required this.appliedPlanId,
    this.initialPreview,
    this.observationWorkoutId,
  });

  @override
  ConsumerState<MacrosPreviewScreen> createState() =>
      _MacrosPreviewScreenState();
}

String _values(Map set, AppLocalizations l10n) {
  final parts = set['subsets'];
  if (parts is List && parts.isNotEmpty) {
    return '${set['set_type'] ?? ''} [${parts.whereType<Map>().map((m) => _values(m, l10n)).join(' / ')}]';
  }
  final volume = set['volume'] ?? set['reps'];
  final effort = set['effort'] ?? set['rpe'];
  final weight = set['working_weight'] ?? set['weight'];
  return [
    if (volume != null) l10n.unitRepsShort(volume.toString()),
    if (set['intensity'] != null) "${set['intensity']}%",
    if (effort != null) 'RPE $effort',
    if (weight != null) l10n.unitKgValue(weight.toString()),
  ].join(', ');
}

class _MacrosPreviewScreenState extends ConsumerState<MacrosPreviewScreen> {
  final _maxima = <String, double>{};
  double? _step = 2.5;
  String _rounding = 'nearest';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final notifier = ref.read(
        macroPreviewNotifierProvider(widget.appliedPlanId).notifier,
      );
      final stored = widget.initialPreview;
      if (stored != null &&
          stored['applied_plan_id'] == widget.appliedPlanId) {
        notifier.show(stored);
      } else {
        notifier.runPreview(
          widget.appliedPlanId,
          observationWorkoutId: widget.observationWorkoutId,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.appliedPlanId;
    final state = ref.watch(macroPreviewNotifierProvider(id));
    final notifier = ref.read(macroPreviewNotifierProvider(id).notifier);
    final names = ref.watch(previewContextProvider(id)).asData?.value;
    final preview = state.preview;
    final missing = (preview?['needs_weight_settings'] as List? ?? [])
        .whereType<int>()
        .toList();
    final anchor =
        preview?['observation_workout_id'] as int? ??
        widget.observationWorkoutId;
    final supported = preview?['contract_version'] == 2;
    final items = (preview?['preview'] as List? ?? []).whereType<Map>();
    final changes = state.applyResult?['apply_result'];
    final mesoResults = state.applyResult?['plan_changes'] as List? ?? [];
    final hasMesos = items.any(
      (item) => (item['plan_changes'] as List? ?? []).isNotEmpty,
    );
    final canApply = supported && !state.loading;

    return AssistantChatHost(
      builder: (context, openChat) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final instrument = InstrumentTheme.of(context);
        final topInset = AmbientScaffoldShell.topContentInset(context);
        final bottomInset = AmbientScaffoldShell.bottomContentInset(context);

        final l10n = AppLocalizations.of(context);
        return AmbientScaffoldShell(
          appBar: PrimaryAppBar(
            title: l10n.macroPreviewAppBarTitle,
            onTitleTap: openChat,
            showBack: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: l10n.refresh,
                onPressed: state.loading
                    ? null
                    : () => notifier.runPreview(
                        id,
                        observationWorkoutId: anchor,
                      ),
              ),
            ],
          ),
          body: ListView(
            padding: EdgeInsets.fromLTRB(
              16,
              topInset + 8,
              16,
              bottomInset + 28,
            ),
            children: [
              if (state.loading) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    color: instrument.workingAura,
                    backgroundColor: instrument.hairlineBorder,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (state.error != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: InstrumentTheme.instrumentCardDecoration(
                    context,
                    accentColor: instrument.peakEffortColor,
                  ),
                  child: Text(
                    state.error!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: instrument.peakEffortColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (preview != null && !supported) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: InstrumentTheme.instrumentCardDecoration(
                    context,
                    accentColor: instrument.moderateEffortColor,
                  ),
                  child: Text(
                    l10n.macroPreviewConfirmNeedsNewServer,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: instrument.moderateEffortColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (anchor != null) ...[
                Text(
                  l10n.macroPreviewObservationWorkout(anchor.toString()),
                  style: InstrumentTheme.microLabel(
                    context,
                    color: instrument.workingAura,
                  ).copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (missing.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: InstrumentTheme.instrumentCardDecoration(
                    context,
                    accentColor: instrument.moderateEffortColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'WEIGHT CALIBRATION REQUIRED',
                        style: InstrumentTheme.microLabel(
                          context,
                          color: instrument.moderateEffortColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.macroPreviewSpecifyWeightParams,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      for (final eid in missing) ...[
                        TextFormField(
                          key: ValueKey(eid),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                          decoration: InstrumentTheme.inputDecoration(
                            context,
                            labelText: l10n.macroPreviewOneRmKgForExercise(
                              names?.exerciseNames[eid] ?? "#$eid",
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (v) => setState(() {
                            final n = double.tryParse(v.replaceAll(',', '.'));
                            if (n != null && n.isFinite && n > 0) {
                              _maxima['$eid'] = n;
                            } else {
                              _maxima.remove('$eid');
                            }
                          }),
                        ),
                        const SizedBox(height: 10),
                      ],
                      TextFormField(
                        initialValue: _step?.toString(),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                        decoration: InstrumentTheme.inputDecoration(
                          context,
                          labelText: l10n.macroPreviewWeightStepKg,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (v) => setState(
                          () => _step = double.tryParse(v.replaceAll(',', '.')),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.applyPlanRoundingHeader,
                        style: InstrumentTheme.microLabel(context),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          InstrumentSelectablePill(
                            label: l10n.macroPreviewRoundNearest,
                            selected: _rounding == 'nearest',
                            bordered: false,
                            onTap: () => setState(() => _rounding = 'nearest'),
                          ),
                          InstrumentSelectablePill(
                            label: l10n.macroPreviewRoundDown,
                            selected: _rounding == 'floor',
                            bordered: false,
                            onTap: () => setState(() => _rounding = 'floor'),
                          ),
                          InstrumentSelectablePill(
                            label: l10n.macroPreviewRoundUp,
                            selected: _rounding == 'ceil',
                            bordered: false,
                            onTap: () => setState(() => _rounding = 'ceil'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      InstrumentActionButton(
                        label: l10n.macroPreviewCalcButton,
                        icon: Icons.calculate_outlined,
                        expanded: true,
                        onPressed:
                            !missing.every((e) => _maxima.containsKey('$e')) ||
                                _step == null ||
                                !_step!.isFinite ||
                                _step! < 0
                            ? null
                            : () => notifier.runPreview(
                                id,
                                observationWorkoutId: anchor,
                                legacyWeights: {
                                  'effective_maxima': _maxima,
                                  'rounding_step': _step,
                                  'rounding_mode': _rounding,
                                },
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (supported &&
                  missing.isEmpty &&
                  preview?['set_changes_count'] == 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: InstrumentTheme.instrumentCardDecoration(context),
                  child: Text(l10n.macroPreviewNoSetChanges),
                ),
              for (final item in items) ...[
                _MacroDiffGroupCard(
                  item: item,
                  names: names,
                ),
                const SizedBox(height: 12),
              ],
              if (changes is Map && mesoResults.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: InstrumentTheme.instrumentCardDecoration(
                    context,
                    accentColor: instrument.successColor,
                  ),
                  child: Text(
                    l10n.macroPreviewExercisesModified(
                      (changes['applied'] ?? 0).toString(),
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: instrument.successColor,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              for (final result in mesoResults.whereType<Map>()) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: InstrumentTheme.instrumentCardDecoration(
                    context,
                    accentColor: result['applied'] == true
                        ? instrument.successColor
                        : instrument.peakEffortColor,
                  ),
                  child: Text(
                    result['applied'] == true
                        ? l10n.macroPreviewMesoAdded
                        : l10n.macroPreviewMesoNotAdded(
                            (result['reason'] ?? '').toString(),
                          ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: result['applied'] == true
                          ? instrument.successColor
                          : instrument.peakEffortColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (preview?['preview_id'] != null) ...[
                InstrumentActionButton(
                  label: l10n.macroPreviewConfirmSetsButton,
                  icon: Icons.check_circle_outline_rounded,
                  expanded: true,
                  accentColor: instrument.executionAccent,
                  onPressed: canApply && changes == null
                      ? () => notifier.apply(id)
                      : null,
                ),
                const SizedBox(height: 10),
              ],
              if (hasMesos)
                InstrumentActionButton(
                  label: l10n.macroPreviewApplyMesoRulesButton,
                  icon: Icons.layers_outlined,
                  variant: InstrumentActionVariant.secondary,
                  expanded: true,
                  onPressed: canApply && mesoResults.isEmpty
                      ? () => notifier.apply(id, mesocyclesOnly: true)
                      : null,
                ),
              const SizedBox(height: 4),
              if (changes != null)
                Text(
                  l10n.macroPreviewAppliedToActivePlan(id.toString()),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MacroDiffGroupCard extends StatelessWidget {
  final Map item;
  final PreviewContextData? names;

  const _MacroDiffGroupCard({
    required this.item,
    required this.names,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final patches = (item['patches'] as List? ?? []).whereType<Map>().toList();
    final planChanges =
        (item['plan_changes'] as List? ?? []).whereType<Map>().toList();

    return Container(
      decoration: InstrumentTheme.instrumentCardDecoration(
        context,
        accentColor: instrument.workingAura,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DRY-RUN DIFF',
                        style: InstrumentTheme.microLabel(
                          context,
                          color: instrument.workingAura,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['name'].toString(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${patches.length + planChanges.length}',
                  style: InstrumentTheme.microLabel(
                    context,
                    color: instrument.workingAura,
                  ).copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          for (final p in patches) ...[
            Container(height: 1, color: instrument.hairlineBorder),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${names?.workoutNames[p['workout_id']] ?? '#${p['workout_id']}'} · "
                    "${names?.exerciseNames[p['exercise_id']] ?? '#${p['exercise_id']}'} · "
                    "${(p['set_id'] as int? ?? 0) < 0 ? AppLocalizations.of(context).macroPreviewInstanceNewSet((p['instance_id'] ?? '').toString()) : AppLocalizations.of(context).macroPreviewInstanceSet((p['instance_id'] ?? '').toString(), (p['set_id'] ?? '').toString())}",
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (p['before'] is Map)
                    Text(
                      AppLocalizations.of(context).macroPreviewBefore(
                        _values(p['before'], AppLocalizations.of(context)),
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  for (final a
                      in (p['alternatives'] as List? ?? []).whereType<Map>()) ...[
                    Text(
                      AppLocalizations.of(context).macroPreviewRequested(
                        _values(a['requested'], AppLocalizations.of(context)),
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: instrument.moderateEffortColor,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context).macroPreviewClosestOption(
                        _values(a['proposed'], AppLocalizations.of(context)),
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: instrument.workingAura,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                  if (p['after'] is Map)
                    Text(
                      AppLocalizations.of(context).macroPreviewAfter(
                        _values(p['after'], AppLocalizations.of(context)),
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: instrument.successColor,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    )
                  else
                    Text(
                      AppLocalizations.of(context).macroPreviewDeleteSet,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: instrument.peakEffortColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ],
          for (final ch in planChanges) ...[
            Container(height: 1, color: instrument.hairlineBorder),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Text(
                AppLocalizations.of(context).macroPreviewMesoInsertParams(
                  (ch['params'] ?? '').toString(),
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: instrument.deloadAura,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
