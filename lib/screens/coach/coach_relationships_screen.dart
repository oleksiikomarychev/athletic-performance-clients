import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:workout_app/config/constants/route_names.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/models/crm_analytics.dart';
import 'package:workout_app/models/crm_coach_athlete_link.dart';
import 'package:workout_app/providers/ambient_environment_provider.dart';
import 'package:workout_app/providers/interface_maker_provider.dart';
import 'package:workout_app/providers/providers.dart';
import 'package:workout_app/screens/coach/coach_chat_screen.dart';
import 'package:workout_app/services/service_locator.dart' as sl;
import 'package:workout_app/src/widgets/snack_utils.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/instrument_metric_matrix.dart';
import 'package:workout_app/widgets/instrument_modal.dart';
import 'package:workout_app/widgets/interface_maker_sheet.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';

final coachRelationshipsStatusFilterProvider = StateProvider<String?>(
  (ref) => null,
);

final coachRelationshipsProvider = FutureProvider<List<CoachAthleteLink>>((
  ref,
) async {
  final svc = ref.watch(sl.crmRelationshipsServiceProvider);
  final links = await svc.getMyAthletes();
  return links;
});

final coachRelationshipsAnalyticsProvider =
    FutureProvider<Map<String, AthleteTrainingSummaryModel>>((ref) async {
      final svc = ref.watch(sl.crmAnalyticsServiceProvider);
      final analytics = await svc.getMyAthletesAnalytics();
      final map = <String, AthleteTrainingSummaryModel>{};
      for (final athlete in analytics.athletes) {
        map[athlete.athleteId] = athlete;
      }
      return map;
    });

class CoachRelationshipsScreen extends ConsumerWidget {
  const CoachRelationshipsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncLinks = ref.watch(coachRelationshipsProvider);
    final analyticsAsync = ref.watch(coachRelationshipsAnalyticsProvider);
    final allUsersAsync = ref.watch(allUsersProvider(false));
    final filter = ref.watch(coachRelationshipsStatusFilterProvider);
    final env = ref.watch(activeTrainingEnvironmentProvider(null));
    final instrument = InstrumentTheme.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dims = UiDimensions.of(context);
    final hairline =
        (theme.brightness == Brightness.dark
                ? instrument.hairlineBorder
                : scheme.outlineVariant)
            .withValues(alpha: 0.65);

    final analyticsMap = analyticsAsync.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    final usersMap = allUsersAsync.maybeWhen(
      data: (users) => {for (final u in users) u.userId: u},
      orElse: () => null,
    );

