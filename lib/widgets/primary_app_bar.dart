import 'dart:ui';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:workout_app/config/constants/theme_constants.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/responsive.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';

/// Shared detached circular glass orb (40x40 visual contour inside >=48x48 tap target).
class DetachedGlassOrb extends StatelessWidget {
  final Widget child;
  final Color? fillColor;
  final Color? borderColor;
  final double visualSize;

  const DetachedGlassOrb({
    super.key,
    required this.child,
    this.fillColor,
    this.borderColor,
    this.visualSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final instrument = InstrumentTheme.of(context);
    final resolvedFill = fillColor ??
        (isDark
            ? InstrumentPalette.obsidianCardLow.withValues(alpha: 0.72)
            : const Color(0xFF0E3A6B).withValues(alpha: 0.82));
    final resolvedBorder = borderColor ??
        (isDark
            ? instrument.hairlineBorder
            : Colors.white.withValues(alpha: 0.28));

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      child: Stack(
        alignment: Alignment.center,
        children: [
          IgnorePointer(
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  width: visualSize,
                  height: visualSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: resolvedFill,
                    border: Border.all(color: resolvedBorder, width: 1.0),
                  ),
                ),
              ),
            ),
          ),
          IconTheme(
            data: const IconThemeData(color: Colors.white, size: 20),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Shared floating translucent center capsule for header titles and AI triggers.
class FloatingTitleCapsule extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? fillColor;
  final Color? borderColor;

  const FloatingTitleCapsule({
    super.key,
    required this.child,
    this.onTap,
    this.fillColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final instrument = InstrumentTheme.of(context);
    final resolvedFill = fillColor ??
        (isDark
            ? InstrumentPalette.obsidianCardLow.withValues(alpha: 0.72)
            : const Color(0xFF0E3A6B).withValues(alpha: 0.84));
    final resolvedBorder = borderColor ??
        (isDark
            ? instrument.hairlineBorder
            : Colors.white.withValues(alpha: 0.28));

    Widget capsule = ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isDark || fillColor != null ? resolvedFill : null,
            gradient: isDark || fillColor != null
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppGradients.blue.colors
                        .map((c) => c.withValues(alpha: 0.86))
                        .toList(growable: false),
                  ),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: resolvedBorder, width: 1.0),
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      capsule = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Center(widthFactor: 1, child: capsule),
          ),
        ),
      );
    }

    return capsule;
  }
}

class PrimaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const double _toolbarHeight = 64;

  final String? title;
  final Widget? titleWidget;
  final VoidCallback? onTitleTap;
  final List<Widget>? actions;
  final bool? showBack;
  final VoidCallback? onBack;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final TextStyle? titleTextStyle;
  final double elevation;
  final PreferredSizeWidget? bottom;

  const PrimaryAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.onTitleTap,
    this.actions,
    this.showBack,
    this.onBack,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.titleTextStyle,
    this.elevation = 0,
    this.bottom,
  });

  const PrimaryAppBar.main({
    super.key,
    required String this.title,
    this.onTitleTap,
    this.actions,
    this.backgroundColor,
    this.bottom,
  })  : titleWidget = null,
        showBack = null,
        onBack = null,
        leading = null,
        centerTitle = true,
        titleTextStyle = null,
        elevation = 0;

  const PrimaryAppBar.detail({
    super.key,
    required String this.title,
    this.actions,
    this.onBack,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.titleTextStyle,
    this.elevation = 0,
    this.bottom,
  })  : titleWidget = null,
        onTitleTap = null,
        showBack = true;

  @override
  Size get preferredSize {
    final double bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(_toolbarHeight + bottomHeight);
  }

  @override
  Widget build(BuildContext context) {
    final dimensions = UiDimensions.of(context);
    final instrument = InstrumentTheme.of(context);
    final VoidCallback? effectiveOnTitleTap =
        onTitleTap ?? AssistantChatHost.of(context)?.openChat;
    final TextStyle effectiveTitleStyle = titleTextStyle ??
        Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ) ??
        const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        );

    final bool effectiveShowBack =
        showBack ?? (ModalRoute.of(context)?.canPop ?? false);

    Widget? resolvedLeading = leading;
    if (resolvedLeading == null && effectiveShowBack) {
      resolvedLeading = IconButton(
        icon: const Icon(Icons.arrow_back),
        color: Colors.white,
        onPressed: onBack ?? () => Navigator.of(context).maybePop(),
      );
    }

    if (resolvedLeading != null) {
      resolvedLeading = Padding(
        padding: const EdgeInsets.only(right: 4),
        child: DetachedGlassOrb(
          fillColor: backgroundColor,
          child: resolvedLeading,
        ),
      );
    }

    Widget? resolvedTitle = titleWidget;
    if (resolvedTitle == null && title != null) {
      final textWidget = Text(
        title!,
        style: effectiveTitleStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
      resolvedTitle = effectiveOnTitleTap != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome_outlined,
                  size: 16,
                  color: instrument.workingAura,
                ),
                const SizedBox(width: 6),
                Flexible(child: textWidget),
              ],
            )
          : textWidget;
    }

    if (resolvedTitle != null) {
      resolvedTitle = FloatingTitleCapsule(
        onTap: effectiveOnTitleTap,
        fillColor: backgroundColor,
        child: resolvedTitle,
      );
    }

    final List<Widget> wrappedActions = actions != null
        ? actions!
            .map(
              (action) => Padding(
                padding: const EdgeInsets.only(left: 4),
                child: DetachedGlassOrb(
                  fillColor: backgroundColor,
                  child: action,
                ),
              ),
            )
            .toList(growable: false)
        : const <Widget>[];

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: _toolbarHeight,
      titleSpacing: 0,
      bottom: bottom,
      flexibleSpace: SafeArea(
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
                  ? const BoxConstraints(
                      maxWidth: Breakpoints.maxContentWidthWide,
                    )
                  : const BoxConstraints(),
              child: SizedBox(
                height: dimensions.headerHeight,
                child: CustomMultiChildLayout(
                  delegate: _HeaderLayoutDelegate(centerTitle: centerTitle),
                  children: [
                    if (resolvedLeading != null)
                      LayoutId(
                        id: _HeaderSlot.leading,
                        child: resolvedLeading,
                      ),
                    if (resolvedTitle != null)
                      LayoutId(
                        id: _HeaderSlot.title,
                        child: resolvedTitle,
                      ),
                    if (wrappedActions.isNotEmpty)
                      LayoutId(
                        id: _HeaderSlot.actions,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: wrappedActions,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _HeaderSlot { leading, title, actions }

class _HeaderLayoutDelegate extends MultiChildLayoutDelegate {
  final bool centerTitle;

  _HeaderLayoutDelegate({required this.centerTitle});

  @override
  void performLayout(Size size) {
    Size leading = Size.zero;
    Size actions = Size.zero;
    final sideConstraints = BoxConstraints.loose(
      Size(size.width / 2, size.height),
    );
    if (hasChild(_HeaderSlot.leading)) {
      leading = layoutChild(_HeaderSlot.leading, sideConstraints);
      positionChild(
        _HeaderSlot.leading,
        Offset(0, (size.height - leading.height) / 2),
      );
    }
    if (hasChild(_HeaderSlot.actions)) {
      actions = layoutChild(_HeaderSlot.actions, sideConstraints);
      positionChild(
        _HeaderSlot.actions,
        Offset(
          size.width - actions.width,
          (size.height - actions.height) / 2,
        ),
      );
    }
    if (hasChild(_HeaderSlot.title)) {
      final reserve = centerTitle
          ? (leading.width > actions.width ? leading.width : actions.width)
          : leading.width;
      final availableWidth = centerTitle
          ? (size.width - 2 * reserve - 8).clamp(0.0, size.width)
          : (size.width - leading.width - actions.width - 8).clamp(
              0.0,
              size.width,
            );
      final title = layoutChild(
        _HeaderSlot.title,
        BoxConstraints.loose(Size(availableWidth, size.height)),
      );
      positionChild(
        _HeaderSlot.title,
        Offset(
          centerTitle ? (size.width - title.width) / 2 : leading.width + 4,
          (size.height - title.height) / 2,
        ),
      );
    }
  }

  @override
  bool shouldRelayout(covariant _HeaderLayoutDelegate oldDelegate) =>
      oldDelegate.centerTitle != centerTitle;
}
