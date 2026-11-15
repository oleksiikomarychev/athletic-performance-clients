import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/config/theme/app_theme.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/models/crm_analytics.dart';
import 'package:workout_app/models/macro.dart';
import 'package:workout_app/providers/macro_providers.dart';
import 'package:workout_app/providers/plan_providers.dart';
import 'package:workout_app/providers/providers.dart';
import 'package:workout_app/screens/coach/coach_dashboard_screen.dart';
import 'package:workout_app/screens/macros/macros_list_screen.dart';
import 'package:workout_app/screens/nutrition_plan_active.dart';
import 'package:workout_app/screens/settings/settings_home_screen.dart';
import 'package:workout_app/screens/workout_session_history_screen.dart';
import 'package:workout_app/services/api_client.dart';
import 'package:workout_app/services/macro_service.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/custom_bottom_nav_bar.dart';
import 'package:workout_app/widgets/floating_header_bar.dart';
import 'package:workout_app/widgets/instrument_metric_matrix.dart';
import 'package:workout_app/widgets/instrument_modal.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';

class _NoopApiClient extends Fake implements ApiClient {}

class _FakeMacroService extends MacroService {
  _FakeMacroService() : super(apiClient: _NoopApiClient());

  @override
  Future<List<PlanMacro>> listMacros(int calendarPlanId) async => [
    PlanMacro(
      id: 1,
      calendarPlanId: calendarPlanId,
      name: 'High RPE Auto Deload',
      isActive: true,
      priority: 10,
      rule: MacroRule.empty(),
    ),
  ];
}

Widget _wrap320At2x(
  Widget child, {
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: AppTheme.darkTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, widget) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations: true,
          size: const Size(320, 760),
          textScaler: const TextScaler.linear(2.0),
        ),
        child: GlobalAmbientStage(
          child: widget ?? const SizedBox.shrink(),
        ),
      ),
      home: child,
    ),
  );
}

