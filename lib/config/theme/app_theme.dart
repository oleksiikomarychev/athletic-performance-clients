import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:workout_app/config/constants/theme_constants.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'instrument_theme.dart';
import 'ui_dimensions.dart';

class AppTheme {
  static TextTheme _scaledTextTheme(TextTheme base, double factor) {
    TextStyle? scaled(TextStyle? style) => style?.fontSize == null
        ? style
        : style!.copyWith(fontSize: style.fontSize! * factor);

    return base.copyWith(
      displayLarge: scaled(base.displayLarge),
      displayMedium: scaled(base.displayMedium),
      displaySmall: scaled(base.displaySmall),
      headlineLarge: scaled(base.headlineLarge),
      headlineMedium: scaled(base.headlineMedium),
      headlineSmall: scaled(base.headlineSmall),
      titleLarge: scaled(base.titleLarge),
      titleMedium: scaled(base.titleMedium),
      titleSmall: scaled(base.titleSmall),
      bodyLarge: scaled(base.bodyLarge),
      bodyMedium: scaled(base.bodyMedium),
      bodySmall: scaled(base.bodySmall),
      labelLarge: scaled(base.labelLarge),
      labelMedium: scaled(base.labelMedium),
      labelSmall: scaled(base.labelSmall),
    );
  }

  static ThemeData lightTheme({UiDensity density = UiDensity.compact}) =>
      _buildTheme(brightness: Brightness.light, density: density);

  static ThemeData darkTheme({UiDensity density = UiDensity.compact}) =>
      _buildTheme(brightness: Brightness.dark, density: density);

  static ThemeData _buildTheme({
    required Brightness brightness,
    required UiDensity density,
  }) {
    final isDark = brightness == Brightness.dark;
    final seededScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    );
    final colorScheme = isDark
        ? seededScheme.copyWith(
            primary: InstrumentPalette.workingAura,
            onPrimary: const Color(0xFF04131E),
            primaryContainer: const Color(0xFF10324A),
            onPrimaryContainer: const Color(0xFFE0F2FE),
            secondary: InstrumentPalette.deloadAura,
            onSecondary: const Color(0xFF041A18),
            secondaryContainer: const Color(0xFF0F3532),
            onSecondaryContainer: const Color(0xFFCCFBF1),
            tertiary: InstrumentPalette.stormAura,
            onTertiary: const Color(0xFF1F1202),
            tertiaryContainer: const Color(0xFF3A2506),
            onTertiaryContainer: const Color(0xFFFEF3C7),
            error: InstrumentPalette.stormCoral,
            surface: InstrumentPalette.obsidianCanvas,
            surfaceContainerLowest: InstrumentPalette.obsidianLowest,
            surfaceContainerLow: InstrumentPalette.obsidianCardLow,
            surfaceContainer: InstrumentPalette.obsidianCardMid,
            surfaceContainerHigh: InstrumentPalette.obsidianSlotHigh,
            surfaceContainerHighest: InstrumentPalette.obsidianSlotHighest,
            onSurface: const Color(0xFFF1F5F9),
            onSurfaceVariant: const Color(0xFF94A3B8),
            outline: InstrumentPalette.obsidianOutline,
            outlineVariant: InstrumentPalette.obsidianHairline,
          )
        : seededScheme;
    final baseTextTheme = isDark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;
    final hairlineColor = isDark
        ? InstrumentPalette.obsidianHairline
        : colorScheme.outlineVariant.withValues(alpha: 0.7);

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor:
          isDark ? InstrumentPalette.obsidianCanvas : colorScheme.surface,
      canvasColor:
          isDark ? InstrumentPalette.obsidianCanvas : colorScheme.surface,
      extensions: [
        density == UiDensity.compact
            ? UiDimensions.compact
            : UiDimensions.comfortable,
        isDark ? InstrumentTheme.dark : InstrumentTheme.light,
      ],
      visualDensity: density == UiDensity.compact
          ? VisualDensity.compact
          : VisualDensity.comfortable,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      colorScheme: colorScheme,
      textTheme: _scaledTextTheme(
        baseTextTheme,
        density == UiDensity.compact ? 0.88 : 0.92,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: density == UiDensity.compact ? 10 : 12,
        ),
        minVerticalPadding: density == UiDensity.compact ? 2 : 4,
        minTileHeight: 48,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isDark ? 20 : 16),
          side: BorderSide(color: hairlineColor),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        highlightElevation: 0,
        hoverElevation: 0,
        focusElevation: 0,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: density == UiDensity.compact ? 10 : 12,
          vertical: density == UiDensity.compact ? 6 : 8,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: density == UiDensity.compact ? 14 : 16,
            vertical: density == UiDensity.compact ? 8 : 10,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      bottomSheetTheme: kIsWeb
          ? const BottomSheetThemeData(constraints: BoxConstraints(maxWidth: 640))
          : null,
      dialogTheme: kIsWeb
          ? const DialogThemeData(constraints: BoxConstraints(maxWidth: 640))
          : null,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.iOS: SeamlessWidgetPageTransitionsBuilder(),
          TargetPlatform.macOS: SeamlessWidgetPageTransitionsBuilder(),
          TargetPlatform.android: SeamlessWidgetPageTransitionsBuilder(),
          TargetPlatform.linux: SeamlessWidgetPageTransitionsBuilder(),
          TargetPlatform.windows: SeamlessWidgetPageTransitionsBuilder(),
          TargetPlatform.fuchsia: SeamlessWidgetPageTransitionsBuilder(),
        },
      ),
    );
  }
}
