import 'package:flutter/material.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/loading_indicator.dart';
import 'package:workout_app/widgets/error_message.dart';
import 'package:workout_app/widgets/empty_state.dart';

import '../config/api_config.dart';
import '../models/user_max.dart';
import '../services/api_client.dart';
import 'user_max_widget.dart';

class UserMaxScreen extends ConsumerStatefulWidget {
  const UserMaxScreen({super.key});

  @override
  ConsumerState<UserMaxScreen> createState() => _UserMaxScreenState();
}

class _UserMaxScreenState extends ConsumerState<UserMaxScreen> {
  final ApiClient _apiClient = ApiClient.create();
  late Future<List<UserMax>> _futureMaxes;

  @override
  void initState() {
    super.initState();
    _futureMaxes = _fetchUserMaxes();
  }

  Future<List<UserMax>> _fetchUserMaxes() async {
    final response = await _apiClient.get(
      ApiConfig.getUserMaxesEndpoint(),
      context: 'UserMaxScreen',
    );

    if (response is List) {
      return response
          .map(
            (item) => UserMax.fromJson(
              item is Map<String, dynamic>
                  ? item
                  : Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    }

    throw const FormatException('Unexpected response when fetching user maxes');
  }

  Future<Map<String, dynamic>> _fetchWeakMuscleAnalysis({
    bool useLlm = true,
  }) async {
    final endpoint = ApiConfig.getWeakMuscleAnalysisEndpoint(useLlm: false);
    final response = await _apiClient.get(
      endpoint,
      queryParams: {'use_llm': useLlm.toString()},
      context: 'UserMaxScreen.analysis',
    );
    if (response is Map<String, dynamic>) return response;
    if (response is Map) return Map<String, dynamic>.from(response);
    throw const FormatException('Unexpected response for weak muscle analysis');
  }

  Future<Map<String, dynamic>> _buildChatContext() async {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    return <String, dynamic>{
      'v': 1,
      'app': 'WorkoutApp',
      'screen': 'user_max',
      'role': 'athlete',
      'timestamp': nowIso,
      'entities': <String, dynamic>{},
    };
  }

  Future<void> _showWeakMuscleAnalysis() async {
    try {
      final data = await _fetchWeakMuscleAnalysis(useLlm: true);
      if (!mounted) return;

      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (ctx) {
          final weak = (data['weak_muscles'] as List?) ?? const [];
          final muscleStrength =
              (data['muscle_strength'] as Map?)?.cast<String, dynamic>() ??
              const {};
          final trends =
              (data['trend'] as Map?)?.cast<String, dynamic>() ?? const {};
          final llmEnabled = data['llm_enabled'] == true;
          final anomalies = (data['anomalies'] as List?) ?? const [];
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.75,
            minChildSize: 0.5,
            builder: (_, controller) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: ListView(
                controller: controller,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).userMaxWeakMusclesTitle,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      if (llmEnabled)
                        Tooltip(
                          message: AppLocalizations.of(context).userMaxLlmEnriched,
                          child: const Icon(Icons.smart_toy_outlined),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context).userMaxTopWeakMuscles,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (weak.isEmpty)
                    Text(AppLocalizations.of(context).noData)
                  else
                    ...weak.map((w) {
                      final m = w as Map;
                      final muscle = m['muscle']?.toString() ?? '-';
                      final z = m['z']?.toString() ?? '-';
                      final score = m['score']?.toString() ?? '-';
                      final pr = m['priority']?.toString();
                      final reason = m['priority_reason']?.toString();
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(muscle),
                        subtitle: Text(
                          'z=$z, score=$score${pr != null ? ', priority=$pr' : ''}${reason != null && reason.isNotEmpty ? '\n$reason' : ''}',
                        ),
                      );
                    }),
                  const Divider(height: 24),
                  Text(
                    AppLocalizations.of(context).userMaxStrengthByMuscle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (muscleStrength.isEmpty)
                    Text(AppLocalizations.of(context).noData)
                  else
                    ...(muscleStrength.entries.toList()
                          ..sort((a, b) => (a.key).compareTo(b.key)))
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              children: [
                                Expanded(child: Text(e.key)),
                                Text(e.value.toString()),
                              ],
                            ),
                          ),
                        ),
                  const Divider(height: 24),
                  Text(
                    AppLocalizations.of(context).userMaxTrends,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (trends.isEmpty)
                    Text(AppLocalizations.of(context).noData)
                  else
                    ...trends.entries.map((e) {
                      final v = (e.value as Map).cast<String, dynamic>();
                      final ra = v['recent_avg'];
                      final pa = v['prev_avg'];
                      final d = v['delta'];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(e.key),
                        subtitle: Text(
                          'recent=${ra ?? '-'}, prev=${pa ?? '-'}, Δ=${d ?? '-'}',
                        ),
                      );
                    }),
                  const Divider(height: 24),
                  Text(
                    AppLocalizations.of(context).userMaxAnomalies,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    anomalies.isEmpty
                        ? AppLocalizations.of(context).userMaxNoneDetected
                        : anomalies.join(', '),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).userMaxAnalysisError(e.toString()),
          ),
        ),
      );
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _futureMaxes = _fetchUserMaxes();
    });
    await _futureMaxes;
  }

  String _exerciseTitle(UserMax max) {
    if (max.exerciseName.isNotEmpty) return max.exerciseName;
    if (max.name.isNotEmpty) return max.name;
    return AppLocalizations.of(context).userMaxExerciseFallback(
      max.exerciseId.toString(),
    );
  }

  Future<void> _deleteUserMax(UserMax max) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.userMaxDeleteTitle),
        content: Text(
          l10n.userMaxDeleteBody(
            _exerciseTitle(max),
            max.repMax.toString(),
            max.maxWeight.toString(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _apiClient.delete(
        ApiConfig.deleteUserMaxEndpoint(max.id.toString()),
        context: 'UserMaxScreen.delete',
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.userMaxDeleted)));
        await _refresh();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.userMaxDeleteError(e.toString()))),
        );
      }
    }
  }

  Widget _buildAttemptRow(UserMax max, {required bool highlight}) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: InstrumentTheme.cardDecoration(
        context,
        color: highlight
            ? Color.alphaBlend(
                instrument.successColor.withValues(alpha: 0.10),
                colors.surfaceContainerHighest,
              )
            : colors.surfaceContainerHighest.withValues(alpha: 0.4),
        borderColor: highlight
            ? instrument.successColor.withValues(alpha: 0.5)
            : null,
        radius: 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context).unitKgValue(max.maxWeight.toString()),
                      style: InstrumentTheme.tabular(
                        (theme.textTheme.bodyMedium ?? const TextStyle())
                            .copyWith(
                          fontWeight:
                              highlight ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ),
                    if (highlight) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: instrument.successColor.withValues(
                            alpha: 0.16,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'TOP',
                          style: InstrumentTheme.microLabel(
                            context,
                            color: instrument.successColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${AppLocalizations.of(context).userMaxRepsLabel}: ${max.repMax}',
                  style: InstrumentTheme.tabular(
                    theme.textTheme.bodySmall ?? const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              tooltip: AppLocalizations.of(context).userMaxDeleteTooltip,
              style: IconButton.styleFrom(
                minimumSize: const Size(48, 48),
                tapTargetSize: MaterialTapTargetSize.padded,
              ),
              icon: Icon(Icons.delete_outline, color: colors.error, size: 20),
              onPressed: () => _deleteUserMax(max),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedList(List<UserMax> data) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dimensions = UiDimensions.of(context);
    final Map<int, List<UserMax>> grouped = {};
    for (final max in data) {
      grouped.putIfAbsent(max.exerciseId, () => []).add(max);
    }

    final entries = grouped.entries.toList()
      ..sort((a, b) {
        final nameA = _exerciseTitle(a.value.first);
        final nameB = _exerciseTitle(b.value.first);
        return nameA.toLowerCase().compareTo(nameB.toLowerCase());
      });

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(dimensions.pagePadding),
      itemCount: entries.length,
      separatorBuilder: (_, __) => SizedBox(height: dimensions.rowGap),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final items = [...entry.value]
          ..sort((a, b) => b.maxWeight.compareTo(a.maxWeight));
        final top = items.first;

        return Container(
          padding: EdgeInsets.all(dimensions.cardPadding),
          decoration: InstrumentTheme.cardDecoration(
            context,
            color: colors.surfaceContainerLow,
            radius: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      _exerciseTitle(top),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        AppLocalizations.of(context).unitKgValue(top.maxWeight.toString()),
                        style: InstrumentTheme.tabular(
                          (theme.textTheme.titleMedium ?? const TextStyle())
                              .copyWith(
                            fontWeight: FontWeight.w800,
                            color: colors.primary,
                          ),
                        ),
                      ),
                      Text(
                        'BEST · ${top.repMax} REPS',
                        style: InstrumentTheme.tabular(
                          InstrumentTheme.microLabel(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ...items.map(
                (max) => _buildAttemptRow(max, highlight: max.id == top.id),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AssistantChatHost(
      contextBuilder: _buildChatContext,
      builder: (context, openChat) {
        final l10n = AppLocalizations.of(context);
        return Scaffold(
          appBar: PrimaryAppBar(
            title: l10n.userMaxesTitle,
            onTitleTap: openChat,
            actions: [
              SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  tooltip: l10n.userMaxWeakMusclesTitle,
                  style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    tapTargetSize: MaterialTapTargetSize.padded,
                  ),
                  icon: const Icon(Icons.analytics_outlined),
                  onPressed: _showWeakMuscleAnalysis,
                ),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refresh,
            child: FutureBuilder<List<UserMax>>(
              future: _futureMaxes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingIndicator();
                }

                if (snapshot.hasError) {
                  return ErrorMessage(
                    message: l10n.failedToLoadData('${snapshot.error}'),
                    onRetry: _refresh,
                  );
                }

                final data = snapshot.data ?? [];
                if (data.isEmpty) {
                  return EmptyState(
                    icon: Icons.fitness_center,
                    title: l10n.noMaxesSavedTitle,
                    description: l10n.addFirstMaxWeightDescription,
                  );
                }

                return _buildGroupedList(data);
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final created = await UserMaxWidget.showAsBottomSheet(context);
              if (created == true) {
                await _refresh();
              }
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }
}