void main() {
  testWidgets('floating header fits three actions at 320 logical pixels', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FloatingHeaderBar(
          title: 'M1-MC2-D1: Day 1 - Workout 1',
          leading: IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_back)),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.restaurant)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.refresh)),
          ],
          onProfileTap: () {},
        ),
      ),
    ));

    expect(find.byIcon(Icons.restaurant), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
    expect(find.byIcon(Icons.account_circle_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bottom navigation grows for larger system text', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    Widget app(double scale) => MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
        ),
        child: child!,
      ),
      home: Scaffold(
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: 0,
          onTap: (_) {},
          items: const [
            BottomNavBarItem(icon: Icons.fitness_center, label: 'Тренировки'),
            BottomNavBarItem(icon: Icons.schedule, label: 'Планы тренировок'),
            BottomNavBarItem(icon: Icons.people, label: 'Сообщество'),
            BottomNavBarItem(icon: Icons.business, label: 'Клиенты'),
            BottomNavBarItem(icon: Icons.bug_report, label: 'Отладка'),
          ],
        ),
      ),
    );

    await tester.pumpWidget(app(1));
    final normalHeight = tester.getSize(find.byType(CustomBottomNavBar)).height;
    await tester.pumpWidget(app(2));
    await tester.pumpAndSettle();
    final largeTextHeight = tester.getSize(find.byType(CustomBottomNavBar)).height;

    expect(largeTextHeight, greaterThan(normalHeight));
    expect(tester.takeException(), isNull);
  });

  testWidgets('app bar keeps title clear of actions on a narrow screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        appBar: PrimaryAppBar.detail(
          title: 'Очень длинное название экрана тренировок',
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
          ],
        ),
      ),
    ));

    final title = tester.getRect(find.text('Очень длинное название экрана тренировок'));
    final search = tester.getRect(find.byIcon(Icons.search));
    expect(title.right, lessThanOrEqualTo(search.left));
    expect(tester.takeException(), isNull);
  });

  testWidgets('main app bar centers its agent title with one action', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        appBar: PrimaryAppBar.main(
          title: 'Workouts',
          actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.person))],
        ),
      ),
    ));

    final titleCenter = tester.getCenter(find.text('Workouts')).dx;
    expect(titleCenter, closeTo(160, 4));
    expect(tester.takeException(), isNull);
  });

  testWidgets('dark app bar keeps the assistant action discoverable', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var taps = 0;

    await tester.pumpWidget(MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: PrimaryAppBar.main(
          title: 'Workouts',
          onTitleTap: () => taps++,
          actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.person))],
        ),
      ),
    ));

    expect(find.byIcon(Icons.auto_awesome_outlined), findsOneWidget);
    await tester.tap(find.text('Workouts'));
    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('plan title stays centered between back and two actions', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: PrimaryAppBar(
          title: 'Training Plans',
          showBack: true,
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.check)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
          ],
        ),
      ),
    ));

    expect(tester.getCenter(find.text('Training Plans')).dx, closeTo(200, 4));
    expect(tester.takeException(), isNull);
  });

  group('Waves 1-5 responsive instrument screens & modals at 320px @ 2.0x', () {
    testWidgets(
      'Wave 1 InstrumentDialog and InstrumentSelectablePill meet >=48dp touch targets without overflow',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 760));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          _wrap320At2x(
            Scaffold(
              body: Builder(
                builder: (context) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InstrumentSelectablePill(
                        label: 'Hypertrophy Block',
                        selected: true,
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      InstrumentActionButton(
                        label: 'Open Confirm',
                        onPressed: () {
                          showInstrumentDialog<void>(
                            context: context,
                            eyebrow: 'CONFIRM',
                            title: 'Apply Selected Plan?',
                            message: 'Schedules 12 weeks starting Monday.',
                            actionsBuilder: (ctx) => [
                              InstrumentActionButton(
                                label: 'Cancel',
                                variant: InstrumentActionVariant.secondary,
                                onPressed: () => Navigator.of(ctx).pop(),
                              ),
                              InstrumentActionButton(
                                label: 'Apply Now',
                                onPressed: () => Navigator.of(ctx).pop(),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          tester.getSize(find.byType(InstrumentSelectablePill)).height,
          greaterThanOrEqualTo(48),
        );
        expect(find.byType(FilterChip), findsNothing);

        await tester.tap(find.text('Open Confirm'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(InstrumentDialog), findsOneWidget);
        expect(find.byType(AlertDialog), findsNothing);
        expect(
          tester
              .getSize(find.widgetWithText(InstrumentActionButton, 'Apply Now'))
              .height,
          greaterThanOrEqualTo(48),
        );
      },
    );

    testWidgets(
      'Wave 2 SettingsHomeScreen renders cleanly in AmbientScaffoldShell at 320px @ 2.0x',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 760));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(_wrap320At2x(const SettingsHomeScreen()));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(AmbientScaffoldShell), findsOneWidget);
        expect(find.byType(PrimaryAppBar), findsOneWidget);
        expect(find.byType(Divider), findsNothing);
        expect(find.byType(ListTile), findsNothing);
      },
    );

    testWidgets(
      'Wave 3 MacrosListScreen renders single-contour rules without overflow at 320px @ 2.0x',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 760));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          _wrap320At2x(
            const MacrosListScreen(calendarPlanId: 1),
            overrides: [
              macroServiceProvider.overrideWithValue(_FakeMacroService()),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(AmbientScaffoldShell), findsOneWidget);
        expect(find.byType(PrimaryAppBar), findsOneWidget);
        expect(find.text('High RPE Auto Deload'), findsOneWidget);
        expect(find.byType(Divider), findsNothing);
        expect(find.byType(ListTile), findsNothing);
      },
    );

    testWidgets(
      'Wave 4 NutritionPlanActive renders without FAB or overflow at 320px @ 2.0x',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 760));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          _wrap320At2x(
            const NutritionPlanActive(),
            overrides: [
              activeAppliedPlanProvider.overrideWith((ref) => null),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(AmbientScaffoldShell), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsNothing);
      },
    );

    testWidgets(
      'Wave 4 WorkoutSessionHistoryScreen renders without FAB or overflow at 320px @ 2.0x',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 760));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          _wrap320At2x(
            const WorkoutSessionHistoryScreen(workoutId: 1),
            overrides: [
              sessionsHistorySWRProvider(1).overrideWith(
                (ref) => Stream.value(const []),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(AmbientScaffoldShell), findsOneWidget);
        expect(find.byType(PrimaryAppBar), findsOneWidget);
      },
    );

    testWidgets(
      'Wave 5 CoachDashboardScreen renders InstrumentMetricMatrix cleanly at 320px @ 2.0x',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 760));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final summary = CoachSummaryAnalyticsModel(
          coachId: 'coach-1',
          generatedAt: DateTime(2026, 5, 1),
          weeks: 12,
          totalAthletes: 12,
          activeLinks: 10,
          avgSessionsPerWeek: 4.1,
          inactiveAthletesCount: 2,
          avgPlanAdherence: 0.91,
          avgIntensity: 79.0,
          avgEffort: 8.2,
          segmentCounts: const {'on_track': 8, 'at_risk': 2},
        );

        await tester.pumpWidget(
          _wrap320At2x(
            const CoachDashboardScreen(),
            overrides: [
              coachSummaryAnalyticsProvider.overrideWith(
                (ref) async => summary,
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(AmbientScaffoldShell), findsOneWidget);
        expect(find.byType(InstrumentMetricMatrix), findsOneWidget);
        expect(find.byType(Card), findsNothing);
      },
    );

    testWidgets(
      'AmbientScaffoldShell applies top ShaderMask feathering only on inset devices outside appBar',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 844));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme(),
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(390, 844),
                padding: EdgeInsets.only(top: 59, bottom: 34),
                disableAnimations: true,
              ),
              child: AmbientScaffoldShell(
                appBar: const PrimaryAppBar.detail(title: 'Account'),
                body: ListView(
                  children: const [SizedBox(height: 1200)],
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(ShaderMask), findsOneWidget);
        expect(
          find.ancestor(
            of: find.byType(PrimaryAppBar),
            matching: find.byType(ShaderMask),
          ),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
      },
    );
  });
}
