import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/responsive.dart';
import 'package:workout_app/providers/chat_provider.dart';
import 'package:workout_app/screens/chat_screen.dart';

class AssistantChatOverlay extends StatefulWidget {
  const AssistantChatOverlay({
    super.key,
    required this.visible,
    required this.onClose,
    this.initialMessage,
    this.contextBuilder,
  });

  final bool visible;
  final VoidCallback onClose;
  final String? initialMessage;
  final Future<Map<String, dynamic>?> Function()? contextBuilder;

  @override
  State<AssistantChatOverlay> createState() => _AssistantChatOverlayState();
}

class _AssistantChatOverlayState extends State<AssistantChatOverlay> {
  bool _seeded = false;

  @override
  void didUpdateWidget(covariant AssistantChatOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.visible && widget.visible) {
      _trySeedChat();
    } else if (!widget.visible) {
      _seeded = false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.visible && !_seeded) {
      _trySeedChat();
    }
  }

  Future<void> _trySeedChat() async {
    if (_seeded || !mounted) return;
    _seeded = true;

    final contextPayload = widget.contextBuilder != null
        ? await widget.contextBuilder!()
        : null;

    await Future.microtask(() {
      if (!mounted) return;
      final container = ProviderScope.containerOf(context, listen: false);
      final controller = container.read(chatControllerProvider.notifier);

      if (contextPayload != null) {
        controller.sendContext(contextPayload);
      }

      final message = widget.initialMessage?.trim();
      if (message != null && message.isNotEmpty) {
        controller.sendMessage(message);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) {
      return const SizedBox.shrink();
    }

    final isWide = Responsive.isWide(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final scrimColor = Colors.black.withValues(alpha: isWide ? 0.28 : 0.34);

    final scrim = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: widget.onClose,
      child: disableAnimations
          ? Container(color: scrimColor)
          : BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: isWide ? 6 : 16,
                sigmaY: isWide ? 6 : 16,
              ),
              child: Container(color: scrimColor),
            ),
    );

    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(child: scrim),
          SafeArea(
            child: Align(
              alignment: isWide ? Alignment.centerRight : Alignment.center,
              child: ConstrainedBox(
                constraints: isWide
                    ? const BoxConstraints(maxWidth: 460)
                    : const BoxConstraints(),
                child: Padding(
                  padding: isWide
                      ? const EdgeInsets.fromLTRB(12, 12, 16, 12)
                      : const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: Container(
                    decoration: InstrumentTheme.instrumentCardDecoration(
                      context,
                      accentColor: instrument.workingAura,
                      radius: 24,
                      fillColor: isDark
                          ? InstrumentPalette.obsidianCardLow.withValues(
                              alpha: 0.94,
                            )
                          : scheme.surface.withValues(alpha: 0.95),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: const Material(
                      type: MaterialType.transparency,
                      child: ChatScreen(
                        embedded: true,
                        transparentBackground: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
