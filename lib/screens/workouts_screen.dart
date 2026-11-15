import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_app/config/api_config.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/responsive.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/models/workout.dart';
import 'package:workout_app/providers/ambient_environment_provider.dart';
import 'package:workout_app/providers/interface_maker_provider.dart';
import 'package:workout_app/screens/user_profile_screen.dart';
import 'package:workout_app/screens/workout_detail_screen.dart';
import 'package:workout_app/services/base_api_service.dart';
import 'package:workout_app/services/logger_service.dart';
import 'package:workout_app/services/service_locator.dart';
import 'package:workout_app/services/user_analytics_service.dart';
import 'package:workout_app/services/workout_service.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/interface_maker_sheet.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';
import 'package:workout_app/widgets/responsive_container.dart';
import 'package:workout_app/widgets/workout_instrument_cards.dart';
import 'active_plan_screen.dart';

final manualWorkoutsNotifierProvider =
    StateNotifierProvider<ManualWorkoutsNotifier, AsyncValue<List<Workout>>>((
      ref,
    ) {
      final workoutService = ref.watch(workoutServiceProvider);
      return ManualWorkoutsNotifier(workoutService);
    });

final nextWorkoutProvider = StreamProvider<Workout?>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final workoutService = ref.watch(workoutServiceProvider);

  return (() async* {
    try {
      await for (final data in apiClient.getSWR(
        ApiConfig.activePlanWorkoutsEndpoint + '/summary',
        context: 'WorkoutsScreen.nextWorkout.activePlanWorkouts.summary',
        ttlSeconds: 60,
        groups: const ['plans:active_workouts'],
        skipNetworkIfFresh: true,
      )) {
        if (data is! List) {
          yield null;
          continue;
        }

        final items = data
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        if (items.isEmpty) {
          yield null;
          continue;
        }

        bool isCompletedSummary(Map<String, dynamic> m) {
          final status = (m['status']?.toString() ?? '').toLowerCase();
          final isCancelled =
              status == 'cancelled' ||
              status == 'canceled' ||
              status == 'dropped';
          if (status == 'completed') return true;
          return m['completed_at'] != null && !isCancelled;
        }

        DateTime? parseDate(dynamic raw) {
          if (raw == null) return null;
          if (raw is DateTime) return raw;
          if (raw is String) return DateTime.tryParse(raw);
          return null;
        }

        items.sort((a, b) {
          final ao = a['order_index'];
          final bo = b['order_index'];
          final ai = ao is int ? ao : int.tryParse(ao?.toString() ?? '') ?? 0;
          final bi = bo is int ? bo : int.tryParse(bo?.toString() ?? '') ?? 0;
          return ai.compareTo(bi);
        });

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        Map<String, dynamic>? chosen;
        Map<String, dynamic>? pastFallback;

        for (final m in items) {
          if (isCompletedSummary(m)) continue;
          final dt = parseDate(m['scheduled_for'])?.toLocal();
          if (dt == null) {
            chosen ??= m;
            continue;
          }
          final day = DateTime(dt.year, dt.month, dt.day);
          if (!day.isBefore(today)) {
            chosen = m;
            break;
          }
          pastFallback ??= m;
        }

        final selected = chosen ?? pastFallback;
        if (selected == null) {
          yield null;
          continue;
        }

        final rawId = selected['id'];
        final workoutId = rawId is int
            ? rawId
            : int.tryParse(rawId?.toString() ?? '');
        if (workoutId == null) {
          yield null;
          continue;
        }

        Workout? resolved;
        try {
          await for (final w in workoutService.getWorkoutWithDetailsSWR(
            workoutId,
            ttlSeconds: 600,
          )) {
            resolved = w;
            break;
          }
        } catch (_) {
          resolved = null;
        }

        yield resolved;
      }
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        yield null;
        return;
      }
      rethrow;
    }
  })();
});

class WorkoutsScreen extends ConsumerStatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  ConsumerState<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class ManualWorkoutsNotifier extends StateNotifier<AsyncValue<List<Workout>>> {
  final WorkoutService _workoutService;
  final int _limit = 20;
  int _skip = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  List<Workout> _items = [];
  StreamSubscription<List<Workout>>? _sub;
  int _nextLocalId = 1;

