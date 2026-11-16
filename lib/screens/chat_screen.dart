import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';

import '../models/chat_message.dart';
import '../providers/chat_provider.dart';
import '../services/chat_service.dart';
import '../widgets/chat_tools/tool_widget_factory.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, this.embedded = false, this.transparentBackground = false});



  final bool embedded;



  final bool transparentBackground;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatCommand {
  const _ChatCommand({
    required this.trigger,
    required this.keyword,
    required this.display,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String trigger;
  final String keyword;
  final String display;
  final String title;
  final String description;
  final IconData icon;
}

class _CommandTriggerInfo {
  const _CommandTriggerInfo({
    required this.trigger,
    required this.startIndex,
    required this.endIndex,
    required this.query,
  });

  final String trigger;
  final int startIndex;
  final int endIndex;
  final String query;
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  _ChatScreenState();

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();

  _CommandTriggerInfo? _activeTrigger;

  List<_ChatCommand> _availableCommands(AppLocalizations l10n) => [
    _ChatCommand(
      trigger: '@',
      keyword: 'fsm_plan_generator',
      display: '@fsm_plan_generator',
      title: l10n.chatPlanGenTitle,
      description: l10n.chatPlanGenDesc,
      icon: Icons.auto_awesome_motion_rounded,
    ),
    _ChatCommand(
      trigger: '/',
      keyword: 'mass_edit',
      display: '/mass_edit',
      title: 'Mass edit',
      description: l10n.chatMassEditDesc,
      icon: Icons.edit_note_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_handleInputChanged);
  }

  @override
  void dispose() {
    _inputController.removeListener(_handleInputChanged);
    _inputController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider);
    final l10n = AppLocalizations.of(context);
    final connectionLabel = _mapConnectionLabel(chatState.connectionState, l10n);
    final canSend = chatState.connectionState == ChatConnectionState.connected ||
        chatState.connectionState == ChatConnectionState.reconnecting;


    ref.listen<ChatState>(
      chatControllerProvider,
      (previous, next) {
        if (!mounted) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final previousError = previous?.errorMessage;
          if (next.errorMessage != null && next.errorMessage != previousError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(next.errorMessage!)),
            );
          }
          final previousLength = previous?.messages.length ?? 0;
          if (next.messages.length != previousLength) {
            _scrollToBottom();
          }
        });
      },
    );


    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.embedded && !widget.transparentBackground)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: _ConnectionBanner(
              label: connectionLabel,
              state: chatState.connectionState,
              sessionId: chatState.sessionId,
            ),
          ),
        if (chatState.lastMassEditResult != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: ToolWidgetFactory(payload: chatState.lastMassEditResult!),
          ),
        Expanded(
          child: Container(
            decoration: widget.transparentBackground
                ? null
                : BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
            child: _buildMessageList(chatState.messages),
          ),
        ),
        if (chatState.isTyping)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: UiDimensions.of(context).pagePadding, vertical: 8),
            child: _TypingIndicator(sessionId: chatState.sessionId),
          ),
        Padding(
          padding: EdgeInsets.fromLTRB(UiDimensions.of(context).pagePadding, 8, UiDimensions.of(context).pagePadding, UiDimensions.of(context).cardPadding),
          child: _buildInputArea(canSend),
        ),
      ],
    );

    if (widget.embedded) {
      return SafeArea(
        top: false,
        bottom: false,
        child: content,
      );
    }

    return AssistantChatHost(
      builder: (context, openChat) {
        return Scaffold(
          appBar: PrimaryAppBar(
            title: AppLocalizations.of(context).chatAssistantTitle,
            onTitleTap: openChat,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(72),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: _ConnectionBanner(
                  label: connectionLabel,
                  state: chatState.connectionState,
                  sessionId: chatState.sessionId,
                ),
              ),
            ),
          ),
          body: SafeArea(
            top: false,
            child: content,
          ),
        );
      },
    );
  }

  Widget _buildMessageList(List<ChatMessage> messages) {
  final dimensions = UiDimensions.of(context);
  if (messages.isEmpty) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(dimensions.pagePadding),
        ),
      );
    }

  final bool transparent = widget.transparentBackground;

  return ListView.builder(
    controller: _scrollController,
    padding: EdgeInsets.symmetric(
      horizontal: dimensions.pagePadding,
      vertical: transparent ? dimensions.sectionGap : dimensions.cardPadding,
    ),
    itemCount: messages.length,
    itemBuilder: (context, index) {
      final message = messages[index];
      final isUser = message.role == ChatRole.user;
      return Padding(
        key: ValueKey('${message.id}_$index'),
        padding: EdgeInsets.only(bottom: dimensions.rowGap),
        child: Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isUser
                    ? (transparent
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.92)
                        : Theme.of(context).colorScheme.primary)
                    : (transparent
                        ? Theme.of(context)
                            .colorScheme
                            .surfaceContainerLow
                            .withValues(alpha: 0.96)
                        : Theme.of(context).colorScheme.surfaceContainerLow),
                border: isUser
                    ? null
                    : Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outlineVariant
                            .withValues(alpha: 0.45),
                      ),
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: const Radius.circular(10),
                  bottomRight: const Radius.circular(10),
                  topLeft: Radius.circular(isUser ? 20 : 10),
                  topRight: Radius.circular(isUser ? 10 : 20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment:
                      isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.content,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isUser
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTimestamp(message.timestamp),
                      style: InstrumentTheme.tabular(
                        (Theme.of(context).textTheme.labelSmall ??
                                const TextStyle(fontSize: 11))
                            .copyWith(
                          color: (isUser
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurface)
                              .withValues(alpha: 0.72),
                        ),
                      ),
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

  Widget _buildInputArea(bool canSend) {
    final transparent = widget.transparentBackground;
    final suggestions = _buildCommandSuggestions();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final inputRow = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: transparent
              ? Container(
                  decoration: InstrumentTheme.cardDecoration(
                    context,
                    color: colors.surfaceContainerLow.withValues(alpha: 0.96),
                    radius: 22,
                  ),
                  child: TextField(
                    controller: _inputController,
                    focusNode: _inputFocusNode,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface,
                    ),
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _handleSend(),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).chatInputHint,
                      hintStyle: TextStyle(color: colors.onSurfaceVariant),
                      filled: false,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                )
              : TextField(
                  controller: _inputController,
                  focusNode: _inputFocusNode,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSend(),
                  decoration: InstrumentTheme.inputDecoration(
                    context,
                    hintText: AppLocalizations.of(context).chatInputHint,
                    radius: 16,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
        ),
        SizedBox(width: transparent ? 10 : 8),
        SizedBox(
          width: 48,
          height: 48,
          child: transparent
              ? IconButton.filled(
                  style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    tapTargetSize: MaterialTapTargetSize.padded,
                  ),
                  icon: const Icon(Icons.send_rounded),
                  onPressed: canSend ? _handleSend : null,
                  tooltip: canSend
                      ? AppLocalizations.of(context).chatSendTooltip
                      : AppLocalizations.of(context).chatNoConnectionTooltip,
                )
              : IconButton(
                  style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    tapTargetSize: MaterialTapTargetSize.padded,
                  ),
                  icon: const Icon(Icons.send_rounded),
                  onPressed: canSend ? _handleSend : null,
                  color: colors.primary,
                  tooltip: canSend
                      ? AppLocalizations.of(context).chatSendTooltip
                      : AppLocalizations.of(context).chatNoConnectionTooltip,
                ),
        ),
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (suggestions != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: suggestions,
          ),
        inputRow,
      ],
    );
  }

  void _handleSend() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    ref.read(chatControllerProvider.notifier).sendMessage(text);
    _inputController.clear();
    setState(() {
      _activeTrigger = null;
    });
  }

