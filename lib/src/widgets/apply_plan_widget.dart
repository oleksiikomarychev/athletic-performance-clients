import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/models/calendar_plan.dart';
import 'package:workout_app/models/microcycle.dart';
import 'package:workout_app/models/user_max.dart';
import 'package:workout_app/src/api/plan_api.dart';
import 'package:workout_app/src/widgets/snack_utils.dart';

class ApplyPlanWidget extends StatefulWidget {
  final CalendarPlan plan;
  final List<UserMax> userMaxList;
  final Set<int> allowedExerciseIds;
  final Set<String> allowedExerciseNames;
  final int planId;
  final Future<void> Function(Map<String, dynamic>) onApply;
  final VoidCallback? onUserMaxAdded;

  const ApplyPlanWidget({
    Key? key,
    required this.plan,
    required this.userMaxList,
    required this.allowedExerciseIds,
    required this.allowedExerciseNames,
    required this.planId,
    required this.onApply,
    this.onUserMaxAdded,
  }) : super(key: key);

  @override
  State<ApplyPlanWidget> createState() => _ApplyPlanWidgetState();
}

class _ApplyPlanWidgetState extends State<ApplyPlanWidget> {
  static const String _prefsKeyPrefix = 'apply_plan_last_user_max_ids';
  static const List<String> _roundingModeCodes = ['nearest', 'ceil', 'floor'];

  String _roundingModeLabel(String code, AppLocalizations l10n) => switch (code) {
    'nearest' => l10n.roundNearest,
    'ceil' => l10n.roundUp,
    'floor' => l10n.roundDown,
    _ => code,
  };

  final _formKey = GlobalKey<FormState>();

  List<int> _selectedUserMaxIds = [];
  List<int> _savedUserMaxIds = [];
  bool _computeWeights = true;
  double _roundingStep = 2.5;
  String _roundingMode = 'nearest';
  bool _isApplying = false;

  String? _progressStage;
  int? _workoutsTotal;
  int? _workoutsDone;

  void setProgress({String? stage, int? workoutsTotal, int? workoutsDone}) {
    if (!mounted) return;
    setState(() {
      _progressStage = stage;
      _workoutsTotal = workoutsTotal;
      _workoutsDone = workoutsDone;
    });
  }

  String _buildProgressText(AppLocalizations l10n) {
    final done = _workoutsDone;
    final total = _workoutsTotal;
    if (done != null && total != null && total > 0) {
      final remaining = (total - done).clamp(0, total);
      return l10n.applyPlanGenProgress(done, remaining, total);
    }
    if ((_progressStage ?? '').trim().isNotEmpty) {
      return l10n.applyPlanGenStage(_progressStage!);
    }
    return l10n.applyPlanGenEllipsis;
  }

  @override
  void initState() {
    super.initState();
    _loadLastSelection();
  }

