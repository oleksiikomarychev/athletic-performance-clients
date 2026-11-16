import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:workout_app/config/api_config.dart';
import 'package:workout_app/config/theme/app_theme.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/models/calendar_plan.dart';
import 'package:workout_app/models/calendar_plan_summary.dart';
import 'package:workout_app/models/coach_review.dart';
import 'package:workout_app/models/exercise_instance.dart';
import 'package:workout_app/models/exercise_set_dto.dart';
import 'package:workout_app/models/microcycle.dart';
import 'package:workout_app/models/workout.dart';
import 'package:workout_app/models/workout_session.dart';
import 'package:workout_app/providers/ambient_environment_provider.dart';
import 'package:workout_app/providers/interface_maker_provider.dart';
import 'package:workout_app/providers/target_data_providers.dart'
    as target_dp;
import 'package:workout_app/screens/analytics_screen.dart';
import 'package:workout_app/screens/macros/widgets/macro_human_preview.dart';
import 'package:workout_app/screens/plan_microcycle_editor.dart';
import 'package:workout_app/screens/settings/settings_legal_screen.dart';
import 'package:workout_app/services/analytics_service.dart';
import 'package:workout_app/services/api_client.dart';
import 'package:workout_app/services/service_locator.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/calendar_plan_card.dart';
import 'package:workout_app/widgets/chat_tools/mass_edit_tool_widget.dart';
import 'package:workout_app/widgets/custom_bottom_nav_bar.dart';
import 'package:workout_app/widgets/floating_header_bar.dart';
import 'package:workout_app/widgets/instrument_metric_matrix.dart';
import 'package:workout_app/widgets/plan_analytics_chart.dart';
import 'package:workout_app/widgets/plan_detail/plan_instrument_widgets.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';
import 'package:workout_app/widgets/review_card.dart';
import 'package:workout_app/widgets/session_instrument_card.dart';
import 'package:workout_app/widgets/workout_detail/workout_instrument_controls.dart';
import 'package:workout_app/widgets/workout_instrument_cards.dart';

class _FakeAnalyticsApiClient extends ApiClient {
  @override
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    String? context,
    Duration timeout = const Duration(seconds: ApiConfig.receiveTimeout),
  }) async {
    if (endpoint == ApiConfig.getActivePlanEndpoint) {
      return {
        'id': 99,
        'calendar_plan_id': 7,
        'is_active': true,
        'end_date': '2026-12-31T00:00:00Z',
        'calendar_plan': {
          'id': 7,
          'name': 'Strength Instrument Plan',
          'schedule': <String, dynamic>{},
          'duration_weeks': 8,
          'is_active': true,
        },
      };
    }
    return <String, dynamic>{};
  }

  @override
  Future<void> setCachedGet(
    String endpoint,
    dynamic data, {
    int ttlSeconds = 60,
    List<String> groups = const [],
    Map<String, dynamic>? queryParams,
  }) async {}
}

class _FakeAnalyticsService extends AnalyticsService {
  final List<(String x, String y)> calls = [];

  _FakeAnalyticsService(super.apiClient);

