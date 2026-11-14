import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:workout_app/config/constants/theme_constants.dart';
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

  static ThemeData lightTheme({UiDensity density = UiDensity.compact}) {
    return ThemeData(
      useMaterial3: true,
      extensions: [
        density == UiDensity.compact
            ? UiDimensions.compact
            : UiDimensions.comfortable,
      ],
      visualDensity: density == UiDensity.compact
          ? VisualDensity.compact
          : VisualDensity.comfortable,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      textTheme: _scaledTextTheme(
        ThemeData.light().textTheme,
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
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    );
  }

  static ThemeData darkTheme({UiDensity density = UiDensity.compact}) {
    return ThemeData(
      useMaterial3: true,
      extensions: [
        density == UiDensity.compact
            ? UiDimensions.compact
            : UiDimensions.comfortable,
      ],
      visualDensity: density == UiDensity.compact
          ? VisualDensity.compact
          : VisualDensity.comfortable,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      textTheme: _scaledTextTheme(
        ThemeData.dark().textTheme,
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
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    );
  }
}
