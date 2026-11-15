import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/src/widgets/snack_utils.dart';
import 'package:workout_app/widgets/instrument_modal.dart';

import '../config/api_config.dart';
import '../models/exercise_definition.dart';
import '../services/api_client.dart';
import '../services/service_locator.dart';
import 'exercise_selection_screen.dart';

class UserMaxWidget extends ConsumerStatefulWidget {
  final bool embeddedInSheet;

  const UserMaxWidget({super.key, this.embeddedInSheet = false});

  static Future<bool?> showAsBottomSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return showInstrumentBottomSheet<bool>(
      context: context,
      eyebrow: '1RM TELEMETRY',
      title: l10n.userMaxTitle,
      builder: (_) => const UserMaxWidget(embeddedInSheet: true),
    );
  }

  @override
  ConsumerState<UserMaxWidget> createState() => _UserMaxWidgetState();
}

class _UserMaxWidgetState extends ConsumerState<UserMaxWidget> {
  final ApiClient _apiClient = ApiClient.create();
  ExerciseDefinition? _selectedExercise;
  final TextEditingController _exerciseNameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _repsController = TextEditingController(
    text: '1',
  );
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _apiClient.dispose();
    _exerciseNameController.dispose();
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  Future<void> _pickExercise() async {
    final exerciseService = ref.read(exerciseServiceProvider);
    await exerciseService.getExerciseDefinitions();
    if (!mounted) return;

    final selected = await Navigator.of(context).push<ExerciseDefinition>(
      MaterialPageRoute(builder: (_) => const ExerciseSelectionScreen()),
    );

    if (selected != null && mounted) {
      setState(() {
        _selectedExercise = selected;
        _exerciseNameController.text = selected.name;
      });
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate() || _selectedExercise == null) {
      showAppSnackBar(
        context,
        l10n.userMaxFillAllFieldsSnack,
        isError: true,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final payload = {
        'exercise_id': _selectedExercise!.id,
        'exercise_name': _selectedExercise!.name,
        'max_weight': int.tryParse(_weightController.text),
        'rep_max': int.tryParse(_repsController.text) ?? 1,
      };
      await _apiClient.post(
        ApiConfig.createUserMaxEndpoint(),
        payload,
        context: 'UserMaxWidget',
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          l10n.userMaxFailedToSave(e.toString()),
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final instrument = InstrumentTheme.of(context);
    final tabularStyle = theme.textTheme.bodyLarge?.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    final formContent = Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!widget.embeddedInSheet) ...[
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: instrument.hairlineBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '1RM TELEMETRY',
              style: InstrumentTheme.microLabel(
                context,
                color: instrument.workingAura,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.userMaxTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            readOnly: true,
            controller: _exerciseNameController,
            decoration: InstrumentTheme.inputDecoration(
              context,
              labelText: l10n.userMaxExerciseLabel,
              suffixIcon: IconButton(
                icon: const Icon(Icons.search_rounded),
                onPressed: _pickExercise,
              ),
            ),
            onTap: _pickExercise,
            validator: (_) {
              if (_selectedExercise == null) {
                return l10n.userMaxSelectExerciseValidator;
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _weightController,
            style: tabularStyle,
            keyboardType: TextInputType.number,
            decoration: InstrumentTheme.inputDecoration(
              context,
              labelText: l10n.userMaxWeightKgLabel,
            ),
            validator: (value) {
              final weight = int.tryParse(value ?? '');
              if (weight == null || weight <= 0) {
                return l10n.userMaxWeightGtZeroValidator;
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _repsController,
            style: tabularStyle,
            keyboardType: TextInputType.number,
            decoration: InstrumentTheme.inputDecoration(
              context,
              labelText: l10n.userMaxRepsLabel,
            ),
            validator: (value) {
              final reps = int.tryParse(value ?? '');
              if (reps == null || reps <= 0) {
                return l10n.userMaxRepsGtZeroValidator;
              }
              if (reps > 12) {
                return l10n.userMaxRepsMax12Validator;
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          InstrumentActionButton(
            label: _isSubmitting ? l10n.userMaxSaving : l10n.userMaxSave,
            icon: Icons.save_rounded,
            expanded: true,
            loading: _isSubmitting,
            onPressed: _isSubmitting ? null : _submit,
          ),
        ],
      ),
    );

    if (widget.embeddedInSheet) {
      return formContent;
    }

    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? InstrumentPalette.obsidianCardLow
            : theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: instrument.hairlineBorder, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            14,
            16,
            16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: formContent,
        ),
      ),
    );
  }
}
