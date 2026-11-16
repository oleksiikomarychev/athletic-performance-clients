import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/screens/macros/macros_preview_screen.dart';
import '../config/api_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/workout.dart';
import '../models/exercise_instance.dart';
import '../models/exercise_definition.dart';
import '../models/exercise_set_dto.dart';
import '../services/service_locator.dart';
import '../services/api_client.dart';
import '../models/workout_session.dart';
import 'dart:convert';
import 'dart:async';
import 'exercise_form_screen.dart';
import 'exercise_selection_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_app/config/rpe_table.dart' as rpe_table;
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/responsive.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/providers/ambient_environment_provider.dart';
import 'package:workout_app/providers/interface_maker_provider.dart';
import 'package:workout_app/providers/workout_provider.dart';
import 'package:workout_app/features/auth/auth_gate.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/floating_header_bar.dart';
import 'package:workout_app/widgets/instrument_metric_matrix.dart';
import 'package:workout_app/widgets/interface_maker_sheet.dart';
import 'package:workout_app/widgets/responsive_container.dart';
import 'package:workout_app/widgets/workout_detail/workout_instrument_controls.dart';
import 'package:workout_app/screens/user_profile_screen.dart';
import 'nutrition_plan_create.dart';

class _SetEditor {
  final TextEditingController weightCtrl;
  final TextEditingController repsCtrl;
  final TextEditingController rpeCtrl;
  final List<String> editedFields = [];
  String? autoDerivedField;
  Timer? debounce;

  _SetEditor({
    required this.weightCtrl,
    required this.repsCtrl,
    required this.rpeCtrl,
  });

  void dispose() {
    debounce?.cancel();
    weightCtrl.dispose();
    repsCtrl.dispose();
    rpeCtrl.dispose();
  }

  void scheduleDebounce(
    VoidCallback action, {
    Duration delay = const Duration(milliseconds: 500),
  }) {
    debounce?.cancel();
    debounce = Timer(delay, action);
  }

  void cancelDebounce() {
    debounce?.cancel();
    debounce = null;
  }
}

class _BaselineSet {
  final int reps;
  final double? weight;
  const _BaselineSet({required this.reps, this.weight});
}

class _PendingSetUpdate {
  final int? reps;
  final double? weight;
  final double? rpe;
  final bool reloadAfter;

  const _PendingSetUpdate({
    required this.reps,
    required this.weight,
    required this.rpe,
    required this.reloadAfter,
  });
}

class WorkoutDetailScreen extends ConsumerWidget {
  final int workoutId;

  const WorkoutDetailScreen({super.key, required this.workoutId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutAsync = ref.watch(workoutSWRProvider(workoutId));

    return workoutAsync.when(
      data: (workout) => _WorkoutDetailContent(workout: workout),
      loading: () => const AmbientScaffoldShell(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => AmbientScaffoldShell(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 40),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context).workoutDetailOpenError,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: () =>
                      ref.invalidate(workoutSWRProvider(workoutId)),
                  icon: const Icon(Icons.refresh),
                  label: Text(AppLocalizations.of(context).retry),
                ),
                TextButton(
                  onPressed: () {
                    final navigator = Navigator.of(context);
                    if (navigator.canPop()) {
                      navigator.pop();
                    } else {
                      navigator.pushReplacement(
                        MaterialPageRoute(builder: (_) => const AuthGate()),
                      );
                    }
                  },
                  child: Text(AppLocalizations.of(context).actionBack),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkoutDetailContent extends StatefulWidget {
  final Workout workout;

  const _WorkoutDetailContent({required this.workout});

  @override
  State<_WorkoutDetailContent> createState() => _WorkoutDetailContentState();
}

class _WorkoutDetailContentState extends State<_WorkoutDetailContent> {
  bool _isLoading = false;
  bool _isLoadingExercises = false;
  final Set<int> _updatingInstanceIds = <int>{};
  List<ExerciseDefinition> _uniqueExercises = [];
  Workout? _workout;
  WidgetRef? _ref;
  WorkoutSession? _activeSession;
  Timer? _sessionTimer;
  Duration _elapsed = Duration.zero;
  final ValueNotifier<Duration> _elapsedNotifier = ValueNotifier(Duration.zero);
  final Map<int, Set<int>> _completedByInstance = {};
  final Set<String> _updatingSetKeys = <String>{};
  final Map<String, _PendingSetUpdate> _pendingSetUpdates =
      <String, _PendingSetUpdate>{};
  bool _isTogglingSet = false;

  Map<int, Map<int, int>> _rpeTable = {};
  Map<int, int> _exerciseMaxByExerciseId = {};

  final Map<String, _SetEditor> _setEditors = <String, _SetEditor>{};
  bool _isSyncingFields = false;

  final TextEditingController _notesCtrl = TextEditingController();
  final TextEditingController _statusCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();
  final TextEditingController _durationCtrl = TextEditingController();
  final TextEditingController _rpeSessionCtrl = TextEditingController();
  final TextEditingController _readinessCtrl = TextEditingController();
  DateTime? _editedStartedAt;
  bool _isSavingMetadata = false;

  double _readinessSlider = 10.0;
  bool _isApplyingReadiness = false;
  final bool _scaleRepsWithReadiness = true;

  final Map<String, _BaselineSet> _baselineSets = <String, _BaselineSet>{};

  bool _sessionTickerRunning = false;
  int _sessionTickerGen = 0;

  @override
  void initState() {
    super.initState();

    _workout = widget.workout;
    _syncMetadataControllers();

    _rebuildUniqueExercisesFromWorkout();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ensureExercisesLoaded();
      if (kDebugMode) {
        _fetchRawWorkoutData();
      }
      if (_workout?.id != null) {
        _loadActiveSession();
      }
    });

    _fetchRpeTable();
  }

  @override
  void didUpdateWidget(covariant _WorkoutDetailContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldId = oldWidget.workout.id;
    final newId = widget.workout.id;

    if (oldId != newId) {
      setState(() {
        _workout = widget.workout;
      });
      _syncMetadataControllers();

      _rebuildUniqueExercisesFromWorkout();
      _ensureExercisesLoaded();
      if (_workout?.id != null) {
        _loadActiveSession();
      }
      return;
    }

    if (oldWidget.workout != widget.workout) {
      setState(() {
        _workout = widget.workout;
      });
      _rebuildUniqueExercisesFromWorkout();
      _ensureExercisesLoaded();
      _reconcileEditors();
    }
  }

  void _rebuildUniqueExercisesFromWorkout() {
    final w = _workout;
    if (w == null) return;

    final Map<int, ExerciseDefinition> byId = <int, ExerciseDefinition>{};
    for (final inst in w.exerciseInstances) {
      final def = inst.exerciseDefinition;
      if (def?.id == null) continue;
      byId[def!.id!] = def;
    }

    if (!mounted) return;
    setState(() {
      _uniqueExercises = byId.values.toList();
    });
  }

  Future<void> _ensureExercisesLoaded() async {
    final w = _workout;
    if (w == null) return;

    if (_ref == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(_ensureExercisesLoaded());
      });
      return;
    }

    final instances = w.exerciseInstances;
    final hasInstances = instances.isNotEmpty;
    final missingDefinitions = instances.any(
      (i) => i.exerciseDefinition == null,
    );
    final hasAnyDefinitions = instances.any(
      (i) => i.exerciseDefinition != null,
    );

    if (!hasInstances) {
      _rebuildUniqueExercisesFromWorkout();
      return;
    }

    if (hasAnyDefinitions && !missingDefinitions) {
      _rebuildUniqueExercisesFromWorkout();
      return;
    }

    await _loadExercises();
  }

  Future<void> _maybeShowMacroSuggestion() async {
    final workout = _workout;
    if (!mounted || workout?.id == null || workout?.appliedPlanId == null) return;
    await showSessionMacroSuggestion(context, ApiClient.create(), workout!.id!, workout.appliedPlanId!);
  }

  double _roundToStep(double value, double step) {
    if (step <= 0) return value;
    final rounded = (value / step).roundToDouble() * step;

    return double.parse(rounded.toStringAsFixed(1));
  }