  @override
  void didUpdateWidget(covariant ApplyPlanWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.userMaxList, widget.userMaxList) ||
        !setEquals(oldWidget.allowedExerciseIds, widget.allowedExerciseIds) ||
        !setEquals(
          oldWidget.allowedExerciseNames,
          widget.allowedExerciseNames,
        )) {
      _filterCurrentSelection();
      _loadLastSelection();
    }
  }

  List<PlanExercise> _getAllPlanExercises() {
    final exercises = <PlanExercise>[];
    final seen = <String>{};

    for (final mesocycle in widget.plan.mesocycles) {
      for (final microcycle in mesocycle.microcycles) {
        for (final workout in microcycle.planWorkouts) {
          for (final exercise in workout.exercises) {
            final key =
                '${exercise.exerciseDefinitionId}_${exercise.exerciseName}';
            if (!seen.contains(key)) {
              seen.add(key);
              exercises.add(exercise);
            }
          }
        }
      }
    }

    exercises.sort((a, b) => a.exerciseName.compareTo(b.exerciseName));
    return exercises;
  }

  String? _normalizeExerciseName(String? name) {
    final value = name?.trim();
    if (value == null || value.isEmpty) return null;
    return value.toLowerCase();
  }

  List<UserMax> _userMaxesForExercise(PlanExercise exercise) {
    final byId = <UserMax>[];
    final byName = <UserMax>[];

    for (final userMax in widget.userMaxList) {
      if (userMax.exerciseId == exercise.exerciseDefinitionId &&
          userMax.exerciseId > 0) {
        byId.add(userMax);
      }
    }

    if (byId.isNotEmpty) {
      return byId;
    }

    final normalized = _normalizeExerciseName(exercise.exerciseName);
    if (normalized == null) {
      return const [];
    }

    for (final userMax in widget.userMaxList) {
      final userMaxNormalized = _normalizeExerciseName(userMax.exerciseName);
      if (userMaxNormalized == normalized) {
        byName.add(userMax);
      }
    }

    return byName;
  }

  UserMax? _latestUserMax(List<UserMax> userMaxes) {
    if (userMaxes.isEmpty) {
      return null;
    }
    UserMax latest = userMaxes.first;
    for (final userMax in userMaxes.skip(1)) {
      if (userMax.id > latest.id) {
        latest = userMax;
      }
    }
    return latest;
  }

  Future<void> _showAddUserMaxSheet(PlanExercise exercise) async {
    final weightController = TextEditingController();
    final repsController = TextEditingController(text: '1');
    bool isSubmitting = false;
    String? errorMessage;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final scheme = theme.colorScheme;
        final instrument = InstrumentTheme.of(sheetContext);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? InstrumentPalette.obsidianCardLow : scheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(
                color: isDark ? instrument.hairlineBorder : scheme.outlineVariant,
              ),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            MediaQuery.of(sheetContext).viewInsets.bottom +
                MediaQuery.of(sheetContext).padding.bottom +
                20,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'USER MAX · 1RM',
                    style: InstrumentTheme.microLabel(context),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exercise.exerciseName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: weightController,
                          keyboardType: TextInputType.number,
                          style: InstrumentTheme.tabular(
                            theme.textTheme.bodyLarge ?? const TextStyle(),
                          ),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(sheetContext).weightKgLabel,
                            filled: true,
                            fillColor: isDark
                                ? InstrumentPalette.obsidianSlotHigh
                                : scheme.surfaceContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: repsController,
                          keyboardType: TextInputType.number,
                          style: InstrumentTheme.tabular(
                            theme.textTheme.bodyLarge ?? const TextStyle(),
                          ),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(sheetContext).repsLabel,
                            filled: true,
                            fillColor: isDark
                                ? InstrumentPalette.obsidianSlotHigh
                                : scheme.surfaceContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      errorMessage!,
                      style: TextStyle(
                        color: instrument.peakEffortColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: instrument.workingAura,
                      foregroundColor:
                          isDark ? const Color(0xFF04131E) : scheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final sheetL10n = AppLocalizations.of(sheetContext);
                            final weight = int.tryParse(weightController.text);
                            final reps = int.tryParse(repsController.text);
                            if (weight == null || weight <= 0) {
                              setModalState(() {
                                errorMessage = sheetL10n.errorValidWeight;
                              });
                              return;
                            }
                            if (reps == null || reps <= 0 || reps > 12) {
                              setModalState(() {
                                errorMessage = sheetL10n.errorValidRepsRange;
                              });
                              return;
                            }

                            setModalState(() {
                              isSubmitting = true;
                              errorMessage = null;
                            });

                            try {
                              await PlanApi.createUserMax(
                                exerciseId: exercise.exerciseDefinitionId,
                                maxWeight: weight,
                                repMax: reps,
                                date: DateTime.now()
                                    .toIso8601String()
                                    .split('T')
                                    .first,
                              );
                              if (sheetContext.mounted &&
                                  Navigator.of(sheetContext).canPop()) {
                                Navigator.of(sheetContext).pop(true);
                              }
                            } catch (e) {
                              setModalState(() {
                                errorMessage =
                                    sheetL10n.saveMaxFailed(e.toString());
                                isSubmitting = false;
                              });
                            }
                          },
                    child: isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(AppLocalizations.of(sheetContext).saveMaxButton),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    weightController.dispose();
    repsController.dispose();

    if (result == true) {
      widget.onUserMaxAdded?.call();
      if (!mounted) return;
      showAppSnackBar(
        context,
        AppLocalizations.of(context).maxSavedForExercise(exercise.exerciseName),
      );
    }
  }

  String get _storageKey => '${_prefsKeyPrefix}_${widget.planId}';

  Future<void> _loadLastSelection() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_storageKey);
    final parsed =
        saved?.map((value) => int.tryParse(value)).whereType<int>().toList() ??
        [];

    if (!mounted) return;
    setState(() {
      _savedUserMaxIds = parsed;
    });
  }

  Future<void> _saveCurrentSelection(List<int> userMaxIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      userMaxIds.map((id) => id.toString()).toList(),
    );
    if (!mounted) return;
    setState(() {
      _savedUserMaxIds = List<int>.from(userMaxIds);
    });
  }

  void _filterCurrentSelection() {
    final allowedUserMaxIds = widget.userMaxList
        .where(_isExerciseAllowed)
        .map((userMax) => userMax.id)
        .toSet();

    _selectedUserMaxIds = _selectedUserMaxIds
        .where(allowedUserMaxIds.contains)
        .toList();
  }

  bool _isExerciseAllowed(UserMax userMax) {
    if (widget.allowedExerciseIds.isEmpty &&
        widget.allowedExerciseNames.isEmpty) {
      return true;
    }

    if (widget.allowedExerciseIds.contains(userMax.exerciseId)) {
      return true;
    }

    final normalizedName = userMax.exerciseName.trim().toLowerCase();
    return widget.allowedExerciseNames.contains(normalizedName);
  }

  String _groupKey(UserMax userMax) {
    if (userMax.exerciseId > 0) {
      return 'id_${userMax.exerciseId}';
    }
    return 'name_${userMax.exerciseName.trim().toLowerCase()}';
  }

  Set<int> _computeLatestSelection(
    Map<String, List<UserMax>> groupedUserMaxes,
  ) {
    final latestIds = <int>{};
    for (final entry in groupedUserMaxes.values) {
      if (entry.isEmpty) continue;
      final latest = entry.reduce(
        (current, next) => next.id > current.id ? next : current,
      );
      latestIds.add(latest.id);
    }
    return latestIds;
  }

  void _applySelection(List<int> userMaxIds) {
    setState(() {
      _selectedUserMaxIds = userMaxIds.toSet().toList();
    });
  }

  void _toggleUserMaxId(int id) {
    setState(() {
      if (_selectedUserMaxIds.contains(id)) {
        _selectedUserMaxIds.remove(id);
      } else {
        _selectedUserMaxIds.add(id);
      }
    });
  }

  void _handleUseLastValues(
    Map<String, List<UserMax>> groupedUserMaxes,
    Set<int> availableUserMaxIds,
  ) {
    final savedMatches = _savedUserMaxIds
        .where(availableUserMaxIds.contains)
        .toList();

    if (savedMatches.isNotEmpty) {
      _applySelection(savedMatches);
      return;
    }

    final latestIds = _computeLatestSelection(
      groupedUserMaxes,
    ).where(availableUserMaxIds.contains).toList();

    if (latestIds.isEmpty) {
      showAppSnackBar(
        context,
        AppLocalizations.of(context).noSavedMaxesForPlan,
      );
      return;
    }

    _applySelection(latestIds);
  }

  Future<void> _submitPlan(Set<int> availableUserMaxIds) async {
    final validSelection = _selectedUserMaxIds
        .where(availableUserMaxIds.contains)
        .toList();

    if (validSelection.isEmpty) {
      showAppSnackBar(
        context,
        AppLocalizations.of(context).selectAtLeastOneUserMax,
        isError: true,
      );
      return;
    }

    setState(() {
      _isApplying = true;
      _progressStage = null;
      _workoutsTotal = null;
      _workoutsDone = null;
    });

    try {
      await _saveCurrentSelection(validSelection);

      await widget.onApply({
        'user_max_ids': validSelection,
        'compute_weights': _computeWeights,
        'rounding_step': _roundingStep,
        'rounding_mode': _roundingMode,
        'generate_workouts': true,
        'on_progress': (String? stage, int? total, int? done) {
          setProgress(
            stage: stage,
            workoutsTotal: total,
            workoutsDone: done,
          );
        },
      });
    } finally {
      if (mounted) {
        setState(() {
          _isApplying = false;
          _progressStage = null;
          _workoutsTotal = null;
          _workoutsDone = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = instrument.workingAura;
    final hairline = isDark ? instrument.hairlineBorder : scheme.outlineVariant;
    final cardBg = isDark
        ? InstrumentPalette.obsidianCardMid
        : scheme.surfaceContainerLow;

    final filteredUserMaxes = widget.userMaxList
        .where(_isExerciseAllowed)
        .toList();
    final useFallback =
        filteredUserMaxes.isEmpty && widget.userMaxList.isNotEmpty;
    final effectiveUserMaxes =
        useFallback ? widget.userMaxList : filteredUserMaxes;
    final availableUserMaxIds =
        effectiveUserMaxes.map((userMax) => userMax.id).toSet();

    final groupedUserMaxes = <String, List<UserMax>>{};
    for (final userMax in effectiveUserMaxes) {
      groupedUserMaxes
          .putIfAbsent(_groupKey(userMax), () => <UserMax>[])
          .add(userMax);
    }

    final groupedEntries = groupedUserMaxes.entries.toList()
      ..sort(
        (a, b) => a.value.first.exerciseName.toLowerCase().compareTo(
          b.value.first.exerciseName.toLowerCase(),
        ),
      );
    final planExercises = _getAllPlanExercises();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? InstrumentPalette.obsidianCardLow : scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: hairline)),
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.78,
        minChildSize: 0.5,
        maxChildSize: 0.94,
        builder: (context, scrollController) {
          return Form(
            key: _formKey,
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                MediaQuery.of(context).padding.bottom +
                    MediaQuery.of(context).viewInsets.bottom +
                    24,
              ),
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PLAN APPLICATION',
                            style: InstrumentTheme.microLabel(context),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context).applyPlanTitle,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          if (widget.plan.name.trim().isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              widget.plan.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: AppLocalizations.of(context).tooltipClose,
                      style: IconButton.styleFrom(
                        minimumSize: const Size(48, 48),
                        tapTargetSize: MaterialTapTargetSize.padded,
                      ),
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                if (_isApplying) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: InstrumentTheme.cardDecoration(
                      context,
                      color: cardBg,
                      borderColor: accent.withValues(alpha: 0.5),
                      radius: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          minHeight: 3,
                          borderRadius: BorderRadius.circular(999),
                          value: (_workoutsTotal != null &&
                                  _workoutsDone != null &&
                                  _workoutsTotal! > 0)
                              ? (_workoutsDone! / _workoutsTotal!)
                                  .clamp(0.0, 1.0)
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _buildProgressText(AppLocalizations.of(context)),
                          style: InstrumentTheme.tabular(
                            theme.textTheme.bodySmall?.copyWith(
                                  color: accent,
                                  fontWeight: FontWeight.w600,
                                ) ??
                                TextStyle(color: accent, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  decoration: InstrumentTheme.cardDecoration(
                    context,
                    color: cardBg,
                    radius: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context).applyPlanBaseMaxesHeader,
                                style: InstrumentTheme.microLabel(context),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppLocalizations.of(context).applyPlanSelectedCount(
                                  _selectedUserMaxIds
                                      .where(availableUserMaxIds.contains)
                                      .length,
                                ),
                                style: InstrumentTheme.tabular(
                                  theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ) ??
                                      const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          if (groupedEntries.isNotEmpty)
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                minimumSize: const Size(48, 48),
                                foregroundColor: accent,
                              ),
                              onPressed: () => _handleUseLastValues(
                                groupedUserMaxes,
                                availableUserMaxIds,
                              ),
                              icon: const Icon(Icons.history, size: 18),
                              label: Text(AppLocalizations.of(context).applyPlanRecentButton),
                            ),
                        ],
                      ),
                      if (planExercises.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        for (int i = 0; i < planExercises.length; i++) ...[
                          Divider(height: 1, thickness: 1, color: hairline),
                          _PlanExerciseMaxRow(
                            exercise: planExercises[i],
                            latestUserMax: _latestUserMax(
                              _userMaxesForExercise(planExercises[i]),
                            ),
                            onAddTap: () =>
                                _showAddUserMaxSheet(planExercises[i]),
                          ),
                        ],
                      ],
                      Divider(height: 16, thickness: 1, color: hairline),
                      if (groupedEntries.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            AppLocalizations.of(context).applyPlanNoMaxesHint,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      else ...[
                        if (useFallback) ...[
                          Text(
                            AppLocalizations.of(context).applyPlanNoExactMatchHint,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        for (int i = 0; i < groupedEntries.length; i++) ...[
                          if (i > 0) const SizedBox(height: 12),
                          _UserMaxGroupSelector(
                            exerciseName:
                                groupedEntries[i].value.first.exerciseName,
                            userMaxes: groupedEntries[i].value,
                            selectedIds: _selectedUserMaxIds,
                            accent: accent,
                            isDark: isDark,
                            onToggle: _toggleUserMaxId,
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: InstrumentTheme.cardDecoration(
                    context,
                    color: cardBg,
                    radius: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        AppLocalizations.of(context).applyPlanWorkingWeightsHeader,
                        style: InstrumentTheme.microLabel(context),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context).applyPlanComputeWeights,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  AppLocalizations.of(context).applyPlanComputeWeightsSubtitle,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value: _computeWeights,
                            onChanged: (value) {
                              setState(() => _computeWeights = value);
                            },
                          ),
                        ],
                      ),
                      Divider(height: 22, thickness: 1, color: hairline),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final stacked = constraints.maxWidth < 300 ||
                              MediaQuery.textScalerOf(context).scale(14) > 20;
                          final stepField = SizedBox(
                            width: stacked ? double.infinity : 110,
                            child: TextFormField(
                              initialValue: _roundingStep.toString(),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              style: InstrumentTheme.tabular(
                                theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ) ??
                                    const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context).applyPlanStepKgLabel,
                                filled: true,
                                fillColor: isDark
                                    ? InstrumentPalette.obsidianSlotHigh
                                    : scheme.surfaceContainer,
                              ),
                              onChanged: (value) {
                                _roundingStep = double.tryParse(value) ?? 2.5;
                              },
                            ),
                          );
                          final roundingSelector = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context).applyPlanRoundingHeader,
                                style: InstrumentTheme.microLabel(context),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: _roundingModeCodes.map((code) {
                                  final selected = _roundingMode == code;
                                  final l10n = AppLocalizations.of(context);
                                  return _InstrumentSelectPill(
                                    label: _roundingModeLabel(code, l10n),
                                    selected: selected,
                                    accent: accent,
                                    isDark: isDark,
                                    onTap: () {
                                      setState(() {
                                        _roundingMode = code;
                                      });
                                    },
                                  );
                                }).toList(growable: false),
                              ),
                            ],
                          );
                          if (stacked) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                stepField,
                                const SizedBox(height: 12),
                                roundingSelector,
                              ],
                            );
                          }
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              stepField,
                              const SizedBox(width: 12),
                              Expanded(child: roundingSelector),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    backgroundColor: accent,
                    foregroundColor:
                        isDark ? const Color(0xFF04131E) : scheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _isApplying
                      ? null
                      : () => _submitPlan(availableUserMaxIds),
                  child: _isApplying
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          AppLocalizations.of(context).applyPlanTitle,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? const Color(0xFF04131E)
                                : scheme.onPrimary,
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PlanExerciseMaxRow extends StatelessWidget {
  final PlanExercise exercise;
  final UserMax? latestUserMax;
  final VoidCallback onAddTap;

  const _PlanExerciseMaxRow({
    required this.exercise,
    required this.latestUserMax,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.exerciseName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                if (latestUserMax != null)
                  Text(
                    AppLocalizations.of(context).userMaxDisplay(
                      latestUserMax!.repMax.toString(),
                      latestUserMax!.maxWeight.toString(),
                    ),
                    style: InstrumentTheme.tabular(
                      theme.textTheme.labelSmall?.copyWith(
                            color: instrument.successColor,
                            fontWeight: FontWeight.w700,
                          ) ??
                          TextStyle(
                            color: instrument.successColor,
                            fontSize: 11,
                          ),
                    ),
                  )
                else
                  Text(
                    AppLocalizations.of(context).planDetailMaxNotSet,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          TextButton.icon(
            style: TextButton.styleFrom(
              minimumSize: const Size(48, 48),
              foregroundColor: instrument.workingAura,
            ),
            onPressed: onAddTap,
            icon: const Icon(Icons.add, size: 16),
            label: Text(AppLocalizations.of(context).actionAdd),
          ),
        ],
      ),
    );
  }
}

