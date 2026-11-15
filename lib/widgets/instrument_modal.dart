import 'package:flutter/material.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';

/// Variants for [InstrumentActionButton].
enum InstrumentActionVariant { primary, secondary, destructive }

/// Pill action button used in instrument dialogs, sheets, and tool cards.
/// Enforces a minimum `48dp` interactive height and tabular numerals.
class InstrumentActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final InstrumentActionVariant variant;
  final Color? accentColor;
  final bool loading;
  final bool expanded;

  const InstrumentActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = InstrumentActionVariant.primary,
    this.accentColor,
    this.loading = false,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final enabled = onPressed != null && !loading;

    final Color bg;
    final Color fg;
    final BorderSide? border;

    switch (variant) {
      case InstrumentActionVariant.primary:
        final baseAccent = accentColor ?? instrument.workingAura;
        bg = enabled
            ? baseAccent.withValues(alpha: isDark ? 0.22 : 0.16)
            : scheme.onSurface.withValues(alpha: 0.06);
        fg = enabled
            ? (isDark ? baseAccent : scheme.primary)
            : scheme.onSurface.withValues(alpha: 0.38);
        border = BorderSide(
          color: enabled
              ? baseAccent.withValues(alpha: 0.70)
              : scheme.outlineVariant.withValues(alpha: 0.25),
        );
      case InstrumentActionVariant.destructive:
        final danger = accentColor ?? instrument.peakEffortColor;
        bg = enabled
            ? danger.withValues(alpha: isDark ? 0.20 : 0.14)
            : scheme.onSurface.withValues(alpha: 0.06);
        fg = enabled ? danger : scheme.onSurface.withValues(alpha: 0.38);
        border = BorderSide(
          color: enabled
              ? danger.withValues(alpha: 0.72)
              : scheme.outlineVariant.withValues(alpha: 0.25),
        );
      case InstrumentActionVariant.secondary:
        bg = isDark
            ? InstrumentPalette.obsidianSlotHigh.withValues(alpha: 0.75)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.65);
        fg = enabled
            ? scheme.onSurface
            : scheme.onSurface.withValues(alpha: 0.38);
        border = BorderSide(
          color: isDark
              ? instrument.hairlineBorder
              : scheme.outlineVariant.withValues(alpha: 0.55),
        );
    }

    final textStyle = InstrumentTheme.tabular(
      (theme.textTheme.labelLarge ?? const TextStyle()).copyWith(
        color: fg,
        fontWeight: FontWeight.w700,
      ),
    );

    final child = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(999),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 64),
          child: Ink(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(999),
              border: Border.fromBorderSide(border),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (loading) ...[
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(fg),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ] else if (icon != null) ...[
                    Icon(icon, size: 17, color: fg),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: textStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return expanded ? SizedBox(width: double.infinity, child: child) : child;
  }
}