  Future<void> _applyReadinessScaling() async {
    if (_workout == null) return;
    if (_isApplyingReadiness) return;

    final hasMissingIds = _workout!.exerciseInstances.any((inst) {
      if (inst.id == null) return true;
      return inst.sets.any((s) => s.id == null);
    });
    if (hasMissingIds) {
      try {
        await _loadExercises();
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Failed to refresh workout before applying readiness',
              ),
            ),
          );
        }
        return;
      }

      if (_workout == null) return;
      final stillMissingIds = _workout!.exerciseInstances.any((inst) {
        if (inst.id == null) return true;
        return inst.sets.any((s) => s.id == null);
      });
      if (stillMissingIds) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Workout is not ready for set updates (missing ids)',
              ),
            ),
          );
        }
        return;
      }
    }

    setState(() {
      _isApplyingReadiness = true;
    });

    _ensureBaselineSets();

    double factor = _readinessFactor(_readinessSlider.clamp(0, 10));
    int updates = 0;
    try {
      final workoutService = _ref!.read(workoutServiceProvider);
      final List<Future<ExerciseInstance>> updateFutures =
          <Future<ExerciseInstance>>[];

      for (final instance in _workout!.exerciseInstances) {
        bool instanceChanged = false;
        final List<ExerciseSetDto> newSets = <ExerciseSetDto>[];

        for (int i = 0; i < instance.sets.length; i++) {
          final set = instance.sets[i];
          final String key = _editorKey(instance, i, set);
          final _BaselineSet base =
              _baselineSets[key] ??
              _BaselineSet(reps: set.reps, weight: set.weight);
          final double? baseWeight = base.weight;

          double? newWeight;
          bool weightChanged = false;
          if (baseWeight != null) {
            final double rawScaled = baseWeight * factor;
            final double step = rawScaled <= 20.0 ? 1.0 : 2.5;
            newWeight = (_roundToStep(
              rawScaled,
              step,
            ).clamp(0.0, double.infinity));
            final double currentWeight = set.weight;
            weightChanged = (newWeight - currentWeight).abs() > 0.0001;
          }

          final int newReps = _scaleRepsWithReadiness
              ? ((base.reps * factor).round().clamp(1, 10000))
              : set.reps;

          final bool repsChanged = newReps != set.reps;
          final bool changed = repsChanged || weightChanged;
          if (!changed) {
            newSets.add(set);
            continue;
          }

          final updatedSet = set.copyWith(
            reps: repsChanged ? newReps : set.reps,
            weight: weightChanged ? (newWeight ?? set.weight) : set.weight,
            order: set.order ?? i,
          );
          newSets.add(updatedSet);
          instanceChanged = true;
          updates++;
        }

        if (!instanceChanged) continue;
        if (instance.id == null) continue;

        final updatedInstance = instance.copyWith(sets: newSets);
        updateFutures.add(
          workoutService.updateExerciseInstance(updatedInstance),
        );
      }

      if (updateFutures.isNotEmpty) {
        final savedInstances = await Future.wait(updateFutures);
        if (_workout != null && mounted) {
          setState(() {
            final updatedInstances = List<ExerciseInstance>.from(
              _workout!.exerciseInstances,
            );
            for (final saved in savedInstances) {
              final idx = updatedInstances.indexWhere((i) => i.id == saved.id);
              if (idx != -1) {
                updatedInstances[idx] = saved;
              }
            }
            _workout = _workout!.copyWith(exerciseInstances: updatedInstances);
          });
        }
      }
      _reconcileEditors();
      await _saveWorkoutMetadata();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Applied readiness ${_readinessSlider.round()}/10 (x${factor.toStringAsFixed(2)}) to $updates set${updates == 1 ? '' : 's'}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).failedToApplyReadiness('$e')),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isApplyingReadiness = false;
        });
      }

      if (updates > 0) {
        try {
          await _loadExercises();
        } catch (_) {
          // ignore: empty_catches
        }
      }
    }
  }

  void _ensureBaselineSets() {
    if (_workout == null) return;
    final Map<String, _BaselineSet> snap = <String, _BaselineSet>{};
    for (final instance in _workout!.exerciseInstances) {
      for (int i = 0; i < instance.sets.length; i++) {
        final set = instance.sets[i];
        final key = _editorKey(instance, i, set);

        final existing = _baselineSets[key];
        snap[key] =
            existing ?? _BaselineSet(reps: set.reps, weight: set.weight);
      }
    }
    _baselineSets
      ..clear()
      ..addAll(snap);
  }

  void _writeReadinessText(double value) {
    final int clamped = value.clamp(0.0, 10.0).round();
    final String next = clamped.toString();
    if (_readinessCtrl.text == next) {
      return;
    }
    _readinessCtrl.text = next;
  }

  double _readinessFactor(double readiness) {
    final r = readiness.clamp(0.0, 10.0);
    const double base = 0.8;
    const double slope = 0.025;
    final double factor = base + slope * r;
    if (factor < 0.8) return 0.8;
    if (factor > 1.05) return 1.05;
    return factor;
  }

  Future<void> _updateSetField(
    ExerciseInstance instance,
    int setIndex, {
    int? reps,
    double? weight,
    double? rpe,
    bool reloadAfter = false,
  }) async {
    final resolvedInstance = (_workout != null && instance.id != null)
        ? (_workout!.exerciseInstances
              .where((i) => i.id == instance.id)
              .cast<ExerciseInstance?>()
              .firstWhere((i) => i != null, orElse: () => instance))!
        : instance;

    if (setIndex < 0 || setIndex >= resolvedInstance.sets.length) return;

    if (_ref == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).failedToUpdateSetNotReady),
          ),
        );
      }
      return;
    }

    final current = resolvedInstance.sets[setIndex];
    final String key = _editorKey(resolvedInstance, setIndex, current);
    if (_updatingSetKeys.contains(key)) {
      _pendingSetUpdates[key] = _PendingSetUpdate(
        reps: reps,
        weight: weight,
        rpe: rpe,
        reloadAfter: reloadAfter,
      );
      return;
    }
    _updatingSetKeys.add(key);

    try {
      final oldSetId = current.id;
      final wasCompleted =
          resolvedInstance.id != null &&
          oldSetId != null &&
          _isSetCompleted(resolvedInstance.id!, oldSetId);

      final updatedSet = current.copyWith(
        reps: reps ?? current.reps,
        weight: weight ?? current.weight,
        rpe: rpe ?? current.effort,
        order: current.order ?? setIndex,
      );

      final workoutService = _ref!.read(workoutServiceProvider);
      ExerciseInstance savedInstance;
      final setId = updatedSet.id ?? current.id;

      if (resolvedInstance.id != null && setId != null) {
        savedInstance = await workoutService.updateExerciseSet(
          instanceId: resolvedInstance.id!,
          setId: setId,
          reps: updatedSet.reps,
          weight: updatedSet.weight,
          rpe: updatedSet.effort,
          order: updatedSet.order,
        );
      } else {
        final newSets = List<ExerciseSetDto>.from(resolvedInstance.sets);
        newSets[setIndex] = updatedSet;
        final updatedInstance = resolvedInstance.copyWith(sets: newSets);
        savedInstance = await workoutService.updateExerciseInstance(
          updatedInstance,
        );
      }

      if (_workout != null && mounted) {
        setState(() {
          final updatedInstances = List<ExerciseInstance>.from(
            _workout!.exerciseInstances,
          );
          final idx = updatedInstances.indexWhere(
            (i) => i.id == savedInstance.id,
          );
          if (idx != -1) {
            updatedInstances[idx] = savedInstance;
            _workout = _workout!.copyWith(exerciseInstances: updatedInstances);
          }
        });
      }

      final newSets = savedInstance.sets;
      final newSetId = (setIndex >= 0 && setIndex < newSets.length)
          ? newSets[setIndex].id
          : null;
      if (wasCompleted &&
          resolvedInstance.id != null &&
          newSetId != null &&
          newSetId != oldSetId) {
        await _handleCompletedSetIdMigration(
          resolvedInstance.id!,
          oldSetId,
          newSetId,
        );
      }

      if (reloadAfter) {
        await _loadExercises();
      }
      _reconcileEditors();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).failedToUpdateSet('$e')),
          ),
        );
      }
    } finally {
      _updatingSetKeys.remove(key);

      final pending = _pendingSetUpdates.remove(key);
      if (pending != null) {
        unawaited(
          _updateSetField(
            resolvedInstance,
            setIndex,
            reps: pending.reps,
            weight: pending.weight,
            rpe: pending.rpe,
            reloadAfter: pending.reloadAfter,
          ),
        );
      }
    }
  }

  Future<void> _fetchRawWorkoutData() async {
    if (_workout?.id == null) return;

    try {
      final api = ApiClient.create();
      final data = await api.get(
        ApiConfig.getWorkoutEndpoint(_workout!.id!.toString()),
        context: 'RawWorkoutDebug',
      );

      print('\nRAW WORKOUT DATA:');
      print(jsonEncode(data));

      if (data is Map && data['exercise_instances'] is List) {
        print('\nEXERCISE INSTANCES (${data['exercise_instances'].length}):');
        for (var instance in data['exercise_instances']) {
          print('Instance ID: ${instance['id']}');
          print('Exercise Definition ID: ${instance['exercise_list_id']}');
          print('Workout ID: ${instance['workout_id']}');
          print('Sets: ${instance['sets']}');
          print(
            'Exercise Definition: ${instance['exercise_definition'] != null}',
          );
          if (instance['exercise_definition'] != null) {
            print(
              '  Exercise Name: ${instance['exercise_definition']['name']}',
            );
          }
          print('---');
        }
      } else {
        print('No exercise instances found or invalid format');
      }
    } catch (e, stackTrace) {
      print('Error fetching raw workout data: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> _deleteExerciseInstance(ExerciseInstance instance) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final l10n = AppLocalizations.of(context);
      final shouldDelete = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.deleteExerciseTitle),
          content: Text(l10n.removeExerciseConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (shouldDelete != true) {
        print('User cancelled deletion');
        return;
      }

      final workoutService = _ref!.read(workoutServiceProvider);
      if (instance.id != null) {
        await workoutService.deleteExerciseInstance(instance.id!);
        print('Successfully deleted instance from backend');

        await _loadExercises();
        print('Successfully refreshed workout data after deletion');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.exerciseRemovedFromWorkout)),
          );
        }
      } else {
        print('Cannot delete instance with null ID');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.errorCannotDeleteUnsavedExercise),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('Error deleting exercise instance: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).failedToRemoveExercise(e.toString()),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addSetToInstance(ExerciseInstance instance) async {
    final instanceId = instance.id;
    if (instanceId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).cannotAddSetUnsavedExercise),
          ),
        );
      }
      return;
    }

    if (_updatingInstanceIds.contains(instanceId)) return;

    try {
      print('Adding set to instance ${instance.id}');
      setState(() {
        _updatingInstanceIds.add(instanceId);
      });

      int lastReps = 5;
      double lastWeight = 0.0;

      if (instance.sets.isNotEmpty) {
        final lastSet = instance.sets.last;
        lastReps = lastSet.reps;
        lastWeight = lastSet.weight;
      }

      final newSet = ExerciseSetDto(
        id: null,
        reps: lastReps,
        weight: lastWeight,
        order: instance.sets.length,
        exerciseInstanceId: instance.id,
        localId: null,
        volume: (lastReps * lastWeight).round(),
      );

      print('Created new set: $newSet');

      final updatedInstance = instance.copyWith(
        sets: [...instance.sets, newSet],
      );

      print(
        'Updated instance with new set: ${updatedInstance.sets.length} total sets',
      );

      if (_workout != null && mounted) {
        setState(() {
          final updatedInstances = List<ExerciseInstance>.from(
            _workout!.exerciseInstances,
          );
          final index = updatedInstances.indexWhere((i) => i.id == instance.id);
          if (index != -1) {
            updatedInstances[index] = updatedInstance;
            _workout = _workout!.copyWith(exerciseInstances: updatedInstances);
          }
        });
        _reconcileEditors(triggerRebuild: false);
      }

      final workoutService = _ref!.read(workoutServiceProvider);
      final savedInstance = await workoutService.updateExerciseInstance(
        updatedInstance,
      );

      print('Successfully updated instance in backend');

      if (_workout != null && mounted) {
        setState(() {
          final updatedInstances = List<ExerciseInstance>.from(
            _workout!.exerciseInstances,
          );
          final index = updatedInstances.indexWhere(
            (i) => i.id == savedInstance.id,
          );
          if (index != -1) {
            updatedInstances[index] = savedInstance;
            _workout = _workout!.copyWith(exerciseInstances: updatedInstances);
          }
        });
        _reconcileEditors(triggerRebuild: false);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).setAddedSuccessfully)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).failedToAddSet(e.toString()),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _updatingInstanceIds.remove(instanceId);
        });
      }
    }
  }

  Future<void> _loadExercises() async {
    if (_workout == null) return;

    setState(() {
      _isLoadingExercises = true;
    });

    try {
      final workoutService = _ref!.read(workoutServiceProvider);
      final updatedWorkout = await workoutService.getWorkoutWithDetails(
        _workout!.id!,
      );

      print(
        'Fetched workout with ${updatedWorkout.exerciseInstances.length} exercise instances',
      );

      final exerciseListIds = updatedWorkout.exerciseInstances
          .where((e) => e.exerciseDefinition == null)
          .map((e) => e.exerciseListId)
          .toSet()
          .toList();

      if (exerciseListIds.isNotEmpty) {
        final exerciseService = _ref!.read(exerciseServiceProvider);
        final exercises = await exerciseService.getExercisesByIds(
          exerciseListIds,
        );

        final exerciseMap = {for (var e in exercises) e.id: e};

        final updatedInstances = updatedWorkout.exerciseInstances.map((
          instance,
        ) {
          final existing = instance.exerciseDefinition;
          if (existing != null) return instance;
          final def = exerciseMap[instance.exerciseListId];
          return instance.copyWith(exerciseDefinition: def);
        }).toList();

        setState(() {
          _workout = updatedWorkout.copyWith(
            exerciseInstances: updatedInstances,
          );
        });
      } else {
        setState(() {
          _workout = updatedWorkout;
        });
      }

      _rebuildUniqueExercisesFromWorkout();
      _reconcileEditors();
    } catch (e, stackTrace) {
      print('Error loading exercises: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).failedToLoadExercises('$e')),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingExercises = false;
        });
      }
    }
  }

  Future<void> _fetchRpeTable() async {
    try {
      final api = ApiClient.create();
      final dynamic json = await api.get(
        ApiConfig.rpeTableEndpoint,
        context: 'RPE',
      );
      if (json is Map) {
        final Map<int, Map<int, int>> parsed = {};
        json.forEach((k, v) {
          final intKey = int.tryParse(k.toString());
          if (intKey != null && v is Map) {
            final inner = <int, int>{};
            v.forEach((ek, ev) {
              final eKey = int.tryParse(ek.toString());
              final eVal = ev is int ? ev : int.tryParse(ev.toString());
              if (eKey != null && eVal != null) {
                inner[eKey] = eVal;
              }
            });
            parsed[intKey] = inner;
          }
        });
        if (mounted) {
          setState(() {
            _rpeTable = parsed;
          });
        }
      }
    } catch (_) {}
  }

  void _d(String msg) {
    if (kDebugMode) {
      print('[WorkoutDetail] ${DateTime.now().toIso8601String()} | $msg');
    }
  }

  void _syncMetadataControllers() {
    final w = _workout;
    _notesCtrl.text = w?.notes ?? '';
    _statusCtrl.text = w?.status ?? '';
    _locationCtrl.text = w?.location ?? '';
    _durationCtrl.text = (w?.durationSeconds ?? '').toString();
    _rpeSessionCtrl.text = (w?.rpeSession == null)
        ? ''
        : ((w!.rpeSession! % 1 == 0)
              ? w.rpeSession!.toStringAsFixed(0)
              : w.rpeSession!.toStringAsFixed(1));

    final double readinessRaw = (w?.readinessScore?.toDouble() ?? 10.0);
    final double normalized = readinessRaw > 10.0
        ? readinessRaw / 10.0
        : readinessRaw;
    _readinessSlider = normalized.clamp(0.0, 10.0);
    _writeReadinessText(_readinessSlider);
    _editedStartedAt = w?.startedAt;
  }

  Future<void> _saveWorkoutMetadata() async {
    if (_workout?.id == null) return;
    if (_isSavingMetadata) return;
    setState(() => _isSavingMetadata = true);
    try {
      int? parseInt(String s) => int.tryParse(s.trim());
      double? parseDouble(String s) =>
          double.tryParse(s.trim().replaceAll(',', '.'));
      String? emptyToNull(String s) => s.trim().isEmpty ? null : s.trim();

      final int? dur = parseInt(_durationCtrl.text);
      final double? rpeRaw = parseDouble(_rpeSessionCtrl.text);
      final double? rpe = (rpeRaw == null)
          ? null
          : (rpeRaw < 1.0)
          ? 1.0
          : (rpeRaw > 10.0)
          ? 10.0
          : rpeRaw;
      final int readiness = _readinessSlider.round().clamp(0, 10);

      final updated = _workout!.copyWith(
        notes: emptyToNull(_notesCtrl.text),
        status: emptyToNull(_statusCtrl.text),
        startedAt: _editedStartedAt,
        durationSeconds: dur,
        effortSession: rpe,
        location: emptyToNull(_locationCtrl.text),
        readinessScore: readiness,
      );

      _d('Saving workout metadata for id=${updated.id}');
      final svc = _ref!.read(workoutServiceProvider);
      final saved = await svc.updateWorkout(updated);
      if (!mounted) return;
      setState(() {
        final currentInstances =
            _workout?.exerciseInstances ?? const <ExerciseInstance>[];
        final savedInstances = saved.exerciseInstances;
        final savedLooksUsable =
            savedInstances.isNotEmpty &&
            savedInstances.any((ei) => ei.id != null);
        _workout = savedLooksUsable
            ? saved
            : saved.copyWith(exerciseInstances: currentInstances);
      });
      _syncMetadataControllers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).workoutUpdated)),
        );
      }
    } catch (e, st) {
      _d('Failed to save workout metadata: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).failedToUpdateWorkout('$e')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingMetadata = false);
    }
  }

  Future<void> _loadActiveSession() async {
    if (_workout?.id == null) return;
    try {
      final svc = _ref!.read(workoutSessionServiceProvider);
      final session = await svc.getActiveSession(_workout!.id!);
      if (!mounted) return;
      setState(() {
        _activeSession = session;

        if (session != null && session.finishedAt != null) {}
      });
      _d(
        'Active session loaded: id=${_activeSession?.id}, isActive=${_activeSession?.isActive}',
      );
      _parseProgressFromSession();
      if (_activeSession?.isActive == true) {
        _startSessionTicker();
      } else {
        _stopSessionTicker();
      }
    } catch (_) {}
  }

  void _parseProgressFromSession() {
    _completedByInstance.clear();
    final Map<String, dynamic> progress =
        _activeSession?.progress ?? const <String, dynamic>{};
    if (progress.isNotEmpty) {
      final completed = progress['completed'];
      if (completed is Map) {
        completed.forEach((key, value) {
          final instId = int.tryParse(key.toString());
          if (instId != null) {
            final setIds = <int>{};
            if (value is List) {
              for (final v in value) {
                final sid = v is int ? v : int.tryParse(v.toString());
                if (sid != null) setIds.add(sid);
              }
            }
            _completedByInstance[instId] = setIds;
          }
        });
      }
    }
    if (mounted) setState(() {});
  }

  void _startSessionTicker() {
    _sessionTickerGen++;
    final myGen = _sessionTickerGen;
    _sessionTimer?.cancel();
    _sessionTickerRunning = true;
    _d('Session ticker START gen=$myGen');

    void tick() {
      if (!_sessionTickerRunning || myGen != _sessionTickerGen) {
        _d(
          'Tick ignored (running=$_sessionTickerRunning, myGen=$myGen, currentGen=$_sessionTickerGen)',
        );
        return;
      }
      if (!mounted || _activeSession == null) {
        _d('Tick aborted (mounted=$mounted, active=${_activeSession != null})');
        return;
      }
      final start = _activeSession!.startedAt;
      final end = _activeSession!.finishedAt;
      final now = DateTime.now();
      final dur = (end ?? now).difference(start);
      _elapsed = dur.isNegative ? Duration.zero : dur;
      _elapsedNotifier.value = _elapsed;
      if (end != null) {
        _d('Session ended; stopping ticker gen=$myGen');
        _stopSessionTicker();
      }
    }

    tick();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  void _stopSessionTicker() {
    _d('Session ticker STOP (before cancel) running=$_sessionTickerRunning');
    _sessionTickerRunning = false;
    _sessionTimer?.cancel();
    _sessionTimer = null;
    _d('Session ticker STOP (after cancel)');
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  Future<void> _startSession() async {
    if (_workout?.id == null) return;
    try {
      _d('Starting session for workoutId=${_workout?.id}');
      setState(() => _isLoading = true);

      final workoutSvc = _ref!.read(workoutServiceProvider);
      final updated = await workoutSvc.startWorkoutBff(
        _workout!.id!,
        includeDefinitions: false,
      );
      if (!mounted) return;
      setState(() {
        _workout = updated;

        _editedStartedAt = updated.startedAt;
        _durationCtrl.text = '0';
      });

      await _loadActiveSession();

      try {
        await _ref!.read(apiClientProvider).invalidateCacheGroups([
          'workouts:detail',
          'workouts:detail:${_workout!.id!}',
          'workouts:list',
        ]);
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).workoutStarted)),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).failedToStartSession('$e')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _finishSession({
    bool cancelled = false,
    bool markWorkoutCompleted = false,
  }) async {
    if (_workout?.id == null) return;
    try {
      _d(
        'Finishing workoutId=${_workout?.id} cancelled=$cancelled markCompleted=$markWorkoutCompleted',
      );
      setState(() => _isLoading = true);

      final workoutSvc = _ref!.read(workoutServiceProvider);
      final updated = await workoutSvc.finishWorkoutBff(
        _workout!.id!,
        includeDefinitions: false,
        cancelled: cancelled,
        markWorkoutCompleted: markWorkoutCompleted,
      );
      if (!mounted) return;

      _stopSessionTicker();
      await _loadActiveSession();

      setState(() {
        _workout = updated;
        _editedStartedAt ??= updated.startedAt;
        if ((updated.durationSeconds ?? 0) > 0) {
          _durationCtrl.text = (updated.durationSeconds!).toString();
        }
      });

      try {
        await _ref!.read(apiClientProvider).invalidateCacheGroups([
          'workouts:detail',
          'workouts:detail:${updated.id}',
          'workouts:list',
        ]);
        if (!cancelled && markWorkoutCompleted && updated.appliedPlanId != null) {
          await _ref!.read(apiClientProvider).invalidateCacheGroups(const ['plans:active', 'plans:active_workouts']);
        }
      } catch (_) {}

      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            cancelled ? l10n.sessionCancelled : l10n.workoutFinished,
          ),
        ),
      );

      if (!cancelled && updated.appliedPlanId != null) await _maybeShowMacroSuggestion();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).failedToFinishSession('$e')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _completeAllSets() async {
    if (_activeSession?.id == null ||
        _activeSession?.isActive != true ||
        _workout == null)
      return;

    setState(() => _isLoading = true);
    try {
      final setsToComplete = <Map<String, int>>[];
      final allSetsByInstance = <int, Set<int>>{};

      for (final instance in _workout!.exerciseInstances) {
        final instanceId = instance.id;
        if (instanceId == null) continue;

        final allSetIds = <int>{};
        for (final set in instance.sets) {
          final setId = set.id;
          if (setId == null) continue;
          allSetIds.add(setId);
          if (!_isSetCompleted(instanceId, setId)) {
            setsToComplete.add({'instanceId': instanceId, 'setId': setId});
          }
        }
        if (allSetIds.isNotEmpty) {
          allSetsByInstance[instanceId] = allSetIds;
        }
      }

      if (setsToComplete.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).allSetsAlreadyCompleted),
            ),
          );
        }
        return;
      }

      final svc = _ref!.read(workoutSessionServiceProvider);
      WorkoutSession? latestSession;
      int success = 0;
      int failed = 0;

      for (final item in setsToComplete) {
        final instanceId = item['instanceId']!;
        final setId = item['setId']!;
        try {
          latestSession = await svc.updateSetCompletion(
            sessionId: _activeSession!.id!,
            instanceId: instanceId,
            setId: setId,
            completed: true,
          );
          success++;
        } catch (e) {
          failed++;
          _d('Mark-all failed for instance=$instanceId set=$setId: $e');
        }
      }

      if (!mounted) return;

      if (latestSession != null) {
        setState(() => _activeSession = latestSession);
        _d('Mark-all latest progress from API: ${latestSession.progress}');
        _parseProgressFromSession();
      }

      // Fallback: если backend вернул пустой progress, но запросы по сетам были успешны,
      // локально выставляем completed, чтобы UI отражал фактическое действие пользователя.
      final hasCompletedFromSession = _completedByInstance.values.any(
        (s) => s.isNotEmpty,
      );
      if (!hasCompletedFromSession && success > 0) {
        _completedByInstance
          ..clear()
          ..addAll(allSetsByInstance);
        if (mounted) setState(() {});
        _d(
          'Mark-all fallback applied locally. completedByInstance=$_completedByInstance',
        );
      }

      final msg = failed == 0
          ? AppLocalizations.of(context).allSetsMarkedCompleted(success)
          : AppLocalizations.of(context).markedSetsPartial(failed, success);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).failedToCompleteAllSets('$e'),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isSetCompleted(int instanceId, int setId) {
    final s = _completedByInstance[instanceId];
    return s != null && s.contains(setId);
  }

  Future<void> _toggleSetCompletion(
    ExerciseInstance instance,
    ExerciseSetDto set,
  ) async {
    if (_activeSession?.id == null || _activeSession?.isActive != true) return;
    if (instance.id == null || set.id == null) return;
    if (_isTogglingSet) return;
    _isTogglingSet = true;

    final instanceId = instance.id!;
    final setId = set.id!;
    final desired = !_isSetCompleted(instanceId, setId);

    final current = _completedByInstance[instanceId] ?? <int>{};
    final updated = Set<int>.from(current);
    if (desired) {
      updated.add(setId);
    } else {
      updated.remove(setId);
    }
    if (updated.isEmpty) {
      _completedByInstance.remove(instanceId);
    } else {
      _completedByInstance[instanceId] = updated;
    }
    if (mounted) {
      setState(() {});
    }
    try {
      final svc = _ref!.read(workoutSessionServiceProvider);
      final session = await svc.updateSetCompletion(
        sessionId: _activeSession!.id!,
        instanceId: instanceId,
        setId: setId,
        completed: desired,
      );
      if (!mounted) return;
      setState(() => _activeSession = session);
      _parseProgressFromSession();
    } catch (e) {
      final rollbackCurrent = _completedByInstance[instanceId] ?? <int>{};
      final rollback = Set<int>.from(rollbackCurrent);
      if (desired) {
        rollback.remove(setId);
      } else {
        rollback.add(setId);
      }
      if (rollback.isEmpty) {
        _completedByInstance.remove(instanceId);
      } else {
        _completedByInstance[instanceId] = rollback;
      }
      if (mounted) {
        setState(() {});
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).failedToUpdateSetCompletion('$e'),
            ),
          ),
        );
      }
    } finally {
      _isTogglingSet = false;
    }
  }

  int? _repsFromIntensityEffort(int intensity, int effort) {
    final row = _rpeTable[intensity];
    return row?[effort];
  }

  int? _effortFromIntensityReps(int intensity, int reps) {
    final row = _rpeTable[intensity];
    if (row == null) return null;
    for (final e in row.entries) {
      if (e.value == reps) return e.key;
    }
    return null;
  }

  int? _intensityFromEffortReps(int effort, int reps) {
    int? best;
    for (final entry in _rpeTable.entries) {
      if (entry.value[effort] == reps) {
        best = entry.key;
        break;
      }
    }
    return best;
  }

  int? _intensityFromWeight(int exerciseId, double w) {
    final max = _exerciseMaxByExerciseId[exerciseId];
    if (max == null || max <= 0) return null;
    int pct = ((w / max) * 100).round();
    if (pct < 1) pct = 1;
    if (pct > 100) pct = 100;
    return pct;
  }

  String _editorKey(
    ExerciseInstance instance,
    int setIndex,
    ExerciseSetDto set,
  ) {
    final instKey = instance.id?.toString() ?? 'inst';
    final setKey = set.id?.toString() ?? 'idx$setIndex';
    return '$instKey-$setKey';
  }

  _SetEditor _getSetEditor(
    ExerciseInstance instance,
    int setIndex,
    ExerciseSetDto set,
  ) {
    final key = _editorKey(instance, setIndex, set);
    final existing = _setEditors[key];
    if (existing != null) return existing;
    String fmtWeight(double w) =>
        (w % 1 == 0) ? w.toStringAsFixed(0) : w.toStringAsFixed(1);
    final editor = _SetEditor(
      weightCtrl: TextEditingController(text: fmtWeight(set.weight)),
      repsCtrl: TextEditingController(text: set.reps.toString()),
      rpeCtrl: TextEditingController(
        text: set.rpeValue == null
            ? ''
            : ((set.rpeValue! % 1 == 0)
                  ? set.rpeValue!.toStringAsFixed(0)
                  : set.rpeValue!.toStringAsFixed(1)),
      ),
    );
    _setEditors[key] = editor;
    return editor;
  }

  Future<void> _handleCompletedSetIdMigration(
    int instanceId,
    int oldSetId,
    int newSetId,
  ) async {
    final localChanged = _updateLocalCompletion(instanceId, oldSetId, newSetId);
    final sessionActive =
        _activeSession?.id != null && _activeSession?.isActive == true;
    if (!sessionActive || _ref == null) {
      if (localChanged && mounted) {
        setState(() {});
      }
      return;
    }
    if (localChanged && mounted) {
      setState(() {});
    }
    try {
      final svc = _ref!.read(workoutSessionServiceProvider);
      final sessionId = _activeSession!.id!;
      await svc.updateSetCompletion(
        sessionId: sessionId,
        instanceId: instanceId,
        setId: oldSetId,
        completed: false,
      );
      final session = await svc.updateSetCompletion(
        sessionId: sessionId,
        instanceId: instanceId,
        setId: newSetId,
        completed: true,
      );
      if (!mounted) return;
      setState(() => _activeSession = session);
      _parseProgressFromSession();
    } catch (e) {
      _d('Failed to resync set completion: $e');
    }
  }

  bool _updateLocalCompletion(int instanceId, int oldSetId, int newSetId) {
    final current = _completedByInstance[instanceId];
    if (current == null || !current.contains(oldSetId)) {
      return false;
    }
    final updated = Set<int>.from(current);
    updated.remove(oldSetId);
    updated.add(newSetId);
    _completedByInstance[instanceId] = updated;
    return true;
  }

  void _onInlineFieldChanged(
    ExerciseInstance instance,
    int setIndex,
    ExerciseSetDto set,
    String field,
    String value,
  ) {
    if (_isSyncingFields) return;
    final editor = _getSetEditor(instance, setIndex, set);

    editor.editedFields.remove(field);
    editor.editedFields.add(field);
    if (editor.editedFields.length > 2) editor.editedFields.removeAt(0);
    if (editor.autoDerivedField == field) {
      editor.autoDerivedField = null;
    }

    double? parseDouble(String s) =>
        double.tryParse(s.replaceAll(',', '.').trim());
    int? parseInt(String s) => int.tryParse(s.trim());

    final w = parseDouble(editor.weightCtrl.text);
    final r = parseInt(editor.repsCtrl.text);
    final eRaw = parseDouble(editor.rpeCtrl.text);
    final e = eRaw?.round();

    final bool hasTwo = editor.editedFields.length >= 2;
    String? third;
    if (hasTwo) {
      final a = editor.editedFields[0];
      final b = editor.editedFields[1];
      third = {'weight', 'reps', 'rpe'}.difference({a, b}).first;
    }

    String fmtWeight(double v) =>
        (v % 1 == 0) ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

    int exerciseId = instance.exerciseListId;
    _isSyncingFields = true;
    try {
      if (hasTwo && third == 'weight' && r != null && e != null) {
        final intensity = _intensityFromEffortReps(
          e.clamp(1, 10),
          r.clamp(1, 1000),
        );
        final max = _exerciseMaxByExerciseId[exerciseId];
        if (intensity != null && max != null) {
          final newWeight = max * (intensity / 100.0);
          editor.weightCtrl.text = fmtWeight(newWeight);
          editor.autoDerivedField = 'weight';
        }
      } else if (hasTwo && third == 'reps' && w != null && e != null) {
        final intensity = _intensityFromWeight(exerciseId, w);
        final reps = (intensity != null)
            ? _repsFromIntensityEffort(intensity, e.clamp(1, 10))
            : null;
        if (reps != null) {
          editor.repsCtrl.text = reps.toString();
          editor.autoDerivedField = 'reps';
        }
      } else if (hasTwo && third == 'rpe' && w != null && r != null) {
        final intensity = _intensityFromWeight(exerciseId, w);
        final eff = (intensity != null)
            ? _effortFromIntensityReps(intensity, r.clamp(1, 1000))
            : null;
        if (eff != null) {
          editor.rpeCtrl.text = eff.toString();
          editor.autoDerivedField = 'rpe';
        }
      }
    } finally {
      _isSyncingFields = false;
    }
    if (mounted) setState(() {});

    editor.scheduleDebounce(() {
      if (!mounted) return;
      editor.cancelDebounce();
      unawaited(_onInlineFieldSubmitted(instance, setIndex, set));
    });
  }

  Future<void> _onInlineFieldSubmitted(
    ExerciseInstance instance,
    int setIndex,
    ExerciseSetDto set,
  ) async {
    final editor = _getSetEditor(instance, setIndex, set);
    editor.cancelDebounce();
    double? parseDouble(String s) =>
        double.tryParse(s.replaceAll(',', '.').trim());
    int? parseInt(String s) => int.tryParse(s.trim());

    final double? weight = parseDouble(editor.weightCtrl.text);
    final int? reps = parseInt(editor.repsCtrl.text);
    final double? rpe = parseDouble(editor.rpeCtrl.text)?.clamp(1.0, 10.0);

    final fields = <String, bool>{
      'weight': weight != null,
      'reps': reps != null,
      'rpe': rpe != null,
    };
    final known = fields.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    if (known.length == 2) {
      _isSyncingFields = true;
      try {
        int exerciseId = instance.exerciseListId;
        final a = known[0];
        final b = known[1];
        final third = {'weight', 'reps', 'rpe'}.difference({a, b}).first;

        String fmtWeight(double v) =>
            (v % 1 == 0) ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

        if (third == 'weight' && reps != null && rpe != null) {
          final intensity = _intensityFromEffortReps(
            (rpe.round()).clamp(1, 10),
            reps.clamp(1, 1000),
          );
          final max = _exerciseMaxByExerciseId[exerciseId];
          if (intensity != null && max != null) {
            final w = max * (intensity / 100.0);
            editor.weightCtrl.text = fmtWeight(w);
            editor.autoDerivedField = 'weight';
          }
        } else if (third == 'reps' && weight != null && rpe != null) {
          final intensity = _intensityFromWeight(exerciseId, weight);
          final repsCalc = (intensity != null)
              ? _repsFromIntensityEffort(intensity, rpe.round().clamp(1, 10))
              : null;
          if (repsCalc != null) {
            editor.repsCtrl.text = repsCalc.toString();
            editor.autoDerivedField = 'reps';
          }
        } else if (third == 'rpe' && weight != null && reps != null) {
          final intensity = _intensityFromWeight(exerciseId, weight);
          final eff = (intensity != null)
              ? _effortFromIntensityReps(intensity, reps.clamp(1, 1000))
              : null;
          if (eff != null) {
            editor.rpeCtrl.text = eff.toString();
            editor.autoDerivedField = 'rpe';
          }
        }
      } finally {
        _isSyncingFields = false;
      }
    }

    final double? finalWeightRaw = double.tryParse(
      editor.weightCtrl.text.replaceAll(',', '.'),
    );
    final int? finalRepsRaw = int.tryParse(editor.repsCtrl.text.trim());
    final double? finalRpeRaw = double.tryParse(editor.rpeCtrl.text.trim());
    final double? finalWeight = finalWeightRaw?.clamp(0.0, 10000.0);
    final int? finalReps = finalRepsRaw?.clamp(1, 1000);
    final double? finalRpe = finalRpeRaw?.clamp(1.0, 10.0);

    await _updateSetField(
      instance,
      setIndex,
      reps: finalReps,
      weight: finalWeight,
      rpe: finalRpe,
    );
  }

  Future<void> _handleDeleteSet(ExerciseInstance instance, int setIndex) async {
    try {
      if (instance.id == null) {
        throw Exception('Cannot delete set: Instance ID is null');
      }

      if (setIndex < 0 || setIndex >= instance.sets.length) {
        throw Exception('Invalid set index: $setIndex');
      }

      final setToDelete = instance.sets[setIndex];

      final l10n = AppLocalizations.of(context);
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.deleteSetTitle),
          content: Text(l10n.deleteSetConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel.toUpperCase()),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(l10n.delete.toUpperCase()),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      setState(() {
        _isLoading = true;
      });

      if (setToDelete.id == null) {
        final workoutService = _ref!.read(workoutServiceProvider);
        try {
          await _loadExercises();

          final refreshedInstance = _workout?.exerciseInstances.firstWhere(
            (i) => i.id == instance.id,
            orElse: () => instance,
          );

          if (refreshedInstance != null &&
              setIndex >= 0 &&
              setIndex < refreshedInstance.sets.length) {
            final refreshedSet = refreshedInstance.sets[setIndex];
            if (refreshedSet.id != null && instance.id != null) {
              await workoutService.deleteExerciseSet(
                instance.id!,
                refreshedSet.id!,
              );

              final updatedSets = List<ExerciseSetDto>.from(
                refreshedInstance.sets,
              )..removeAt(setIndex);
              final updatedInstance = refreshedInstance.copyWith(
                sets: updatedSets,
              );

              if (_workout != null) {
                final updatedInstances = List<ExerciseInstance>.from(
                  _workout!.exerciseInstances,
                );
                final idx = updatedInstances.indexWhere(
                  (i) => i.id == updatedInstance.id,
                );
                if (idx != -1) {
                  updatedInstances[idx] = updatedInstance;
                  setState(() {
                    _workout = _workout!.copyWith(
                      exerciseInstances: updatedInstances,
                    );
                  });
                }
              }
              _reconcileEditors();

              await _loadExercises();
            } else {
              final updatedSets = List<ExerciseSetDto>.from(instance.sets)
                ..removeAt(setIndex);
              final updatedInstance = instance.copyWith(sets: updatedSets);
              if (_workout != null) {
                final updatedInstances = List<ExerciseInstance>.from(
                  _workout!.exerciseInstances,
                );
                final idx = updatedInstances.indexWhere(
                  (i) => i.id == instance.id,
                );
                if (idx != -1) {
                  updatedInstances[idx] = updatedInstance;
                  setState(() {
                    _workout = _workout!.copyWith(
                      exerciseInstances: updatedInstances,
                    );
                  });
                }
              }
              _reconcileEditors();
            }
          } else {
            final updatedSets = List<ExerciseSetDto>.from(instance.sets)
              ..removeAt(setIndex);
            final updatedInstance = instance.copyWith(sets: updatedSets);
            if (_workout != null) {
              final updatedInstances = List<ExerciseInstance>.from(
                _workout!.exerciseInstances,
              );
              final idx = updatedInstances.indexWhere(
                (i) => i.id == instance.id,
              );
              if (idx != -1) {
                updatedInstances[idx] = updatedInstance;
                setState(() {
                  _workout = _workout!.copyWith(
                    exerciseInstances: updatedInstances,
                  );
                });
              }
            }
            _reconcileEditors();
          }
        } catch (e) {
          final updatedSets = List<ExerciseSetDto>.from(instance.sets)
            ..removeAt(setIndex);
          final updatedInstance = instance.copyWith(sets: updatedSets);
          if (_workout != null) {
            final updatedInstances = List<ExerciseInstance>.from(
              _workout!.exerciseInstances,
            );
            final idx = updatedInstances.indexWhere((i) => i.id == instance.id);
            if (idx != -1) {
              updatedInstances[idx] = updatedInstance;
              setState(() {
                _workout = _workout!.copyWith(
                  exerciseInstances: updatedInstances,
                );
              });
            }
          }
          _reconcileEditors();
        }
      } else {
        final workoutService = _ref!.read(workoutServiceProvider);
        await workoutService.deleteExerciseSet(instance.id!, setToDelete.id!);

        final updatedSets = List<ExerciseSetDto>.from(instance.sets)
          ..removeAt(setIndex);
        final updatedInstance = instance.copyWith(sets: updatedSets);

        if (_workout != null) {
          final updatedInstances = List<ExerciseInstance>.from(
            _workout!.exerciseInstances,
          );
          final index = updatedInstances.indexWhere((i) => i.id == instance.id);
          if (index != -1) {
            updatedInstances[index] = updatedInstance;
            setState(() {
              _workout = _workout!.copyWith(
                exerciseInstances: updatedInstances,
              );
            });
          }
        }
        _reconcileEditors();

        await _loadExercises();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).setDeletedSuccessfully),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('Error deleting set: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).failedToDeleteSet(e.toString()),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  double _calculateTotalVolume(ExerciseInstance instance) {
    return instance.sets.fold<double>(
      0,
      (sum, set) => sum + (set.weight * set.reps),
    );
  }

  Future<void> _showAddExerciseDialog() async {
    try {
      if (_workout?.id == null) {
        throw Exception('Workout ID is required');
      }

      final selectedExercise = await Navigator.push<ExerciseDefinition>(
        context,
        MaterialPageRoute(
          builder: (context) => const ExerciseSelectionScreen(),
        ),
      );

      if (selectedExercise != null) {
        if (selectedExercise.id == null) {
          throw Exception('Exercise ID is required');
        }

        final instance = ExerciseInstance(
          exerciseListId: selectedExercise.id!,
          exerciseDefinition: selectedExercise,
          workoutId: _workout!.id!,
          order: _workout?.exerciseInstances.length,
          sets: const [ExerciseSetDto(reps: 0, weight: 0.0, order: 0)],
        );

        final workoutService = _ref!.read(workoutServiceProvider);
        setState(() => _isLoading = true);
        try {
          final created = await workoutService.createExerciseInstance(instance);
          _d('Created new exercise instance: ${created.id}');
          await _loadExercises();
        } finally {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).exerciseAddedSuccessfully,
              ),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('Error adding exercise: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).failedToAddExercise(e.toString()),
            ),
          ),
        );
      }
    }
  }

  Future<void> _navigateToExerciseForm(
    ExerciseDefinition exercise,
    ExerciseInstance? instance,
  ) async {
    if (_workout?.id == null) return;

    try {
      final exerciseDef = instance?.exerciseDefinition ?? exercise;

      final result = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (context) => ExerciseFormScreen(
            exercise: exerciseDef,
            workoutId: _workout!.id!,
            defaultOrder: _workout?.exerciseInstances.length,
            initialInstance: instance,
          ),
        ),
      );

      if (result != null && mounted) {
        final updatedInstance = result['instance'] as ExerciseInstance?;
        final refresh = result['refresh'] == true;

        if (updatedInstance != null) {
          final workoutService = _ref!.read(workoutServiceProvider);
          setState(() => _isLoading = true);
          try {
            if (updatedInstance.id == null) {
              await workoutService.createExerciseInstance(updatedInstance);
            } else {
              await workoutService.updateExerciseInstance(updatedInstance);
            }
          } finally {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          }
        }

        if (refresh) {
          await _loadExercises();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  updatedInstance?.id == null
                      ? AppLocalizations.of(context).exerciseAddedSuccessfully
                      : AppLocalizations.of(context).exerciseUpdatedSuccessfully,
                ),
              ),
            );
          }
        }
      }
    } catch (e, stackTrace) {
      print('Error in exercise form: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).errorUpdatingExercise(e.toString()),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>> _buildChatContext() async {
    return <String, dynamic>{
      'v': 1,
      'app': 'WorkoutApp',
      'screen': 'workout_detail',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'entities': <String, dynamic>{
        'workout_id': _workout?.id,
        'workout_name': _workout?.name,
        'is_active_session': _activeSession?.isActive == true,
        'readiness_score': _readinessSlider.round(),
        'exercise_count': _uniqueExercises.length,
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        _ref = ref;
        final isLive = _activeSession?.isActive == true;
        final env = TrainingEnvironmentData.fromWorkout(
          _workout,
          isLiveExecution: isLive,
        );
        final interfaceConfig = ref.watch(interfaceMakerProvider);
        final instrument = InstrumentTheme.of(context);
        final accent = env.accentColor(instrument);

        if (_isLoading) {
          return AmbientScaffoldShell(
            environment: env,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return AssistantChatHost(
          contextBuilder: _buildChatContext,
          builder: (context, openChat) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: Theme.of(context).brightness == Brightness.light
                  ? SystemUiOverlayStyle.dark
                  : SystemUiOverlayStyle.light,
              child: AmbientScaffoldShell(
                environment: env,
                appBar: FloatingHeaderBar(
                  title: _workout?.name ?? AppLocalizations.of(context).workoutDetailFallbackTitle,
                  onTitleTap: openChat,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  actions: [
                    IconButton(
                      tooltip: AppLocalizations.of(context).gridPillLabel,
                      icon: const Icon(Icons.grid_view_rounded),
                      onPressed: () => InterfaceMakerSheet.show(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.restaurant),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NutritionPlanCreate(
                              initialPlan: {
                                'workout_id': _workout?.id,
                                'user_id': 1,
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadExercises,
                    ),
                  ],
                  onProfileTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const UserProfileScreen(),
                      ),
                    );
                  },
                ),
                body: ResponsiveContainer(
                  maxWidth: Breakpoints.maxContentWidthMedium,
                  child: _buildBody(
                    env: env,
                    interfaceConfig: interfaceConfig,
                    accent: accent,
                  ),
                ),
                bottomNavigationBar: SafeArea(
                  top: false,
                  child: ResponsiveContainer(
                    maxWidth: Breakpoints.maxContentWidthMedium,
                    child: Padding(
                      padding: EdgeInsets.all(UiDimensions.of(context).pagePadding),
                      child: FilledButton.icon(
                        onPressed: _showAddExerciseDialog,
                        style: FilledButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: accent.computeLuminance() > 0.45
                              ? const Color(0xFF0A0E14)
                              : Colors.white,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        icon: const Icon(Icons.add_rounded),
                        label: Text(AppLocalizations.of(context).exerciseFormTitleAdd),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBody({
    required TrainingEnvironmentData env,
    required InterfaceConfig interfaceConfig,
    required Color accent,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dimensions = UiDimensions.of(context);
    if (_isLoadingExercises) {
      return const Center(child: CircularProgressIndicator());
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(height: AmbientScaffoldShell.topContentInset(context)),
        ),
        if (_workout != null)
          SliverToBoxAdapter(
            child: _buildExecutionHeader(
              env: env,
              interfaceConfig: interfaceConfig,
              accent: accent,
            ),
          ),
        if (_uniqueExercises.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  dimensions.sectionGap * 2,
                  dimensions.sectionGap,
                  dimensions.sectionGap * 2,
                  AmbientScaffoldShell.bottomContentInset(context),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scheme.surfaceContainerHigh,
                      ),
                      child: Icon(
                        Icons.fitness_center_rounded,
                        size: 36,
                        color: accent,
                      ),
                    ),
                    SizedBox(height: dimensions.sectionGap),
                    Text(
                      AppLocalizations.of(context).workoutDetailNoExercisesTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: dimensions.rowGap),
                    Text(
                      AppLocalizations.of(context).workoutDetailNoExercisesSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              dimensions.pagePadding,
              dimensions.rowGap,
              dimensions.pagePadding,
              AmbientScaffoldShell.bottomContentInset(context),
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildExerciseCard(
                  _uniqueExercises[index],
                  accent: accent,
                ),
                childCount: _uniqueExercises.length,
              ),
            ),
          ),
      ],
    );
  }

  List<InstrumentMetricCellData> _buildExecutionMatrixCells(
    InterfaceConfig interfaceConfig, {
    required TrainingEnvironmentData env,
    required Color accent,
  }) {
    final w = _workout;
    double liveTonnage = 0;
    int liveReps = 0;
    int liveSets = 0;
    double rpeSum = 0;
    int rpeCount = 0;
    double? peakRpe;
    double? peakE1rm;
    double? peakIntensity;

    if (w != null) {
      for (final inst in w.exerciseInstances) {
        for (int i = 0; i < inst.sets.length; i++) {
          final s = inst.sets[i];
          final editor = _setEditors[_editorKey(inst, i, s)];
          final double weightVal = editor != null
              ? (double.tryParse(
                      editor.weightCtrl.text.replaceAll(',', '.').trim(),
                    ) ??
                    s.weight)
              : s.weight;
          final int repsVal = editor != null
              ? (int.tryParse(editor.repsCtrl.text.trim()) ?? s.reps)
              : s.reps;
          final double? rpeVal = editor != null
              ? (double.tryParse(
                      editor.rpeCtrl.text.replaceAll(',', '.').trim(),
                    ) ??
                    s.rpeValue)
              : s.rpeValue;

          liveSets++;
          liveReps += repsVal;
          if (weightVal > 0 && repsVal > 0) {
            liveTonnage += weightVal * repsVal;
            double? e1rm;
            if (rpeVal != null && rpeVal >= 6.0 && rpeVal <= 10.0) {
              final pct = rpe_table.RpeTable.getIntensity(
                repsVal,
                rpeVal.round(),
              );
              if (pct != null && pct > 0) {
                e1rm = weightVal / (pct / 100.0);
              }
            }
            e1rm ??= repsVal == 1
                ? weightVal
                : weightVal * (1.0 + repsVal / 30.0);
            peakE1rm = peakE1rm == null || e1rm > peakE1rm ? e1rm : peakE1rm;
          }
          if (rpeVal != null && rpeVal > 0) {
            rpeSum += rpeVal;
            rpeCount++;
            peakRpe = peakRpe == null || rpeVal > peakRpe ? rpeVal : peakRpe;
          }
          if (s.intensity > 0) {
            final iv = s.intensity.toDouble();
            peakIntensity =
                peakIntensity == null || iv > peakIntensity ? iv : peakIntensity;
          }
        }
      }
    }

    final avgRpe = rpeCount > 0 ? rpeSum / rpeCount : env.avgRpe;
    final hasAutoDerived = _setEditors.values.any(
      (e) => e.autoDerivedField != null,
    );

    return interfaceConfig.slots.map((slot) {
      switch (slot) {
        case MetricSlot.peakIntensity:
          return InstrumentMetricCellData(
            slot: slot,
            value: peakIntensity != null ? '${peakIntensity.round()}%' : '—',
            valueColor: peakIntensity != null ? accent : null,
          );
        case MetricSlot.e1rm:
          return InstrumentMetricCellData(
            slot: slot,
            value: peakE1rm != null ? '${peakE1rm.round()} kg' : '—',
            isAutoDerived: hasAutoDerived,
          );
        case MetricSlot.peakRpe:
          return InstrumentMetricCellData(
            slot: slot,
            value: peakRpe != null ? 'RPE ${peakRpe.toStringAsFixed(1)}' : '—',
            valueColor: peakRpe != null ? accent : null,
          );
        case MetricSlot.avgRpe:
          return InstrumentMetricCellData(
            slot: slot,
            value: avgRpe != null ? 'RPE ${avgRpe.toStringAsFixed(1)}' : '—',
          );
        case MetricSlot.tonnage:
          return InstrumentMetricCellData(
            slot: slot,
            value: liveTonnage > 0 ? '${liveTonnage.round()} kg' : '—',
          );
        case MetricSlot.kpsh:
          return InstrumentMetricCellData(
            slot: slot,
            value: liveReps > 0 ? '$liveReps' : '—',
          );
        case MetricSlot.setsCount:
          return InstrumentMetricCellData(
            slot: slot,
            value: liveSets > 0 ? '$liveSets' : '—',
          );
        case MetricSlot.density:
          final exCount = w?.exerciseInstances.length ?? 0;
          return InstrumentMetricCellData(
            slot: slot,
            label: AppLocalizations.of(context).metricExercisesShort,
            value: '$exCount',
          );
        case MetricSlot.durationWeeks:
          return InstrumentMetricCellData(
            slot: slot,
            label: AppLocalizations.of(context).metricTimerShort,
            value: _formatDuration(_elapsed),
          );
        case MetricSlot.frequencyPerWeek:
          return InstrumentMetricCellData(
            slot: slot,
            label: AppLocalizations.of(context).metricModeShort,
            value: env.localizedBadgeLabel(AppLocalizations.of(context)),
          );
      }
    }).toList(growable: false);
  }

  Widget _buildExecutionHeader({
    required TrainingEnvironmentData env,
    required InterfaceConfig interfaceConfig,
    required Color accent,
  }) {
    final isActive = _activeSession?.isActive == true;
    final matrixCells = _buildExecutionMatrixCells(
      interfaceConfig,
      env: env,
      accent: accent,
    );
    return WorkoutExecutionHeaderBar(
      isActiveSession: isActive,
      isBusy: _isLoading,
      canStartSession: _workout?.id != null,
      lastFinishedAt: _activeSession?.finishedAt,
      lastElapsed: _elapsed,
      elapsedListenable: _elapsedNotifier,
      formatDuration: _formatDuration,
      onStartSession: _startSession,
      onCancelSession: () => _finishSession(cancelled: true),
      onCompleteAllSets: _completeAllSets,
      onFinishSession: () =>
          _finishSession(cancelled: false, markWorkoutCompleted: true),
      readinessScore: _readinessSlider.round(),
      readinessFactor: _readinessFactor(_readinessSlider),
      isApplyingReadiness: _isApplyingReadiness,
      canApplyReadiness: _workout != null,
      onDecrementReadiness: () {
        final current =
            int.tryParse(_readinessCtrl.text) ?? _readinessSlider.round();
        final next = (current - 1).clamp(0, 10);
        setState(() {
          _readinessSlider = next.toDouble();
          _writeReadinessText(_readinessSlider);
        });
      },
      onIncrementReadiness: () {
        final current =
            int.tryParse(_readinessCtrl.text) ?? _readinessSlider.round();
        final next = (current + 1).clamp(0, 10);
        setState(() {
          _readinessSlider = next.toDouble();
          _writeReadinessText(_readinessSlider);
        });
      },
      onApplyReadiness: _applyReadinessScaling,
      footerSlot: InstrumentMetricMatrix(
        cells: matrixCells,
        accentColor: accent,
        onSelectSlot: (_) => InterfaceMakerSheet.show(context),
      ),
    );
  }

  Widget _buildExerciseCard(
    ExerciseDefinition exercise, {
    required Color accent,
  }) {
    final instances =
        _workout?.exerciseInstances
            .where((instance) => instance.exerciseListId == exercise.id)
            .toList() ??
        [];

    if (instances.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: instances
          .map(
            (instance) => _buildInstanceCard(
              instance,
              exercise: exercise,
              accent: accent,
            ),
          )
          .toList(),
    );
  }

  Widget _buildInstanceCard(
    ExerciseInstance instance, {
    required ExerciseDefinition exercise,
    required Color accent,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dimensions = UiDimensions.of(context);
    final instrument = InstrumentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hairline = (isDark ? instrument.hairlineBorder : scheme.outlineVariant)
        .withValues(alpha: isDark ? 0.85 : 0.55);
    final isUpdating =
        instance.id != null && _updatingInstanceIds.contains(instance.id!);
    final totalVolume = _calculateTotalVolume(instance);
    final metaParts = <String>[
      if ((exercise.muscleGroup ?? '').isNotEmpty) exercise.muscleGroup!,
      if ((exercise.equipment ?? '').isNotEmpty) exercise.equipment!,
      AppLocalizations.of(context).setCountLabel(instance.sets.length),
      if (totalVolume > 0) '${totalVolume.round()} kg',
    ];

    return Container(
      margin: EdgeInsets.only(bottom: dimensions.cardPadding),
      decoration: InstrumentTheme.instrumentCardDecoration(
        context,
        accentColor: accent,
        radius: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                        metaParts.join(' · ').toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: InstrumentTheme.tabular(
                          InstrumentTheme.microLabel(
                            context,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        exercise.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (instance.notes?.isNotEmpty == true) ...[
                        const SizedBox(height: 3),
                        Text(
                          instance.notes!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton(
                        icon: isUpdating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.add_circle_outline, size: 20),
                        onPressed: (isUpdating || _isLoading)
                            ? null
                            : () => _addSetToInstance(instance),
                        tooltip: AppLocalizations.of(context).exerciseFormAddSet,
                        color: accent,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () => _navigateToExerciseForm(
                          instance.exerciseDefinition ??
                              ExerciseDefinition(
                                id: instance.exerciseListId,
                                name: exercise.name,
                                muscleGroup: exercise.muscleGroup ?? '',
                                equipment: exercise.equipment ?? '',
                              ),
                          instance,
                        ),
                        tooltip: AppLocalizations.of(context).tooltipEditExercise,
                        color: scheme.primary,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () => _deleteExerciseInstance(instance),
                        tooltip: AppLocalizations.of(context).deleteExerciseTooltip,
                        color: scheme.error,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (instance.sets.isNotEmpty) ...[
            Container(height: 1, color: hairline),
            const SetTableColumnHeaders(),
          ],
          ...instance.sets.asMap().entries.map((entry) {
            final setIndex = entry.key;
            final set = entry.value;
            final editor = _getSetEditor(instance, setIndex, set);
            final bool isCompleted =
                _activeSession != null && instance.id != null && set.id != null
                ? _isSetCompleted(instance.id!, set.id!)
                : false;
            final bool canToggle =
                _activeSession?.isActive == true &&
                instance.id != null &&
                set.id != null;
            final double? currentRpe =
                double.tryParse(editor.rpeCtrl.text.replaceAll(',', '.').trim()) ??
                set.rpeValue;

            return SetCapsuleRow(
              setIndex: setIndex,
              isCompleted: isCompleted,
              canToggle: canToggle,
              isBusy: _isLoading,
              weightController: editor.weightCtrl,
              repsController: editor.repsCtrl,
              rpeController: editor.rpeCtrl,
              currentRpeValue: currentRpe,
              autoDerivedField: editor.autoDerivedField,
              onToggleCompletion: canToggle
                  ? () => _toggleSetCompletion(instance, set)
                  : null,
              onDelete: () => _handleDeleteSet(instance, setIndex),
              onWeightChanged: (v) => _onInlineFieldChanged(
                instance,
                setIndex,
                set,
                'weight',
                v,
              ),
              onRepsChanged: (v) => _onInlineFieldChanged(
                instance,
                setIndex,
                set,
                'reps',
                v,
              ),
              onRpeChanged: (v) => _onInlineFieldChanged(
                instance,
                setIndex,
                set,
                'rpe',
                v,
              ),
              onWeightSubmitted: () {
                editor.cancelDebounce();
                _onInlineFieldSubmitted(instance, setIndex, set);
              },
              onRepsSubmitted: () {
                editor.cancelDebounce();
                _onInlineFieldSubmitted(instance, setIndex, set);
              },
              onRpeSubmitted: () {
                editor.cancelDebounce();
                _onInlineFieldSubmitted(instance, setIndex, set);
              },
            );
          }),
          if (instance.sets.isNotEmpty) const SizedBox(height: 4),
        ],
      ),
    );
  }

  void _reconcileEditors({bool triggerRebuild = true}) {
    if (_workout == null) return;
    final validKeys = <String>{};
    _isSyncingFields = true;
    try {
      for (final instance in _workout!.exerciseInstances) {
        for (int i = 0; i < instance.sets.length; i++) {
          final set = instance.sets[i];
          final key = _editorKey(instance, i, set);
          validKeys.add(key);
          final editor = _setEditors[key] ?? _getSetEditor(instance, i, set);

          String fmtWeight(double w) =>
              (w % 1 == 0) ? w.toStringAsFixed(0) : w.toStringAsFixed(1);
          final desiredWeight = fmtWeight(set.weight);
          final desiredReps = set.reps.toString();
          final desiredRpe = set.rpeValue == null
              ? ''
              : ((set.rpeValue! % 1 == 0)
                    ? set.rpeValue!.toStringAsFixed(0)
                    : set.rpeValue!.toStringAsFixed(1));
          if (editor.weightCtrl.text != desiredWeight)
            editor.weightCtrl.text = desiredWeight;
          if (editor.repsCtrl.text != desiredReps)
            editor.repsCtrl.text = desiredReps;
          if (editor.rpeCtrl.text != desiredRpe)
            editor.rpeCtrl.text = desiredRpe;
        }
      }
    } finally {
      _isSyncingFields = false;
    }

    final toRemove = _setEditors.keys
        .where((k) => !validKeys.contains(k))
        .toList();
    for (final k in toRemove) {
      _setEditors[k]?.dispose();
      _setEditors.remove(k);
    }
    if (triggerRebuild && mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final e in _setEditors.values) {
      e.dispose();
    }
    _d('Disposing WorkoutDetailScreen; cleaning up');
    _stopSessionTicker();
    _elapsedNotifier.dispose();

    _notesCtrl.dispose();
    _statusCtrl.dispose();
    _locationCtrl.dispose();
    _durationCtrl.dispose();
    _rpeSessionCtrl.dispose();
    _readinessCtrl.dispose();
    super.dispose();
  }
}
