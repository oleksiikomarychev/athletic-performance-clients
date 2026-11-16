import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/config/api_config.dart';
import 'package:workout_app/models/calendar_plan.dart';
import 'package:workout_app/services/api_client.dart';
import 'package:workout_app/services/base_api_service.dart';
import 'package:workout_app/widgets/calendar_plan_delete_dialog.dart';

class _DeletionApi extends ApiClient {
  final bool hasVariants;
  final bool forbidden;
  final bool failCache;
  final List<Map<String, dynamic>?> calls = [];
  List<String> invalidated = [];

  _DeletionApi({
    this.hasVariants = false,
    this.forbidden = false,
    this.failCache = false,
  });

  @override
  Future<dynamic> delete(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    String? context,
    Duration timeout = const Duration(seconds: ApiConfig.receiveTimeout),
  }) async {
    expect(endpoint, ApiConfig.deleteCalendarPlanEndpoint('7'));
    calls.add(queryParams);
    if (forbidden) throw ApiException('Permission denied', statusCode: 403);
    if (hasVariants && queryParams == null) {
      throw ApiException(
        'Cannot delete the original plan while variants exist',
        statusCode: 400,
      );
    }
  }

  @override
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    String? context,
    Duration timeout = const Duration(seconds: ApiConfig.receiveTimeout),
  }) async => [
    {'id': 7, 'name': 'Original'},
    {'id': 8, 'name': 'Variant A'},
  ];

  @override
  Future<void> invalidateCacheGroups(Iterable<String> groups) async {
    if (failCache) throw StateError('Cache unavailable');
    invalidated = groups.toList();
  }
}

final _plan = CalendarPlan(
  id: 7,
  userId: 'owner',
  name: 'Original',
  schedule: {},
  durationWeeks: 12,
);

void main() {
  test('only a known matching owner has deletion rights', () {
    expect(_plan.isOwnedBy('owner'), isTrue);
    expect(_plan.isOwnedBy('visitor'), isFalse);
    expect(_plan.isOwnedBy(null), isFalse);
    expect(_plan.isOwnedBy(''), isFalse);
    final legacy = CalendarPlan.fromJson({'id': 7, 'name': 'Legacy'});
    expect(legacy.isOwnedBy('owner'), isFalse);
    expect(CalendarPlan.fromJson(_plan.toJson()).isOwnedBy('owner'), isTrue);
  });

  Future<void> open(
    WidgetTester tester,
    _DeletionApi api,
    ValueChanged<Object> result,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                try {
                  result(
                    await confirmAndDeleteCalendarPlan(
                      context,
                      plan: _plan,
                      apiClient: api,
                    ),
                  );
                } catch (error) {
                  result(error);
                }
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('cancel never sends a delete request', (tester) async {
    final api = _DeletionApi();
    Object? result;
    await open(tester, api, (value) => result = value);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(result, false);
    expect(api.calls, isEmpty);
  });

  testWidgets('normal deletion refreshes plan and workout caches', (
    tester,
  ) async {
    final api = _DeletionApi();
    Object? result;
    await open(tester, api, (value) => result = value);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(result, true);
    expect(api.calls, [null]);
    expect(
      api.invalidated,
      containsAll([
        'plans:list',
        'plans:detail',
        'plans:variants',
        'plans:active',
        'plans:active_workouts',
        'workouts:list',
      ]),
    );
  });

  for (final confirmCascade in [false, true]) {
    testWidgets('variants require separate confirmation: $confirmCascade', (
      tester,
    ) async {
      final api = _DeletionApi(hasVariants: true);
      Object? result;
      await open(tester, api, (value) => result = value);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(api.calls, [null]);
      expect(find.text('Variant A'), findsOneWidget);
      expect(find.text('Original'), findsNothing);
      expect(find.byIcon(Icons.subdirectory_arrow_right_rounded), findsOneWidget);
      await tester.tap(find.text(confirmCascade ? 'Delete all' : 'Cancel'));
      await tester.pumpAndSettle();
      expect(result, confirmCascade);
      expect(
        api.calls,
        confirmCascade
            ? [
                null,
                {'cascade': 'true'},
              ]
            : [null],
      );
    });
  }

  testWidgets('permission failure never escalates to cascade', (tester) async {
    final api = _DeletionApi(forbidden: true);
    Object? result;
    await open(tester, api, (value) => result = value);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(result, isA<ApiException>());
    expect(api.calls, [null]);
    expect(api.invalidated, isEmpty);
  });

  testWidgets('cache failure does not suggest retrying a completed delete', (
    tester,
  ) async {
    final api = _DeletionApi(failCache: true);
    Object? result;
    await open(tester, api, (value) => result = value);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(result, true);
    expect(api.calls, [null]);
  });
}