  @override
  Future<Map<String, dynamic>> fetchMetrics({
    required int planId,
    required String metricX,
    required String metricY,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    calls.add((metricX, metricY));
    return {
      'items': [
        {
          'date': '2026-11-01',
          'values': {'volume': 0.0, 'effort': 6.0, 'kpsh': 10.0, 'reps': 12.0},
        },
        {
          'date': '2026-11-03',
          'values': {'volume': 2400.0, 'effort': 8.5, 'kpsh': 24.0, 'reps': 30.0},
        },
      ],
      'one_rm': [
        {'date': '2026-11-01', 'value': 100.0},
        {'date': '2026-11-03', 'value': 105.0},
      ],
    };
  }
}

Workout _buildSampleWorkout() {
  return Workout(
    id: 42,
    name: 'Heavy Push Hypertrophy Session Alpha',
    status: 'scheduled',
    scheduledFor: DateTime.now(),
    exerciseInstances: const [
      ExerciseInstance(
        id: 101,
        exerciseListId: 10,
        sets: [
          ExerciseSetDto(id: 1, reps: 5, weight: 100, rpe: 8.5),
          ExerciseSetDto(id: 2, reps: 5, weight: 105, rpe: 9.0),
        ],
      ),
    ],
  );
}

void main() {
  group('InstrumentTheme', () {
    test('colorForRpe distinguishes light, moderate, peak, and null effort', () {
      const theme = InstrumentTheme.light;
      final scheme = ColorScheme.fromSeed(seedColor: Colors.blue);

      final cNull = theme.colorForRpe(null, scheme);
      final cLight = theme.colorForRpe(6.5, scheme);
      final cModerate = theme.colorForRpe(8.0, scheme);
      final cPeak = theme.colorForRpe(9.5, scheme);

      expect(cNull, scheme.onSurfaceVariant);
      expect(cLight, theme.lightEffortColor);
      expect(cModerate, theme.moderateEffortColor);
      expect(cPeak, theme.peakEffortColor);
      expect({cNull, cLight, cModerate, cPeak}.length, 4);
    });
  });

  group('Wave 1 Instrument UI responsive & density matrix', () {
    for (final brightness in [Brightness.light, Brightness.dark]) {
      for (final density in UiDensity.values) {
        testWidgets(
          'renders Wave 1 widgets cleanly at 320px width & 2.0 textScale ($brightness, $density)',
          (tester) async {
            await tester.binding.setSurfaceSize(const Size(320, 700));
            addTearDown(() => tester.binding.setSurfaceSize(null));

            final weightCtrl = TextEditingController(text: '100');
            final repsCtrl = TextEditingController(text: '5');
            final rpeCtrl = TextEditingController(text: '8.5');
            final elapsed = ValueNotifier<Duration>(const Duration(minutes: 12, seconds: 34));
            addTearDown(() {
              weightCtrl.dispose();
              repsCtrl.dispose();
              rpeCtrl.dispose();
              elapsed.dispose();
            });

            final workout = _buildSampleWorkout();
            final appTheme = brightness == Brightness.dark
                ? AppTheme.darkTheme(density: density)
                : AppTheme.lightTheme(density: density);

            await tester.pumpWidget(
              MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                theme: appTheme,
                home: MediaQuery(
                  data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
                  child: Scaffold(
                    body: ListView(
                      padding: const EdgeInsets.all(10),
                      children: [
                        NextWorkoutInstrumentCard(
                          workout: workout,
                          onOpenWorkout: () {},
                          onOpenPlan: () {},
                        ),
                        const SizedBox(height: 8),
                        NextWorkoutInstrumentCard(
                          workout: null,
                          onOpenWorkout: null,
                          onOpenPlan: () {},
                        ),
                        const SizedBox(height: 8),
                        WorkoutLibraryCard(
                          workout: workout,
                          onTap: () {},
                          onDelete: () {},
                        ),
                        const SizedBox(height: 8),
                        WorkoutExecutionHeaderBar(
                          isActiveSession: false,
                          isBusy: false,
                          canStartSession: true,
                          lastFinishedAt: null,
                          lastElapsed: Duration.zero,
                          elapsedListenable: elapsed,
                          formatDuration: (d) =>
                              '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}',
                          onStartSession: () {},
                          onCancelSession: () {},
                          onCompleteAllSets: () {},
                          onFinishSession: () {},
                          readinessScore: 8,
                          readinessFactor: 1.0,
                          isApplyingReadiness: false,
                          canApplyReadiness: true,
                          onDecrementReadiness: () {},
                          onIncrementReadiness: () {},
                          onApplyReadiness: () {},
                        ),
                        const SizedBox(height: 8),
                        WorkoutExecutionHeaderBar(
                          isActiveSession: true,
                          isBusy: false,
                          canStartSession: true,
                          lastFinishedAt: null,
                          lastElapsed: Duration.zero,
                          elapsedListenable: elapsed,
                          formatDuration: (d) =>
                              '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}',
                          onStartSession: () {},
                          onCancelSession: () {},
                          onCompleteAllSets: () {},
                          onFinishSession: () {},
                          readinessScore: 7,
                          readinessFactor: 0.975,
                          isApplyingReadiness: false,
                          canApplyReadiness: true,
                          onDecrementReadiness: () {},
                          onIncrementReadiness: () {},
                          onApplyReadiness: () {},
                        ),
                        const SizedBox(height: 8),
                        ExerciseSummaryHeader(
                          name: 'Barbell Bench Press Incline',
                          muscleGroup: 'Chest',
                          equipment: 'Barbell',
                          setCount: 3,
                          totalVolume: 1500,
                          onDeleteExercise: () {},
                        ),
                        const SetTableColumnHeaders(),
                        SetCapsuleRow(
                          setIndex: 0,
                          isCompleted: false,
                          canToggle: true,
                          isBusy: false,
                          weightController: weightCtrl,
                          repsController: repsCtrl,
                          rpeController: rpeCtrl,
                          currentRpeValue: 8.5,
                          autoDerivedField: 'weight',
                          onToggleCompletion: () {},
                          onDelete: () {},
                          onWeightChanged: (_) {},
                          onRepsChanged: (_) {},
                          onRpeChanged: (_) {},
                          onWeightSubmitted: () {},
                          onRepsSubmitted: () {},
                          onRpeSubmitted: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );

            await tester.pump();
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  });

  group('Data provenance & tap target guarantees', () {
    testWidgets('SetCapsuleRow displays AUTO badge only for autoDerivedField', (tester) async {
      final weightCtrl = TextEditingController(text: '80');
      final repsCtrl = TextEditingController(text: '8');
      final rpeCtrl = TextEditingController(text: '8');
      addTearDown(() {
        weightCtrl.dispose();
        repsCtrl.dispose();
        rpeCtrl.dispose();
      });

      Widget buildRow(String? derivedField) {
        return MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.darkTheme(density: UiDensity.compact),
          home: Scaffold(
            body: SetCapsuleRow(
              setIndex: 0,
              isCompleted: false,
              canToggle: true,
              isBusy: false,
              weightController: weightCtrl,
              repsController: repsCtrl,
              rpeController: rpeCtrl,
              currentRpeValue: 8.0,
              autoDerivedField: derivedField,
              onToggleCompletion: () {},
              onDelete: () {},
              onWeightChanged: (_) {},
              onRepsChanged: (_) {},
              onRpeChanged: (_) {},
              onWeightSubmitted: () {},
              onRepsSubmitted: () {},
              onRpeSubmitted: () {},
            ),
          ),
        );
      }

      await tester.pumpWidget(buildRow(null));
      expect(find.text('AUTO'), findsNothing);

      for (final field in ['weight', 'reps', 'rpe']) {
        await tester.pumpWidget(buildRow(field));
        expect(find.text('AUTO'), findsOneWidget);
      }
    });

    testWidgets('interactive buttons meet >= 48x48 minimum tap targets', (tester) async {
      final weightCtrl = TextEditingController(text: '80');
      final repsCtrl = TextEditingController(text: '8');
      final rpeCtrl = TextEditingController(text: '8');
      final elapsed = ValueNotifier<Duration>(Duration.zero);
      addTearDown(() {
        weightCtrl.dispose();
        repsCtrl.dispose();
        rpeCtrl.dispose();
        elapsed.dispose();
      });

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.darkTheme(density: UiDensity.compact),
          home: Scaffold(
            body: ListView(
              children: [
                WorkoutExecutionHeaderBar(
                  isActiveSession: false,
                  isBusy: false,
                  canStartSession: true,
                  lastFinishedAt: null,
                  lastElapsed: Duration.zero,
                  elapsedListenable: elapsed,
                  formatDuration: (_) => '00:00',
                  onStartSession: () {},
                  onCancelSession: () {},
                  onCompleteAllSets: () {},
                  onFinishSession: () {},
                  readinessScore: 10,
                  readinessFactor: 1.05,
                  isApplyingReadiness: false,
                  canApplyReadiness: true,
                  onDecrementReadiness: () {},
                  onIncrementReadiness: () {},
                  onApplyReadiness: () {},
                ),
                ExerciseSummaryHeader(
                  name: 'Squat',
                  muscleGroup: 'Legs',
                  equipment: 'Barbell',
                  setCount: 3,
                  totalVolume: 1200,
                  onDeleteExercise: () {},
                ),
                SetCapsuleRow(
                  setIndex: 0,
                  isCompleted: false,
                  canToggle: true,
                  isBusy: false,
                  weightController: weightCtrl,
                  repsController: repsCtrl,
                  rpeController: rpeCtrl,
                  currentRpeValue: 8.0,
                  autoDerivedField: null,
                  onToggleCompletion: () {},
                  onDelete: () {},
                  onWeightChanged: (_) {},
                  onRepsChanged: (_) {},
                  onRpeChanged: (_) {},
                  onWeightSubmitted: () {},
                  onRepsSubmitted: () {},
                  onRpeSubmitted: () {},
                ),
              ],
            ),
          ),
        ),
      );

      final checks = <String, Finder>{
        'Start': find
            .ancestor(
              of: find.text('Start'),
              matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
            )
            .first,
        'Apply': find
            .ancestor(
              of: find.text('Apply'),
              matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
            )
            .first,
        'Decrement readiness': find.widgetWithIcon(IconButton, Icons.remove),
        'Increment readiness': find.widgetWithIcon(IconButton, Icons.add),
        'Delete exercise':
            find.widgetWithIcon(IconButton, Icons.delete_outline_rounded),
        'Delete set': find.widgetWithIcon(IconButton, Icons.delete_outline),
        'Set checkbox': find.byType(Checkbox),
      };

      for (final entry in checks.entries) {
        final size = tester.getSize(entry.value);
        expect(size.width, greaterThanOrEqualTo(48), reason: '${entry.key} width');
        expect(size.height, greaterThanOrEqualTo(48), reason: '${entry.key} height');
      }
    });
  });

  group('Wave 2 Plan Instrument UI', () {
    testWidgets('CalendarPlanCard renders ACTIVE badge only for active plans', (
      tester,
    ) async {
      final activePlan = CalendarPlan(
        id: 1,
        name: 'Active Strength Cycle',
        schedule: const {},
        durationWeeks: 8,
        isActive: true,
        primaryGoal: 'strength',
        intendedFrequencyPerWeek: 4,
      );
      final templatePlan = CalendarPlan(
        id: 2,
        name: 'Template Cycle',
        schedule: const {},
        durationWeeks: 8,
        isActive: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.darkTheme(density: UiDensity.compact),
          home: Scaffold(
            body: Column(
              children: [
                CalendarPlanCard(plan: activePlan, onTap: () {}),
                CalendarPlanCard(plan: templatePlan, onTap: () {}),
              ],
            ),
          ),
        ),
      );

      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsNWidgets(2));
    });

    for (final brightness in [Brightness.light, Brightness.dark]) {
      for (final density in UiDensity.values) {
        testWidgets(
          'renders Wave 2 plan widgets at 320px & 2.0 textScale ($brightness, $density)',
          (tester) async {
            await tester.binding.setSurfaceSize(const Size(320, 700));
            addTearDown(() => tester.binding.setSurfaceSize(null));

            final plan = CalendarPlan(
              id: 7,
              name: 'Upper Lower Hypertrophy Telemetry Block',
              schedule: const {},
              durationWeeks: 12,
              isActive: true,
              primaryGoal: 'strength_hypertrophy',
              intendedExperienceLevel: 'intermediate-advanced',
              intendedFrequencyPerWeek: 4,
              sessionDurationTargetMin: 75,
              requiredEquipment: const ['Barbell', 'Dumbbells', 'Cable'],
              notes: 'Track RPE across all compounds.',
            );

            final appTheme = brightness == Brightness.dark
                ? AppTheme.darkTheme(density: density)
                : AppTheme.lightTheme(density: density);

            await tester.pumpWidget(
              MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                theme: appTheme,
                home: MediaQuery(
                  data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
                  child: Scaffold(
                    body: ListView(
                      padding: const EdgeInsets.all(10),
                      children: [
                        CalendarPlanCard(plan: plan, onTap: () {}),
                        const SizedBox(height: 8),
                        PlanPassportCard(
                          plan: plan,
                          adoptersLoading: false,
                          adoptersError: null,
                          adoptersCount: 42,
                          updatingPublic: false,
                          onPublicChanged: (_) {},
                        ),
                        const SizedBox(height: 8),
                        PlanVariantsBar(
                          currentPlanId: 7,
                          rootPlanId: 7,
                          variants: [
                            CalendarPlanSummary(
                              id: 7,
                              name: 'Original',
                              durationWeeks: 12,
                              isActive: true,
                              rootPlanId: 7,
                              isOriginal: true,
                            ),
                            CalendarPlanSummary(
                              id: 8,
                              name: '3-Day Volume Variant',
                              durationWeeks: 12,
                              isActive: false,
                              rootPlanId: 7,
                              isOriginal: false,
                            ),
                          ],
                          isLoading: false,
                          errorText: null,
                          onSelectOriginal: () {},
                          onSelectVariant: (_) {},
                          onCreateVariant: () {},
                        ),
                        const SizedBox(height: 8),
                        PlanAnalyticsInstrumentShell(
                          expanded: true,
                          pointsSummaryText: 'POINTS (S): 12',
                          onToggleExpanded: () {},
                          expandedChild: const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text('Chart body'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );

            await tester.pump();
            expect(tester.takeException(), isNull);

            await tester.scrollUntilVisible(
              find.byType(PlanAnalyticsInstrumentShell),
              200,
              scrollable: find.byType(Scrollable).first,
            );
            await tester.pump();
            expect(tester.takeException(), isNull);

            final toggleSize = tester.getSize(
              find.ancestor(
                of: find.byIcon(Icons.keyboard_arrow_up_rounded),
                matching: find.byType(IconButton),
              ),
            );
            expect(toggleSize.width, greaterThanOrEqualTo(48));
            expect(toggleSize.height, greaterThanOrEqualTo(48));
          },
        );
      }
    }
  });

  group('Wave 3 Analysis & Honest Chart UI', () {
    testWidgets(
      'PlanAnalyticsChart preserves 0.0 values, shows discrete dots, and distinguishes Planned vs Actual',
      (tester) async {
        const points = [
          PlanAnalyticsPoint(
            order: 0,
            label: 'D1',
            values: {'volume': 0.0},
            actualValues: {'volume': 0.0},
          ),
          PlanAnalyticsPoint(
            order: 1,
            label: 'D2',
            values: {'volume': 1200.0},
            actualValues: {'volume': 1350.0},
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.darkTheme(density: UiDensity.compact),
            home: const Scaffold(
              body: SizedBox(
                width: 360,
                height: 240,
                child: PlanAnalyticsChart(
                  points: points,
                  metricX: 'volume',
                  metricY: 'volume',
                ),
              ),
            ),
          ),
        );

        expect(find.text('PLANNED'), findsOneWidget);
        expect(find.text('ACTUAL'), findsOneWidget);

        final lineChart = tester.widget<LineChart>(find.byType(LineChart));
        final bars = lineChart.data.lineBarsData;
        expect(bars.length, 2);
        for (final bar in bars) {
          expect(bar.spots.length, 2, reason: '0.0 must not be dropped');
          expect(bar.spots.first.y, 0.0);
          expect(bar.isCurved, isFalse);
          expect(bar.dotData.show, isTrue);
        }
        expect(bars[0].dashArray, isNotNull);
        expect(bars[1].dashArray, isNull);
      },
    );

    testWidgets(
      'PlanAnalyticsChart scatter keeps paired 0.0 points without axis misalignment',
      (tester) async {
        const points = [
          PlanAnalyticsPoint(
            order: 0,
            label: 'D1',
            values: {'volume': 0.0, 'effort': 0.0},
          ),
          PlanAnalyticsPoint(
            order: 1,
            label: 'D2',
            values: {'volume': 500.0, 'effort': 8.0},
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.lightTheme(density: UiDensity.compact),
            home: const Scaffold(
              body: SizedBox(
                width: 360,
                height: 240,
                child: PlanAnalyticsChart(
                  points: points,
                  metricX: 'volume',
                  metricY: 'effort',
                ),
              ),
            ),
          ),
        );

        final scatter = tester.widget<ScatterChart>(find.byType(ScatterChart));
        expect(scatter.data.scatterSpots.length, 2);
        expect(scatter.data.scatterSpots.first.x, 0.0);
        expect(scatter.data.scatterSpots.first.y, 0.0);
      },
    );

    testWidgets(
      'AnalyticsScreen collapses date picker by default, auto-loads chart, and switches metrics reactively at 320px & 2.0 textScale',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 700));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final apiClient = _FakeAnalyticsApiClient();
        final analyticsSvc = _FakeAnalyticsService(apiClient);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              apiClientProvider.overrideWithValue(apiClient),
              analyticsServiceProvider.overrideWithValue(analyticsSvc),
            ],
            child: MaterialApp(
              theme: AppTheme.darkTheme(density: UiDensity.compact),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('en'),
              home: MediaQuery(
                data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
                child: const AnalyticsScreen(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(analyticsSvc.calls, [('volume', 'volume')]);
        expect(find.byType(TableCalendar<dynamic>), findsNothing);
        expect(find.byType(LineChart), findsOneWidget);

        // Tap ChoiceChip for effort -> reactive refetch in Trend mode
        final effortChip = find.text('Effort (RPE)').first;
        await tester.ensureVisible(effortChip);
        await tester.tap(effortChip);
        await tester.pumpAndSettle();
        expect(analyticsSvc.calls.last, ('effort', 'effort'));
        expect(tester.takeException(), isNull);

        // Tap to expand calendar
        final dateToggle = find.byTooltip('Select date range');
        await tester.ensureVisible(dateToggle);
        await tester.tap(dateToggle);
        await tester.pumpAndSettle();
        expect(find.byType(TableCalendar<dynamic>), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('Wave 4 Residual Screens UI', () {
    testWidgets(
      'SessionInstrumentCard renders status and tabular metrics cleanly at 320px & 2.0 textScale',
      (tester) async {
        tester.view.physicalSize = const Size(320, 700);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final session = WorkoutSession(
          id: 42,
          workoutId: 7,
          startedAt: DateTime(2026, 11, 10, 9, 30),
          finishedAt: DateTime(2026, 11, 10, 10, 15),
          status: 'completed',
          durationSeconds: 2700,
          progress: const {
            'completed': {
              '101': [1, 2, 3],
              '102': [1, 2],
            },
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.lightTheme(density: UiDensity.compact),
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
              child: Scaffold(
                body: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    SessionInstrumentCard(session: session, onTap: () {}),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('SESSION #42'), findsOneWidget);
        expect(find.text('COMPLETED'), findsOneWidget);
        expect(find.text('2700 s'), findsOneWidget);
        expect(find.text('5'), findsOneWidget);
      },
    );

    testWidgets(
      'PlanMicrocycleEditor wraps action bar and tabular set cells cleanly at 320px & 2.0 textScale',
      (tester) async {
        tester.view.physicalSize = const Size(320, 720);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final micro = Microcycle(
          id: 1,
          mesocycleId: 10,
          name: 'Week 1 Accumulation',
          orderIndex: 1,
          schedule: const {},
          planWorkouts: [
            PlanWorkout(
              id: 11,
              microcycleId: 1,
              dayLabel: 'Day 1 · Upper Heavy',
              orderIndex: 1,
              exercises: [
                PlanExercise(
                  id: 21,
                  exerciseDefinitionId: 301,
                  exerciseName: 'Bench Press Competition Pause',
                  orderIndex: 1,
                  sets: [
                    const PlanSet(
                      id: 100,
                      intensity: 82,
                      effort: 8,
                      volume: 5,
                    ),
                  ],
                ),
              ],
            ),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.darkTheme(density: UiDensity.compact),
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
              child: PlanMicrocycleEditor(microcycle: micro),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('Day 1 · Upper Heavy'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Bench Press Competition Pause'), findsOneWidget);
        expect(find.text('Replace'), findsOneWidget);
        expect(find.text('Set'), findsOneWidget);
        expect(find.text('Bulk'), findsOneWidget);
      },
    );

    testWidgets(
      'Wave 5 chrome shells render hairline glass without ambient box shadows',
      (tester) async {
        for (final brightness in [Brightness.dark, Brightness.light]) {
          final theme = brightness == Brightness.dark
              ? AppTheme.darkTheme(density: UiDensity.compact)
              : AppTheme.lightTheme(density: UiDensity.compact);
          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: theme,
              home: Scaffold(
                appBar: PrimaryAppBar.main(
                  title: 'Workouts',
                  onTitleTap: () {},
                ),
                body: Stack(
                  children: [
                    const Center(child: Text('Body')),
                    FloatingHeaderBar(
                      title: 'Profile',
                      onTitleTap: () {},
                      onProfileTap: () {},
                    ),
                  ],
                ),
                bottomNavigationBar: CustomBottomNavBar(
                  currentIndex: 0,
                  onTap: (_) {},
                  items: const [
                    BottomNavBarItem(
                      icon: Icons.fitness_center,
                      label: 'Workouts',
                    ),
                    BottomNavBarItem(
                      icon: Icons.calendar_today,
                      label: 'Plans',
                    ),
                  ],
                ),
              ),
            ),
          );
          await tester.pump();
          expect(tester.takeException(), isNull);

          final decorated = tester.widgetList<DecoratedBox>(find.byType(DecoratedBox));
          for (final widget in decorated) {
            final deco = widget.decoration;
            if (deco is BoxDecoration) {
              expect(deco.boxShadow ?? const [], isEmpty);
            }
          }
        }
      },
    );

    testWidgets(
      'Wave 3 Blueprint A WorkoutHeroInstrumentCard & WorkoutLibraryInstrumentModule enforce Max Border Depth = 1, switch spark metric, and fit 320px @ 2.0x',
      (tester) async {
        final workout = _buildSampleWorkout();
        final env = TrainingEnvironmentData.fromWorkout(workout);
        MetricSlot? tappedSlot;

        await tester.binding.setSurfaceSize(const Size(320, 760));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.darkTheme(density: UiDensity.compact),
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(320, 760),
                textScaler: TextScaler.linear(2.0),
              ),
              child: AmbientScaffoldShell(
                environment: env,
                appBar: FloatingHeaderBar(
                  title: 'Тренировки',
                  onTitleTap: () {},
                  onProfileTap: () {},
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12, 88, 12, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      WorkoutHeroInstrumentCard(
                        workout: workout,
                        environment: env,
                        slots: const [
                          MetricSlot.peakIntensity,
                          MetricSlot.e1rm,
                          MetricSlot.peakRpe,
                          MetricSlot.kpsh,
                        ],
                        onSelectSlot: (slot) => tappedSlot = slot,
                        onOpenWorkout: () {},
                        onOpenPlan: () {},
                      ),
                      const SizedBox(height: 16),
                      WorkoutLibraryInstrumentModule(
                        workouts: [workout],
                        onRetry: () {},
                        onCreateWorkout: () {},
                        onOpenWorkout: (_) {},
                        onDeleteWorkout: (_) async {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 450));
        expect(tester.takeException(), isNull);

        // Max Border Depth = 1 inside WorkoutHeroInstrumentCard (outer card only).
        final heroContainers = tester.widgetList<Container>(
          find.descendant(
            of: find.byType(WorkoutHeroInstrumentCard),
            matching: find.byType(Container),
          ),
        );
        final heroBorders = heroContainers.where((c) {
          final d = c.decoration;
          return d is BoxDecoration &&
              d.border != null &&
              d.shape == BoxShape.rectangle;
        }).toList();
        expect(heroBorders.length, 1);

        // Max Border Depth = 1 inside WorkoutLibraryInstrumentModule (outer card only).
        final libContainers = tester.widgetList<Container>(
          find.descendant(
            of: find.byType(WorkoutLibraryInstrumentModule),
            matching: find.byType(Container),
          ),
        );
        final libBorders = libContainers.where((c) {
          final d = c.decoration;
          return d is BoxDecoration &&
              d.border != null &&
              d.shape == BoxShape.rectangle;
        }).toList();
        expect(libBorders.length, 1);

        // Tapping a matrix cell switches the spark wave immediately.
        await tester.tap(find.text('REPS'));
        await tester.pump(const Duration(milliseconds: 450));
        expect(tappedSlot, MetricSlot.kpsh);
        expect(find.text('SESSION WAVE · REPS'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Wave 3 liveExecution AmbientScaffoldShell + WorkoutExecutionHeaderBar with InstrumentMetricMatrix + AUTO badge renders cleanly at 320px @ 2.0x',
      (tester) async {
        final workout = _buildSampleWorkout();
        final liveEnv = TrainingEnvironmentData.fromWorkout(
          workout,
          isLiveExecution: true,
        );
        expect(liveEnv.state, TrainingEnvironmentState.liveExecution);

        final elapsed = ValueNotifier<Duration>(const Duration(minutes: 14, seconds: 25));
        addTearDown(elapsed.dispose);

        await tester.binding.setSurfaceSize(const Size(320, 760));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.darkTheme(density: UiDensity.compact),
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(320, 760),
                textScaler: TextScaler.linear(2.0),
              ),
              child: AmbientScaffoldShell(
                environment: liveEnv,
                appBar: FloatingHeaderBar(
                  title: workout.name,
                  onTitleTap: () {},
                  onProfileTap: () {},
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 84, bottom: 24),
                  child: WorkoutExecutionHeaderBar(
                    isActiveSession: true,
                    isBusy: false,
                    canStartSession: true,
                    lastFinishedAt: null,
                    lastElapsed: elapsed.value,
                    elapsedListenable: elapsed,
                    formatDuration: (d) =>
                        '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}',
                    onStartSession: () {},
                    onCancelSession: () {},
                    onCompleteAllSets: () {},
                    onFinishSession: () {},
                    readinessScore: 8,
                    readinessFactor: 1.0,
                    isApplyingReadiness: false,
                    canApplyReadiness: true,
                    onDecrementReadiness: () {},
                    onIncrementReadiness: () {},
                    onApplyReadiness: () {},
                    footerSlot: InstrumentMetricMatrix(
                      accentColor: liveEnv.accentColor(
                        InstrumentTheme.dark,
                      ),
                      cells: const [
                        InstrumentMetricCellData(
                          slot: MetricSlot.tonnage,
                          value: '4500 kg',
                        ),
                        InstrumentMetricCellData(
                          slot: MetricSlot.e1rm,
                          value: '185 kg',
                          isAutoDerived: true,
                        ),
                        InstrumentMetricCellData(
                          slot: MetricSlot.peakRpe,
                          value: 'RPE 9.5',
                        ),
                        InstrumentMetricCellData(
                          slot: MetricSlot.setsCount,
                          value: '16',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('AUTO'), findsOneWidget);
        expect(find.text('4500 kg'), findsOneWidget);
        expect(find.text('185 kg'), findsOneWidget);
      },
    );
  });

  group('Waves 1-5 Cross-Wave Instrument Audit at 320px @ 2.0x & Static Regression Gate', () {
    testWidgets(
      'Wave 1 ToolResultCard and Wave 5 ReviewCard keep Max Border Depth = 1 without overflow at 320px @ 2.0x',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 760));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final review = CoachReview(
          id: 1,
          linkId: 2,
          reviewerId: 'ath-1',
          reviewerName: 'Jordan',
          coachId: 'coach-1',
          rating: 5,
          comment: 'Consistent block periodization and crisp check-ins.',
          createdAt: DateTime(2026, 4, 20),
          updatedAt: DateTime(2026, 4, 20),
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.darkTheme(),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: MediaQuery(
                data: const MediaQueryData(
                  size: Size(320, 760),
                  textScaler: TextScaler.linear(2.0),
                ),
                child: Scaffold(
                  body: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      ToolResultCard(
                        title: 'Mass Edit Preview',
                        icon: Icons.tune,
                        isPreview: true,
                        content: const Text('3 workouts adjusted (+2.5%)'),
                      ),
                      const SizedBox(height: 16),
                      ReviewCard(review: review),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(Card), findsNothing);

        final toolBorders = tester
            .widgetList<Container>(
              find.descendant(
                of: find.byType(ToolResultCard),
                matching: find.byType(Container),
              ),
            )
            .where((c) {
              final d = c.decoration;
              return d is BoxDecoration &&
                  d.border != null &&
                  d.shape == BoxShape.rectangle;
            })
            .toList();
        expect(toolBorders.length, 1);

        final reviewBorders = tester
            .widgetList<Container>(
              find.descendant(
                of: find.byType(ReviewCard),
                matching: find.byType(Container),
              ),
            )
            .where((c) {
              final d = c.decoration;
              return d is BoxDecoration &&
                  d.border != null &&
                  d.shape == BoxShape.rectangle;
            })
            .toList();
        expect(reviewBorders.length, 1);
      },
    );

    testWidgets(
      'Wave 2 SettingsLegalScreen over GlobalAmbientStage renders cleanly at 320px @ 2.0x',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 760));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.darkTheme(),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  disableAnimations: true,
                  size: const Size(320, 760),
                  textScaler: const TextScaler.linear(2.0),
                ),
                child: GlobalAmbientStage(
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
              home: const SettingsLegalScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(AmbientScaffoldShell), findsOneWidget);
        expect(find.byType(Card), findsNothing);
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).last);
        expect(scaffold.backgroundColor, Colors.transparent);
      },
    );

    testWidgets(
      'Wave 3 MacroHumanPreview renders cleanly with tabular figures at 320px @ 2.0x',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 760));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              target_dp.exerciseDefinitionsProvider.overrideWith(
                (ref) async => const [],
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.darkTheme(),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const MediaQuery(
                data: MediaQueryData(
                  size: Size(320, 760),
                  textScaler: TextScaler.linear(2.0),
                ),
                child: Scaffold(
                  body: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: MacroHumanPreview(
                      trigger: {
                        'metric': 'RPE',
                        'threshold': 9,
                        'op': '>=',
                      },
                      condition: {},
                      action: {
                        'target': {'all': true},
                        'type': 'Adjust_Load',
                        'params': {'weight_delta_percent': -5},
                      },
                      duration: {'scope': 'Next_N_Workouts', 'count': 2},
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
    );

    test(
      'Static hygiene gate: Waves 1-5 migrated files contain zero AlertDialog, FilterChip, or hardcoded Colors.red/green/grey',
      () {
        final libDir = Directory('lib');
        if (!libDir.existsSync()) {
          fail('Expected lib/ directory relative to flutter_app test runner');
        }

        const migratedFiles = <String>[
          'lib/widgets/instrument_modal.dart',
          'lib/widgets/plan_catalog_filters.dart',
          'lib/widgets/calendar_plan_apply_confirmation.dart',
          'lib/widgets/calendar_plan_delete_dialog.dart',
          'lib/widgets/review_form_dialog.dart',
          'lib/widgets/assistant_chat_overlay.dart',
          'lib/widgets/chat_tools/mass_edit_tool_widget.dart',
          'lib/widgets/chat_tools/schedule_shift_tool_widget.dart',
          'lib/widgets/empty_state.dart',
          'lib/widgets/error_message.dart',
          'lib/widgets/loading_indicator.dart',
          'lib/widgets/activity_heatmap_colors.dart',
          'lib/src/widgets/snack_utils.dart',
          'lib/screens/settings/settings_home_screen.dart',
          'lib/screens/settings/settings_general_screen.dart',
          'lib/screens/settings/settings_import_screen.dart',
          'lib/screens/settings/settings_legal_screen.dart',
          'lib/screens/debug_screen.dart',
          'lib/screens/debug/amplitude_test_screen.dart',
          'lib/screens/macros/macros_list_screen.dart',
          'lib/screens/macros/macro_editor_screen.dart',
          'lib/screens/macros/macros_preview_screen.dart',
          'lib/screens/macros/widgets/action_builder.dart',
          'lib/screens/macros/widgets/condition_builder.dart',
          'lib/screens/macros/widgets/duration_selector.dart',
          'lib/screens/macros/widgets/macro_human_preview.dart',
          'lib/screens/macros/widgets/target_selector.dart',
          'lib/screens/macros/widgets/trigger_builder.dart',
          'lib/screens/macros/widgets/workout_picker.dart',
          'lib/screens/nutrition_plans_list.dart',
          'lib/screens/nutrition_plan_active.dart',
          'lib/screens/nutrition_plan_detail.dart',
          'lib/screens/nutrition_plan_create.dart',
          'lib/screens/workout_list_screen.dart',
          'lib/screens/workout_session_history_screen.dart',
          'lib/screens/exercise_list_screen.dart',
          'lib/screens/exercise_form_screen.dart',
          'lib/screens/exercise_selection_screen.dart',
          'lib/screens/exercise_detail_screen.dart',
          'lib/screens/user_max_widget.dart',
          'lib/widgets/workout_detail/workout_header.dart',
          'lib/widgets/mode_value_control.dart',
          'lib/screens/coach/coach_dashboard_screen.dart',
          'lib/screens/coach/coach_athletes_screen.dart',
          'lib/screens/coach/athlete_detail_screen.dart',
          'lib/screens/coach_athlete_plan_screen.dart',
          'lib/screens/coach/coach_relationships_screen.dart',
          'lib/screens/coach/coach_chat_screen.dart',
          'lib/screens/coaching/my_coaches_screen.dart',
          'lib/screens/all_users_screen.dart',
          'lib/screens/public_user_profile_screen.dart',
          'lib/screens/social/social_feed_screen.dart',
          'lib/widgets/review_card.dart',
          'lib/widgets/coach_rating_display.dart',
          'lib/widgets/user_profile_view.dart',
          'lib/widgets/profile_sections.dart',
        ];

        final forbiddenPattern = RegExp(
          r'\bAlertDialog\b|\bFilterChip\b|\bColors\.(red|green|grey)\b',
        );
        final violations = <String>[];

        for (final relativePath in migratedFiles) {
          final file = File(relativePath);
          expect(file.existsSync(), isTrue, reason: 'Missing $relativePath');
          final lines = file.readAsLinesSync();
          for (var i = 0; i < lines.length; i++) {
            final trimmed = lines[i].trimLeft();
            if (trimmed.startsWith('///') || trimmed.startsWith('//')) {
              continue;
            }
            if (forbiddenPattern.hasMatch(lines[i])) {
              violations.add('$relativePath:${i + 1}: ${trimmed}');
            }
          }
        }

        expect(violations, isEmpty, reason: violations.join('\n'));
      },
    );
  });
}
