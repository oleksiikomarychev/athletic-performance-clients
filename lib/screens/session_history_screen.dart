import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/providers/providers.dart';
import 'package:workout_app/screens/session_log_screen.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/empty_state.dart';
import 'package:workout_app/widgets/error_message.dart';
import 'package:workout_app/widgets/loading_indicator.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';
import 'package:workout_app/widgets/session_instrument_card.dart';

class SessionHistoryScreen extends ConsumerStatefulWidget {
  const SessionHistoryScreen({super.key});

  @override
  ConsumerState<SessionHistoryScreen> createState() =>
      _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends ConsumerState<SessionHistoryScreen> {
  final TextEditingController _workoutIdController = TextEditingController();
  int? _filterWorkoutId;

  @override
  void dispose() {
    _workoutIdController.dispose();
    super.dispose();
  }

  Future<void> _handleLoadTapped() async {
    final raw = _workoutIdController.text.trim();
    final workoutId = raw.isEmpty ? null : int.tryParse(raw);
    setState(() {
      _filterWorkoutId = workoutId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dimensions = UiDimensions.of(context);
    final sessionsAsync = ref.watch(
      completedSessionsProviderFamily(_filterWorkoutId),
    );

    return AssistantChatHost(
      contextBuilder: () async => {
        'screen': 'session_history',
        'entities': {'filter_workout_id': _filterWorkoutId},
      },
      builder: (context, openChat) {
        return Scaffold(
          appBar: PrimaryAppBar(
            title: 'Session History',
            onTitleTap: openChat,
            showBack: true,
          ),
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(dimensions.pagePadding),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _workoutIdController,
                        keyboardType: TextInputType.number,
                        style: InstrumentTheme.tabular(
                          Theme.of(context).textTheme.bodyMedium ??
                              const TextStyle(),
                        ),
                        decoration: InstrumentTheme.inputDecoration(
                          context,
                          labelText: 'Workout ID',
                          prefixIcon: const Icon(Icons.tag),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onSubmitted: (_) => _handleLoadTapped(),
                      ),
                    ),
                    SizedBox(width: dimensions.rowGap),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton.filledTonal(
                        tooltip: 'Load sessions',
                        style: IconButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          tapTargetSize: MaterialTapTargetSize.padded,
                        ),
                        icon: const Icon(Icons.search),
                        onPressed: _handleLoadTapped,
                      ),
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton(
                        tooltip: 'Clear filter',
                        style: IconButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          tapTargetSize: MaterialTapTargetSize.padded,
                        ),
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _workoutIdController.clear();
                          setState(() => _filterWorkoutId = null);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: sessionsAsync.when(
                  loading: () => const LoadingIndicator(),
                  error: (err, _) => ErrorMessage(
                    message: 'Error loading history: $err',
                    onRetry: () => ref.invalidate(
                      completedSessionsProviderFamily(_filterWorkoutId),
                    ),
                  ),
                  data: (sessions) {
                    if (sessions.isEmpty) {
                      return const EmptyState(
                        icon: Icons.history,
                        title: 'No sessions found',
                        description: 'Try changing your filter',
                      );
                    }
                    return ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                        dimensions.pagePadding,
                        0,
                        dimensions.pagePadding,
                        dimensions.pagePadding,
                      ),
                      itemCount: sessions.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(height: dimensions.rowGap),
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        return SessionInstrumentCard(
                          session: session,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    SessionLogScreen(session: session),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