  ManualWorkoutsNotifier(this._workoutService)
    : super(const AsyncValue.loading()) {
    loadInitial();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  List<Workout> get items => _items;

  int addOptimistic(Workout workout) {
    final localId = _nextLocalId++;
    final optimistic = workout.copyWith(localId: localId);
    _items = [optimistic, ..._items];
    state = AsyncValue.data(_items);
    return localId;
  }

  void commitOptimistic(int localId, Workout serverWorkout) {
    final idx = _items.indexWhere((w) => w.localId == localId);
    if (idx == -1) return;
    _items = [..._items]..[idx] = serverWorkout;
    state = AsyncValue.data(_items);
  }

  void rollbackOptimistic(int localId) {
    _items = _items.where((w) => w.localId != localId).toList();
    state = AsyncValue.data(_items);
  }

  Future<void> loadInitial() async {
    await _sub?.cancel();

    if (_items.isEmpty) {
      state = const AsyncValue.loading();
    }
    _skip = 0;
    _hasMore = true;
    _items = [];

    _sub = _workoutService
        .getWorkoutsByTypeSWR(WorkoutType.manual)
        .listen(
          (workouts) {
            _items = workouts;
            _hasMore = workouts.length == _limit;
            _skip = _items.length;
            state = AsyncValue.data(_items);
          },
          onError: (e, st) {
            state = AsyncValue.error(
              e,
              st is StackTrace ? st : StackTrace.current,
            );
          },
        );
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;
    _isLoadingMore = true;
    try {
      final page = await _workoutService.getWorkoutsPaged(
        skip: _skip,
        limit: _limit,
      );
      if (page.isEmpty) {
        _hasMore = false;
      } else {
        _items = [..._items, ...page];
        _skip = _items.length;
        _hasMore = page.length == _limit;
        state = AsyncValue.data(_items);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> deleteWorkout(int workoutId) async {
    try {
      await _workoutService.deleteWorkout(workoutId);
      _items.removeWhere((workout) => workout.id == workoutId);
      state = AsyncValue.data(_items);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

class _WorkoutsScreenState extends ConsumerState<WorkoutsScreen> {
  final LoggerService _logger = LoggerService('WorkoutsScreen');
  final TextEditingController _nameController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Track screen opening
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        UserAnalyticsService.instance.trackScreenOpen('workouts_screen'),
      );
      ref.read(manualWorkoutsNotifierProvider.notifier).loadInitial();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(manualWorkoutsNotifierProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _buildChatContext() async {
    final nextWorkout = ref.read(nextWorkoutProvider).valueOrNull;
    final manualCount = ref.read(manualWorkoutsNotifierProvider).valueOrNull?.length ?? 0;
    return <String, dynamic>{
      'v': 1,
      'app': 'WorkoutApp',
      'screen': 'workouts',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'entities': <String, dynamic>{
        'next_workout': nextWorkout != null
            ? {'id': nextWorkout.id, 'name': nextWorkout.name}
            : null,
        'manual_workouts_count': manualCount,
      },
    };
  }

  Future<void> _showCreateWorkoutDialog() async {
    // Track workout creation attempt
    await UserAnalyticsService.instance.trackWorkoutAction(
      'create_attempt',
      null,
    );

    _nameController.clear();
    final workoutService = ref.read(workoutServiceProvider);

    final notesController = TextEditingController();
    bool startNow = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) {
          return AlertDialog(
            title: const Text('Create Workout'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name *'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: 'Notes'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: startNow,
                        onChanged: (v) =>
                            setStateDialog(() => startNow = v ?? false),
                      ),
                      const Text('Start now (sets started_at)'),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  String? emptyToNull(String s) =>
                      s.trim().isEmpty ? null : s.trim();
                  final name = _nameController.text.trim();
                  if (name.isEmpty) return;
                  try {
                    final workout = Workout(
                      name: name,
                      notes: emptyToNull(notesController.text),
                      startedAt: startNow ? DateTime.now() : null,
                      exerciseInstances: const [],
                    );
                    Navigator.of(ctx).pop();
                    if (!mounted) return;

                    unawaited(() async {
                      final notifier = ref.read(
                        manualWorkoutsNotifierProvider.notifier,
                      );
                      final optimisticLocalId = notifier.addOptimistic(workout);
                      try {
                        final created = await workoutService.createWorkout(
                          workout,
                        );
                        if (!mounted) return;

                        // Track successful workout creation
                        await UserAnalyticsService.instance.trackWorkoutAction(
                          'create_success',
                          created.id,
                          properties: {
                            'workout_name': created.name,
                            'start_now': startNow,
                          },
                        );

                        notifier.commitOptimistic(optimisticLocalId, created);

                        await ref.read(apiClientProvider).invalidateCacheGroups(
                          const ['workouts:list'],
                        );
                        notifier.loadInitial();
                      } catch (e) {
                        if (!mounted) return;
                        notifier.rollbackOptimistic(optimisticLocalId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to create workout: $e'),
                          ),
                        );
                      }
                    }());
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to create workout: $e')),
                    );
                  }
                },
                child: const Text('Create'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openActivePlan() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ActivePlanScreen()),
    );
  }

  Future<void> _openManualWorkout(int workoutId) async {
    await UserAnalyticsService.instance.trackWorkoutAction('open', workoutId);

    try {
      // ignore: unawaited_futures
      ref.read(workoutServiceProvider).getWorkoutWithDetailsSWR(workoutId).first;
    } catch (_) {}

    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkoutDetailScreen(workoutId: workoutId),
      ),
    );
    if (!mounted) return;
    try {
      await ref.read(apiClientProvider).invalidateCacheGroups(const [
        'workouts:list',
        'workouts:detail',
      ]);
    } catch (_) {}
    if (!mounted) return;
    // ignore: unawaited_futures
    ref.read(manualWorkoutsNotifierProvider.notifier).loadInitial();
  }

  Future<void> _deleteManualWorkout(Workout workout) async {
    final workoutId = workout.id;
    if (workoutId == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить тренировку?'),
        content: const Text(
          'Вы уверены, что хотите удалить эту ручную тренировку?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref
          .read(manualWorkoutsNotifierProvider.notifier)
          .deleteWorkout(workoutId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dimensions = UiDimensions.of(context);
    final instrument = InstrumentTheme.of(context);

    final nextWorkoutAsync = ref.watch(nextWorkoutProvider);
    final manualWorkoutsState = ref.watch(manualWorkoutsNotifierProvider);
    final interfaceConfig = ref.watch(interfaceMakerProvider);

    final Workout? envWorkout = nextWorkoutAsync.valueOrNull ??
        ((manualWorkoutsState.valueOrNull?.isNotEmpty ?? false)
            ? manualWorkoutsState.valueOrNull!.first
            : null);
    final env = TrainingEnvironmentData.fromWorkout(envWorkout);
    final accent = env.accentColor(instrument);

    return AssistantChatHost(
      contextBuilder: _buildChatContext,
      builder: (context, openChat) {
        final showBriefing = interfaceConfig.isModuleVisible(
          LayoutModule.commandBriefing,
        );

        Widget buildModule(LayoutModule module) {
          switch (module) {
            case LayoutModule.variantOrHorizonStrip:
              return Padding(
                padding: EdgeInsets.only(bottom: dimensions.sectionGap),
                child: CanvasPillStrip(
                  padding: EdgeInsets.symmetric(
                    horizontal: dimensions.pagePadding,
                  ),
                  items: [
                    CanvasPillItem(
                      label: InterfacePreset.powerlifter.label,
                      selected:
                          interfaceConfig.preset == InterfacePreset.powerlifter,
                      accentColor: accent,
                      onTap: () => ref
                          .read(interfaceMakerProvider.notifier)
                          .applyPreset(InterfacePreset.powerlifter),
                    ),
                    CanvasPillItem(
                      label: InterfacePreset.volume.label,
                      selected:
                          interfaceConfig.preset == InterfacePreset.volume,
                      accentColor: accent,
                      onTap: () => ref
                          .read(interfaceMakerProvider.notifier)
                          .applyPreset(InterfacePreset.volume),
                    ),
                    CanvasPillItem(
                      label: InterfacePreset.minimalist.label,
                      selected:
                          interfaceConfig.preset == InterfacePreset.minimalist,
                      accentColor: accent,
                      onTap: () => ref
                          .read(interfaceMakerProvider.notifier)
                          .applyPreset(InterfacePreset.minimalist),
                    ),
                    CanvasPillItem(
                      label: 'Сетка',
                      icon: Icons.grid_view_rounded,
                      onTap: () => InterfaceMakerSheet.show(context),
                    ),
                    CanvasPillItem(
                      label: 'План',
                      icon: Icons.calendar_today_outlined,
                      onTap: _openActivePlan,
                    ),
                  ],
                ),
              );
            case LayoutModule.commandBriefing:
              // Rendered cleanly inside WorkoutHeroInstrumentCard header.
              return const SizedBox.shrink();
            case LayoutModule.primaryTelemetry:
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  dimensions.pagePadding,
                  0,
                  dimensions.pagePadding,
                  dimensions.sectionGap,
                ),
                child: nextWorkoutAsync.when(
                  loading: () => Container(
                    padding: EdgeInsets.all(dimensions.cardPadding + 8),
                    decoration: InstrumentTheme.instrumentCardDecoration(
                      context,
                      accentColor: accent,
                      radius: 22,
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, _) => Container(
                    padding: EdgeInsets.all(dimensions.cardPadding + 2),
                    decoration: InstrumentTheme.instrumentCardDecoration(
                      context,
                      accentColor: scheme.error,
                      radius: 22,
                    ),
                    child: Text(
                      'Ошибка загрузки плана: $err',
                      style: TextStyle(color: scheme.error),
                    ),
                  ),
                  data: (nextWorkout) => WorkoutHeroInstrumentCard(
                    workout: nextWorkout,
                    environment: env,
                    slots: interfaceConfig.slots,
                    showChart: interfaceConfig.showChart,
                    showBriefing: showBriefing,
                    snarkyVoice: interfaceConfig.snarkyVoice,
                    onOpenPlan: _openActivePlan,
                    onOpenWorkout:
                        (nextWorkout != null && nextWorkout.id != null)
                            ? () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => WorkoutDetailScreen(
                                      workoutId: nextWorkout.id!,
                                    ),
                                  ),
                                );
                                if (!mounted) return;
                                ref.invalidate(nextWorkoutProvider);
                              }
                            : null,
                  ),
                ),
              );
            case LayoutModule.scheduleOrLibrary:
              final notifier =
                  ref.read(manualWorkoutsNotifierProvider.notifier);
              final workouts = manualWorkoutsState.valueOrNull ?? const [];
              if (manualWorkoutsState.hasError) {
                _logger.e(
                  'Error loading workouts: ${manualWorkoutsState.error}\n${manualWorkoutsState.stackTrace}',
                );
              }
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: dimensions.pagePadding,
                ),
                child: WorkoutLibraryInstrumentModule(
                  workouts: workouts,
                  isLoading: manualWorkoutsState.isLoading,
                  error: manualWorkoutsState.hasError
                      ? manualWorkoutsState.error
                      : null,
                  isLoadingMore: notifier.isLoadingMore,
                  hasMore: notifier.hasMore,
                  onRetry: notifier.loadInitial,
                  onCreateWorkout: _showCreateWorkoutDialog,
                  onOpenWorkout: (workout) {
                    final id = workout.id;
                    if (id == null) return;
                    _openManualWorkout(id);
                  },
                  onDeleteWorkout: _deleteManualWorkout,
                ),
              );
          }
        }

        final moduleChildren = <Widget>[
          for (final module in interfaceConfig.visibleModules)
            buildModule(module),
        ];

        return AmbientScaffoldShell(
          environment: env,
          appBar: PrimaryAppBar.main(
            title: 'Тренировки',
            onTitleTap: openChat,
            actions: [
              IconButton(
                tooltip: 'Профиль',
                icon: const Icon(Icons.account_circle_outlined),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const UserProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(nextWorkoutProvider);
              await Future.wait([
                ref
                    .read(manualWorkoutsNotifierProvider.notifier)
                    .loadInitial(),
                ref.read(nextWorkoutProvider.future),
              ]);
            },
            child: ResponsiveContainer(
              maxWidth: Breakpoints.maxContentWidthWide,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.only(
                      top: AmbientScaffoldShell.topContentInset(context),
                      bottom: AmbientScaffoldShell.bottomContentInset(context),
                    ),
                    sliver: SliverList.list(children: moduleChildren),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
