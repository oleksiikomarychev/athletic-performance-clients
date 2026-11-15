import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/responsive.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';

/// Detached translucent glass header with circular action orbs and a compact
/// center AI/title pill floating directly over the ambient canvas.
class FloatingHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onTitleTap;
  final VoidCallback? onProfileTap;
  final Widget? leading;
  final List<Widget>? actions;

  const FloatingHeaderBar({
    super.key,
    required this.title,
    this.onTitleTap,
    this.onProfileTap,
    this.leading,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final dimensions = UiDimensions.of(context);
    final instrument = InstrumentTheme.of(context);
    final VoidCallback? effectiveOnTitleTap =
        onTitleTap ?? AssistantChatHost.of(context)?.openChat;

    final theme = Theme.of(context);
    final textStyle =
        theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: Colors.white,
        ) ??
        const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        );

    final profileButton = onProfileTap == null
        ? null
        : IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            color: Colors.white,
            splashRadius: 22,
            onPressed: onProfileTap,
          );

    final effectiveActions = <Widget>[
      if (actions != null) ...actions!,
      if (profileButton != null) profileButton,
    ];

    final Widget titlePill = FloatingTitleCapsule(
      onTap: effectiveOnTitleTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (effectiveOnTitleTap != null) ...[
            Icon(
              Icons.auto_awesome_outlined,
              size: 16,
              color: instrument.workingAura,
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              title,
              style: textStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    final decoratedActions = effectiveActions
        .map(
          (widget) => Padding(
            padding: const EdgeInsets.only(left: 2),
            child: DetachedGlassOrb(child: widget),
          ),
        )
        .toList(growable: false);

    final Widget? decoratedLeading = leading == null
        ? null
        : Padding(
            padding: const EdgeInsets.only(right: 2),
            child: DetachedGlassOrb(child: leading!),
          );

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          dimensions.headerInset,
          8,
          dimensions.headerInset,
          8,
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: kIsWeb
                ? const BoxConstraints(maxWidth: Breakpoints.maxContentWidthWide)
                : const BoxConstraints(),
            child: SizedBox(
              height: dimensions.headerHeight,
              child: Row(
                children: [
                  if (decoratedLeading != null) decoratedLeading,
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Center(child: titlePill),
                    ),
                  ),
                  if (decoratedActions.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: decoratedActions,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