    return AssistantChatHost(
      initialMessage:
          'Opening assistant from CoachRelationshipsScreen. Use v1 context to understand status filter and priority relationships.',
      contextBuilder: () => _buildCoachRelationshipsChatContext(ref),
      builder: (context, openChat) {
        return AmbientScaffoldShell(
          environment: env,
          appBar: PrimaryAppBar(
            title: l10n.coachRelationshipsTitle,
            onTitleTap: openChat,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: l10n.refresh,
                onPressed: () => ref.refresh(coachRelationshipsProvider),
              ),
            ],
          ),
          body: asyncLinks.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Padding(
                padding: EdgeInsets.all(dims.pagePadding),
                child: Text(
                  l10n.coachRelationshipsError(error.toString()),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            data: (links) {
              final filteredLinks = filter == null
                  ? links
                  : links
                        .where((l) => l.status.toLowerCase() == filter)
                        .toList();

              return RefreshIndicator(
                onRefresh: () => ref.refresh(coachRelationshipsProvider.future),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    0,
                    AmbientScaffoldShell.topContentInset(context),
                    0,
                    AmbientScaffoldShell.bottomContentInset(context),
                  ),
                  children: [
                    CanvasPillStrip(
                      padding: EdgeInsets.symmetric(
                        horizontal: dims.pagePadding,
                      ),
                      items: [
                        CanvasPillItem(
                          key: const ValueKey('status_all'),
                          label: l10n.coachRelationshipsMenuAll,
                          selected: filter == null,
                          onTap: () =>
                              ref
                                      .read(
                                        coachRelationshipsStatusFilterProvider
                                            .notifier,
                                      )
                                      .state =
                                  null,
                        ),
                        CanvasPillItem(
                          key: const ValueKey('status_pending'),
                          label: l10n.coachRelationshipsMenuPending,
                          selected: filter == 'pending',
                          accentColor: instrument.moderateEffortColor,
                          onTap: () =>
                              ref
                                      .read(
                                        coachRelationshipsStatusFilterProvider
                                            .notifier,
                                      )
                                      .state =
                                  'pending',
                        ),
                        CanvasPillItem(
                          key: const ValueKey('status_active'),
                          label: l10n.coachRelationshipsMenuActive,
                          selected: filter == 'active',
                          accentColor: instrument.successColor,
                          onTap: () =>
                              ref
                                      .read(
                                        coachRelationshipsStatusFilterProvider
                                            .notifier,
                                      )
                                      .state =
                                  'active',
                        ),
                        CanvasPillItem(
                          key: const ValueKey('status_paused'),
                          label: l10n.coachRelationshipsMenuPaused,
                          selected: filter == 'paused',
                          onTap: () =>
                              ref
                                      .read(
                                        coachRelationshipsStatusFilterProvider
                                            .notifier,
                                      )
                                      .state =
                                  'paused',
                        ),
                        CanvasPillItem(
                          key: const ValueKey('status_ended'),
                          label: l10n.coachRelationshipsMenuEnded,
                          selected: filter == 'ended',
                          accentColor: instrument.peakEffortColor,
                          onTap: () =>
                              ref
                                      .read(
                                        coachRelationshipsStatusFilterProvider
                                            .notifier,
                                      )
                                      .state =
                                  'ended',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (filteredLinks.isEmpty)
                      Padding(
                        padding: EdgeInsets.all(dims.pagePadding * 2),
                        child: Center(
                          child: Text(
                            l10n.coachRelationshipsEmpty,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    else
                      for (final link in filteredLinks) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: dims.pagePadding,
                          ),
                          child: _RelationshipModule(
                            link: link,
                            summary: analyticsMap?[link.athleteId],
                            analyticsLoading: analyticsAsync.isLoading,
                            athleteName:
                                usersMap?[link.athleteId]?.displayName ??
                                link.athleteId,
                            hairline: hairline,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _RelationshipModule extends ConsumerWidget {
  final CoachAthleteLink link;
  final AthleteTrainingSummaryModel? summary;
  final bool analyticsLoading;
  final String athleteName;
  final Color hairline;

  const _RelationshipModule({
    required this.link,
    required this.summary,
    required this.analyticsLoading,
    required this.athleteName,
    required this.hairline,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final dims = UiDimensions.of(context);

    final hasChannel = (link.channelId ?? '').isNotEmpty;
    final statusUpper = link.status.toUpperCase();
    final statusLower = link.status.toLowerCase();
    final channelLabel = link.channelId ?? l10n.coachRelationshipsChannelNotCreated;

    final statusAccent = switch (statusLower) {
      'active' => instrument.successColor,
      'pending' => instrument.moderateEffortColor,
      'paused' => instrument.workingAura,
      'ended' => instrument.peakEffortColor,
      _ => scheme.onSurfaceVariant,
    };

    return Container(
      decoration: InstrumentTheme.instrumentCardDecoration(
        context,
        accentColor: statusLower == 'pending'
            ? instrument.moderateEffortColor
            : (statusLower == 'active' ? instrument.successColor : null),
        radius: 22,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              dims.cardPadding,
              dims.cardPadding,
              dims.cardPadding,
              12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.coachRelationshipsChannelPrefix(channelLabel)
                                .toUpperCase(),
                            style: InstrumentTheme.tabular(
                              InstrumentTheme.microLabel(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.coachRelationshipsAthletePrefix(athleteName),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      statusUpper,
                      style: InstrumentTheme.microLabel(
                        context,
                        color: statusAccent,
                      ),
                    ),
                  ],
                ),
                if ((link.note ?? '').isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    l10n.coachRelationshipsNotePrefix(link.note ?? ''),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (analyticsLoading && summary == null) ...[
                  const SizedBox(height: 6),
                  Text(
                    l10n.coachRelationshipsLoadingTrainingSummary,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (summary != null) ...[
            Container(height: 1, color: hairline),
            Padding(
              padding: EdgeInsets.all(dims.cardPadding),
              child: InstrumentMetricMatrix(
                cells: [
                  InstrumentMetricCellData(
                    slot: MetricSlot.setsCount,
                    label: '12W SESS',
                    value: '${summary!.sessionsCount}',
                  ),
                  InstrumentMetricCellData(
                    slot: MetricSlot.tonnage,
                    label: l10n.volumeUpperLabel,
                    value: summary!.totalVolume != null
                        ? summary!.totalVolume!.toStringAsFixed(1)
                        : l10n.coachRelationshipsVolumeDash,
                  ),
                  InstrumentMetricCellData(
                    slot: MetricSlot.durationWeeks,
                    label: l10n.lastUpperLabel,
                    value: summary!.lastWorkoutAt != null
                        ? DateFormat('MMM d').format(
                            summary!.lastWorkoutAt!.toLocal(),
                          )
                        : l10n.coachRelationshipsLastWorkoutNA,
                    subValue: summary!.daysSinceLastWorkout != null
                        ? l10n.coachRelationshipsDaysAgoSuffix(
                            summary!.daysSinceLastWorkout.toString(),
                          )
                        : null,
                  ),
                  InstrumentMetricCellData(
                    slot: MetricSlot.kpsh,
                    label: l10n.planUpperLabel,
                    value:
                        summary!.activePlanName ??
                        l10n.coachRelationshipsLastWorkoutNA,
                  ),
                ],
              ),
            ),
          ],
          Container(height: 1, color: hairline),
          Padding(
            padding: EdgeInsets.all(dims.cardPadding),
            child: statusLower == 'pending'
                ? Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      InstrumentActionButton(
                        label: l10n.coachRelationshipsAccept,
                        icon: Icons.check,
                        variant: InstrumentActionVariant.primary,
                        onPressed: () => _acceptRequest(context, ref, l10n),
                      ),
                      InstrumentActionButton(
                        label: l10n.coachRelationshipsDecline,
                        icon: Icons.close,
                        variant: InstrumentActionVariant.destructive,
                        onPressed: () => _declineRequest(context, ref, l10n),
                      ),
                    ],
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      InstrumentActionButton(
                        label: l10n.coachRelationshipsChatTooltip,
                        icon: Icons.chat_bubble_outline,
                        variant: InstrumentActionVariant.secondary,
                        onPressed: hasChannel
                            ? () {
                                Navigator.of(context).pushNamed(
                                  RouteNames.coachChat,
                                  arguments: CoachChatScreenArgs(
                                    channelId: link.channelId!,
                                    title: athleteName,
                                  ),
                                );
                              }
                            : null,
                      ),
                      InstrumentActionButton(
                        label: l10n.coachRelationshipsAnalyticsTooltip,
                        icon: Icons.insights_outlined,
                        variant: InstrumentActionVariant.secondary,
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            RouteNames.coachAthleteDetail,
                            arguments: link.athleteId,
                          );
                        },
                      ),
                      if (statusLower == 'active' && hasChannel)
                        InstrumentActionButton(
                          label: l10n.coachRelationshipsNudgeTooltip,
                          icon: Icons.notifications_active_outlined,
                          variant: InstrumentActionVariant.primary,
                          onPressed: () =>
                              _sendNudge(context, ref, link, summary),
                        ),
                      if (statusLower == 'active')
                        InstrumentActionButton(
                          label: l10n.coachRelationshipsMenuPauseCoaching,
                          icon: Icons.pause_circle_outline,
                          variant: InstrumentActionVariant.secondary,
                          onPressed: () => _pauseCoaching(context, ref, l10n),
                        ),
                      if (statusLower == 'paused')
                        InstrumentActionButton(
                          label: l10n.coachRelationshipsMenuResumeCoaching,
                          icon: Icons.play_circle_outline,
                          variant: InstrumentActionVariant.primary,
                          onPressed: () => _resumeCoaching(context, ref, l10n),
                        ),
                      if (statusLower != 'ended')
                        InstrumentActionButton(
                          label: l10n.coachRelationshipsEndCoaching,
                          icon: Icons.stop_circle_outlined,
                          variant: InstrumentActionVariant.destructive,
                          onPressed: () => _endCoaching(context, ref, l10n),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptRequest(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final svc = ref.read(sl.crmRelationshipsServiceProvider);
    try {
      await svc.updateStatus(id: link.id, status: 'active');
      if (context.mounted) {
        showAppSnackBar(context, l10n.coachRelationshipsRequestAccepted);
      }
      ref.invalidate(coachRelationshipsProvider);
    } catch (e) {
      if (context.mounted) {
        showAppSnackBar(
          context,
          l10n.coachRelationshipsFailedToAccept(e.toString()),
          isError: true,
        );
      }
    }
  }

  Future<void> _declineRequest(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final controller = TextEditingController();
    final confirmed = await showInstrumentDialog<bool>(
      context: context,
      eyebrow: l10n.relationshipEyebrow,
      title: l10n.coachRelationshipsDeclineRequestTitle,
      content: TextField(
        controller: controller,
        decoration: InstrumentTheme.inputDecoration(
          context,
          labelText: l10n.coachRelationshipsDeclineReasonHint,
        ),
        maxLines: 3,
      ),
      actionsBuilder: (dialogCtx) => [
        InstrumentActionButton(
          label: l10n.cancel,
          variant: InstrumentActionVariant.secondary,
          onPressed: () => Navigator.of(dialogCtx).pop(false),
        ),
        InstrumentActionButton(
          label: l10n.coachRelationshipsDecline,
          variant: InstrumentActionVariant.destructive,
          onPressed: () => Navigator.of(dialogCtx).pop(true),
        ),
      ],
    );
    if (confirmed != true) return;
    final svc = ref.read(sl.crmRelationshipsServiceProvider);
    try {
      final reason = controller.text.trim();
      await svc.updateStatus(
        id: link.id,
        status: 'ended',
        endedReason: reason.isEmpty ? null : reason,
      );
      if (context.mounted) {
        showAppSnackBar(context, l10n.coachRelationshipsRequestDeclined);
      }
      ref.invalidate(coachRelationshipsProvider);
    } catch (e) {
      if (context.mounted) {
        showAppSnackBar(
          context,
          l10n.coachRelationshipsFailedToDecline(e.toString()),
          isError: true,
        );
      }
    }
  }

  Future<void> _pauseCoaching(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final svc = ref.read(sl.crmRelationshipsServiceProvider);
    try {
      await svc.updateStatus(id: link.id, status: 'paused');
      if (context.mounted) {
        showAppSnackBar(context, l10n.coachRelationshipsCoachingPaused);
      }
      ref.invalidate(coachRelationshipsProvider);
    } catch (e) {
      if (context.mounted) {
        showAppSnackBar(
          context,
          l10n.coachRelationshipsFailedToPause(e.toString()),
          isError: true,
        );
      }
    }
  }

  Future<void> _resumeCoaching(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final svc = ref.read(sl.crmRelationshipsServiceProvider);
    try {
      await svc.updateStatus(id: link.id, status: 'active');
      if (context.mounted) {
        showAppSnackBar(context, l10n.coachRelationshipsCoachingResumed);
      }
      ref.invalidate(coachRelationshipsProvider);
    } catch (e) {
      if (context.mounted) {
        showAppSnackBar(
          context,
          l10n.coachRelationshipsFailedToResume(e.toString()),
          isError: true,
        );
      }
    }
  }

  Future<void> _endCoaching(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final controller = TextEditingController();
    final confirmed = await showInstrumentDialog<bool>(
      context: context,
      eyebrow: l10n.relationshipEyebrow,
      title: l10n.coachRelationshipsEndCoaching,
      content: TextField(
        controller: controller,
        decoration: InstrumentTheme.inputDecoration(
          context,
          labelText: l10n.coachRelationshipsDeclineReasonHint,
        ),
        maxLines: 3,
      ),
      actionsBuilder: (dialogCtx) => [
        InstrumentActionButton(
          label: l10n.cancel,
          variant: InstrumentActionVariant.secondary,
          onPressed: () => Navigator.of(dialogCtx).pop(false),
        ),
        InstrumentActionButton(
          label: l10n.coachRelationshipsEndCoaching,
          variant: InstrumentActionVariant.destructive,
          onPressed: () => Navigator.of(dialogCtx).pop(true),
        ),
      ],
    );
    if (confirmed != true) return;
    final svc = ref.read(sl.crmRelationshipsServiceProvider);
    try {
      final reason = controller.text.trim();
      await svc.updateStatus(
        id: link.id,
        status: 'ended',
        endedReason: reason.isEmpty ? null : reason,
      );
      if (context.mounted) {
        showAppSnackBar(context, l10n.coachRelationshipsCoachingEnded);
      }
      ref.invalidate(coachRelationshipsProvider);
    } catch (e) {
      if (context.mounted) {
        showAppSnackBar(
          context,
          l10n.coachRelationshipsFailedToEnd(e.toString()),
          isError: true,
        );
      }
    }
  }
}

Future<void> _sendNudge(
  BuildContext context,
  WidgetRef ref,
  CoachAthleteLink link,
  AthleteTrainingSummaryModel? summary,
) async {
  final l10n = AppLocalizations.of(context);
  final channelId = link.channelId;
  if (channelId == null || channelId.isEmpty) {
    if (context.mounted) {
      showAppSnackBar(
        context,
        l10n.coachRelationshipsChatChannelNotAvailable,
        isError: true,
      );
    }
    return;
  }

  final days = summary?.daysSinceLastWorkout;
  final message = days != null && days > 0
      ? l10n.coachRelationshipsNudgeMessageWithDays(
          link.athleteId,
          days.toString(),
        )
      : l10n.coachRelationshipsNudgeMessageNoDays(link.athleteId);

  try {
    final messaging = ref.read(sl.messagingServiceProvider);
    await messaging.sendTextMessage(channelId: channelId, content: message);
    if (context.mounted) {
      showAppSnackBar(context, l10n.coachRelationshipsNudgeSent);
    }
  } catch (e) {
    if (context.mounted) {
      showAppSnackBar(
        context,
        l10n.coachRelationshipsFailedToSendNudge(e.toString()),
        isError: true,
      );
    }
  }
}

Future<Map<String, dynamic>> _buildCoachRelationshipsChatContext(
  WidgetRef ref,
) async {
  try {
    final links = await ref.read(coachRelationshipsProvider.future);
    Map<String, AthleteTrainingSummaryModel>? analyticsMap;
    try {
      analyticsMap = await ref.read(coachRelationshipsAnalyticsProvider.future);
    } catch (_) {}

    final filter = ref.read(coachRelationshipsStatusFilterProvider);
    final nowIso = DateTime.now().toUtc().toIso8601String();

    final byStatus = <String, int>{};
    for (final link in links) {
      final key = link.status.toLowerCase();
      byStatus[key] = (byStatus[key] ?? 0) + 1;
    }

    final highlighted = links
        .where((l) => filter == null || l.status.toLowerCase() == filter)
        .take(3)
        .map((link) {
          final summary = analyticsMap?[link.athleteId];
          return {
            'relationship_id': link.id,
            'athlete_id': link.athleteId,
            'status': link.status,
            'channel_id': link.channelId,
            'note': link.note,
            'summary': summary == null
                ? null
                : {
                    'sessions_12w': summary.sessionsCount,
                    'sessions_per_week': summary.sessionsPerWeek,
                    'plan_adherence': summary.planAdherence,
                    'days_since_last_workout': summary.daysSinceLastWorkout,
                    'active_plan_name': summary.activePlanName,
                  },
          };
        })
        .toList();

    return {
      'v': 1,
      'app': 'WorkoutApp',
      'screen': 'coach_relationships',
      'role': 'coach',
      'timestamp': nowIso,
      'entities': {
        'relationships_summary': {'total': links.length, 'by_status': byStatus},
        'highlighted_relationships': highlighted,
      },
      'selection': {'status_filter': filter},
    };
  } catch (e) {
    return {
      'v': 1,
      'app': 'WorkoutApp',
      'screen': 'coach_relationships',
      'role': 'coach',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'error': e.toString(),
    };
  }
}
