import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workout_app/config/constants/route_names.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/models/crm_coach_athlete_link.dart';
import 'package:workout_app/providers/ambient_environment_provider.dart';
import 'package:workout_app/screens/coach/coach_chat_screen.dart';
import 'package:workout_app/services/base_api_service.dart';
import 'package:workout_app/services/service_locator.dart' as sl;
import 'package:workout_app/src/widgets/snack_utils.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/instrument_modal.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';

final myCoachesProvider = FutureProvider<List<CoachAthleteLink>>((ref) async {
  final svc = ref.watch(sl.crmRelationshipsServiceProvider);
  final links = await svc.getMyCoaches();
  return links;
});

final coachSubscriptionStatusProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, linkId) async {
      final billing = ref.watch(sl.crmBillingServiceProvider);
      try {
        final status = await billing.getSubscriptionStatus(linkId);
        return status;
      } catch (_) {
        return const <String, dynamic>{};
      }
    });

final coachDisplayNameProvider =
    FutureProvider.family<String, String>((ref, coachId) async {
      final profileService = ref.watch(sl.profileServiceProvider);
      try {
        final profile = await profileService.fetchProfileById(coachId);
        final displayName = profile.displayName;
        if (displayName != null && displayName.trim().isNotEmpty) {
          return displayName;
        }
      } catch (_) {}
      return coachId;
    });

class MyCoachesScreen extends ConsumerWidget {
  const MyCoachesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLinks = ref.watch(myCoachesProvider);
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

    return AssistantChatHost(
      builder: (context, openChat) {
        final l10n = AppLocalizations.of(context);
        return AmbientScaffoldShell(
          environment: env,
          appBar: PrimaryAppBar(
            title: l10n.myCoachesTitle,
            onTitleTap: openChat,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: l10n.refresh,
                onPressed: () => ref.refresh(myCoachesProvider),
              ),
            ],
          ),
          body: asyncLinks.when(
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
            data: (links) {
              if (links.isEmpty) {
                return Center(
                  child: Text(
                    'No coaches yet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  final refreshedLinks = await ref.refresh(
                    myCoachesProvider.future,
                  );
                  for (final link in refreshedLinks) {
                    ref.invalidate(coachSubscriptionStatusProvider(link.id));
                  }
                },
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    dims.pagePadding,
                    AmbientScaffoldShell.topContentInset(context),
                    dims.pagePadding,
                    AmbientScaffoldShell.bottomContentInset(context),
                  ),
                  itemCount: links.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final link = links[index];
                    final hasChannel = (link.channelId ?? '').isNotEmpty;
                    final statusLower = link.status.toLowerCase();
                    final statusUpper = link.status.toUpperCase();
                    final statusAccent = switch (statusLower) {
                      'active' => instrument.successColor,
                      'pending' => instrument.moderateEffortColor,
                      'paused' => instrument.workingAura,
                      _ => scheme.onSurfaceVariant,
                    };
                    final displayNameAsync = ref.watch(
                      coachDisplayNameProvider(link.coachId),
                    );
                    final coachTitle = displayNameAsync.when(
                      data: (value) => value,
                      loading: () => link.coachId,
                      error: (_, __) => link.coachId,
                    );
                    final subscriptionAsync = ref.watch(
                      coachSubscriptionStatusProvider(link.id),
                    );

                    return Container(
                      decoration: InstrumentTheme.instrumentCardDecoration(
                        context,
                        accentColor: statusLower == 'active'
                            ? instrument.successColor
                            : null,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'COACH LINK · #${index + 1}',
                                            style: InstrumentTheme.tabular(
                                              InstrumentTheme.microLabel(
                                                context,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            coachTitle,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
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
                                const SizedBox(height: 8),
                                Text(
                                  'Channel: ${link.channelId ?? 'not created'}',
                                  style: InstrumentTheme.tabular(
                                    (theme.textTheme.bodySmall ??
                                            const TextStyle())
                                        .copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                  ),
                                ),
                                if ((link.note ?? '').isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Note: ${link.note}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 6),
                                subscriptionAsync.when(
                                  loading: () => Text(
                                    'Subscription: loading...',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                  error: (error, _) => Text(
                                    'Subscription error: $error',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: instrument.peakEffortColor,
                                    ),
                                  ),
                                  data: (sub) {
                                    final active = sub['active'] == true;
                                    final validUntil = sub['valid_until']
                                        ?.toString();
                                    return Text(
                                      active
                                          ? 'Subscription: active until ${validUntil ?? 'unknown'}'
                                          : 'Subscription: inactive',
                                      style: InstrumentTheme.tabular(
                                        (theme.textTheme.bodySmall ??
                                                const TextStyle())
                                            .copyWith(
                                              color: active
                                                  ? instrument.successColor
                                                  : scheme.onSurfaceVariant,
                                              fontWeight: active
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          Container(height: 1, color: hairline),
                          Padding(
                            padding: EdgeInsets.all(dims.cardPadding),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                InstrumentActionButton(
                                  label: l10n.analyticsLabel,
                                  icon: Icons.insights_outlined,
                                  variant: InstrumentActionVariant.secondary,
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(
                                      RouteNames.coachAthleteDetail,
                                      arguments: link.athleteId,
                                    );
                                  },
                                ),
                                InstrumentActionButton(
                                  label: l10n.chatLabel,
                                  icon: Icons.chat_bubble_outline,
                                  variant: InstrumentActionVariant.secondary,
                                  onPressed: hasChannel
                                      ? () {
                                          Navigator.of(context).pushNamed(
                                            RouteNames.coachChat,
                                            arguments: CoachChatScreenArgs(
                                              channelId: link.channelId!,
                                              title: coachTitle,
                                            ),
                                          );
                                        }
                                      : null,
                                ),
                                InstrumentActionButton(
                                  label: l10n.subscribeLabel,
                                  icon: Icons.credit_card_outlined,
                                  variant: InstrumentActionVariant.primary,
                                  onPressed: statusLower == 'active'
                                      ? () async {
                                          await _startCheckoutForLink(
                                            context,
                                            ref,
                                            link.id,
                                          );
                                          ref.invalidate(
                                            coachSubscriptionStatusProvider(
                                              link.id,
                                            ),
                                          );
                                        }
                                      : null,
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
          ),
        );
      },
    );
  }
}

Future<void> _startCheckoutForLink(
  BuildContext context,
  WidgetRef ref,
  int linkId,
) async {
  try {
    final billing = ref.read(sl.crmBillingServiceProvider);
    final result = await billing.createCheckoutSession(linkId);
    final urlStr = (result['checkout_url'] ?? result['url'])?.toString();
    if (urlStr == null || urlStr.isEmpty) {
      if (context.mounted) {
        showAppSnackBar(
          context,
          'Failed to create checkout session',
          isError: true,
        );
      }
      return;
    }
    final uri = Uri.tryParse(urlStr);
    if (uri == null) {
      if (context.mounted) {
        showAppSnackBar(
          context,
          AppLocalizations.of(context).invalidCheckoutUrl,
          isError: true,
        );
      }
      return;
    }
    final canLaunch = await canLaunchUrl(uri);
    if (!canLaunch) {
      if (context.mounted) {
        showAppSnackBar(
          context,
          AppLocalizations.of(context).cannotOpenCheckoutUrl,
          isError: true,
        );
      }
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    if (context.mounted) {
      final message = e is ApiException
          ? e.message
          : 'Failed to start checkout: $e';
      showAppSnackBar(context, message, isError: true);
    }
  }
}