class _UserMaxGroupSelector extends StatelessWidget {
  final String exerciseName;
  final List<UserMax> userMaxes;
  final List<int> selectedIds;
  final Color accent;
  final bool isDark;
  final ValueChanged<int> onToggle;

  const _UserMaxGroupSelector({
    required this.exerciseName,
    required this.userMaxes,
    required this.selectedIds,
    required this.accent,
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          exerciseName,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: userMaxes.map((userMax) {
            final selected = selectedIds.contains(userMax.id);
            return _InstrumentSelectPill(
              label: AppLocalizations.of(context).userMaxDisplay(
                userMax.repMax.toString(),
                userMax.maxWeight.toString(),
              ),
              selected: selected,
              accent: accent,
              isDark: isDark,
              tabular: true,
              onTap: () => onToggle(userMax.id),
            );
          }).toList(growable: false),
        ),
      ],
    );
  }
}

/// Borderless surface-stepped selection pill adhering to Max Border Depth = 1
/// inside outer [InstrumentTheme.cardDecoration] containers.
class _InstrumentSelectPill extends StatelessWidget {
  final String label;
  final bool selected;
  final Color accent;
  final bool isDark;
  final bool tabular;
  final VoidCallback onTap;

  const _InstrumentSelectPill({
    required this.label,
    required this.selected,
    required this.accent,
    required this.isDark,
    this.tabular = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fillColor = selected
        ? accent.withValues(alpha: isDark ? 0.22 : 0.16)
        : (isDark
              ? InstrumentPalette.obsidianSlotHigh
              : scheme.surfaceContainer);
    final fgColor = selected ? accent : scheme.onSurface;
    final baseStyle = theme.textTheme.labelMedium?.copyWith(
          color: fgColor,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ) ??
        TextStyle(color: fgColor, fontSize: 12);

    return Material(
      color: fillColor,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Center(
              widthFactor: 1,
              child: Text(
                label,
                style: tabular ? InstrumentTheme.tabular(baseStyle) : baseStyle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
