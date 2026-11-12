import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/config/api_config.dart';
import 'package:workout_app/services/api_client.dart';
import 'package:workout_app/services/base_api_service.dart';
import 'package:workout_app/src/api/plan_api.dart';
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
}
