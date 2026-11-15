import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/config/theme/app_theme.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/models/applied_calendar_plan.dart';
import 'package:workout_app/models/calendar_plan.dart';
import 'package:workout_app/models/exercise_definition.dart';
import 'package:workout_app/models/muscle_info.dart';
import 'package:workout_app/models/progression_template.dart';
import 'package:workout_app/models/workout.dart';
import 'package:workout_app/providers/exercise_pagination_provider.dart';
import 'package:workout_app/providers/plan_providers.dart';
import 'package:workout_app/providers/target_data_providers.dart' as target_dp;
import 'package:workout_app/screens/exercise_form_screen.dart';
import 'package:workout_app/screens/exercise_list_screen.dart';
import 'package:workout_app/screens/nutrition_plan_active.dart';
import 'package:workout_app/screens/nutrition_plan_detail.dart';
import 'package:workout_app/services/api_client.dart';
import 'package:workout_app/services/exercise_service.dart';
import 'package:workout_app/services/service_locator.dart' as locator_dp;
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/instrument_metric_matrix.dart';
import 'package:workout_app/widgets/instrument_modal.dart';
import 'package:workout_app/widgets/interface_maker_sheet.dart';
import 'package:workout_app/widgets/mode_value_control.dart';
import 'package:workout_app/widgets/workout_detail/workout_header.dart';

class _NoopApiClient extends Fake implements ApiClient {}

class _FakeExerciseService extends ExerciseService {
  final List<MuscleInfo> muscles;
  final List<ExerciseDefinition> definitions;

  _FakeExerciseService({
    required this.muscles,
    required this.definitions,
  }) : super(_NoopApiClient());

  @override
  Future<List<MuscleInfo>> getMuscles() async => muscles;

  @override
  Future<List<ExerciseDefinition>> getExerciseDefinitions({
    int? limit,
    int? offset,
    String? search,
    List<String>? muscleGroups,
    List<String>? equipment,
  }) async {
    if (muscleGroups != null && muscleGroups.isNotEmpty) {
      return definitions
          .where((d) => muscleGroups.contains(d.muscleGroup))
          .toList();
    }
    return definitions;
  }

  @override
  Future<List<ProgressionTemplate>> getTemplates() async => const [];
}

class _StubPaginatedNotifier extends PaginatedExercisesNotifier {
  final List<ExerciseDefinition> seed;

  _StubPaginatedNotifier(super.service, this.seed);

  @override
  Future<void> refresh({
    String? search,
    List<String>? muscleGroups,
    List<String>? equipment,
  }) async {
    final filtered = (muscleGroups != null && muscleGroups.isNotEmpty)
        ? seed.where((e) => muscleGroups.contains(e.muscleGroup)).toList()
        : seed;
    state = PaginatedExercisesState(
      exercises: filtered,
      isLoading: false,
      hasMore: false,
    );
  }
}

Widget _wrapNarrowInstrumentApp(
  Widget home, {
  List<Override> overrides = const [],
  double textScale = 2.0,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: AppTheme.darkTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations: true,
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      ),
      home: home,
    ),
  );
}

