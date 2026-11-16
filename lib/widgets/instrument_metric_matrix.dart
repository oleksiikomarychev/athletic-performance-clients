import 'package:flutter/material.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/providers/interface_maker_provider.dart';

/// Descriptor for one cell in an [InstrumentMetricMatrix].
@immutable
class InstrumentMetricCellData {
  final MetricSlot slot;
  final String? label;
  final String value;
  final String? subValue;
  final Color? valueColor;
  final bool isAutoDerived;

  const InstrumentMetricCellData({
    required this.slot,
    this.label,
    required this.value,
    this.subValue,
    this.valueColor,
    this.isAutoDerived = false,
  });

  String get effectiveLabel => label ?? slot.shortLabel;

  String localizedLabel(AppLocalizations l10n) =>
      label ?? slot.localizedShortLabel(l10n);
}

/// Bare 4-column telemetry matrix ("Data Point Picker") placed at the bottom
/// of a single-contour [InstrumentCard].
///
/// Strictly enforces `Zero Nested Boxes`: cells have NO outer or inner
/// `BoxDecoration(border: ...)`, separated only by `1px` hairlines.
/// Automatically switches to a `2x2` hairline grid at `< 340px` width or
/// `textScale > 1.35`.
class InstrumentMetricMatrix extends StatelessWidget {
  final List<InstrumentMetricCellData> cells;
  final MetricSlot? selectedSlot;
  final ValueChanged<MetricSlot>? onSelectSlot;
  final Color? accentColor;
  final EdgeInsetsGeometry padding;

  const InstrumentMetricMatrix({
    super.key,
    required this.cells,
    this.selectedSlot,
    this.onSelectSlot,
    this.accentColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    if (cells.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hairline = (isDark
            ? instrument.hairlineBorder
            : scheme.outlineVariant)
        .withValues(alpha: isDark ? 0.85 : 0.55);
    final activeAccent = accentColor ?? instrument.workingAura;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final useTwoByTwo =
            cells.length == 4 &&
            (constraints.maxWidth < 340 || textScale > 1.35);

        if (useTwoByTwo) {
          return Padding(
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildRow(
                  context,
                  cells.sublist(0, 2),
                  hairline: hairline,
                  activeAccent: activeAccent,
                ),
                Container(height: 1, color: hairline),
                _buildRow(
                  context,
                  cells.sublist(2, 4),
                  hairline: hairline,
                  activeAccent: activeAccent,
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: padding,
          child: _buildRow(
            context,
            cells,
            hairline: hairline,
            activeAccent: activeAccent,
          ),
        );
      },
    );
  }

  Widget _buildRow(
    BuildContext context,
    List<InstrumentMetricCellData> rowCells, {
    required Color hairline,
    required Color activeAccent,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < rowCells.length; i++) ...[
            if (i > 0)
              Center(
                child: Container(
                  width: 1,
                  height: 36,
                  color: hairline,
                ),
              ),
            Expanded(
              child: _MatrixCell(
                data: rowCells[i],
                isSelected: selectedSlot == rowCells[i].slot,
                activeAccent: activeAccent,
                onTap: onSelectSlot != null
                    ? () => onSelectSlot!(rowCells[i].slot)
                    : null,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MatrixCell extends StatelessWidget {
  final InstrumentMetricCellData data;
  final bool isSelected;
  final Color activeAccent;
  final VoidCallback? onTap;

  const _MatrixCell({
    required this.data,
    required this.isSelected,
    required this.activeAccent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);

    final labelColor = isSelected ? activeAccent : scheme.onSurfaceVariant;
    final valueColor = data.valueColor ??
        (isSelected ? scheme.onSurface : scheme.onSurface);

    final content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 52),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    data.localizedLabel(AppLocalizations.of(context)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: InstrumentTheme.microLabel(
                      context,
                      color: labelColor,
                    ).copyWith(fontSize: 9.5, letterSpacing: 0.55),
                  ),
                ),
                if (data.isAutoDerived) ...[
                  const SizedBox(width: 4),
                  Text(
                    'AUTO',
                    style: InstrumentTheme.microLabel(
                      context,
                      color: instrument.derivedColor,
                    ).copyWith(fontSize: 8.5),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 3),
            Text(
              data.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: InstrumentTheme.tabular(
                theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: valueColor,
                      letterSpacing: -0.2,
                    ) ??
                    TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: valueColor,
                    ),
              ),
            ),
            if (data.subValue != null && data.subValue!.isNotEmpty) ...[
              const SizedBox(height: 1),
              Text(
                data.subValue!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: InstrumentTheme.tabular(
                  theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: scheme.onSurfaceVariant,
                      ) ??
                      TextStyle(
                        fontSize: 10,
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ),
            ],
            const SizedBox(height: 5),
            AnimatedContainer(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 180),
              height: 2.5,
              width: isSelected ? 26 : 0,
              decoration: BoxDecoration(
                color: isSelected ? activeAccent : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap == null) return content;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${data.localizedLabel(AppLocalizations.of(context))}: ${data.value}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: content,
        ),
      ),
    );
  }
}
