import 'package:flutter/material.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';

enum ParamMode { set, offset, scale }

class ModeValue {
  ParamMode mode;
  double value;
  ModeValue({required this.mode, required this.value});
}

class ModeValueControl extends StatelessWidget {
  final String label;
  final bool enabled;
  final ValueChanged<bool> onEnabledChanged;
  final ModeValue value;
  final ValueChanged<ModeValue> onChanged;

  final List<ParamMode> allowedModes;
  final Map<ParamMode, String> modeTitles;

  final String Function(ParamMode, double) displayTextBuilder;
  final double Function(ParamMode) stepForMode;

  final double? setMin;
  final double? setMax;
  final double? scaleMin;

  const ModeValueControl({
    super.key,
    required this.label,
    required this.enabled,
    required this.onEnabledChanged,
    required this.value,
    required this.onChanged,
    required this.allowedModes,
    required this.modeTitles,
    required this.displayTextBuilder,
    required this.stepForMode,
    this.setMin,
    this.setMax,
    this.scaleMin,
  });

  String _labelForMode(ParamMode m) {
    final fromMap = modeTitles[m];
    if (fromMap != null) return fromMap;
    final s = m.toString();
    final idx = s.indexOf('.');
    return idx >= 0 ? s.substring(idx + 1) : s;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    final dropdown = DropdownButtonFormField<ParamMode>(
      initialValue: value.mode,
      isExpanded: true,
      decoration: InstrumentTheme.inputDecoration(context),
      items: allowedModes
          .map(
            (m) => DropdownMenuItem(
              value: m,
              child: Text(_labelForMode(m), overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: enabled
          ? (m) {
              if (m == null) return;
              onChanged(ModeValue(mode: m, value: value.value));
            }
          : null,
    );

    final toggleHeader = InkWell(
      onTap: () => onEnabledChanged(!enabled),
      borderRadius: BorderRadius.circular(10),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch.adaptive(
              value: enabled,
              activeThumbColor: instrument.workingAura,
              activeTrackColor: instrument.workingAura.withValues(alpha: 0.55),
              onChanged: onEnabledChanged,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    void decrement() {
      final step = stepForMode(value.mode);
      double newVal = value.value - step;
      if (value.mode == ParamMode.scale && scaleMin != null && newVal < scaleMin!) {
        newVal = scaleMin!;
      } else if (value.mode == ParamMode.set && setMin != null && newVal < setMin!) {
        newVal = setMin!;
      }
      onChanged(ModeValue(mode: value.mode, value: newVal));
    }

    void increment() {
      final step = stepForMode(value.mode);
      double newVal = value.value + step;
      if (value.mode == ParamMode.set && setMax != null && newVal > setMax!) {
        newVal = setMax!;
      }
      onChanged(ModeValue(mode: value.mode, value: newVal));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 340 || textScale > 1.35;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (compact) ...[
              toggleHeader,
              const SizedBox(height: 8),
              dropdown,
            ] else
              Row(
                children: [
                  Expanded(child: toggleHeader),
                  const SizedBox(width: 12),
                  Flexible(child: dropdown),
                ],
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                _StepPillButton(
                  icon: Icons.remove_rounded,
                  enabled: enabled,
                  isDark: isDark,
                  scheme: scheme,
                  instrument: instrument,
                  onTap: decrement,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? InstrumentPalette.obsidianSlotHigh
                          : scheme.surfaceContainerHighest.withValues(
                              alpha: 0.55,
                            ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      displayTextBuilder(value.mode, value.value),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: enabled
                            ? scheme.onSurface
                            : scheme.onSurfaceVariant,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _StepPillButton(
                  icon: Icons.add_rounded,
                  enabled: enabled,
                  isDark: isDark,
                  scheme: scheme,
                  instrument: instrument,
                  onTap: increment,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _StepPillButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final bool isDark;
  final ColorScheme scheme;
  final InstrumentTheme instrument;
  final VoidCallback onTap;

  const _StepPillButton({
    required this.icon,
    required this.enabled,
    required this.isDark,
    required this.scheme,
    required this.instrument,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark
        ? InstrumentPalette.obsidianSlotHigh
        : scheme.surfaceContainerHighest.withValues(alpha: 0.7);
    final fg = enabled
        ? (isDark ? instrument.workingAura : scheme.primary)
        : scheme.onSurfaceVariant.withValues(alpha: 0.4);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: Icon(icon, color: fg),
        ),
      ),
    );
  }
}
