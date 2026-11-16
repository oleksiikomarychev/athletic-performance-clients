import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_app/config/constants/route_names.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/responsive.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/models/crm_analytics.dart';
import 'package:workout_app/providers/ambient_environment_provider.dart';
import 'package:workout_app/providers/interface_maker_provider.dart';
import 'package:workout_app/services/service_locator.dart' as sl;
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/instrument_metric_matrix.dart';
import 'package:workout_app/widgets/instrument_modal.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';
import 'package:workout_app/widgets/responsive_container.dart';

final coachSummaryAnalyticsProvider =
    FutureProvider<CoachSummaryAnalyticsModel>((ref) async {
      final svc = ref.watch(sl.crmAnalyticsServiceProvider);
      return svc.getMySummaryAnalytics();
    });

class CoachDashboardScreen extends ConsumerWidget {
  const CoachDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSummary = ref.watch(coachSummaryAnalyticsProvider);
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

    Future<Map<String, dynamic>> buildChatContext() async {
      final summary = asyncSummary.valueOrNull;
      return <String, dynamic>{
        'v': 1,
        'app': 'WorkoutApp',
        'screen': 'coach_dashboard',
        'role': 'coach',
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'entities': <String, dynamic>{
          if (summary != null)
            'summary': <String, dynamic>{
              'active_links': summary.activeLinks,
              'avg_sessions_per_week': summary.avgSessionsPerWeek,
              'inactive_athletes_count': summary.inactiveAthletesCount,
            },
        },
      };
    }

    return AssistantChatHost(
      initialMessage:
          'Opening assistant from CRM CoachDashboardScreen. Use v1 context for an overview of active athletes and engagement.',
      contextBuilder: buildChatContext,
      builder: (context, openChat) {
        final l10n = AppLocalizations.of(context);
        return AmbientScaffoldShell(
          environment: env,
          appBar: PrimaryAppBar(
            title: l10n.crmTitle,
            onTitleTap: openChat,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: l10n.refresh,
                onPressed: () => ref.invalidate(coachSummaryAnalyticsProvider),
              ),
            ],
          ),
          body: asyncSummary.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Padding(
                padding: EdgeInsets.all(dims.pagePadding),
                child: Text(
                  'Error: $error',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            data: (summary) {
              final engagedCount =
                  (summary.activeLinks - summary.inactiveAthletesCount)
                      .clamp(0, summary.activeLinks);
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(coachSummaryAnalyticsProvider);
                  await ref.read(coachSummaryAnalyticsProvider.future);
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    dims.pagePadding,
                    AmbientScaffoldShell.topContentInset(context),
                    dims.pagePadding,
                    AmbientScaffoldShell.bottomContentInset(context),
                  ),
                  children: [
                    ResponsiveContainer(
                      maxWidth: Breakpoints.maxContentWidthMedium,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            decoration: InstrumentTheme.instrumentCardDecoration(
                              context,
                              accentColor: instrument.workingAura,
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
                                    14,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'COACH COMMAND · TELEMETRY',
                                              style: InstrumentTheme.microLabel(
                                                context,
                                                color: instrument.workingAura,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Portfolio Overview',
                                              style: theme.textTheme.titleLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        summary.inactiveAthletesCount > 0
                                            ? 'ATTENTION'
                                            : 'NOMINAL',
                                        style: InstrumentTheme.microLabel(
                                          context,
                                          color: summary.inactiveAthletesCount > 0
                                              ? instrument.moderateEffortColor
                                              : instrument.successColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(height: 1, color: hairline),
                                Padding(
                                  padding: EdgeInsets.all(dims.cardPadding),
                                  child: InstrumentMetricMatrix(
                                    cells: [
                                      InstrumentMetricCellData(
                                        slot: MetricSlot.setsCount,
                                        label: l10n.activeUpperLabel,
                                        value: summary.activeLinks.toString(),
                                        valueColor: instrument.workingAura,
                                      ),
                                      InstrumentMetricCellData(
                                        slot: MetricSlot.frequencyPerWeek,
                                        label: l10n.sessPerWeekUpperLabel,
                                        value: summary.avgSessionsPerWeek
                                            .toStringAsFixed(1),
                                      ),
                                      InstrumentMetricCellData(
                                        slot: MetricSlot.kpsh,
                                        label: l10n.engagedUpperLabel,
                                        value: engagedCount.toString(),
                                        valueColor: instrument.successColor,
                                      ),
                                      InstrumentMetricCellData(
                                        slot: MetricSlot.density,
                                        label: l10n.inactiveUpperLabel,
                                        value: summary.inactiveAthletesCount
                                            .toString(),
                                        valueColor:
                                            summary.inactiveAthletesCount > 0
                                                ? instrument.moderateEffortColor
                                                : scheme.onSurfaceVariant,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            decoration: InstrumentTheme.instrumentCardDecoration(
                              context,
                              radius: 22,
                            ),
                            padding: EdgeInsets.all(dims.cardPadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  l10n.workflowsChannelsEyebrow,
                                  style: InstrumentTheme.microLabel(context),
                                ),
                                const SizedBox(height: 12),
                                InstrumentActionButton(
                                  label: l10n.viewAthletesListLabel,
                                  icon: Icons.groups_outlined,
                                  variant: InstrumentActionVariant.primary,
                                  expanded: true,
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(
                                      RouteNames.coachAthletes,
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                                InstrumentActionButton(
                                  label: l10n.relationshipsAndChatLabel,
                                  icon: Icons.chat_bubble_outline,
                                  variant: InstrumentActionVariant.secondary,
                                  expanded: true,
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(
                                      RouteNames.coachRelationships,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
