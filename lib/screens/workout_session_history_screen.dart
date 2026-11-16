import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/providers/providers.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/empty_state.dart';
import 'package:workout_app/widgets/error_message.dart';
import 'package:workout_app/widgets/loading_indicator.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';
import 'package:workout_app/widgets/session_instrument_card.dart';

class WorkoutSessionHistoryScreen extends ConsumerStatefulWidget {
  final int workoutId;
  const WorkoutSessionHistoryScreen({super.key, required this.workoutId});

  @override
  ConsumerState<WorkoutSessionHistoryScreen> createState() =>
      _WorkoutSessionHistoryScreenState();
}

class _WorkoutSessionHistoryScreenState
    extends ConsumerState<WorkoutSessionHistoryScreen> {
  bool _hasValue = false;

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(
      sessionsHistorySWRProvider(widget.workoutId),
    );
    final canShowLoader = !_hasValue && sessionsAsync.isLoading;

    return AssistantChatHost(
      contextBuilder: () async => {
        'screen': 'workout_session_history',
        'entities': {'workout_id': widget.workoutId},
      },
      builder: (context, openChat) {
        final l10n = AppLocalizations.of(context);
        final topInset = AmbientScaffoldShell.topContentInset(context);
        final bottomInset = AmbientScaffoldShell.bottomContentInset(context);

        return AmbientScaffoldShell(
          appBar: PrimaryAppBar(
            title: l10n.sessionHistoryTitle,
            onTitleTap: openChat,
            showBack: true,
            actions: [
              IconButton(
                tooltip: l10n.refresh,
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () {
                  ref.invalidate(sessionsHistorySWRProvider(widget.workoutId));
                },
              ),
            ],
          ),
          body: sessionsAsync.when(
            loading: () => canShowLoader
                ? Padding(
                    padding: EdgeInsets.only(top: topInset, bottom: bottomInset),
                    child: const LoadingIndicator(),
                  )
                : const SizedBox.shrink(),
            error: (e, _) => Padding(
              padding: EdgeInsets.only(top: topInset, bottom: bottomInset),
              child: ErrorMessage(
                message: AppLocalizations.of(context).loadErrorWithDetails(
                  e.toString(),
                ),
                onRetry: () => ref.invalidate(
                  sessionsHistorySWRProvider(widget.workoutId),
                ),
              ),
            ),
            data: (sessions) {
              if (!_hasValue) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _hasValue = true);
                });
              }
              if (sessions.isEmpty) {
                final l10n = AppLocalizations.of(context);
                return ListView(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    topInset + 24,
                    16,
                    bottomInset + 24,
                  ),
                  children: [
                    EmptyState(
                      icon: Icons.history_rounded,
                      title: l10n.noDisplayDataTitle,
                      description: l10n.workoutHistoryEmptyDesc,
                    ),
                  ],
                );
              }
              return ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  16,
                  topInset + 8,
                  16,
                  bottomInset + 24,
                ),
                itemCount: sessions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => SessionInstrumentCard(session: sessions[i]),
              );
            },
          ),
        );
      },
    );
  }
}