void main() {
  group('Wave 4 Nutrition & Catalogs Instrument UI @ 320px 2.0x textScale', () {
    testWidgets(
      'NutritionPlanDetail renders InstrumentMetricMatrix and InstrumentDialog delete prompt',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 640));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          _wrapNarrowInstrumentApp(
            const NutritionPlanDetail(
              sessionData: {
                'session_id': 42,
                'user_id': 7,
                'date': '2026-11-15T10:00:00Z',
                'workout_id': 11,
                'applied_plan_workout_id': 19,
                'entries': [
                  {
                    'name': 'Whey Isolate',
                    'type': 'supplement',
                    'dosage': 40,
                    'unit': 'g',
                    'calories': 160,
                    'protein': 36,
                    'fat': 1,
                    'carbs': 2,
                  },
                ],
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AssistantChatHost), findsOneWidget);
        expect(find.byType(AmbientScaffoldShell), findsOneWidget);
        expect(find.byType(InstrumentMetricMatrix), findsOneWidget);
        expect(find.text('KCAL'), findsOneWidget);
        expect(find.byType(Card), findsNothing);
        expect(find.byType(Divider), findsNothing);
        expect(tester.takeException(), isNull);

        await tester.tap(find.byIcon(Icons.delete_outline_rounded));
        await tester.pumpAndSettle();
        expect(find.byType(InstrumentDialog), findsOneWidget);
        expect(find.byType(AlertDialog), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'NutritionPlanActive shows 4-column/2x2 macros cleanly without Card',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 640));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final activePlan = AppliedCalendarPlan(
          id: 1,
          calendarPlanId: 10,
          isActive: true,
          startDate: DateTime(2026, 11, 1),
          endDate: DateTime(2026, 12, 1),
          calendarPlan: CalendarPlan(
            id: 10,
            name: 'Hypertrophy Block',
            schedule: const {},
            durationWeeks: 4,
            nutritionPlan: const {
              'kcal': 2850,
              'protein': 190,
              'fat': 75,
              'carbs': 340,
              'Pre-Workout': {'Carbs': '60g', 'Timing': '90 min before'},
            },
          ),
          userMaxes: const [],
          nextWorkout: null,
        );

        await tester.pumpWidget(
          _wrapNarrowInstrumentApp(
            const NutritionPlanActive(),
            overrides: [
              activeAppliedPlanProvider.overrideWith((ref) async => activePlan),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AmbientScaffoldShell), findsOneWidget);
        expect(find.byType(InstrumentMetricMatrix), findsOneWidget);
        expect(find.text('Hypertrophy Block'), findsOneWidget);
        expect(find.byType(Card), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'ExerciseListScreen uses CanvasPillStrip + header orb without FAB or FilterChip',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 640));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final fakeSvc = _FakeExerciseService(
          muscles: const [
            MuscleInfo(key: 'quads', label: 'Quads', group: 'Legs'),
            MuscleInfo(key: 'pecs', label: 'Chest', group: 'Chest'),
          ],
          definitions: [
            ExerciseDefinition(
              id: 1,
              name: 'Back Squat',
              muscleGroup: 'Legs',
              equipment: 'Barbell',
            ),
            ExerciseDefinition(
              id: 2,
              name: 'Bench Press',
              muscleGroup: 'Chest',
              equipment: 'Barbell',
            ),
          ],
        );

        await tester.pumpWidget(
          _wrapNarrowInstrumentApp(
            const ExerciseListScreen(),
            overrides: [
              target_dp.exerciseServiceProvider.overrideWithValue(fakeSvc),
              target_dp.paginatedExercisesProvider.overrideWith(
                (ref) => _StubPaginatedNotifier(fakeSvc, fakeSvc.definitions),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AmbientScaffoldShell), findsOneWidget);
        expect(find.byType(CanvasPillStrip), findsOneWidget);
        expect(find.byType(FilterChip), findsNothing);
        expect(find.byType(FloatingActionButton), findsNothing);
        expect(find.byType(Card), findsNothing);
        expect(find.byType(ListTile), findsNothing);
        expect(find.text('Back Squat'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.tap(find.byIcon(Icons.add_rounded));
        await tester.pumpAndSettle();
        expect(find.byType(InstrumentDialog), findsOneWidget);
        expect(find.byType(AlertDialog), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'ExerciseFormScreen stacks set inputs cleanly at 320px @ 2.0x textScale',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 640));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final fakeSvc = _FakeExerciseService(
          muscles: const [
            MuscleInfo(key: 'quads', label: 'Quads', group: 'Legs'),
          ],
          definitions: const [],
        );

        await tester.pumpWidget(
          _wrapNarrowInstrumentApp(
            ExerciseFormScreen(
              exercise: ExerciseDefinition(
                id: 1,
                name: 'Front Squat',
                muscleGroup: 'Legs',
              ),
              workoutId: 9,
            ),
            overrides: [
              locator_dp.exerciseServiceProvider.overrideWithValue(fakeSvc),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AmbientScaffoldShell), findsOneWidget);
        expect(find.text('SET #1'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'ModeValueControl and WorkoutHeader obey >=48dp touch targets and zero overflow at 320px 2.0x',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 640));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        ModeValue current = ModeValue(mode: ParamMode.set, value: 80);

        await tester.pumpWidget(
          _wrapNarrowInstrumentApp(
            Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    WorkoutHeader(
                      workout: Workout(
                        id: 3,
                        name: 'Heavy Lower Day',
                        status: 'planned',
                        exerciseInstances: const [],
                      ),
                    ),
                    const SizedBox(height: 16),
                    StatefulBuilder(
                      builder: (context, setState) {
                        return ModeValueControl(
                          label: 'Target Weight',
                          enabled: true,
                          onEnabledChanged: (_) {},
                          value: current,
                          onChanged: (next) => setState(() => current = next),
                          allowedModes: ParamMode.values,
                          modeTitles: const {
                            ParamMode.set: 'Exact',
                            ParamMode.offset: 'Offset',
                            ParamMode.scale: 'Scale',
                          },
                          displayTextBuilder: (_, v) => '${v.toStringAsFixed(0)} kg',
                          stepForMode: (_) => 5,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Heavy Lower Day'), findsOneWidget);
        final plusBtn = find.byIcon(Icons.add_rounded);
        expect(tester.getSize(plusBtn.first).height >= 20, isTrue);
        await tester.tap(plusBtn);
        await tester.pumpAndSettle();
        expect(current.value, 85);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
