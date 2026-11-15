import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workout_app/widgets/calendar_plan_delete_dialog.dart';
import 'package:workout_app/widgets/calendar_plan_apply_confirmation.dart';
import 'package:workout_app/src/widgets/snack_utils.dart';
import 'package:workout_app/models/calendar_plan.dart';
import 'package:workout_app/models/exercise_definition.dart';
import 'package:workout_app/models/mesocycle.dart';
import 'package:workout_app/models/microcycle.dart';
import 'package:workout_app/models/muscle_info.dart';
import 'package:workout_app/models/user_max.dart';
import 'package:workout_app/services/api_client.dart';
import 'package:workout_app/services/exercise_service.dart';
import 'package:workout_app/src/api/plan_api.dart';
import 'package:workout_app/config/api_config.dart';
import 'package:workout_app/src/widgets/apply_plan_widget.dart'
    show ApplyPlanWidget;
import 'package:workout_app/models/calendar_plan_summary.dart';
import 'package:workout_app/screens/plan_editor_screen.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/providers/ambient_environment_provider.dart';
import 'package:workout_app/providers/interface_maker_provider.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/instrument_metric_matrix.dart';
import 'package:workout_app/widgets/interface_maker_sheet.dart';
import 'package:workout_app/widgets/plan_detail/plan_instrument_widgets.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';
import 'package:workout_app/widgets/plan_analytics_chart.dart';
import 'package:workout_app/screens/user_profile_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_app/providers/plan_providers.dart';
import 'package:workout_app/services/service_locator.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'dart:async';
import 'dart:math' as math;

class CalendarPlanDetail extends StatefulWidget {
  final CalendarPlan plan;

  const CalendarPlanDetail({super.key, required this.plan});

  @override
  _CalendarPlanDetailState createState() => _CalendarPlanDetailState();
}

enum _TimeBucket { session, microcycle, calendarWeek }

class _MultiSelectOption<T> {
  final T value;
  final String label;

  const _MultiSelectOption({required this.value, required this.label});
}

class _MultiSelectSheet<T> extends StatefulWidget {
  final String title;
  final List<_MultiSelectOption<T>> options;
  final Set<T> initialSelection;

  const _MultiSelectSheet({
    required this.title,
    required this.options,
    required this.initialSelection,
  });

  @override
  State<_MultiSelectSheet<T>> createState() => _MultiSelectSheetState<T>();
}

class _MultiSelectSheetState<T> extends State<_MultiSelectSheet<T>> {
  late final Set<T> _selection;

  @override
  void initState() {
    super.initState();
    _selection = Set<T>.from(widget.initialSelection);
  }

