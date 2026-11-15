import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_app/config/api_config.dart';
import 'package:workout_app/config/theme/app_theme.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/models/calendar_plan.dart';
import 'package:workout_app/models/user_max.dart';
import 'package:workout_app/services/api_client.dart';
import 'package:workout_app/services/base_api_service.dart';
import 'package:workout_app/src/api/plan_api.dart';
import 'package:workout_app/src/widgets/apply_plan_widget.dart';
import 'package:workout_app/widgets/calendar_plan_apply_confirmation.dart';

class _ApplyApi extends ApiClient {
  final bool asyncMode;
  final List<Map<String, dynamic>?> requests = [];
  _ApplyApi({this.asyncMode = true});

  @override
  Future<dynamic> post(
    String endpoint,
    dynamic data, {
    Map<String, dynamic>? queryParams,
    String? context,
    Duration timeout = const Duration(seconds: ApiConfig.receiveTimeout),
  }) async {
    requests.add(queryParams);
    return asyncMode ? {'task_id': 'queued'} : <dynamic>[];
  }

  @override
  Future<void> invalidateCacheGroups(Iterable<String> groups) async {}
}

void main() {
  Future<void> open(
    WidgetTester tester,
    Future<String> Function(bool) submit,
    ValueChanged<Object?> result,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                try {
                  result(
                    await applyPlanWithConfirmation<String>(
                      context,
                      submit: submit,
                    ),
                  );
                } catch (error) {
                  result(error);
                }
              },
              child: const Text('Apply'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
  }

  testWidgets('first application sends no replacement and shows no dialog', (
    tester,
  ) async {
    final calls = <bool>[];
    Object? result;
    await open(tester, (replace) async {
      calls.add(replace);
      return 'queued';
    }, (value) => result = value);
    expect(calls, [false]);
    expect(result, 'queued');
    expect(find.byType(AlertDialog), findsNothing);
  });

  for (final confirm in [false, true]) {
    testWidgets('409 asks before replacement; confirm=$confirm', (
      tester,
    ) async {
      final calls = <bool>[];
      Object? result = 'pending';
      await open(tester, (replace) async {
        calls.add(replace);
        if (!replace)
          throw ApiException('An active plan already exists', statusCode: 409);
        return 'queued';
      }, (value) => result = value);
      expect(calls, [false]);
      expect(find.text('Заменить активный план?'), findsOneWidget);
      await tester.tap(find.text(confirm ? 'Заменить план' : 'Отмена'));
      await tester.pumpAndSettle();
      expect(calls, confirm ? [false, true] : [false]);
      expect(result, confirm ? 'queued' : null);
    });
  }

  testWidgets('server failure does not offer replacement or retry', (
    tester,
  ) async {
    final calls = <bool>[];
    Object? result;
    await open(tester, (replace) async {
      calls.add(replace);
      throw ApiException('Server unavailable', statusCode: 503);
    }, (value) => result = value);
    expect(calls, [false]);
    expect(result, isA<ApiException>());
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('replacement failure propagates without another confirmation', (
    tester,
  ) async {
    final calls = <bool>[];
    Object? result;
    await open(tester, (replace) async {
      calls.add(replace);
      throw ApiException('Conflict', statusCode: 409);
    }, (value) => result = value);
    await tester.tap(find.text('Заменить план'));
    await tester.pumpAndSettle();
    expect(calls, [false, true]);
    expect(result, isA<ApiException>());
    expect(find.byType(AlertDialog), findsNothing);
  });

  for (final asyncMode in [false, true]) {
    test(
      'API forwards flag only for explicit replacement; async=$asyncMode',
      () async {
        final api = _ApplyApi(asyncMode: asyncMode);
        for (final replace in [false, true]) {
          if (asyncMode) {
            await PlanApi.applyPlanAsync(
              planId: 7,
              userMaxIds: [1],
              computeWeights: false,
              roundingStep: 2.5,
              roundingMode: 'nearest',
              replaceActive: replace,
              apiClient: api,
            );
          } else {
            await PlanApi.applyPlan(
              planId: 7,
              userMaxIds: [1],
              computeWeights: false,
              roundingStep: 2.5,
              roundingMode: 'nearest',
              replaceActive: replace,
              apiClient: api,
            );
          }
        }
        expect(api.requests[0], {'user_max_ids': '1'});
        expect(api.requests[1], {
          'user_max_ids': '1',
          'replace_active': 'true',
        });
      },
    );
  }

  testWidgets(
    'ApplyPlanWidget renders Adaptive Instrument sheet cleanly at 320px @ 2.0x and submits selected UserMax + rounding',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.binding.setSurfaceSize(const Size(320, 760));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      Map<String, dynamic>? submitted;
      final plan = CalendarPlan(
        id: 7,
        name: 'Strength 5/3/1',
        schedule: const {},
        durationWeeks: 6,
      );
      const userMaxes = [
        UserMax(
          id: 11,
          name: 'Bench 1RM',
          exerciseId: 42,
          exerciseName: 'Bench Press',
          maxWeight: 120,
          repMax: 1,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme(density: UiDensity.compact),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              size: const Size(320, 760),
              textScaler: const TextScaler.linear(2.0),
            ),
            child: child!,
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => ApplyPlanWidget(
                      plan: plan,
                      userMaxList: userMaxes,
                      allowedExerciseIds: const {42},
                      allowedExerciseNames: const {'bench press'},
                      planId: 7,
                      onApply: (payload) async {
                        submitted = payload;
                      },
                    ),
                  );
                },
                child: const Text('Open Sheet'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.byType(ExpansionTile), findsNothing);
      expect(find.byType(FilterChip), findsNothing);
      expect(find.text('PLAN APPLICATION'), findsOneWidget);
      expect(tester.takeException(), isNull);

      final scrollableFinder = find.byType(Scrollable).last;

      final pillFinder = find.text('120 кг × 1');
      await tester.scrollUntilVisible(pillFinder, 180, scrollable: scrollableFinder);
      await tester.pumpAndSettle();
      await tester.tap(pillFinder);
      await tester.pumpAndSettle();

      final ceilFinder = find.text('Вверх');
      await tester.scrollUntilVisible(ceilFinder, 180, scrollable: scrollableFinder);
      await tester.pumpAndSettle();
      await tester.tap(ceilFinder);
      await tester.pumpAndSettle();

      final applyBtn = find.widgetWithText(FilledButton, 'Применить план');
      await tester.scrollUntilVisible(applyBtn, 180, scrollable: scrollableFinder);
      await tester.pumpAndSettle();
      await tester.tap(applyBtn);
      await tester.pumpAndSettle();

      expect(submitted?['user_max_ids'], [11]);
      expect(submitted?['rounding_mode'], 'ceil');
      expect(submitted?['compute_weights'], true);
      expect(tester.takeException(), isNull);
    },
  );
}