void _scrollToBottom() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!_scrollController.hasClients || !_scrollController.position.hasContentDimensions) return;


    if (_scrollController.position.maxScrollExtent > 0 &&
        _scrollController.position.maxScrollExtent.isFinite) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  });
}

  String _formatTimestamp(DateTime timestamp) {
    final local = timestamp.toLocal();
    final time = TimeOfDay.fromDateTime(local);
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  String _mapConnectionLabel(ChatConnectionState state, AppLocalizations l10n) {
    switch (state) {
      case ChatConnectionState.connected:
        return l10n.chatStatusConnected;
      case ChatConnectionState.connecting:
        return l10n.chatStatusConnecting;
      case ChatConnectionState.reconnecting:
        return l10n.chatStatusReconnecting;
      case ChatConnectionState.error:
        return l10n.chatStatusError;
      case ChatConnectionState.disconnected:
        return l10n.chatStatusDisconnected;
    }
  }

  void _handleInputChanged() {
    final nextTrigger = _detectCommandTrigger();
    if (mounted) {
      setState(() {
        _activeTrigger = nextTrigger;
      });
    }
  }

  _CommandTriggerInfo? _detectCommandTrigger() {
    final value = _inputController.value;
    final text = value.text;
    if (text.isEmpty) return null;

    final cursorIndex = value.selection.baseOffset;
    if (cursorIndex < 0 || cursorIndex > text.length) {
      return null;
    }

    var start = cursorIndex;
    while (start > 0 && !_isWhitespace(text[start - 1])) {
      start--;
    }

    if (start >= text.length) {
      return null;
    }

    final triggerChar = text[start];
    if (triggerChar != '@' && triggerChar != '/') {
      return null;
    }

    if (start > 0 && !_isWhitespace(text[start - 1])) {
      return null;
    }

    var end = cursorIndex;
    while (end < text.length && !_isWhitespace(text[end])) {
      end++;
    }

    final query = text.substring(start + 1, cursorIndex).toLowerCase();
    return _CommandTriggerInfo(
      trigger: triggerChar,
      startIndex: start,
      endIndex: end,
      query: query,
    );
  }

  Widget? _buildCommandSuggestions() {
    if (_activeTrigger == null || !_inputFocusNode.hasFocus) {
      return null;
    }

    final commands = _filteredCommands;
    if (commands.isEmpty) {
      return null;
    }

    final theme = Theme.of(context);
    final dividerColor = theme.dividerColor.withValues(alpha: 0.2);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 200),
      child: Material(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
        color: theme.colorScheme.surface,
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: commands.length,
          itemBuilder: (context, index) {
            final command = commands[index];
            return ListTile(
              dense: true,
              leading: Icon(command.icon, color: theme.colorScheme.primary),
              title: Text(
                command.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                '${command.display} — ${command.description}',
                style: theme.textTheme.bodySmall,
              ),
              onTap: () => _handleCommandSelected(command),
            );
          },
          separatorBuilder: (_, __) => Divider(height: 1, color: dividerColor),
        ),
      ),
    );
  }

  List<_ChatCommand> get _filteredCommands {
    final trigger = _activeTrigger;
    if (trigger == null) {
      return const [];
    }

    final query = trigger.query.toLowerCase();

    final chatState = ref.watch(chatControllerProvider);
    final contextPayload = chatState.contextPayload;
    final Map<String, dynamic> autocomplete =
        (contextPayload != null && contextPayload['autocomplete'] is Map<String, dynamic>)
            ? contextPayload['autocomplete'] as Map<String, dynamic>
            : const {};
    final List<dynamic> workoutItems =
        autocomplete['workouts'] is List ? autocomplete['workouts'] as List<dynamic> : const [];
    final List<dynamic> exerciseItems =
        autocomplete['exercises'] is List ? autocomplete['exercises'] as List<dynamic> : const [];

    final l10n = AppLocalizations.of(context);
    final List<_ChatCommand> base = _availableCommands(l10n)
        .where((command) => command.trigger == trigger.trigger)
        .toList();

    final List<_ChatCommand> dsl = <_ChatCommand>[];
    if (trigger.trigger == '/') {
      for (final item in workoutItems) {
        if (item is! Map<String, dynamic>) continue;
        final alias = item['alias']?.toString() ?? '';
        if (alias.isEmpty) continue;
        final name = item['name']?.toString() ?? '';
        final keyword = alias.substring(1);
        final aliasLower = alias.toLowerCase();
        final keywordLower = keyword.toLowerCase();
        if (query.isNotEmpty &&
            !aliasLower.contains(query) &&
            !keywordLower.contains(query) &&
            !name.toLowerCase().contains(query)) {
          continue;
        }
        final title = name.isNotEmpty ? '$alias — $name' : alias;
        dsl.add(
          _ChatCommand(
            trigger: '/',
            keyword: keyword,
            display: alias,
            title: title,
            description: AppLocalizations.of(context).chatWorkoutLinkDesc,
            icon: Icons.fitness_center_rounded,
          ),
        );
      }

      for (final item in exerciseItems) {
        if (item is! Map<String, dynamic>) continue;
        final alias = item['alias']?.toString() ?? '';
        if (alias.isEmpty) continue;
        final name = item['name']?.toString() ?? '';
        final keyword = alias.substring(1);
        final aliasLower = alias.toLowerCase();
        final keywordLower = keyword.toLowerCase();
        if (query.isNotEmpty &&
            !aliasLower.contains(query) &&
            !keywordLower.contains(query) &&
            !name.toLowerCase().contains(query)) {
          continue;
        }
        final title = name.isNotEmpty ? '$alias — $name' : alias;
        dsl.add(
          _ChatCommand(
            trigger: '/',
            keyword: keyword,
            display: alias,
            title: title,
            description: AppLocalizations.of(context).chatExerciseLinkDesc,
            icon: Icons.fitness_center_outlined,
          ),
        );
      }
    }

    var all = <_ChatCommand>[...base, ...dsl];
    if (query.isEmpty) {
      return all;
    }

    all = all
        .where(
          (command) => command.keyword.toLowerCase().contains(query) ||
              command.display.toLowerCase().contains(query) ||
              command.title.toLowerCase().contains(query),
        )
        .toList();

    return all;
  }

  void _handleCommandSelected(_ChatCommand command) {
    final trigger = _activeTrigger;
    if (trigger == null) {
      return;
    }

    final text = _inputController.text;
    final safeEnd = trigger.endIndex.clamp(0, text.length);
    final safeStart = trigger.startIndex.clamp(0, safeEnd);
    final insertion = '${command.display} ';

    final newText = text.replaceRange(safeStart, safeEnd, insertion);
    final cursorPosition = safeStart + command.display.length + 1;

    _inputController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );

    setState(() {
      _activeTrigger = null;
    });
  }

  bool _isWhitespace(String character) {
    return character.trim().isEmpty;
  }
}