  void _toggle(T value, bool selected) {
    setState(() {
      if (selected) {
        _selection.add(value);
      } else {
        _selection.remove(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () =>
                      Navigator.of(context).pop(widget.initialSelection),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: widget.options
                      .map(
                        (option) => CheckboxListTile(
                          value: _selection.contains(option.value),
                          onChanged: (checked) =>
                              _toggle(option.value, checked ?? false),
                          title: Text(option.label),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(widget.initialSelection),
                  child: const Text('Отмена'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).pop(Set<T>.from(_selection)),
                  child: const Text('Готово'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SingleSelectSheet<T> extends StatefulWidget {
  final String title;
  final List<_MultiSelectOption<T>> options;
  final T initialValue;

  const _SingleSelectSheet({
    required this.title,
    required this.options,
    required this.initialValue,
  });

  @override
  State<_SingleSelectSheet<T>> createState() => _SingleSelectSheetState<T>();
}

class _SingleSelectSheetState<T> extends State<_SingleSelectSheet<T>> {
  late T _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  void _select(T value) {
    setState(() {
      _value = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                child: RadioGroup<T>(
                  groupValue: _value,
                  onChanged: (selected) {
                    if (selected != null) {
                      _select(selected);
                    }
                  },
                  child: Column(
                    children: widget.options
                        .map(
                          (option) => RadioListTile<T>(
                            value: option.value,
                            title: Text(option.label),
                            contentPadding: EdgeInsets.zero,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Отмена'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(_value),
                  child: const Text('Готово'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _HeaderMenuAction { editPlan, recalcSets, profile, deletePlan }

class _CalendarPlanDetailState extends State<CalendarPlanDetail> {
  late final CalendarPlan _originalPlan;
  late CalendarPlan _currentPlan;
  late final int _rootPlanId;
  final Map<int, CalendarPlan> _variantCache = {};
  bool _prefetchingVariants = false;
  bool _changingVariant = false;
  bool _updatingPublic = false;
  bool _deletingPlan = false;

  bool get _canDeletePlan =>
      _currentPlan.isOwnedBy(FirebaseAuth.instance.currentUser?.uid);
  List<UserMax> _userMaxList = [];
  Map<int, List<UserMax>> _userMaxesByExerciseId = {};
  Map<String, List<UserMax>> _userMaxesByName = {};
  Set<int> _planExerciseDefinitionIds = {};
  Set<String> _planExerciseNames = {};

  List<CalendarPlanSummary> _variants = const [];
  bool _variantsLoading = false;
  String? _variantsError;
  StreamSubscription<dynamic>? _variantsSub;
  StreamSubscription<dynamic>? _planSub;

  Future<Map<String, dynamic>> _waitPlanTask({
    required String taskId,
    required void Function(Map<String, dynamic>) onTick,
  }) async {
    while (true) {
      final status = await PlanApi.getPlanTaskStatus(taskId);
      onTick(status);
      final st = (status['status'] ?? '').toString();
      if (st == 'SUCCESS' || st == 'FAILURE') {
        return status;
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  final List<String> _metrics = const ['sets', 'volume', 'intensity', 'effort'];
  String _metricX = 'intensity';
  String _metricY = 'intensity';
  MetricSlot? _selectedChartSlot = MetricSlot.peakIntensity;
  late List<PlanAnalyticsPoint> _planAnalytics;
  _TimeBucket _timeBucket = _TimeBucket.session;

  int? _adoptersCount;
  bool _adoptersLoading = false;
  String? _adoptersError;

  late final ApiClient _apiClient;
  late final ExerciseService _exerciseService;
  List<ExerciseDefinition> _exerciseDefs = [];
  Map<int, ExerciseDefinition> _exDefById = {};
  List<MuscleInfo> _muscles = [];
  final Set<int> _selectedExerciseIds = {};
  final Set<String> _selectedMuscles = {};
  bool _loadingMeta = true;
  String? _metaError;
  bool _recalcInProgress = false;

  String _shortPlanTitle(String title, {int maxChars = 32}) {
    if (title.length <= maxChars) return title;
    return '${title.substring(0, maxChars - 1)}…';
  }

  Future<void> _deletePlan(WidgetRef ref) async {
    if (_deletingPlan || _changingVariant || !_canDeletePlan) return;
    final plan = _currentPlan;
    setState(() => _deletingPlan = true);
    try {
      final deleted = await confirmAndDeleteCalendarPlan(
        context,
        plan: plan,
        apiClient: _apiClient,
      );
      if (!mounted || !deleted) return;
      ref.read(calendarPlansProvider.notifier).removeLocal(plan.id);
      ref.read(calendarPlansProvider.notifier).load();
      ref.invalidate(activeAppliedPlanProvider);
      ref.invalidate(activeAppliedPlanSWRProvider);
      setState(() => _deletingPlan = false);
      Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        showAppSnackBar(context, 'Не удалось удалить план: $error', isError: true);
      }
    } finally {
      if (mounted) setState(() => _deletingPlan = false);
    }
  }

  Widget _buildOverflowMenu(WidgetRef ref) {
    return PopupMenuButton<_HeaderMenuAction>(
      icon: const Icon(Icons.more_vert),
      tooltip: 'Дополнительные действия',
      enabled: !_deletingPlan,
      onSelected: (action) {
        switch (action) {
          case _HeaderMenuAction.editPlan:
            _openPlanEditor();
            break;
          case _HeaderMenuAction.recalcSets:
            if (!_recalcInProgress) {
              _recalcPlanSets();
            }
            break;
          case _HeaderMenuAction.deletePlan:
            _deletePlan(ref);
            break;
          case _HeaderMenuAction.profile:
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const UserProfileScreen()),
            );
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: _HeaderMenuAction.editPlan,
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text('Редактировать план'),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        PopupMenuItem(
          enabled: !_recalcInProgress,
          value: _HeaderMenuAction.recalcSets,
          child: ListTile(
            leading: _recalcInProgress
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_fix_high),
            title: const Text('Пересчитать сеты (RPE)'),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        const PopupMenuItem(
          value: _HeaderMenuAction.profile,
          child: ListTile(
            leading: Icon(Icons.account_circle_outlined),
            title: Text('Профиль'),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        if (_canDeletePlan) ...[
          const PopupMenuDivider(),
          PopupMenuItem(
            enabled: !_changingVariant && !_recalcInProgress,
            value: _HeaderMenuAction.deletePlan,
            child: ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Удалить план',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _openPlanEditor() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PlanEditorScreen(plan: _currentPlan)),
    );
    _subscribePlanById(_currentPlan.id);
  }

  String? _normalizeExerciseName(String? name) {
    final value = name?.trim();
    if (value == null || value.isEmpty) return null;
    return value.toLowerCase();
  }

  void _indexUserMaxes(List<UserMax> userMaxes) {
    final byId = <int, List<UserMax>>{};
    final byName = <String, List<UserMax>>{};

    for (final userMax in userMaxes) {
      if (userMax.exerciseId > 0) {
        byId.putIfAbsent(userMax.exerciseId, () => []).add(userMax);
      }
      final normalizedName = _normalizeExerciseName(userMax.exerciseName);
      if (normalizedName != null) {
        byName.putIfAbsent(normalizedName, () => []).add(userMax);
      }
    }

    setState(() {
      _userMaxList = userMaxes;
      _userMaxesByExerciseId = byId;
      _userMaxesByName = byName;
    });
  }

  List<UserMax> _userMaxesForExercise(PlanExercise exercise) {
    final byId = _userMaxesByExerciseId[exercise.exerciseDefinitionId];
    if (byId != null && byId.isNotEmpty) {
      return byId;
    }
    final normalized = _normalizeExerciseName(exercise.exerciseName);
    if (normalized == null) {
      return const [];
    }
    return _userMaxesByName[normalized] ?? const [];
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

  Future<void> _fetchUserMaxes() async {
    try {
      final userMaxes = await PlanApi.getUserMaxes();
      if (!mounted) return;
      _indexUserMaxes(userMaxes);
    } catch (e) {
      print('Failed to fetch user maxes: $e');
    }
  }

  Future<void> _fetchAdoptersCount() async {
    if (_adoptersLoading) return;
    setState(() {
      _adoptersLoading = true;
      _adoptersError = null;
    });
    try {
      final count = await PlanApi.getRootPlanAdoptersCount(_rootPlanId);
      if (!mounted) return;
      setState(() {
        _adoptersCount = count;
        _adoptersLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _adoptersError = 'Не удалось загрузить счетчик применений: $e';
        _adoptersLoading = false;
      });
    }
  }

  Future<void> _prefetchAllVariants() async {
    if (_prefetchingVariants) return;
    _prefetchingVariants = true;
    try {
      for (final v in _variants) {
        if (_variantCache.containsKey(v.id)) continue;
        _subscribePlanById(v.id);
      }
    } finally {
      _prefetchingVariants = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    _exerciseService = ExerciseService(_apiClient);
    _originalPlan = widget.plan;
    _currentPlan = widget.plan;
    _rootPlanId = _originalPlan.rootPlanId ?? _originalPlan.id;
    _variantCache[_originalPlan.id] = _originalPlan;
    final exerciseData = _collectPlanExerciseData(_currentPlan);
    _planExerciseDefinitionIds = exerciseData.$1;
    _planExerciseNames = exerciseData.$2;
    _fetchUserMaxes();
    _fetchAdoptersCount();
    _planAnalytics = _computePlanAnalytics(_currentPlan);
    _loadExerciseMeta();
    _fetchVariants();
    _subscribePlanById(_currentPlan.id);
  }

  @override
  void dispose() {
    _variantsSub?.cancel();
    _planSub?.cancel();
    super.dispose();
  }

  void _subscribePlanById(int planId) {
    _planSub?.cancel();
    setState(() => _changingVariant = true);

    final endpoint = ApiConfig.getCalendarPlanEndpoint(planId.toString());
    _planSub = _apiClient
        .getSWR(
          endpoint,
          context: 'CalendarPlanDetail.getCalendarPlanSWR',
          ttlSeconds: 3600,
          groups: ['plans:detail', 'plans:detail:$planId'],
        )
        .listen(
          (data) {
            if (!mounted) return;
            if (data is Map<String, dynamic>) {
              final full = CalendarPlan.fromJson(data);
              _variantCache[planId] = full;
              _setPlan(full);
            }
          },
          onError: (e) {
            if (!mounted) return;
            showAppSnackBar(
              context,
              'Не удалось загрузить план: $e',
              isError: true,
            );
          },
          onDone: () {
            if (mounted) setState(() => _changingVariant = false);
          },
        );
  }

  Future<void> _recalcPlanSets() async {
    if (_recalcInProgress) return;
    setState(() {
      _recalcInProgress = true;
    });
    try {
      final planId = _currentPlan.id;
      final updated = await PlanApi.recalcCalendarPlanSets(planId);
      if (!mounted) return;
      _setPlan(updated);
      showAppSnackBar(context, 'План пересчитан');
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Не удалось пересчитать план: $e',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _recalcInProgress = false;
        });
      }
    }
  }

  Future<void> _fetchVariants() async {
    await _variantsSub?.cancel();
    setState(() {
      _variantsLoading = true;
      _variantsError = null;
    });

    final endpoint = ApiConfig.listPlanVariantsEndpoint(_rootPlanId.toString());
    _variantsSub = _apiClient
        .getSWR(
          endpoint,
          context: 'CalendarPlanDetail.getVariantsSWR',
          ttlSeconds: 900,
          groups: ['plans:variants', 'plans:variants:$_rootPlanId'],
        )
        .listen(
          (data) {
            if (!mounted) return;
            if (data is! List) return;

            final list = data
                .whereType<Map<String, dynamic>>()
                .map((j) => CalendarPlanSummary.fromJson(j))
                .toList(growable: false);

            setState(() {
              _variants = list;
              _variantsLoading = false;

              final orig = _variants
                  .where((v) => v.isOriginal)
                  .cast<CalendarPlanSummary?>()
                  .firstWhere((v) => v != null, orElse: () => null);
              if (orig != null && _originalPlan.id != orig.id) {
                _originalPlan = _variantCache[orig.id] ?? _originalPlan;
              }
            });

            // ignore: unawaited_futures
            _prefetchAllVariants();
          },
          onError: (e) {
            if (!mounted) return;
            setState(() {
              _variantsError = 'Не удалось загрузить варианты: $e';
              _variantsLoading = false;
            });
          },
        );
  }

  void _createVariantDialog() {
    final controller = TextEditingController();
    bool submitting = false;
    String? error;

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Новый вариант плана'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Название варианта',
                    ),
                    autofocus: true,
                  ),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: submitting
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Отмена'),
                ),
                FilledButton(
                  onPressed: submitting
                      ? null
                      : () async {
                          final name = controller.text.trim();
                          if (name.isEmpty) {
                            setModalState(() => error = 'Введите название');
                            return;
                          }
                          setModalState(() {
                            submitting = true;
                            error = null;
                          });
                          try {
                            await PlanApi.createVariant(
                              planId: _rootPlanId,
                              name: name,
                            );
                            if (!mounted) return;
                            Navigator.of(context).pop();
                            await _fetchVariants();
                            if (!mounted) return;
                            showAppSnackBar(context, 'Вариант создан');
                          } catch (e) {
                            setModalState(() {
                              submitting = false;
                              error = 'Ошибка: $e';
                            });
                          }
                        },
                  child: submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Создать'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => controller.dispose());
  }

  Future<void> _applyPlan(BuildContext context, WidgetRef ref) async {
    try {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ApplyPlanWidget(
          plan: _currentPlan,
          userMaxList: _userMaxList,
          allowedExerciseIds: _planExerciseDefinitionIds,
          allowedExerciseNames: _planExerciseNames,
          planId: _currentPlan.id,
          onApply: (settings) async {
            try {
              final onProgress = settings['on_progress'];

              final submission = await applyPlanWithConfirmation<Map<String, dynamic>>(
                context,
                submit: (replaceActive) => PlanApi.applyPlanAsync(
                  planId: _currentPlan.id,
                  userMaxIds: settings['user_max_ids'],
                  computeWeights: settings['compute_weights'],
                  roundingStep: settings['rounding_step'],
                  roundingMode: settings['rounding_mode'],
                  replaceActive: replaceActive,
                ),
              );
              if (submission == null) return;
              final taskId = (submission['task_id'] ?? '').toString();
              if (taskId.isEmpty) {
                throw Exception('No task_id returned');
              }

              final status = await _waitPlanTask(
                taskId: taskId,
                onTick: (payload) {
                  final meta = payload['meta'];
                  if (meta is Map) {
                    final stage = meta['stage']?.toString();
                    int? total;
                    int? done;
                    try {
                      final rawTotal = meta['workouts_total'];
                      final rawDone = meta['workouts_done'];
                      total = rawTotal is int
                          ? rawTotal
                          : int.tryParse(rawTotal?.toString() ?? '');
                      done = rawDone is int
                          ? rawDone
                          : int.tryParse(rawDone?.toString() ?? '');
                    } catch (_) {}

                    if (onProgress is Function) {
                      try {
                        onProgress(stage, total, done);
                      } catch (_) {}
                    }
                  }
                },
              );

              if ((status['status'] ?? '').toString() == 'FAILURE') {
                throw Exception(status['error'] ?? 'Task failed');
              }

              try {
                await ref.read(apiClientProvider).invalidateCacheGroups(const [
                  'plans:active',
                  'plans:active_workouts',
                  'plans:list',
                  'plans:variants',
                ]);
              } catch (_) {}

              ref.invalidate(activeAppliedPlanProvider);
              ref.invalidate(activeAppliedPlanSWRProvider);
              Navigator.of(context).pop();
              showAppSnackBar(context, 'Plan applied successfully');
            } catch (e) {
              showAppSnackBar(
                context,
                'Failed to apply plan: $e',
                isError: true,
              );
            }
          },
          onUserMaxAdded: () {
            _fetchUserMaxes();
          },
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  String _mapSlotToPlanMetric(MetricSlot slot) {
    switch (slot) {
      case MetricSlot.peakIntensity:
      case MetricSlot.e1rm:
        return 'intensity';
      case MetricSlot.peakRpe:
      case MetricSlot.avgRpe:
        return 'effort';
      case MetricSlot.tonnage:
      case MetricSlot.kpsh:
        return 'volume';
      case MetricSlot.setsCount:
      case MetricSlot.density:
      case MetricSlot.durationWeeks:
      case MetricSlot.frequencyPerWeek:
        return 'sets';
    }
  }

  List<InstrumentMetricCellData> _buildPlanMetricCells(
    List<MetricSlot> slots,
    TrainingEnvironmentData env,
    InstrumentTheme instrument,
    ColorScheme colors,
  ) {
    int totalSets = 0;
    int totalReps = 0;
    int totalWorkouts = 0;
    double? peakIntensity;
    double? peakRpe;
    double rpeSum = 0;
    int rpeCount = 0;

    for (final meso in _currentPlan.mesocycles) {
      for (final micro in meso.microcycles) {
        totalWorkouts += micro.planWorkouts.length;
        for (final pw in micro.planWorkouts) {
          for (final ex in pw.exercises) {
            for (final set in ex.sets) {
              totalSets++;
              if (set.volume != null) totalReps += set.volume!;
              if (set.intensity != null && set.intensity! > 0) {
                final v = set.intensity!.toDouble();
                if (peakIntensity == null || v > peakIntensity) {
                  peakIntensity = v;
                }
              }
              if (set.effort != null && set.effort! > 0) {
                final e = set.effort!.toDouble();
                rpeSum += e;
                rpeCount++;
                if (peakRpe == null || e > peakRpe) {
                  peakRpe = e;
                }
              }
            }
          }
        }
      }
    }

    peakIntensity ??= env.peakIntensity;
    peakRpe ??= env.peakRpe;
    final avgRpe = rpeCount > 0 ? rpeSum / rpeCount : env.avgRpe;
    final topUserMax = _userMaxList.isEmpty
        ? null
        : _userMaxList
              .map((m) => m.maxWeight.toDouble())
              .reduce(math.max);

    InstrumentMetricCellData cellFor(MetricSlot slot) {
      switch (slot) {
        case MetricSlot.peakIntensity:
          return InstrumentMetricCellData(
            slot: slot,
            value: peakIntensity != null ? '${peakIntensity.round()}%' : '—',
          );
        case MetricSlot.e1rm:
          return InstrumentMetricCellData(
            slot: slot,
            value: topUserMax != null
                ? '${topUserMax.round()} кг'
                : (peakIntensity != null ? '${peakIntensity.round()}%' : '—'),
          );
        case MetricSlot.peakRpe:
          return InstrumentMetricCellData(
            slot: slot,
            value: peakRpe != null ? 'RPE ${peakRpe.toStringAsFixed(1)}' : '—',
            valueColor: peakRpe != null
                ? instrument.colorForRpe(peakRpe, colors)
                : null,
          );
        case MetricSlot.avgRpe:
          return InstrumentMetricCellData(
            slot: slot,
            value: avgRpe != null ? 'RPE ${avgRpe.toStringAsFixed(1)}' : '—',
            valueColor: avgRpe != null
                ? instrument.colorForRpe(avgRpe, colors)
                : null,
          );
        case MetricSlot.tonnage:
          return InstrumentMetricCellData(
            slot: slot,
            label: 'ОБЪЁМ',
            value: totalReps > 0 ? '$totalReps повт.' : '—',
          );
        case MetricSlot.kpsh:
          return InstrumentMetricCellData(
            slot: slot,
            value: totalReps > 0 ? '$totalReps' : '—',
          );
        case MetricSlot.setsCount:
          return InstrumentMetricCellData(
            slot: slot,
            value: '$totalSets',
          );
        case MetricSlot.density:
          return InstrumentMetricCellData(
            slot: slot,
            value: totalWorkouts > 0
                ? '${(totalSets / totalWorkouts).toStringAsFixed(1)}/тр'
                : '—',
          );
        case MetricSlot.durationWeeks:
          return InstrumentMetricCellData(
            slot: slot,
            value: '${_currentPlan.durationWeeks} wk',
          );
        case MetricSlot.frequencyPerWeek:
          return InstrumentMetricCellData(
            slot: slot,
            value: _currentPlan.intendedFrequencyPerWeek != null
                ? '${_currentPlan.intendedFrequencyPerWeek}×/wk'
                : '—',
          );
      }
    }

    return slots.map(cellFor).toList(growable: false);
  }

  Future<void> _showSecondaryFiltersSheet() async {
    final filtersReady = !_loadingMeta && _metaError == null;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final theme = Theme.of(sheetContext);
            final hasFilters =
                _selectedExerciseIds.isNotEmpty || _selectedMuscles.isNotEmpty;
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Фильтры аналитики',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (hasFilters)
                        TextButton(
                          onPressed: () {
                            _clearFilters();
                            setSheetState(() {});
                          },
                          child: const Text('Сбросить'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'ГРАНУЛЯРНОСТЬ',
                    style: InstrumentTheme.microLabel(sheetContext),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _TimeBucket.values
                        .map((bucket) {
                          return ChoiceChip(
                            label: Text(_timeBucketLabel(bucket)),
                            selected: _timeBucket == bucket,
                            onSelected: (_) {
                              setState(() => _timeBucket = bucket);
                              _applyFilters();
                              setSheetState(() {});
                            },
                          );
                        })
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    enabled: filtersReady,
                    leading: const Icon(Icons.fitness_center_outlined),
                    title: const Text('Упражнения'),
                    subtitle: Text(
                      filtersReady
                          ? _exerciseSummaryText()
                          : (_loadingMeta ? 'Загрузка…' : (_metaError ?? '')),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: filtersReady
                        ? () async {
                            await _showExerciseFilter();
                            setSheetState(() {});
                          }
                        : null,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    enabled: filtersReady,
                    leading: const Icon(Icons.accessibility_new_outlined),
                    title: const Text('Мышечные группы'),
                    subtitle: Text(
                      filtersReady
                          ? _muscleSummaryText()
                          : (_loadingMeta ? 'Загрузка…' : (_metaError ?? '')),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: filtersReady
                        ? () async {
                            await _showMuscleFilter();
                            setSheetState(() {});
                          }
                        : null,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.scatter_plot_outlined),
                    title: const Text('Ось X / Ось Y'),
                    subtitle: Text(
                      '${_metricLabel(_metricX)} × ${_metricLabel(_metricY)}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await _showMetricPicker(isX: false);
                      setSheetState(() {});
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final interfaceConfig = ref.watch(interfaceMakerProvider);
        final env = TrainingEnvironmentData.fromPlan(_currentPlan);
        final hasFilters =
            _selectedExerciseIds.isNotEmpty || _selectedMuscles.isNotEmpty;
        final filterCount =
            _selectedExerciseIds.length + _selectedMuscles.length;

        return AssistantChatHost(
          contextBuilder: () async {
            return {
              'v': 1,
              'app': 'WorkoutApp',
              'screen': 'plan_details',
              'metric_x': _metricX,
              'metric_y': _metricY,
              'entities': {
                'calendar_plan_id': _currentPlan.id,
                'root_plan_id': _rootPlanId,
                'plan_name': _currentPlan.name,
                'duration_weeks': _currentPlan.durationWeeks,
              },
            };
          },
          builder: (context, openChat) {
            final dimensions = UiDimensions.of(context);
            final theme = Theme.of(context);
            final colors = theme.colorScheme;
            final instrument = InstrumentTheme.of(context);

            final accent = env.accentColor(instrument);
            final metricCells = _buildPlanMetricCells(
              interfaceConfig.slots,
              env,
              instrument,
              colors,
            );
            final MetricSlot selectedMetricSlot =
                _selectedChartSlot != null &&
                        interfaceConfig.slots.contains(_selectedChartSlot)
                    ? _selectedChartSlot!
                    : (interfaceConfig.slots.isNotEmpty
                        ? interfaceConfig.slots.first
                        : MetricSlot.peakIntensity);

            Widget buildModule(LayoutModule module) {
              switch (module) {
                case LayoutModule.variantOrHorizonStrip:
                  return Padding(
                    padding: EdgeInsets.only(bottom: dimensions.sectionGap),
                    child: PlanVariantsBar(
                      padding: EdgeInsets.symmetric(
                        horizontal: dimensions.pagePadding,
                      ),
                      currentPlanId: _currentPlan.id,
                      rootPlanId: _rootPlanId,
                      variants: _variants,
                      isLoading: _variantsLoading || _changingVariant,
                      errorText: _variantsError,
                      onSelectOriginal: () {
                        final orig = _variants.firstWhere(
                          (v) => v.isOriginal,
                          orElse: () => CalendarPlanSummary(
                            id: _rootPlanId,
                            name: '',
                            durationWeeks: 0,
                            isActive: true,
                            rootPlanId: _rootPlanId,
                            isOriginal: true,
                          ),
                        );
                        if (_currentPlan.id == orig.id) return;
                        _subscribePlanById(orig.id);
                      },
                      onSelectVariant: _switchToVariant,
                      onCreateVariant: _createVariantDialog,
                      extraPills: [
                        CanvasPillItem(
                          label: hasFilters
                              ? 'Фильтры · ${_bucketShort()} ($filterCount)'
                              : 'Фильтры · ${_bucketShort()}',
                          icon: Icons.tune_rounded,
                          selected: hasFilters,
                          accentColor: accent,
                          onTap: _showSecondaryFiltersSheet,
                        ),
                        CanvasPillItem(
                          label: 'Сетка',
                          icon: Icons.grid_view_rounded,
                          onTap: () => InterfaceMakerSheet.show(context),
                        ),
                      ],
                    ),
                  );
                case LayoutModule.commandBriefing:
                  // Rendered inside the unified PlanPassportCard header.
                  return const SizedBox.shrink();
                case LayoutModule.primaryTelemetry:
                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      dimensions.pagePadding,
                      0,
                      dimensions.pagePadding,
                      dimensions.sectionGap,
                    ),
                    child: _buildPlanInfo(
                      context,
                      environment: env,
                      snarkyVoice: interfaceConfig.snarkyVoice,
                      showBriefing: interfaceConfig.isModuleVisible(
                        LayoutModule.commandBriefing,
                      ),
                      chartSlot: interfaceConfig.showChart
                          ? SizedBox(
                              height: 152,
                              child: PlanAnalyticsChart(
                                points: _planAnalytics,
                                metricX: _metricX,
                                metricY: _metricY,
                                bleedMode: true,
                                accentColor: accent,
                                emptyText: 'Нет данных для плана',
                              ),
                            )
                          : null,
                      metricCells: metricCells,
                      selectedSlot: selectedMetricSlot,
                      onSelectSlot: (slot) {
                        final mapped = _mapSlotToPlanMetric(slot);
                        setState(() {
                          _selectedChartSlot = slot;
                          _metricX = mapped;
                          _metricY = mapped;
                        });
                      },
                    ),
                  );
                case LayoutModule.scheduleOrLibrary:
                  if (_currentPlan.mesocycles.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: dimensions.pagePadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _currentPlan.mesocycles
                          .map((m) => _buildMesocycleExpansionTile(m, accent))
                          .toList(growable: false),
                    ),
                  );
              }
            }

            return PopScope(
              canPop: !_deletingPlan,
              child: AbsorbPointer(
                absorbing: _deletingPlan,
                child: AmbientScaffoldShell(
                  environment: env,
                  appBar: PrimaryAppBar(
                    title: _shortPlanTitle(_currentPlan.name),
                    onTitleTap: openChat,
                    showBack: true,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: _deletingPlan
                            ? null
                            : () => _applyPlan(context, ref),
                        tooltip: 'Apply Plan',
                      ),
                      _buildOverflowMenu(ref),
                    ],
                  ),
                  body: RefreshIndicator(
                    onRefresh: () async => _subscribePlanById(_currentPlan.id),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        0,
                        AmbientScaffoldShell.topContentInset(context, extra: 6),
                        0,
                        MediaQuery.paddingOf(context).bottom + 28,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_deletingPlan) const LinearProgressIndicator(),
                          ...interfaceConfig.visibleModules.map(buildModule),
                        ],
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

  void _setPlan(CalendarPlan plan) {
    final exerciseData = _collectPlanExerciseData(plan);
    setState(() {
      _currentPlan = plan;
      _planExerciseDefinitionIds = exerciseData.$1;
      _planExerciseNames = exerciseData.$2;
      _selectedExerciseIds.clear();
      _selectedMuscles.clear();
      _planAnalytics = _computePlanAnalytics(plan);
    });
    _loadExerciseMeta();
  }

  Future<void> _switchToVariant(CalendarPlanSummary v) async {
    if (v.id == _currentPlan.id) return;
    _subscribePlanById(v.id);
  }

  List<PlanAnalyticsPoint> _computePlanAnalytics(
    CalendarPlan plan, {
    Set<int>? onlyExerciseIds,
    Set<String>? onlyMuscles,
  }) {
    final points = <PlanAnalyticsPoint>[];
    var order = 0;

    List<PlanWorkout> _sortedWorkouts(Microcycle microcycle) {
      final workouts = [...microcycle.planWorkouts];
      workouts.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      return workouts;
    }

    bool _passesFilters(int? exDefId) {
      final filtersActive =
          (onlyExerciseIds != null && onlyExerciseIds.isNotEmpty) ||
          (onlyMuscles != null && onlyMuscles.isNotEmpty);
      if (!filtersActive) {
        return true;
      }
      if (exDefId == null || exDefId == 0) return false;
      if (onlyExerciseIds != null &&
          onlyExerciseIds.isNotEmpty &&
          !onlyExerciseIds.contains(exDefId)) {
        return false;
      }
      if (onlyMuscles != null && onlyMuscles.isNotEmpty) {
        final def = _exDefById[exDefId];
        if (def == null) return false;
        final all = {
          ...(def.targetMuscles ?? const []),
          ...(def.synergistMuscles ?? const []),
        };
        if (all.intersection(onlyMuscles).isEmpty) return false;
      }
      return true;
    }

    Map<String, double> _aggregateSetsFromExercises(
      List<PlanExercise> exercises,
    ) {
      double setsCount = 0;
      double volume = 0;
      double intensitySum = 0;
      int intensityCount = 0;
      double effortSum = 0;
      int effortCount = 0;

      for (final exercise in exercises) {
        if (!_passesFilters(exercise.exerciseDefinitionId)) continue;
        for (final set in exercise.sets) {
          setsCount += 1;
          if (set.volume != null) volume += set.volume!.toDouble();
          if (set.intensity != null) {
            intensitySum += set.intensity!.toDouble();
            intensityCount += 1;
          }
          if (set.effort != null) {
            effortSum += set.effort!.toDouble();
            effortCount += 1;
          }
        }
      }

      return {
        'sets': setsCount,
        'volume': volume,
        'intensity': intensityCount > 0 ? intensitySum / intensityCount : 0,
        'effort': effortCount > 0 ? effortSum / effortCount : 0,
      };
    }

    Map<String, double> _aggregateMicrocycle(Microcycle micro) {
      double setsCount = 0;
      double volume = 0;
      double intensitySum = 0;
      int intensityCount = 0;
      double effortSum = 0;
      int effortCount = 0;

      final workouts = _sortedWorkouts(micro);
      for (final workout in workouts) {
        for (final ex in workout.exercises) {
          if (!_passesFilters(ex.exerciseDefinitionId)) continue;
          for (final set in ex.sets) {
            setsCount += 1;
            if (set.volume != null) volume += set.volume!.toDouble();
            if (set.intensity != null) {
              intensitySum += set.intensity!.toDouble();
              intensityCount += 1;
            }
            if (set.effort != null) {
              effortSum += set.effort!.toDouble();
              effortCount += 1;
            }
          }
        }
      }

      return {
        'sets': setsCount,
        'volume': volume,
        'intensity': intensityCount > 0 ? intensitySum / intensityCount : 0,
        'effort': effortCount > 0 ? effortSum / effortCount : 0,
      };
    }

    final mesocycles = [...plan.mesocycles]
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    final totalMicrocyclesCount = mesocycles.fold<int>(
      0,
      (sum, meso) => sum + meso.microcycles.length,
    );

    if (_timeBucket == _TimeBucket.session) {
      for (final mesocycle in mesocycles) {
        final microcycles = [...mesocycle.microcycles]
          ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
        for (final micro in microcycles) {
          final workouts = _sortedWorkouts(micro);
          if (workouts.isNotEmpty) {
            for (final workout in workouts) {
              order += 1;
              final values = _aggregateSetsFromExercises(workout.exercises);
              final hasAny = values.values.any((v) => v != 0);
              if (hasAny) {
                points.add(
                  PlanAnalyticsPoint(
                    order: order,
                    label: 'S$order',
                    values: values,
                  ),
                );
              }
            }
          }
        }
      }
      return points;
    }

    if (_timeBucket == _TimeBucket.microcycle) {
      var mOrder = 0;
      for (final mesocycle in mesocycles) {
        final microcycles = [...mesocycle.microcycles]
          ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
        for (final micro in microcycles) {
          final values = _aggregateMicrocycle(micro);
          final hasAny = values.values.any((v) => v != 0);
          if (hasAny) {
            mOrder += 1;
            points.add(
              PlanAnalyticsPoint(
                order: mOrder,
                label: 'M$mOrder',
                values: values,
              ),
            );
          }
        }
      }
      return points;
    }

    final sessions = <({Map<String, double> values, double dayOffset})>[];
    double cumulativeDays = 0.0;

    for (final mesocycle in mesocycles) {
      final microcycles = [...mesocycle.microcycles]
        ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      for (final micro in microcycles) {
        final workouts = _sortedWorkouts(micro);

        double microLen = (micro.daysCount?.toDouble()) ?? 0.0;
        if (microLen <= 0 &&
            plan.durationWeeks > 0 &&
            totalMicrocyclesCount > 0) {
          microLen = (plan.durationWeeks * 7) / totalMicrocyclesCount;
        }
        if (microLen <= 0 && workouts.isNotEmpty) {
          microLen = workouts.length.toDouble();
        }
        if (microLen <= 0) {
          microLen = 7.0;
        }

        final n = workouts.length;
        for (var i = 0; i < n; i++) {
          final workout = workouts[i];
          final values = _aggregateSetsFromExercises(workout.exercises);
          final hasAny = values.values.any((v) => v != 0);
          if (!hasAny) continue;
          final dayWithin = (i + 0.5) * (microLen / n);
          sessions.add((values: values, dayOffset: cumulativeDays + dayWithin));
        }

        cumulativeDays += microLen;
      }
    }

    int weeks;
    if (plan.durationWeeks > 0) {
      weeks = plan.durationWeeks;
    } else {
      weeks = (cumulativeDays / 7).ceil();
      if (weeks <= 0) weeks = sessions.length;
    }
    if (weeks <= 0) return points;

    final bins = List.generate(
      weeks,
      (_) => {
        'sets': 0.0,
        'volume': 0.0,
        'intensityWeighted': 0.0,
        'effortWeighted': 0.0,
        'weight': 0.0,
      },
    );

    for (final s in sessions) {
      final sets = s.values['sets'] ?? 0;
      final vol = s.values['volume'] ?? 0;
      final intVal = s.values['intensity'] ?? 0;
      final effVal = s.values['effort'] ?? 0;
      int wIdx = (s.dayOffset / 7).floor();
      if (wIdx < 0) wIdx = 0;
      if (wIdx >= weeks) wIdx = weeks - 1;
      bins[wIdx]['sets'] = (bins[wIdx]['sets'] as double) + sets;
      bins[wIdx]['volume'] = (bins[wIdx]['volume'] as double) + vol;
      bins[wIdx]['intensityWeighted'] =
          (bins[wIdx]['intensityWeighted'] as double) + intVal * sets;
      bins[wIdx]['effortWeighted'] =
          (bins[wIdx]['effortWeighted'] as double) + effVal * sets;
      bins[wIdx]['weight'] = (bins[wIdx]['weight'] as double) + sets;
    }

    for (var w = 0; w < weeks; w++) {
      final weight = bins[w]['weight'] as double;
      final intensity = weight > 0
          ? (bins[w]['intensityWeighted'] as double) / weight
          : 0.0;
      final effort = weight > 0
          ? (bins[w]['effortWeighted'] as double) / weight
          : 0.0;
      final values = <String, double>{
        'sets': bins[w]['sets'] as double,
        'volume': bins[w]['volume'] as double,
        'intensity': intensity,
        'effort': effort,
      };
      final hasAny = values.values.any((v) => v != 0);
      if (hasAny) {
        points.add(
          PlanAnalyticsPoint(order: w + 1, label: 'W${w + 1}', values: values),
        );
      }
    }

    return points;
  }

  Future<void> _loadExerciseMeta() async {
    try {
      setState(() => _loadingMeta = true);
      final defs = await _exerciseService.getExercisesByIds(
        _planExerciseDefinitionIds.toList(),
      );
      final muscles = await _exerciseService.getMuscles();
      final byId = <int, ExerciseDefinition>{
        for (final d in defs)
          if (d.id != null) d.id!: d,
      };
      setState(() {
        _exerciseDefs = defs;
        _exDefById = byId;
        _muscles = muscles;
        _loadingMeta = false;
      });
    } catch (e) {
      setState(() {
        _metaError = 'Не удалось загрузить данные упражнений';
        _loadingMeta = false;
      });
    }
  }

  void _applyFilters({VoidCallback? beforeRecalc}) {
    beforeRecalc?.call();
    final onlyIds = _selectedExerciseIds.isEmpty ? null : _selectedExerciseIds;
    final onlyMuscles = _selectedMuscles.isEmpty ? null : _selectedMuscles;
    setState(() {
      _planAnalytics = _computePlanAnalytics(
        _currentPlan,
        onlyExerciseIds: onlyIds,
        onlyMuscles: onlyMuscles,
      );
    });
  }

  // Legacy multi-row analytics dropdown section decommissioned in favor of
  // unified PlanPassportCard bleed-to-edge wave + InstrumentMetricMatrix +
  // _showSecondaryFiltersSheet().

  List<ExerciseDefinition> _availableExercises() {
    final defs =
        _exerciseDefs
            .where(
              (d) => d.id != null && _planExerciseDefinitionIds.contains(d.id),
            )
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
    return defs;
  }

  List<MapEntry<String, String>> _availableMuscles() {
    final presentMuscles = <String, String>{};
    String labelFor(String key) {
      for (final muscle in _muscles) {
        if (muscle.key == key) return muscle.label;
      }
      return key;
    }

    for (final def in _exerciseDefs) {
      if (def.id == null || !_planExerciseDefinitionIds.contains(def.id))
        continue;
      for (final key in (def.targetMuscles ?? const [])) {
        presentMuscles[key] = labelFor(key);
      }
      for (final key in (def.synergistMuscles ?? const [])) {
        presentMuscles[key] = labelFor(key);
      }
    }

    final entries = presentMuscles.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return entries;
  }

  String _exerciseSummaryText() {
    if (_selectedExerciseIds.isEmpty) return 'Все упражнения';
    final defs = _availableExercises();
    final selected = defs
        .where((d) => d.id != null && _selectedExerciseIds.contains(d.id))
        .toList();
    if (selected.isEmpty) return 'Фильтр не содержит данных';
    if (selected.length <= 2) {
      return selected.map((d) => d.name).join(', ');
    }
    final displayed = selected.take(2).map((d) => d.name).join(', ');
    return '$displayed и еще ${selected.length - 2}';
  }

  String _muscleSummaryText() {
    if (_selectedMuscles.isEmpty) return 'Все мышцы';
    final options = _availableMuscles();
    final selected = options
        .where((entry) => _selectedMuscles.contains(entry.key))
        .toList();
    if (selected.isEmpty) return 'Фильтр не содержит данных';
    if (selected.length <= 2) {
      return selected.map((entry) => entry.value).join(', ');
    }
    final displayed = selected.take(2).map((entry) => entry.value).join(', ');
    return '$displayed и еще ${selected.length - 2}';
  }

  // Removed legacy _buildFilterDropdown, _buildMetricPicker, and _buildTimeBucketPicker.

  Future<void> _showExerciseFilter() async {
    final options = _availableExercises();
    final initial = Set<int>.from(_selectedExerciseIds);
    final result = await _showMultiSelectSheet<int>(
      title: 'Выберите упражнения',
      options: options
          .map(
            (def) => _MultiSelectOption<int>(value: def.id!, label: def.name),
          )
          .toList(),
      initialSelection: initial,
    );
    if (result == null) return;
    _applyFilters(
      beforeRecalc: () {
        _selectedExerciseIds
          ..clear()
          ..addAll(result);
      },
    );
  }

  Future<void> _showMuscleFilter() async {
    final options = _availableMuscles();
    final initial = Set<String>.from(_selectedMuscles);
    final result = await _showMultiSelectSheet<String>(
      title: 'Выберите мышцы',
      options: options
          .map(
            (entry) => _MultiSelectOption<String>(
              value: entry.key,
              label: entry.value,
            ),
          )
          .toList(),
      initialSelection: initial,
    );
    if (result == null) return;
    _applyFilters(
      beforeRecalc: () {
        _selectedMuscles
          ..clear()
          ..addAll(result);
      },
    );
  }

  Future<void> _showMetricPicker({required bool isX}) async {
    final current = isX ? _metricX : _metricY;
    final options = _metrics
        .map(
          (metric) => _MultiSelectOption<String>(
            value: metric,
            label: _metricLabel(metric),
          ),
        )
        .toList();

    final result = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _SingleSelectSheet<String>(
        title: isX
            ? 'Выберите метрику для оси X'
            : 'Выберите метрику для оси Y',
        options: options,
        initialValue: current,
      ),
    );

    if (result == null || result == current) return;
    setState(() {
      if (isX) {
        _metricX = result;
      } else {
        _metricY = result;
      }
    });
  }

  Future<Set<T>?> _showMultiSelectSheet<T>({
    required String title,
    required List<_MultiSelectOption<T>> options,
    required Set<T> initialSelection,
  }) async {
    if (options.isEmpty) return initialSelection;

    final result = await showModalBottomSheet<Set<T>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return _MultiSelectSheet<T>(
          title: title,
          options: options,
          initialSelection: initialSelection,
        );
      },
    );

    return result ?? initialSelection;
  }

  void _clearFilters() {
    if (_selectedExerciseIds.isEmpty && _selectedMuscles.isEmpty) return;
    _applyFilters(
      beforeRecalc: () {
        _selectedExerciseIds.clear();
        _selectedMuscles.clear();
      },
    );
  }

  String _metricLabel(String m) {
    switch (m) {
      case 'sets':
        return 'Сеты';
      case 'volume':
        return 'Повторения (volume)';
      case 'intensity':
        return 'Интенсивность (%)';
      case 'effort':
        return 'Усилие (RPE)';
      default:
        return m;
    }
  }

  String _timeBucketLabel(_TimeBucket b) {
    switch (b) {
      case _TimeBucket.session:
        return 'Сессии';
      case _TimeBucket.microcycle:
        return 'Микроциклы';
      case _TimeBucket.calendarWeek:
        return 'Недели';
    }
  }

  String _bucketShort() {
    switch (_timeBucket) {
      case _TimeBucket.session:
        return 'S';
      case _TimeBucket.microcycle:
        return 'M';
      case _TimeBucket.calendarWeek:
        return 'W';
    }
  }

  (Set<int>, Set<String>) _collectPlanExerciseData(CalendarPlan plan) {
    final ids = <int>{};
    final names = <String>{};

    void addExercise({int? id, String? name}) {
      if (id != null && id > 0) {
        ids.add(id);
      }
      final normalized = _normalizeExerciseName(name);
      if (normalized != null) {
        names.add(normalized);
      }
    }

    for (final mesocycle in plan.mesocycles) {
      for (final microcycle in mesocycle.microcycles) {
        for (final workout in microcycle.planWorkouts) {
          for (final exercise in workout.exercises) {
            addExercise(
              id: exercise.exerciseDefinitionId,
              name: exercise.exerciseName,
            );
          }
        }
      }
    }

    return (ids, names);
  }

  Widget _buildWorkoutDayCard(PlanWorkout workout, Color hairline) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        title: Row(
          children: [
            Icon(Icons.fitness_center, size: 15, color: colors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                workout.dayLabel,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${workout.exercises.length} EX',
              style: InstrumentTheme.tabular(
                InstrumentTheme.microLabel(context),
              ),
            ),
          ],
        ),
        children: [
          for (var i = 0; i < workout.exercises.length; i++) ...[
            if (i > 0) Container(height: 1, color: hairline),
            _buildExerciseCard(workout.exercises[i], i + 1, hairline),
          ],
        ],
      ),
    );
  }

  Widget _buildExerciseCard(PlanExercise exercise, int index, Color hairline) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final userMaxes = _userMaxesForExercise(exercise);
    final latestUserMax = _latestUserMax(userMaxes);
    final hasNotes =
        (exercise.notes != null && exercise.notes!.trim().isNotEmpty);
    final hasRest = exercise.restSeconds != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$index.',
                style: InstrumentTheme.tabular(
                  theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.primary,
                      ) ??
                      const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  exercise.exerciseName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (hasRest || hasNotes) ...[
            const SizedBox(height: 4),
            Text(
              [
                if (hasRest) 'Rest ${exercise.restSeconds}s',
                if (hasNotes) exercise.notes!.trim(),
              ].join(' · '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            latestUserMax != null
                ? 'Текущий максимум: ${latestUserMax.maxWeight} кг × ${latestUserMax.repMax}'
                : 'Максимум не задан',
            style: InstrumentTheme.tabular(
              theme.textTheme.bodySmall?.copyWith(
                    color: latestUserMax != null
                        ? colors.tertiary
                        : colors.onSurfaceVariant,
                    fontWeight: latestUserMax != null
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ) ??
                  const TextStyle(fontSize: 12),
            ),
          ),
          if (exercise.sets.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildSetsSection(exercise.sets, hairline),
          ],
        ],
      ),
    );
  }

  Widget _buildSetsSection(List<PlanSet> sets, Color hairline) {
    final labelStyle = InstrumentTheme.microLabel(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          child: Row(
            children: [
              SizedBox(
                width: 34,
                child: Text('SET', style: labelStyle),
              ),
              Expanded(
                child: Text(
                  'INT',
                  textAlign: TextAlign.center,
                  style: labelStyle,
                ),
              ),
              Expanded(
                child: Text(
                  'REPS',
                  textAlign: TextAlign.center,
                  style: labelStyle,
                ),
              ),
              Expanded(
                child: Text(
                  'RPE',
                  textAlign: TextAlign.center,
                  style: labelStyle,
                ),
              ),
            ],
          ),
        ),
        Container(height: 1, color: hairline),
        for (var i = 0; i < sets.length; i++) ...[
          if (i > 0) Container(height: 1, color: hairline.withValues(alpha: 0.45)),
          _buildSetRow(sets[i], i + 1),
        ],
      ],
    );
  }

  Widget _buildSetRow(PlanSet set, int setNumber) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final rpeValue = set.effort?.toDouble();
    final rpeColor = instrument.colorForRpe(rpeValue, colors);
    final hasRpe = rpeValue != null && rpeValue > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(
              '$setNumber',
              style: InstrumentTheme.tabular(
                theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ) ??
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          Expanded(
            child: Text(
              set.intensity != null ? '${set.intensity}%' : '—',
              textAlign: TextAlign.center,
              style: InstrumentTheme.tabular(
                theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ) ??
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Expanded(
            child: Text(
              set.volume != null ? '${set.volume}' : '—',
              textAlign: TextAlign.center,
              style: InstrumentTheme.tabular(
                theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ) ??
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Expanded(
            child: Text(
              set.effort != null ? '${set.effort}' : '—',
              textAlign: TextAlign.center,
              style: InstrumentTheme.tabular(
                theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: hasRpe ? rpeColor : colors.onSurfaceVariant,
                    ) ??
                    const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanInfo(
    BuildContext context, {
    required TrainingEnvironmentData environment,
    required bool snarkyVoice,
    required bool showBriefing,
    required Widget? chartSlot,
    required List<InstrumentMetricCellData> metricCells,
    required MetricSlot selectedSlot,
    required ValueChanged<MetricSlot> onSelectSlot,
  }) {
    return PlanPassportCard(
      plan: _currentPlan,
      adoptersLoading: _adoptersLoading,
      adoptersError: _adoptersError,
      adoptersCount: _adoptersCount,
      updatingPublic: _updatingPublic,
      environment: environment,
      snarkyVoice: snarkyVoice,
      showBriefing: showBriefing,
      chartSlot: chartSlot,
      metricCells: metricCells,
      selectedSlot: selectedSlot,
      onSelectSlot: onSelectSlot,
      onPublicChanged: (value) async {
        setState(() {
          _updatingPublic = true;
        });
        try {
          final updated = await PlanApi.updateCalendarPlanPublic(
            planId: _currentPlan.id,
            isPublic: value,
          );
          if (!mounted) return;
          _setPlan(updated);
          showAppSnackBar(
            context,
            value ? 'План сделан публичным' : 'План скрыт (только для вас)',
          );
        } catch (e) {
          if (!mounted) return;
          showAppSnackBar(
            context,
            'Не удалось обновить видимость плана: $e',
            isError: true,
          );
        } finally {
          if (mounted) {
            setState(() {
              _updatingPublic = false;
            });
          }
        }
      },
    );
  }

  Widget _buildMesocycleExpansionTile(Mesocycle mesocycle, Color accent) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hairline = (isDark
            ? instrument.hairlineBorder
            : colors.outlineVariant)
        .withValues(alpha: isDark ? 0.85 : 0.55);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: InstrumentTheme.instrumentCardDecoration(
        context,
        radius: 22,
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded:
              mesocycle.orderIndex <= 1 || _currentPlan.mesocycles.length == 1,
          tilePadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          childrenPadding: const EdgeInsets.only(bottom: 8),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MESOCYCLE ${mesocycle.orderIndex} · ${mesocycle.microcycles.length} MICRO',
                style: InstrumentTheme.tabular(
                  InstrumentTheme.microLabel(context, color: accent),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                mesocycle.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          children: [
            if (mesocycle.weeksCount != null ||
                mesocycle.microcycleLengthDays != null ||
                (mesocycle.normalizationValue != null &&
                    mesocycle.normalizationUnit != null)) ...[
              Container(height: 1, color: hairline),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Wrap(
                  spacing: 14,
                  runSpacing: 4,
                  children: [
                    if (mesocycle.weeksCount != null)
                      _buildCompactInfo('Weeks', '${mesocycle.weeksCount}'),
                    if (mesocycle.microcycleLengthDays != null)
                      _buildCompactInfo(
                        'Length',
                        '${mesocycle.microcycleLengthDays}d',
                      ),
                    if (mesocycle.normalizationValue != null &&
                        mesocycle.normalizationUnit != null)
                      _buildCompactInfo(
                        'Norm',
                        '${mesocycle.normalizationValue}${mesocycle.normalizationUnit}',
                      ),
                  ],
                ),
              ),
            ],
            for (var i = 0; i < mesocycle.microcycles.length; i++) ...[
              Container(height: 1, color: hairline),
              _buildMicrocycleCard(mesocycle.microcycles[i], hairline),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMicrocycleCard(Microcycle microcycle, Color hairline) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final name = microcycle.name.trim();
    final orderIndex = microcycle.orderIndex;
    final orderNumber = orderIndex >= 0 ? orderIndex + 1 : 1;
    final fallbackLabel = 'Micro $orderNumber';
    final primaryLabel = name.isNotEmpty ? name : fallbackLabel;
    final hasSecondaryLabel = name.isNotEmpty;

    final plannedDays = microcycle.planWorkouts.length;
    final dayCount =
        microcycle.daysCount ?? (plannedDays > 0 ? plannedDays : null);
    final subtitleParts = <String>[
      if (hasSecondaryLabel) fallbackLabel,
      if (dayCount != null) '${dayCount}d',
      if (microcycle.normalizationValue != null &&
          microcycle.normalizationUnit != null)
        'Norm ${microcycle.normalizationValue}${microcycle.normalizationUnit}',
    ];

    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
        title: Text(
          primaryLabel,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: subtitleParts.isNotEmpty
            ? Text(
                subtitleParts.join(' · '),
                style: InstrumentTheme.tabular(
                  theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ) ??
                      TextStyle(color: colors.onSurfaceVariant, fontSize: 11),
                ),
              )
            : null,
        children: [
          if (microcycle.normalizationRules.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 2, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NORMALIZATION RULES',
                    style: InstrumentTheme.microLabel(context),
                  ),
                  const SizedBox(height: 4),
                  ...microcycle.normalizationRules.map(
                    (rule) => _buildNormalizationRuleChip(rule),
                  ),
                ],
              ),
            ),
          if (microcycle.planWorkouts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text('No plan workouts available'),
            )
          else
            for (var i = 0; i < microcycle.planWorkouts.length; i++) ...[
              Container(height: 1, color: hairline),
              _buildWorkoutDayCard(microcycle.planWorkouts[i], hairline),
            ],
        ],
      ),
    );
  }

  Widget _buildNormalizationRuleChip(NormalizationRule rule) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Δ ${rule.value}${rule.unit}',
            style: InstrumentTheme.tabular(
              TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colors.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _formatNormalizationScope(rule),
              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactInfo(String label, String value) {
    final colors = Theme.of(context).colorScheme;
    return Text(
      '$label: $value',
      style: InstrumentTheme.tabular(
        TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
      ),
    );
  }

  String _formatNormalizationScope(NormalizationRule rule) {
    final scopes = <String>[];
    if (rule.exerciseIds.isNotEmpty) {
      scopes.add('ex: ${rule.exerciseIds.join(', ')}');
    }
    if (rule.muscleGroups.isNotEmpty) {
      scopes.add('groups: ${rule.muscleGroups.join(', ')}');
    }
    if (rule.targetMuscles.isNotEmpty) {
      scopes.add('targets: ${rule.targetMuscles.join(', ')}');
    }
    if (scopes.isEmpty) {
      return 'All exercises';
    }
    return scopes.join(' • ');
  }
}