/// Selectable obsidian pill replacing Material [FilterChip] / [ChoiceChip].
/// Provides a `>= 48dp` interactive tap target and tabular typography.
/// Set [bordered] to `false` when placed inside an outer bordered card so
/// `Max Border Depth = 1` holds strictly.
class InstrumentSelectablePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? accentColor;
  final bool bordered;

  const InstrumentSelectablePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.accentColor,
    this.bordered = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = accentColor ?? instrument.workingAura;

    final fillColor = selected
        ? accent.withValues(alpha: isDark ? 0.22 : 0.14)
        : (isDark
              ? InstrumentPalette.obsidianSlotHigh.withValues(alpha: 0.78)
              : scheme.surfaceContainerHigh.withValues(alpha: 0.72));
    final borderColor = selected
        ? accent.withValues(alpha: 0.76)
        : (isDark
              ? instrument.hairlineBorder
              : scheme.outlineVariant.withValues(alpha: 0.60));
    final fgColor = selected
        ? (isDark ? accent : scheme.primary)
        : scheme.onSurface;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Center(
              widthFactor: 1.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(999),
                  border: bordered
                      ? Border.all(color: borderColor, width: 1.0)
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 15, color: fgColor),
                      const SizedBox(width: 6),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: InstrumentTheme.tabular(
                          (theme.textTheme.labelMedium ?? const TextStyle())
                              .copyWith(
                                color: fgColor,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                        ),
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

/// Compact non-interactive tonal pill for counts or status summaries inside
/// single-contour cards (borderless by default to maintain `Max Border Depth = 1`).
class InstrumentStatusPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;

  const InstrumentStatusPill({
    super.key,
    required this.label,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final instrument = InstrumentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tint = color ?? instrument.workingAura;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: isDark ? 0.16 : 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: tint),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: InstrumentTheme.tabular(
                (theme.textTheme.labelSmall ?? const TextStyle()).copyWith(
                  color: tint,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows a single-contour obsidian dialog replacing Material [AlertDialog].
Future<T?> showInstrumentDialog<T>({
  required BuildContext context,
  required String title,
  String? eyebrow,
  String? message,
  Widget? content,
  List<Widget>? actions,
  List<Widget> Function(BuildContext dialogContext)? actionsBuilder,
  Color? accentColor,
  bool barrierDismissible = true,
}) {
  assert(
    actions != null || actionsBuilder != null,
    'Provide either actions or actionsBuilder to showInstrumentDialog.',
  );
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black.withValues(alpha: isDark ? 0.68 : 0.44),
    builder: (dialogContext) => InstrumentDialog(
      title: title,
      eyebrow: eyebrow,
      message: message,
      content: content,
      actions: actionsBuilder != null
          ? actionsBuilder(dialogContext)
          : (actions ?? const []),
      accentColor: accentColor,
    ),
  );
}

/// Single-contour obsidian dialog container.
class InstrumentDialog extends StatelessWidget {
  final String title;
  final String? eyebrow;
  final String? message;
  final Widget? content;
  final List<Widget> actions;
  final Color? accentColor;

  const InstrumentDialog({
    super.key,
    required this.title,
    this.eyebrow,
    this.message,
    this.content,
    required this.actions,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hairline =
        (isDark ? instrument.hairlineBorder : scheme.outlineVariant)
            .withValues(alpha: isDark ? 0.85 : 0.55);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          decoration: InstrumentTheme.instrumentCardDecoration(
            context,
            accentColor: accentColor,
            radius: 22,
            fillColor: isDark
                ? InstrumentPalette.obsidianCardLow
                : scheme.surface,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (eyebrow != null && eyebrow!.trim().isNotEmpty) ...[
                      Text(
                        eyebrow!.toUpperCase(),
                        style: InstrumentTheme.microLabel(
                          context,
                          color: accentColor ?? instrument.workingAura,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 1, color: hairline),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message != null)
                        Text(
                          message!,
                          style: InstrumentTheme.tabular(
                            (theme.textTheme.bodyMedium ?? const TextStyle())
                                .copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ),
                      if (content != null) content!,
                    ],
                  ),
                ),
              ),
              if (actions.isNotEmpty) ...[
                Container(height: 1, color: hairline),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 8,
                    runSpacing: 8,
                    children: actions,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows an obsidian bottom sheet matching [InstrumentBottomSheetShell].
Future<T?> showInstrumentBottomSheet<T>({
  required BuildContext context,
  String? title,
  String? eyebrow,
  List<Widget>? headerActions,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  double? heightFactor,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: true,
    showDragHandle: false,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: isDark ? 0.64 : 0.40),
    builder: (sheetContext) {
      final shell = InstrumentBottomSheetShell(
        title: title,
        eyebrow: eyebrow,
        headerActions: headerActions,
        child: builder(sheetContext),
      );
      if (heightFactor != null) {
        return FractionallySizedBox(heightFactor: heightFactor, child: shell);
      }
      return shell;
    },
  );
}

/// Single-contour obsidian bottom-sheet container with centered grab handle,
/// optional header, and keyboard-safe bottom inset.
class InstrumentBottomSheetShell extends StatelessWidget {
  final String? title;
  final String? eyebrow;
  final List<Widget>? headerActions;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const InstrumentBottomSheetShell({
    super.key,
    this.title,
    this.eyebrow,
    this.headerActions,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hairline =
        (isDark ? instrument.hairlineBorder : scheme.outlineVariant)
            .withValues(alpha: isDark ? 0.85 : 0.55);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? InstrumentPalette.obsidianCardLow : scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: hairline, width: 1.0),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.38),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              if (title != null || eyebrow != null || headerActions != null) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (eyebrow != null &&
                                eyebrow!.trim().isNotEmpty) ...[
                              Text(
                                eyebrow!.toUpperCase(),
                                style: InstrumentTheme.microLabel(
                                  context,
                                  color: instrument.workingAura,
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                            if (title != null)
                              Text(
                                title!,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (headerActions != null) ...headerActions!,
                    ],
                  ),
                ),
                Container(height: 1, color: hairline),
              ],
              Flexible(
                child: padding != null
                    ? Padding(padding: padding!, child: child)
                    : child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
