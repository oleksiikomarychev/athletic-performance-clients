import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/models/macro.dart';
import 'package:workout_app/providers/macro_providers.dart';
import 'package:workout_app/providers/plan_providers.dart';
import 'package:workout_app/screens/macros/macro_editor_screen.dart';
import 'package:workout_app/screens/macros/macros_preview_screen.dart';
import 'package:workout_app/src/widgets/snack_utils.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/empty_state.dart';
import 'package:workout_app/widgets/instrument_modal.dart';
import 'package:workout_app/widgets/interface_maker_sheet.dart';
import 'package:workout_app/widgets/loading_indicator.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';

enum _MacroFilter { all, active, paused }

class MacrosListScreen extends ConsumerStatefulWidget {
  final int calendarPlanId;
  const MacrosListScreen({super.key, required this.calendarPlanId});

  @override
  ConsumerState<MacrosListScreen> createState() => _MacrosListScreenState();
}

class _MacrosListScreenState extends ConsumerState<MacrosListScreen> {
  _MacroFilter _filter = _MacroFilter.all;

  Future<void> _openPreview() async {
    final active = await ref.read(activeAppliedPlanSWRProvider.future);
    final id = active?.id;
    if (!mounted) return;
    if (id == null) {
      showAppSnackBar(
        context,
        AppLocalizations.of(context).activePlanNotFound,
      );
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MacrosPreviewScreen(appliedPlanId: id)),
    );
  }

  Future<void> _createMacro() async {
    await Navigator.of(context).push<PlanMacro>(
      MaterialPageRoute(
        builder: (_) => MacroEditorScreen(
          initial: PlanMacro(
            calendarPlanId: widget.calendarPlanId,
            name: '',
            isActive: true,
            priority: 100,
            rule: MacroRule.empty(),
          ),
          calendarPlanId: widget.calendarPlanId,
        ),
      ),
    );
  }

  Future<void> _openEditor(PlanMacro macro) async {
    await Navigator.of(context).push<PlanMacro>(
      MaterialPageRoute(
        builder: (_) => MacroEditorScreen(
          initial: macro,
          calendarPlanId: widget.calendarPlanId,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(PlanMacro macro) async {
    final l10n = AppLocalizations.of(context);
    final instrument = InstrumentTheme.of(context);
    final confirm = await showInstrumentDialog<bool>(
      context: context,
      eyebrow: l10n.removeRuleEyebrow,
      title: l10n.deleteMacroTitle,
      message: l10n.deleteExerciseConfirmBody(macro.name),
      accentColor: instrument.peakEffortColor,
      actionsBuilder: (ctx) => [
        InstrumentActionButton(
          label: l10n.cancel,
          variant: InstrumentActionVariant.secondary,
          onPressed: () => Navigator.of(ctx).pop(false),
        ),
        InstrumentActionButton(
          label: l10n.delete,
          variant: InstrumentActionVariant.destructive,
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
      ],
    );
    if (confirm == true && macro.id != null) {
      await ref
          .read(macrosNotifierProvider(widget.calendarPlanId).notifier)
          .delete(macro.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(macrosNotifierProvider(widget.calendarPlanId));
    final notifier =
        ref.read(macrosNotifierProvider(widget.calendarPlanId).notifier);
    final topInset = AmbientScaffoldShell.topContentInset(context);
    final bottomInset = AmbientScaffoldShell.bottomContentInset(context);

    final filtered = state.items.where((m) {
      switch (_filter) {
        case _MacroFilter.all:
          return true;
        case _MacroFilter.active:
          return m.isActive;
        case _MacroFilter.paused:
          return !m.isActive;
      }
    }).toList(growable: false);

    return AssistantChatHost(
      builder: (context, openChat) {
        final l10n = AppLocalizations.of(context);
        final instrument = InstrumentTheme.of(context);
        return AmbientScaffoldShell(
          appBar: PrimaryAppBar(
            title: l10n.planMacrosTitle,
            onTitleTap: openChat,
            showBack: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.visibility_outlined),
                tooltip: l10n.previewApplyTooltip,
                onPressed: _openPreview,
              ),
              IconButton(
                icon: const Icon(Icons.add_rounded),
                tooltip: l10n.addMacroLabel,
                onPressed: _createMacro,
              ),
            ],
          ),
          body: RefreshIndicator(
            color: instrument.workingAura,
            onRefresh: () async => notifier.load(),
            child: state.loading
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(top: topInset, bottom: bottomInset),
                    children: const [
                      SizedBox(height: 160),
                      Center(child: LoadingIndicator()),
                    ],
                  )
                : state.items.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          16,
                          topInset + 24,
                          16,
                          bottomInset + 24,
                        ),
                        children: [
                          EmptyState(
                            icon: Icons.auto_fix_high_rounded,
                            title: l10n.noMacrosYet,
                            description:
                                'Create rule-based automation to adapt loads, reps, sets, or mesocycles.',
                            action: InstrumentActionButton(
                              label: l10n.addMacroLabel,
                              icon: Icons.add_rounded,
                              onPressed: _createMacro,
                            ),
                          ),
                        ],
                      )
                    : ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          16,
                          topInset + 8,
                          16,
                          bottomInset + 24,
                        ),
                        children: [
                          CanvasPillStrip(
                            padding: EdgeInsets.zero,
                            items: [
                              CanvasPillItem(
                                label: l10n.allCountLabel(state.items.length),
                                selected: _filter == _MacroFilter.all,
                                onTap: () =>
                                    setState(() => _filter = _MacroFilter.all),
                              ),
                              CanvasPillItem(
                                label:
                                    'Active (${state.items.where((m) => m.isActive).length})',
                                selected: _filter == _MacroFilter.active,
                                accentColor: instrument.successColor,
                                onTap: () => setState(
                                  () => _filter = _MacroFilter.active,
                                ),
                              ),
                              CanvasPillItem(
                                label:
                                    'Paused (${state.items.where((m) => !m.isActive).length})',
                                selected: _filter == _MacroFilter.paused,
                                accentColor: instrument.moderateEffortColor,
                                onTap: () => setState(
                                  () => _filter = _MacroFilter.paused,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          if (filtered.isEmpty)
                            EmptyState(
                              icon: Icons.filter_list_off_rounded,
                              title: l10n.noMatchingMacros,
                              description: l10n.switchFilterToViewRules,
                            )
                          else
                            for (int i = 0; i < filtered.length; i++) ...[
                              if (i > 0) const SizedBox(height: 12),
                              _MacroRuleCard(
                                macro: filtered[i],
                                onTap: () => _openEditor(filtered[i]),
                                onEdit: () => _openEditor(filtered[i]),
                                onDelete: () => _confirmDelete(filtered[i]),
                              ),
                            ],
                        ],
                      ),
          ),
        );
      },
    );
  }
}

class _MacroRuleCard extends StatelessWidget {
  final PlanMacro macro;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MacroRuleCard({
    required this.macro,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  String _scopeLine() {
    final metric = (macro.rule.trigger['metric'] ?? '').toString();
    final op = (macro.rule.condition['op'] ?? '').toString();
    final actionType = (macro.rule.action['type'] ?? '').toString();
    final parts = [
      if (metric.isNotEmpty) metric,
      if (op.isNotEmpty) op,
      if (actionType.isNotEmpty) actionType,
    ];
    if (parts.isEmpty) return 'Rule definition pending';
    return parts.join(' → ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final statusColor = macro.isActive
        ? instrument.successColor
        : scheme.onSurfaceVariant;

    return Container(
      decoration: InstrumentTheme.instrumentCardDecoration(
        context,
        accentColor: macro.isActive ? instrument.workingAura : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PRIORITY #${macro.priority} · ${macro.isActive ? 'ACTIVE' : 'PAUSED'}',
                          style: InstrumentTheme.microLabel(
                            context,
                            color: statusColor,
                          ).copyWith(
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          macro.name.isEmpty ? 'Untitled macro' : macro.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: scheme.onSurfaceVariant,
                    ),
                    tooltip: AppLocalizations.of(context).edit,
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: instrument.peakEffortColor,
                    ),
                    tooltip: AppLocalizations.of(context).delete,
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ),
            Container(height: 1, color: instrument.hairlineBorder),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _scopeLine(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '#${macro.id ?? '-'}',
                    style: InstrumentTheme.microLabel(
                      context,
                      color: scheme.onSurfaceVariant,
                    ).copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