class _ConnectionBanner extends StatelessWidget {
  const _ConnectionBanner({
    required this.label,
    required this.state,
    required this.sessionId,
  });

  final String label;
  final ChatConnectionState state;
  final String? sessionId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color background;
    Color foreground;
    switch (state) {
      case ChatConnectionState.connected:
        background = colorScheme.primary.withValues(alpha: 0.15);
        foreground = colorScheme.primary;
        break;
      case ChatConnectionState.connecting:
      case ChatConnectionState.reconnecting:
        background = colorScheme.secondary.withValues(alpha: 0.15);
        foreground = colorScheme.secondary;
        break;
      case ChatConnectionState.error:
        background = theme.colorScheme.errorContainer;
        foreground = theme.colorScheme.onErrorContainer;
        break;
      case ChatConnectionState.disconnected:
        background = colorScheme.surfaceContainerHighest;
        foreground = colorScheme.onSurfaceVariant;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            _iconForState(state),
            color: foreground,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(color: foreground),
                ),
                if (sessionId != null && sessionId!.isNotEmpty)
                  Text(
                    AppLocalizations.of(context).chatSessionLabel(sessionId!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: foreground.withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ),
          ),
          if (state == ChatConnectionState.error ||
              state == ChatConnectionState.disconnected)
            Consumer(
              builder: (context, ref, _) => TextButton.icon(
                onPressed: () {
                  ref.read(chatControllerProvider.notifier).reconnect();
                },
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context).retry),
                style: TextButton.styleFrom(foregroundColor: foreground),
              ),
            )
          else if (state == ChatConnectionState.reconnecting ||
              state == ChatConnectionState.connecting)
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(foreground),
              ),
            ),
        ],
      ),
    );
  }

  static IconData _iconForState(ChatConnectionState state) {
    switch (state) {
      case ChatConnectionState.connected:
        return Icons.check_circle_rounded;
      case ChatConnectionState.connecting:
      case ChatConnectionState.reconnecting:
        return Icons.sync_rounded;
      case ChatConnectionState.error:
        return Icons.error_outline_rounded;
      case ChatConnectionState.disconnected:
        return Icons.offline_bolt_outlined;
    }
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator({required this.sessionId});

  final String? sessionId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        const SizedBox(width: 4),
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            AppLocalizations.of(context).chatTypingStatus(
              sessionId?.isNotEmpty == true
                  ? AppLocalizations.of(context).chatTypingSessionSuffix(
                      sessionId!,
                    )
                  : '',
            ),
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
