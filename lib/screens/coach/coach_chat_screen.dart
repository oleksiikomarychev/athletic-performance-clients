import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/providers/ambient_environment_provider.dart';
import 'package:workout_app/services/service_locator.dart' as sl;
import 'package:workout_app/src/widgets/snack_utils.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';

class CoachChatScreenArgs {
  final String channelId;
  final String title;

  CoachChatScreenArgs({required this.channelId, required this.title});
}

final _channelMessagesProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, channelId) async {
      final messaging = ref.watch(sl.messagingServiceProvider);
      return await messaging.getChannelMessages(channelId: channelId);
    });

class CoachChatScreen extends ConsumerStatefulWidget {
  final CoachChatScreenArgs args;

  const CoachChatScreen({super.key, required this.args});

  @override
  ConsumerState<CoachChatScreen> createState() => _CoachChatScreenState();
}

class _CoachChatScreenState extends ConsumerState<CoachChatScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _buildChatContext() async {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    return <String, dynamic>{
      'v': 1,
      'app': 'WorkoutApp',
      'screen': 'coach_chat',
      'role': 'coach',
      'timestamp': nowIso,
      'entities': <String, dynamic>{
        'channel': {
          'id': widget.args.channelId,
          'title': widget.args.title,
          'type': 'coach_athlete',
        },
      },
    };
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) {
      return;
    }
    setState(() {
      _sending = true;
    });
    try {
      final messaging = ref.read(sl.messagingServiceProvider);
      await messaging.sendTextMessage(
        channelId: widget.args.channelId,
        content: text,
      );
      _controller.clear();
      ref.invalidate(_channelMessagesProvider(widget.args.channelId));
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, 'Failed to send: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncMessages = ref.watch(
      _channelMessagesProvider(widget.args.channelId),
    );
    final env = ref.watch(activeTrainingEnvironmentProvider(null));
    final instrument = InstrumentTheme.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dims = UiDimensions.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hairline =
        (isDark ? instrument.hairlineBorder : scheme.outlineVariant)
            .withValues(alpha: 0.70);
    final df = DateFormat('dd.MM HH:mm');

    return AssistantChatHost(
      initialMessage:
          'Открываю ассистента из CoachChatScreen. Используй контекст v1, чтобы понимать текущий канал коуч–атлет.',
      contextBuilder: _buildChatContext,
      builder: (context, openChat) {
        return AmbientScaffoldShell(
          environment: env,
          extendBody: false,
          appBar: PrimaryAppBar(
            title: widget.args.title,
            onTitleTap: openChat,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: () => ref.refresh(
                  _channelMessagesProvider(widget.args.channelId),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: asyncMessages.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
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
                  data: (messages) {
                    if (messages.isEmpty) {
                      return Center(
                        child: Text(
                          'No messages yet.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      reverse: true,
                      padding: EdgeInsets.fromLTRB(
                        dims.pagePadding,
                        AmbientScaffoldShell.topContentInset(context),
                        dims.pagePadding,
                        16,
                      ),
                      itemCount: messages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final content = msg['content']?.toString() ?? '';
                        final sender = msg['sender_id']?.toString() ?? 'user';
                        final createdAtRaw = msg['created_at']?.toString();
                        final createdAt = createdAtRaw != null
                            ? DateTime.tryParse(createdAtRaw)
                            : null;
                        final metaLine =
                            '${sender.toUpperCase()} · ${createdAt != null ? df.format(createdAt.toLocal()) : 'UNKNOWN'}';
                        return Container(
                          decoration: InstrumentTheme.instrumentCardDecoration(
                            context,
                            radius: 18,
                          ),
                          padding: EdgeInsets.all(dims.cardPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                metaLine,
                                style: InstrumentTheme.tabular(
                                  InstrumentTheme.microLabel(
                                    context,
                                    color: instrument.workingAura,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                content,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurface,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? InstrumentPalette.obsidianDock.withValues(alpha: 0.94)
                      : scheme.surface.withValues(alpha: 0.96),
                  border: Border(top: BorderSide(color: hairline, width: 1.0)),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      dims.pagePadding,
                      10,
                      dims.pagePadding,
                      10,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            minLines: 1,
                            maxLines: 4,
                            decoration: InstrumentTheme.inputDecoration(
                              context,
                              hintText: 'Type a message...',
                              radius: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Semantics(
                          button: true,
                          label: 'Send message',
                          child: InkWell(
                            onTap: _sending ? null : _sendMessage,
                            borderRadius: BorderRadius.circular(999),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                minWidth: 48,
                                minHeight: 48,
                              ),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: instrument.workingAura.withValues(
                                    alpha: 0.18,
                                  ),
                                  border: Border.all(
                                    color: instrument.workingAura.withValues(
                                      alpha: 0.70,
                                    ),
                                  ),
                                ),
                                child: Center(
                                  child: _sending
                                      ? SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  instrument.workingAura,
                                                ),
                                          ),
                                        )
                                      : Icon(
                                          Icons.send_rounded,
                                          size: 20,
                                          color: instrument.workingAura,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
