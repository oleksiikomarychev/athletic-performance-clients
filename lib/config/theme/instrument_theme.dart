import 'package:flutter/material.dart';

/// Explicit obsidian-graphite surface constants and ambient spectrum palette
/// for the Adaptive Training Instrument UI.
abstract final class InstrumentPalette {
  static const Color obsidianCanvas = Color(0xFF0A0E14);
  static const Color obsidianLowest = Color(0xFF070A0F);
  static const Color obsidianCardLow = Color(0xFF111722);
  static const Color obsidianCardMid = Color(0xFF141B28);
  static const Color obsidianSlotHigh = Color(0xFF172030);
  static const Color obsidianSlotHighest = Color(0xFF1E293D);
  static const Color obsidianHairline = Color(0xFF263449);
  static const Color obsidianOutline = Color(0xFF384B66);
  static const Color obsidianDock = Color(0xFF0D131D);

  static const Color deloadAura = Color(0xFF2DD4BF);
  static const Color workingAura = Color(0xFF38BDF8);
  static const Color stormAura = Color(0xFFF59E0B);
  static const Color stormCoral = Color(0xFFEF4444);
  static const Color executionAccent = Color(0xFF10B981);
}

/// Semantic colors and typography helpers for the Adaptive Training Instrument UI.
@immutable
class InstrumentTheme extends ThemeExtension<InstrumentTheme> {
  final Color lightEffortColor;
  final Color moderateEffortColor;
  final Color peakEffortColor;
  final Color successColor;
  final Color derivedColor;
  final Color deloadAura;
  final Color workingAura;
  final Color stormAura;
  final Color executionAccent;
  final Color dockBackground;
  final Color glassOrbBackground;
  final Color hairlineBorder;

  const InstrumentTheme({
    required this.lightEffortColor,
    required this.moderateEffortColor,
    required this.peakEffortColor,
    required this.successColor,
    required this.derivedColor,
    this.deloadAura = InstrumentPalette.deloadAura,
    this.workingAura = InstrumentPalette.workingAura,
    this.stormAura = InstrumentPalette.stormAura,
    this.executionAccent = InstrumentPalette.executionAccent,
    this.dockBackground = InstrumentPalette.obsidianDock,
    this.glassOrbBackground = InstrumentPalette.obsidianCardLow,
    this.hairlineBorder = InstrumentPalette.obsidianHairline,
  });

  static const light = InstrumentTheme(
    lightEffortColor: Color(0xFF00857D),
    moderateEffortColor: Color(0xFFB45309),
    peakEffortColor: Color(0xFFDC2626),
    successColor: Color(0xFF15803D),
    derivedColor: Color(0xFF0063B0),
    deloadAura: Color(0xFF0D9488),
    workingAura: Color(0xFF0284C7),
    stormAura: Color(0xFFD97706),
    executionAccent: Color(0xFF059669),
    dockBackground: Color(0xFFF8FAFC),
    glassOrbBackground: Color(0xFFFFFFFF),
    hairlineBorder: Color(0xFFD6E0EC),
  );

  static const dark = InstrumentTheme(
    lightEffortColor: Color(0xFF2DD4BF),
    moderateEffortColor: Color(0xFFF59E0B),
    peakEffortColor: Color(0xFFEF4444),
    successColor: Color(0xFF10B981),
    derivedColor: Color(0xFF38BDF8),
    deloadAura: InstrumentPalette.deloadAura,
    workingAura: InstrumentPalette.workingAura,
    stormAura: InstrumentPalette.stormAura,
    executionAccent: InstrumentPalette.executionAccent,
    dockBackground: InstrumentPalette.obsidianDock,
    glassOrbBackground: InstrumentPalette.obsidianCardLow,
    hairlineBorder: InstrumentPalette.obsidianHairline,
  );

  static InstrumentTheme of(BuildContext context) {
    final ext = Theme.of(context).extension<InstrumentTheme>();
    if (ext != null) return ext;
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }

  /// Maps an RPE value (1–10) to the semantic intensity spectrum.
  Color colorForRpe(double? rpe, ColorScheme scheme) {
    if (rpe == null || rpe <= 0) return scheme.onSurfaceVariant;
    if (rpe >= 9.0) return peakEffortColor;
    if (rpe >= 7.5) return moderateEffortColor;
    return lightEffortColor;
  }

