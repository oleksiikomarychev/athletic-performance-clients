import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/models/exercise_definition.dart';
import 'package:workout_app/models/exercise_instance.dart';
import 'package:workout_app/models/exercise_set_dto.dart';
import 'package:workout_app/models/progression_template.dart';
import 'package:workout_app/services/service_locator.dart';
import 'package:workout_app/src/widgets/snack_utils.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/instrument_modal.dart';
import 'package:workout_app/widgets/loading_indicator.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';

class ExerciseFormScreen extends ConsumerStatefulWidget {
  final ExerciseDefinition exercise;
  final int workoutId;
  final ExerciseInstance? initialInstance;
  final int? defaultOrder;

  const ExerciseFormScreen({
    super.key,
    required this.exercise,
    required this.workoutId,
    this.initialInstance,
    this.defaultOrder,
  });

  @override
  ConsumerState<ExerciseFormScreen> createState() => _ExerciseFormScreenState();
}

class _ExerciseFormScreenState extends ConsumerState<ExerciseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _muscleGroupController;

  final List<TextEditingController> _volumeControllers = [];
  final List<TextEditingController> _weightControllers = [];
  final List<ExerciseSetDto?> _existingSetDtos = [];

  List<String> _muscleGroups = [];
  String? _selectedMuscleGroup;

  List<ProgressionTemplate> _templates = [];
  ProgressionTemplate? _selectedTemplate;
  bool _isLoading = false;

  void _addSetRow({ExerciseSetDto? existing, String? volume, String? weight}) {
    final defaultReps = existing?.reps.toString() ?? '5';
    final defaultWeight = () {
      final val = existing?.weight ?? 0.0;
      return (val % 1 == 0)
          ? val.toStringAsFixed(0)
          : val.toStringAsFixed(1);
    }();
    final v = TextEditingController(text: volume ?? defaultReps);
    final w = TextEditingController(text: weight ?? defaultWeight);
    _volumeControllers.add(v);
    _weightControllers.add(w);
    _existingSetDtos.add(existing);
  }

  void _removeSetRow(int index) {
    if (index < 0 || index >= _volumeControllers.length) return;
    final v = _volumeControllers.removeAt(index);
    final w = _weightControllers.removeAt(index);
    _existingSetDtos.removeAt(index);
    v.dispose();
    w.dispose();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.exercise.name);
    _muscleGroupController = TextEditingController(
      text: widget.exercise.muscleGroup ?? '',
    );

    final existingSets = widget.initialInstance?.sets ?? [];
    if (existingSets.isNotEmpty) {
      for (final set in existingSets) {
        _addSetRow(existing: set);
      }
    } else {
      _addSetRow();
    }

    _selectedMuscleGroup = null;
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _muscleGroupController.dispose();
    for (final c in _volumeControllers) {
      c.dispose();
    }
    for (final c in _weightControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final exerciseService = ref.read(exerciseServiceProvider);
      final results = await Future.wait([
        exerciseService.getTemplates(),
        exerciseService.getMuscles(),
      ]);

      final templates = results[0] as List<ProgressionTemplate>;
      final muscles = results[1];

      final groups = Set<String>.from(
        muscles.map((m) => (m as dynamic).group as String),
      );
      _muscleGroups = groups.toList()..sort();

      if (mounted) {
        setState(() {
          _templates = templates;
          final current = _muscleGroupController.text.trim();
          if (current.isNotEmpty) {
            String? match;
            for (final g in groups) {
              if (g.toLowerCase() == current.toLowerCase()) {
                match = g;
                break;
              }
            }
            _selectedMuscleGroup = match;
          } else {
            _selectedMuscleGroup = null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          AppLocalizations.of(context).failedToLoadData('$e'),
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _saveExercise() async {
    if (!(_formKey.currentState?.validate() ?? false)) return false;

    setState(() => _isLoading = true);
    try {
      final exerciseDef = widget.exercise;
      final exerciseListId = exerciseDef.id;
      if (exerciseListId == null) {
        throw Exception('Exercise definition id is required');
      }

      final sets = <ExerciseSetDto>[];
      for (int i = 0; i < _volumeControllers.length; i++) {
        final reps = int.tryParse(_volumeControllers[i].text.trim()) ?? 0;
        final weightRaw = _weightControllers[i].text
            .replaceAll(',', '.')
            .trim();
        final weight = double.tryParse(weightRaw) ?? 0.0;
        final existing = _existingSetDtos[i];

        sets.add(
          ExerciseSetDto(
            id: existing?.id,
            reps: reps,
            weight: weight,
            effort: existing?.rpe?.toDouble() ?? 0.0,
            order: existing?.order ?? i,
            exerciseInstanceId: existing?.exerciseInstanceId,
          ),
        );
      }

      final newInstance = ExerciseInstance(
        id: widget.initialInstance?.id,
        workoutId: widget.initialInstance?.workoutId ?? widget.workoutId,
        exerciseListId: exerciseListId,
        exerciseDefinition: exerciseDef,
        userMaxId: widget.initialInstance?.userMaxId,
        sets: sets,
        notes: widget.initialInstance?.notes,
        order: widget.initialInstance?.order ?? widget.defaultOrder,
      );

      if (mounted) {
        Navigator.of(context).pop({
          'instance': newInstance,
          'isNew': widget.initialInstance == null,
          'refresh': true,
        });
      }
      return true;
    } catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          AppLocalizations.of(context).errorSaving('$e'),
          isError: true,
        );
      }
      return false;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTemplateDropdown(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DropdownButtonFormField<ProgressionTemplate>(
      initialValue: _selectedTemplate,
      decoration: InstrumentTheme.inputDecoration(
        context,
        labelText: l10n.progressionTemplateOptionalLabel,
      ),
      hint: Text(l10n.selectTemplateHint),
      isExpanded: true,
      items: [
        DropdownMenuItem<ProgressionTemplate>(
          value: null,
          child: Text(l10n.noTemplateOption),
        ),
        ..._templates.map((template) {
          return DropdownMenuItem<ProgressionTemplate>(
            value: template,
            child: Text(template.name),
          );
        }),
      ],
      onChanged: (template) {
        setState(() {
          _selectedTemplate = template;
          if (template != null) {
            if (_volumeControllers.isNotEmpty) {
              _volumeControllers.first.text = template.volume.toString();
            }
          } else {
            if (_volumeControllers.isNotEmpty) {
              _volumeControllers.first.text = '5';
            }
            if (_weightControllers.isNotEmpty) {
              _weightControllers.first.text = '0';
            }
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AssistantChatHost(
      contextBuilder: () async => {
        'screen': 'exercise_form',
        'entities': {
          'workout_id': widget.workoutId,
          'exercise_id': widget.exercise.id,
          'sets_count': _volumeControllers.length,
        },
      },
      builder: (context, openChat) {
        final theme = Theme.of(context);
        final instrument = InstrumentTheme.of(context);
        final topInset = AmbientScaffoldShell.topContentInset(context);
        final bottomInset = AmbientScaffoldShell.bottomContentInset(context);

        return AmbientScaffoldShell(
          appBar: PrimaryAppBar(
            title: widget.initialInstance == null
                ? 'Add Exercise'
                : 'Edit Exercise',
            onTitleTap: openChat,
            showBack: true,
            actions: [
              IconButton(
                onPressed: _isLoading ? null : _saveExercise,
                icon: const Icon(Icons.check_rounded),
                tooltip: AppLocalizations.of(context).saveExercise,
              ),
            ],
          ),
          body: _isLoading
              ? Padding(
                  padding: EdgeInsets.only(top: topInset, bottom: bottomInset),
                  child: const LoadingIndicator(),
                )
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      topInset + 8,
                      16,
                      bottomInset + 28,
                    ),
                    children: [
                      _FormSectionCard(
                        eyebrow: AppLocalizations.of(context).exerciseSpecEyebrow,
                        title: AppLocalizations.of(context).exerciseDetailsTitle,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: InstrumentTheme.inputDecoration(
                                context,
                                labelText: AppLocalizations.of(context).exerciseNameLabel,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context).pleaseEnterNameValidation;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedMuscleGroup,
                              decoration: InstrumentTheme.inputDecoration(
                                context,
                                labelText: AppLocalizations.of(context).muscleGroupLabel,
                              ),
                              isExpanded: true,
                              hint: _muscleGroups.isEmpty
                                  ? Text(AppLocalizations.of(context).loadingEllipsis)
                                  : Text(AppLocalizations.of(context).selectGroupHint),
                              items: _muscleGroups
                                  .map(
                                    (g) => DropdownMenuItem<String>(
                                      value: g,
                                      child: Text(g),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedMuscleGroup = val;
                                  _muscleGroupController.text = val ?? '';
                                });
                              },
                              validator: (val) {
                                if (_muscleGroups.isEmpty) {
                                  return 'Loading groups...';
                                }
                                if (val == null || val.isEmpty) {
                                  return 'Please select a muscle group';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildTemplateDropdown(context),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _FormSectionCard(
                        eyebrow: AppLocalizations.of(context).prescribedSetsEyebrow(_volumeControllers.length),
                        title: AppLocalizations.of(context).sets,
                        accentColor: instrument.workingAura,
                        flushBody: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (
                              int i = 0;
                              i < _volumeControllers.length;
                              i++
                            ) ...[
                              if (i > 0)
                                Container(
                                  height: 1,
                                  color: instrument.hairlineBorder,
                                ),
                              _SetInputRow(
                                index: i,
                                weightController: _weightControllers[i],
                                repsController: _volumeControllers[i],
                                canDelete: _volumeControllers.length > 1,
                                onDelete: () => _removeSetRow(i),
                                theme: theme,
                                instrument: instrument,
                              ),
                            ],
                            Container(
                              height: 1,
                              color: instrument.hairlineBorder,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: InstrumentActionButton(
                                label: AppLocalizations.of(context).addSet,
                                icon: Icons.add_rounded,
                                variant: InstrumentActionVariant.secondary,
                                expanded: true,
                                onPressed: () {
                                  setState(() {
                                    _addSetRow();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      InstrumentActionButton(
                        label: AppLocalizations.of(context).saveExercise,
                        icon: Icons.save_rounded,
                        expanded: true,
                        loading: _isLoading,
                        onPressed: _isLoading ? null : _saveExercise,
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _FormSectionCard extends StatelessWidget {
  final String eyebrow;
  final String title;
  final Widget child;
  final Color? accentColor;
  final bool flushBody;

  const _FormSectionCard({
    required this.eyebrow,
    required this.title,
    required this.child,
    this.accentColor,
    this.flushBody = false,
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
                  ).copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
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
          if (flushBody)
            child
          else
            Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}

class _SetInputRow extends StatelessWidget {
  final int index;
  final TextEditingController weightController;
  final TextEditingController repsController;
  final bool canDelete;
  final VoidCallback onDelete;
  final ThemeData theme;
  final InstrumentTheme instrument;

  const _SetInputRow({
    required this.index,
    required this.weightController,
    required this.repsController,
    required this.canDelete,
    required this.onDelete,
    required this.theme,
    required this.instrument,
  });

  @override
  Widget build(BuildContext context) {
    final tabularStyle = theme.textTheme.bodyLarge?.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    final weightField = TextFormField(
      controller: weightController,
      style: tabularStyle,
      decoration: InstrumentTheme.inputDecoration(
        context,
        labelText: AppLocalizations.of(context).weightKgLabel,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context).requiredField;
        }
        return null;
      },
    );

    final repsField = TextFormField(
      controller: repsController,
      style: tabularStyle,
      decoration: InstrumentTheme.inputDecoration(
        context,
        labelText: AppLocalizations.of(context).repsLabel,
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context).requiredField;
        }
        return null;
      },
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context).setNumberLabel(index + 1),
                  style: InstrumentTheme.microLabel(
                    context,
                    color: instrument.workingAura,
                  ).copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                child: IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: canDelete
                        ? instrument.peakEffortColor
                        : theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.35,
                          ),
                  ),
                  tooltip: AppLocalizations.of(context).removeSetTooltip,
                  onPressed: canDelete ? onDelete : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 260) {
                  return Column(
                    children: [
                      weightField,
                      const SizedBox(height: 10),
                      repsField,
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: weightField),
                    const SizedBox(width: 10),
                    Expanded(child: repsField),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
