import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/services/api_client.dart';
import 'package:workout_app/services/service_locator.dart';
import 'package:workout_app/src/widgets/snack_utils.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/empty_state.dart';
import 'package:workout_app/widgets/error_message.dart';
import 'package:workout_app/widgets/instrument_modal.dart';
import 'package:workout_app/widgets/loading_indicator.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';

import '../models/workout.dart';
import '../services/plan_service.dart';
import 'workout_detail_screen.dart';

class WorkoutListScreen extends ConsumerStatefulWidget {
  final int progressionId;

  const WorkoutListScreen({super.key, required this.progressionId});

  @override
  ConsumerState<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends ConsumerState<WorkoutListScreen> {
  late Future<List<Workout>> _workoutsFuture;
  bool _isLoading = false;
  String? _errorMessage;
  late Future<Workout?> _nextWorkoutFuture;

  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _loadWorkouts();
      await _loadNextWorkout();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadWorkouts() async {
    final workoutService = ref.read(workoutServiceProvider);
    if (widget.progressionId > 0) {
      _workoutsFuture = workoutService.getWorkoutsByProgressionId(
        widget.progressionId,
      );
    } else {
      _workoutsFuture = workoutService.getWorkouts();
    }
  }

  Future<void> _loadNextWorkout() async {
    final apiClient = ApiClient.create();
    final planService = PlanService(apiClient: apiClient);
    final workoutService = ref.read(workoutServiceProvider);
    _nextWorkoutFuture = () async {
      try {
        debugPrint(
          '[WorkoutListScreen] Loading next workout (by plan order)...',
        );
        final activePlan = await planService.getActivePlan();
        if (activePlan == null) {
          debugPrint('[WorkoutListScreen] No active plan');
          return null;
        }
        final workouts = await workoutService.getWorkoutsByAppliedPlan(
          activePlan.id,
        );
        debugPrint(
          '[WorkoutListScreen] Loaded ${workouts.length} workouts from active plan',
        );
        if (workouts.isEmpty) return null;
        workouts.sort(
          (a, b) => (a.planOrderIndex ?? 1 << 30).compareTo(
            b.planOrderIndex ?? 1 << 30,
          ),
        );
        for (final w in workouts) {
          final completed =
              (w.status?.toLowerCase() == 'completed') ||
              (w.completedAt != null);
          if (!completed) {
            debugPrint(
              '[WorkoutListScreen] Next workout by order: id=${w.id}, idx=${w.planOrderIndex}',
            );
            return w;
          }
        }
        debugPrint('[WorkoutListScreen] All workouts in plan are completed');
        return null;
      } catch (_) {
        return null;
      }
    }();
  }

  Future<void> _refreshWorkouts() async {
    await _loadData();
  }

  Future<void> _showAddWorkoutDialog() async {
    final l10n = AppLocalizations.of(context);
    _nameController.clear();
    final created = await showInstrumentDialog<bool>(
      context: context,
      eyebrow: 'NEW WORKOUT',
      title: l10n.workoutListAddTitle,
      content: TextField(
        controller: _nameController,
        autofocus: true,
        decoration: InstrumentTheme.inputDecoration(
          context,
          labelText: l10n.workoutListNameLabel,
        ),
      ),
      actions: [
        InstrumentActionButton(
          label: l10n.cancel,
          variant: InstrumentActionVariant.secondary,
          onPressed: () => Navigator.pop(context, false),
        ),
        InstrumentActionButton(
          label: l10n.actionAdd,
          icon: Icons.add_rounded,
          onPressed: () {
            if (_nameController.text.trim().isEmpty) {
              showAppSnackBar(
                context,
                l10n.workoutListNameRequired,
                isError: true,
              );
              return;
            }
            Navigator.pop(context, true);
          },
        ),
      ],
    );

    if (created != true || !mounted) return;
    try {
      final workoutService = ref.read(workoutServiceProvider);
      final workout = Workout(
        name: _nameController.text.trim(),
        exerciseInstances: [],
        id: null,
      );
      await workoutService.createWorkout(workout);
      if (mounted) {
        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          l10n.workoutListCreateError(e.toString()),
          isError: true,
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AssistantChatHost(
      contextBuilder: () async => {
        'screen': 'workout_list',
        'entities': {'progression_id': widget.progressionId},
      },
      builder: (context, openChat) {
        final l10n = AppLocalizations.of(context);
        return AmbientScaffoldShell(
          appBar: PrimaryAppBar(
            title: l10n.workoutListTitle,
            onTitleTap: openChat,
            showBack: true,
            actions: [
              IconButton(
                onPressed: _showAddWorkoutDialog,
                icon: const Icon(Icons.add_rounded),
                tooltip: l10n.workoutListAddTitle,
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refreshWorkouts,
            child: _buildBody(context),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    final topInset = AmbientScaffoldShell.topContentInset(context);
    final bottomInset = AmbientScaffoldShell.bottomContentInset(context);

    if (_isLoading) {
      return Padding(
        padding: EdgeInsets.only(top: topInset, bottom: bottomInset),
        child: const LoadingIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: EdgeInsets.only(top: topInset, bottom: bottomInset),
        child: ErrorMessage(
          message: AppLocalizations.of(context).workoutListLoadError(_errorMessage!),
          onRetry: _loadData,
        ),
      );
    }

    return FutureBuilder<List<Workout>>(
      future: _workoutsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: EdgeInsets.only(top: topInset, bottom: bottomInset),
            child: const LoadingIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: EdgeInsets.only(top: topInset, bottom: bottomInset),
            child: ErrorMessage(
              message: AppLocalizations.of(context).workoutListLoadError(
                snapshot.error.toString(),
              ),
              onRetry: _loadData,
            ),
          );
        }

        final workouts = snapshot.data ?? [];

        if (workouts.isEmpty) {
          final l10n = AppLocalizations.of(context);
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              16,
              topInset + 24,
              16,
              bottomInset + 24,
            ),
            children: [
              EmptyState(
                icon: Icons.fitness_center_rounded,
                title: l10n.workoutListEmptyTitle,
                description: l10n.workoutListEmptyDescription,
                action: InstrumentActionButton(
                  label: l10n.workoutListAddTitle,
                  icon: Icons.add_rounded,
                  onPressed: _showAddWorkoutDialog,
                ),
              ),
            ],
          );
        }

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            16,
            topInset + 8,
            16,
            bottomInset + 24,
          ),
          children: [
            _buildNextWorkoutCard(),
            _WorkoutCatalogModule(
              workouts: workouts,
              onSelect: (workout) async {
                if (workout.id == null) return;
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        WorkoutDetailScreen(workoutId: workout.id!),
                  ),
                );
                if (result == true && mounted) {
                  await _refreshWorkouts();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildNextWorkoutCard() {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);

    return FutureBuilder<Workout?>(
      future: _nextWorkoutFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting ||
            snap.hasError ||
            snap.data == null) {
          return const SizedBox.shrink();
        }
        final nw = snap.data!;
        final when = nw.scheduledFor != null
            ? DateFormat('yMMMd, HH:mm').format(nw.scheduledFor!.toLocal())
            : null;

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Container(
            decoration: InstrumentTheme.instrumentCardDecoration(
              context,
              accentColor: instrument.workingAura,
            ),
            clipBehavior: Clip.antiAlias,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  if (nw.id == null) return;
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          WorkoutDetailScreen(workoutId: nw.id!),
                    ),
                  );
                  if (result == true && mounted) {
                    await _refreshWorkouts();
                  } else {
                    await _loadNextWorkout();
                    if (mounted) setState(() {});
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'NEXT IN PLAN',
                              style: InstrumentTheme.microLabel(
                                context,
                                color: instrument.workingAura,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: scheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        nw.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(height: 1, color: instrument.hairlineBorder),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.workoutListNextWorkout,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          if (when != null)
                            Text(
                              when,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: instrument.workingAura,
                                fontWeight: FontWeight.w600,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WorkoutCatalogModule extends StatelessWidget {
  final List<Workout> workouts;
  final ValueChanged<Workout> onSelect;

  const _WorkoutCatalogModule({
    required this.workouts,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);

    return Container(
      decoration: InstrumentTheme.instrumentCardDecoration(context),
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
                  'WORKOUT DIRECTORY · ${workouts.length}',
                  style: InstrumentTheme.microLabel(context).copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context).workoutListSectionTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: instrument.hairlineBorder),
          for (int i = 0; i < workouts.length; i++) ...[
            if (i > 0) Container(height: 1, color: instrument.hairlineBorder),
            InkWell(
              onTap: () => onSelect(workouts[i]),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 56),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workouts[i].name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              l10n.exerciseCount(
                                workouts[i].exerciseInstances.length,
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: scheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