  /// Applies tabular numerals so weights, reps, RPE and timers never jitter.
  static TextStyle tabular(TextStyle base) =>
      base.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  static TextStyle microLabel(BuildContext context, {Color? color}) {
    final scheme = Theme.of(context).colorScheme;
    return TextStyle(
      fontSize: 10.5,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.7,
      color: color ?? scheme.onSurfaceVariant,
    );
  }

  static BoxDecoration cardDecoration(
    BuildContext context, {
    Color? color,
    Color? borderColor,
    double borderWidth = 1.0,
    double radius = 14.0,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = of(context);
    final defaultBorder = theme.brightness == Brightness.dark
        ? instrument.hairlineBorder
        : scheme.outlineVariant.withValues(alpha: 0.55);
    return BoxDecoration(
      color: color ?? scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? defaultBorder,
        width: borderWidth,
      ),
    );
  }

  /// Single-contour outer card decoration for self-contained telemetry modules.
  static BoxDecoration instrumentCardDecoration(
    BuildContext context, {
    Color? accentColor,
    double radius = 22.0,
    Color? fillColor,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseBorder = isDark
        ? instrument.hairlineBorder
        : scheme.outlineVariant.withValues(alpha: 0.55);
    final resolvedBorder = accentColor != null
        ? Color.lerp(baseBorder, accentColor, isDark ? 0.34 : 0.42)!
        : baseBorder;

    return BoxDecoration(
      color: fillColor ?? scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: resolvedBorder, width: 1.0),
    );
  }

  /// Hairline input decoration for instrument forms, search fields, and numeric cells.
  static InputDecoration inputDecoration(
    BuildContext context, {
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    double radius = 10.0,
    EdgeInsetsGeometry? contentPadding,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final restBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(
        color: scheme.outlineVariant.withValues(alpha: 0.45),
        width: 1.0,
      ),
    );
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding:
          contentPadding ??
          const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      border: restBorder,
      enabledBorder: restBorder,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
    );
  }

  @override
  InstrumentTheme copyWith({
    Color? lightEffortColor,
    Color? moderateEffortColor,
    Color? peakEffortColor,
    Color? successColor,
    Color? derivedColor,
    Color? deloadAura,
    Color? workingAura,
    Color? stormAura,
    Color? executionAccent,
    Color? dockBackground,
    Color? glassOrbBackground,
    Color? hairlineBorder,
  }) => InstrumentTheme(
    lightEffortColor: lightEffortColor ?? this.lightEffortColor,
    moderateEffortColor: moderateEffortColor ?? this.moderateEffortColor,
    peakEffortColor: peakEffortColor ?? this.peakEffortColor,
    successColor: successColor ?? this.successColor,
    derivedColor: derivedColor ?? this.derivedColor,
    deloadAura: deloadAura ?? this.deloadAura,
    workingAura: workingAura ?? this.workingAura,
    stormAura: stormAura ?? this.stormAura,
    executionAccent: executionAccent ?? this.executionAccent,
    dockBackground: dockBackground ?? this.dockBackground,
    glassOrbBackground: glassOrbBackground ?? this.glassOrbBackground,
    hairlineBorder: hairlineBorder ?? this.hairlineBorder,
  );

  @override
  InstrumentTheme lerp(ThemeExtension<InstrumentTheme>? other, double t) {
    if (other is! InstrumentTheme) return this;
    return InstrumentTheme(
      lightEffortColor: Color.lerp(lightEffortColor, other.lightEffortColor, t)!,
      moderateEffortColor: Color.lerp(
        moderateEffortColor,
        other.moderateEffortColor,
        t,
      )!,
      peakEffortColor: Color.lerp(peakEffortColor, other.peakEffortColor, t)!,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      derivedColor: Color.lerp(derivedColor, other.derivedColor, t)!,
      deloadAura: Color.lerp(deloadAura, other.deloadAura, t)!,
      workingAura: Color.lerp(workingAura, other.workingAura, t)!,
      stormAura: Color.lerp(stormAura, other.stormAura, t)!,
      executionAccent: Color.lerp(executionAccent, other.executionAccent, t)!,
      dockBackground: Color.lerp(dockBackground, other.dockBackground, t)!,
      glassOrbBackground: Color.lerp(
        glassOrbBackground,
        other.glassOrbBackground,
        t,
      )!,
      hairlineBorder: Color.lerp(hairlineBorder, other.hairlineBorder, t)!,
    );
  }
}
