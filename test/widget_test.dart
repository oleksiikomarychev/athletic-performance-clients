import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_app/config/theme/app_theme.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/models/user_stats.dart';
import 'package:workout_app/providers/app_theme_mode_provider.dart';
import 'package:workout_app/providers/app_ui_density_provider.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/widgets/profile_sections.dart';
import 'package:workout_app/widgets/calendar_plan_card.dart';
import 'package:workout_app/models/calendar_plan.dart';
import 'package:workout_app/models/mesocycle.dart';

void main() {
  testWidgets('plan rows fit a narrow screen in both densities', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final density in UiDensity.values) {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme(density: density),
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: ListView(
              padding: const EdgeInsets.all(10),
              children: [
                CalendarPlanCard(
                  key: const Key('plan-tile'),
                  plan: CalendarPlan(
                    id: 1,
                    name: 'Power Hypertrophy Adaptive Training',
                    schedule: {},
                    durationWeeks: 12,
                    primaryGoal: 'strength_hypertrophy',
                    intendedExperienceLevel: 'intermediate-advanced',
                    intendedFrequencyPerWeek: 5,
                    sessionDurationTargetMin: 90,
                    mesocycles: [Mesocycle(id: 1, name: 'Base', orderIndex: 0)],
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.delete), findsNothing);
      expect(find.byIcon(Icons.check_circle), findsNothing);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      expect(tester.getSize(find.byKey(const Key('plan-tile'))).height, greaterThanOrEqualTo(48));
    }
  });

  test('saved interface size is available before the first frame', () async {
    SharedPreferences.setMockInitialValues({'app_ui_density': 'comfortable'});
    final density = await AppUiDensityController.loadInitialDensity();
    expect(density, UiDensity.comfortable);
    expect(AppTheme.lightTheme(density: density).extension<UiDimensions>(), UiDimensions.comfortable);
    final controller = AppUiDensityController(initialDensity: density);
    await controller.setDensity(UiDensity.compact);
    expect(await AppUiDensityController.loadInitialDensity(), UiDensity.compact);
    controller.dispose();
  });

  test('saved theme is available before the first frame', () async {
    SharedPreferences.setMockInitialValues({'app_theme_mode': 'dark'});
    final mode = await AppThemeModeController.loadInitialThemeMode();
    expect(mode, ThemeMode.dark);
    final controller = AppThemeModeController(initialThemeMode: mode);
    expect(controller.debugState, ThemeMode.dark);
    controller.dispose();
  });

  testWidgets('profile stat cards use the active color scheme', (tester) async {
    const stats = UserStats(
      totalWorkouts: 8,
      totalVolume: 1200,
      activeDays: 4,
      activityMap: {},
      completedSessions: [],
      maxDayVolume: 0,
      weeks: 1,
    );

    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      final theme = mode == ThemeMode.light
          ? AppTheme.lightTheme()
          : AppTheme.darkTheme();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: mode,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: ProfileStatsRow(stats: stats)),
        ),
      );
      await tester.pumpAndSettle();

      final instrument =
          theme.extension<InstrumentTheme>() ??
          (mode == ThemeMode.light
              ? InstrumentTheme.light
              : InstrumentTheme.dark);
      final value = tester.widget<Text>(find.text('8'));
      expect(value.style?.color, instrument.workingAura);
      expect(find.text('PROFILE TELEMETRY'), findsOneWidget);
      final card = tester.widget<Container>(
        find
            .ancestor(of: find.text('PROFILE TELEMETRY'), matching: find.byType(Container))
            .first,
      );
      final decoration = card.decoration as BoxDecoration;
      expect(
        decoration.color,
        theme.colorScheme.surfaceContainerLow,
      );
      expect(decoration.border, isNotNull);
    }
  });
}
