import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/models/macro.dart';
import 'package:workout_app/providers/macro_providers.dart';
import 'package:workout_app/screens/macros/widgets/action_builder.dart';
import 'package:workout_app/screens/macros/widgets/condition_builder.dart';
import 'package:workout_app/screens/macros/widgets/duration_selector.dart';
import 'package:workout_app/screens/macros/widgets/macro_human_preview.dart';
import 'package:workout_app/screens/macros/widgets/trigger_builder.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/instrument_modal.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';

class MacroEditorScreen extends ConsumerStatefulWidget {
  final PlanMacro initial;
  final int calendarPlanId;
  const MacroEditorScreen({
    super.key,
    required this.initial,
    required this.calendarPlanId,
  });

  @override
  ConsumerState<MacroEditorScreen> createState() => _MacroEditorScreenState();
}

class _MacroEditorScreenState extends ConsumerState<MacroEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _priorityCtrl;
  late TextEditingController _ruleCtrl;
  bool _isActive = true;
  String? _error;
  bool _editRawJson = false;

  Map<String, dynamic> _trigger = {};
  Map<String, dynamic> _condition = {};
  Map<String, dynamic> _action = {};
  Map<String, dynamic> _duration = {'scope': 'Next_N_Workouts', 'count': 1};

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initial.name);
    _priorityCtrl = TextEditingController(
      text: widget.initial.priority.toString(),
    );
    _ruleCtrl = TextEditingController(
      text: const JsonEncoder.withIndent('  ').convert(
        widget.initial.rule.toJson(),
      ),
    );
    _isActive = widget.initial.isActive;
    _trigger = Map<String, dynamic>.from(widget.initial.rule.trigger);
    _condition = Map<String, dynamic>.from(widget.initial.rule.condition);
    _action = Map<String, dynamic>.from(widget.initial.rule.action);
    _duration = Map<String, dynamic>.from(
      widget.initial.rule.duration.isEmpty
          ? {'scope': 'Next_N_Workouts', 'count': 1}
          : widget.initial.rule.duration,
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priorityCtrl.dispose();
    _ruleCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);
    try {
      MacroRule rule;
      if (_editRawJson) {
        final Map<String, dynamic> ruleJson =
            jsonDecode(_ruleCtrl.text) as Map<String, dynamic>;
        rule = MacroRule.fromJson(ruleJson);
      } else {
        final built = {
          'trigger': _trigger,
          'condition': _condition,
          'action': _action,
          'duration': _duration,
        };
        rule = MacroRule.fromJson(built);
      }
      final priority = int.tryParse(_priorityCtrl.text) ?? 100;

      final notifier =
          ref.read(macrosNotifierProvider(widget.calendarPlanId).notifier);
      final draft = PlanMacro(
        id: widget.initial.id,
        calendarPlanId: widget.calendarPlanId,
        name: _nameCtrl.text.trim(),
        isActive: _isActive,
        priority: priority,
        rule: rule,
      );

      if (draft.id == null) {
        await notifier.create(draft);
      } else {
        await notifier.update(draft);
      }
      if (mounted) Navigator.of(context).pop(draft);
    } catch (e) {
      setState(() => _error = 'Некорректный JSON правила: $e');
    }
  }

  void _syncRulePreview() {
    if (_editRawJson) return;
    final built = {
      'trigger': _trigger,
      'condition': _condition,
      'action': _action,
      'duration': _duration,
    };
    _ruleCtrl.text = const JsonEncoder.withIndent('  ').convert(built);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(macrosNotifierProvider(widget.calendarPlanId));

    Map<String, dynamic> humanTrigger = _trigger;
    Map<String, dynamic> humanCondition = _condition;
    Map<String, dynamic> humanAction = _action;
    Map<String, dynamic> humanDuration = _duration;
    if (_editRawJson) {
      try {
        final parsed = jsonDecode(_ruleCtrl.text);
        if (parsed is Map) {
          final j = parsed.cast<String, dynamic>();
          if (j['trigger'] is Map) {
            humanTrigger = (j['trigger'] as Map).cast<String, dynamic>();
          }
          if (j['condition'] is Map) {
            humanCondition = (j['condition'] as Map).cast<String, dynamic>();
          }
          if (j['action'] is Map) {
            humanAction = (j['action'] as Map).cast<String, dynamic>();
          }
          if (j['duration'] is Map) {
            humanDuration = (j['duration'] as Map).cast<String, dynamic>();
          }
        }
      } catch (_) {}
    }

    final actionType = (_action['type'] ?? '').toString();
    final showDuration = actionType != 'Inject_Mesocycle';

    return AssistantChatHost(
      builder: (context, openChat) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final instrument = InstrumentTheme.of(context);
        final topInset = AmbientScaffoldShell.topContentInset(context);
        final bottomInset = AmbientScaffoldShell.bottomContentInset(context);

        return AmbientScaffoldShell(
          appBar: PrimaryAppBar(
            title: widget.initial.id == null
                ? 'Создать макрос'
                : 'Редактировать макрос',
            onTitleTap: openChat,
            showBack: true,
            actions: [
              IconButton(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                tooltip: 'Сохранить',
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                topInset + 8,
                16,
                bottomInset + 28,
              ),
              children: [
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: InstrumentTheme.instrumentCardDecoration(
                      context,
                      accentColor: instrument.peakEffortColor,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 18,
                          color: instrument.peakEffortColor,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _error!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: instrument.peakEffortColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                _MacroClauseCard(
                  eyebrow: 'RULE METADATA',
                  title: 'Параметры правила',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: InstrumentTheme.inputDecoration(
                          context,
                          labelText: 'Название',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Обязательно'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final stacked = constraints.maxWidth < 290;
                          final priorityField = TextFormField(
                            controller: _priorityCtrl,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                            decoration: InstrumentTheme.inputDecoration(
                              context,
                              labelText: 'Приоритет',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              final n = int.tryParse(v ?? '');
                              if (n == null) return 'Некорректное число';
                              if (n < 0 || n > 10000) return '0..10000';
                              return null;
                            },
                          );
                          final activeToggle = InkWell(
                            onTap: () =>
                                setState(() => _isActive = !_isActive),
                            borderRadius: BorderRadius.circular(12),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 48),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Активен',
                                      style: theme.textTheme.titleSmall,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Switch.adaptive(
                                    value: _isActive,
                                    activeThumbColor: instrument.workingAura,
                                    activeTrackColor: instrument.workingAura
                                        .withValues(alpha: 0.55),
                                    onChanged: (val) =>
                                        setState(() => _isActive = val),
                                  ),
                                ],
                              ),
                            ),
                          );
                          if (stacked) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                priorityField,
                                const SizedBox(height: 10),
                                activeToggle,
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(child: priorityField),
                              const SizedBox(width: 14),
                              activeToggle,
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _MacroClauseCard(
                  eyebrow: '01 · TRIGGER',
                  title: 'Триггер',
                  child: TriggerBuilder(
                    initial: _trigger,
                    onChanged: (v) {
                      setState(() => _trigger = v);
                      _syncRulePreview();
                    },
                  ),
                ),
                const SizedBox(height: 14),
                _MacroClauseCard(
                  eyebrow: '02 · CONDITION',
                  title: 'Условие',
                  child: ConditionBuilder(
                    initial: _condition,
                    metric: (_trigger['metric'] as String?),
                    onChanged: (v) {
                      setState(() => _condition = v);
                      _syncRulePreview();
                    },
                  ),
                ),
                const SizedBox(height: 14),
                _MacroClauseCard(
                  eyebrow: '03 · ACTION',
                  title: 'Действие',
                  child: ActionBuilder(
                    initial: _action,
                    onChanged: (v) {
                      setState(() => _action = v);
                      _syncRulePreview();
                    },
                  ),
                ),
                if (showDuration) ...[
                  const SizedBox(height: 14),
                  _MacroClauseCard(
                    eyebrow: '04 · DURATION',
                    title: 'Длительность',
                    child: DurationSelector(
                      initial: _duration,
                      onChanged: (v) {
                        setState(() => _duration = v);
                        _syncRulePreview();
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                _MacroClauseCard(
                  eyebrow: 'PLAIN-LANGUAGE READOUT',
                  title: 'Естественное описание',
                  accentColor: instrument.deloadAura,
                  child: MacroHumanPreview(
                    trigger: humanTrigger,
                    condition: humanCondition,
                    action: humanAction,
                    duration: humanDuration,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  decoration: InstrumentTheme.instrumentCardDecoration(context),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 12, 10),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          alignment: WrapAlignment.spaceBetween,
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CONTRACT PAYLOAD',
                                  style: InstrumentTheme.microLabel(context),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Редактировать JSON',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Switch.adaptive(
                              value: _editRawJson,
                              activeThumbColor: instrument.workingAura,
                              activeTrackColor: instrument.workingAura
                                  .withValues(alpha: 0.55),
                              onChanged: (v) => setState(() {
                                _editRawJson = v;
                                if (!v) _syncRulePreview();
                              }),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 1, color: instrument.hairlineBorder),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextFormField(
                          controller: _ruleCtrl,
                          readOnly: !_editRawJson,
                          maxLines: 14,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            color: _editRawJson
                                ? scheme.onSurface
                                : scheme.onSurfaceVariant,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                          decoration: InstrumentTheme.inputDecoration(
                            context,
                            labelText: 'Правило (предпросмотр JSON)',
                          ),
                          validator: (v) {
                            if (!_editRawJson) return null;
                            if (v == null || v.trim().isEmpty) {
                              return 'Обязательно';
                            }
                            try {
                              final parsed = jsonDecode(v);
                              if (parsed is! Map) {
                                return 'Должен быть JSON-объект';
                              }
                            } catch (_) {
                              return 'Некорректный JSON';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                InstrumentActionButton(
                  label: 'Сохранить',
                  icon: Icons.save_rounded,
                  expanded: true,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MacroClauseCard extends StatelessWidget {
  final String eyebrow;
  final String title;
  final Widget child;
  final Color? accentColor;

  const _MacroClauseCard({
    required this.eyebrow,
    required this.title,
    required this.child,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final instrument = InstrumentTheme.of(context);

    return Container(
      decoration: InstrumentTheme.instrumentCardDecoration(
        context,
        accentColor: accentColor,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: InstrumentTheme.microLabel(
                    context,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: instrument.hairlineBorder),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}
