import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/config/api_config.dart';
import 'package:workout_app/config/theme/app_theme.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/screens/calendar_plans_screen.dart';
import 'package:workout_app/services/api_client.dart';
import 'package:workout_app/services/service_locator.dart';

class ScreenCatalogApi extends ApiClient {
  final queries = <Map<String, dynamic>>[];
  int detailRequests = 0;
  @override
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    String? context,
    Duration timeout = const Duration(seconds: ApiConfig.receiveTimeout),
  }) async {
    if (!endpoint.endsWith('/catalog')) {
      detailRequests++;
      throw Exception('Detail unavailable');
    }
    queries.add(queryParams!);
    return {
      'items': [
        {
          'id': 1,
          'name': 'Starting Strength',
          'duration_weeks': 10,
          'primary_goal': 'strength',
          'intended_experience_level': 'novice',
          'intended_frequency_per_week': 3,
        },
      ],
      'total': 1,
      'facets': {
        'duration_weeks': [
          {'value': 10, 'count': 1},
        ],
        'goals': [
          {'value': 'strength', 'count': 1},
          {'value': 'strength_hypertrophy', 'count': 0},
        ],
        'frequencies': [
          {'value': 3, 'count': 1},
        ],
        'levels': [
          {'value': 'novice_to_intermediate', 'count': 1},
          {'value': 'beginner-intermediate', 'count': 0},
        ],
      },
    };
  }
}

void main() {
  Future<ScreenCatalogApi> mount(
    WidgetTester tester, {
    double scale = 1,
  }) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final api = ScreenCatalogApi();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [apiClientProvider.overrideWithValue(api)],
        child: MaterialApp(
          theme: AppTheme.darkTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: const CalendarPlansScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return api;
  }

  testWidgets('filter draft cancellation, apply and removable selections', (
    tester,
  ) async {
    final api = await mount(tester);
    await tester.tap(find.byTooltip('Фильтры'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('strength (1)'));
    await tester.pumpAndSettle();
    expect(api.queries.last['goals'], ['strength']);
    await tester.tap(find.byTooltip('Закрыть'));
    await tester.pumpAndSettle();
    expect(find.byType(InputChip), findsNothing);
    await tester.tap(find.byTooltip('Фильтры'));
    await tester.pumpAndSettle();
    expect(api.queries.last.containsKey('goals'), false);
    await tester.tap(find.text('strength (1)'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Применить'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Применить'));
    await tester.pumpAndSettle();
    expect(api.queries.last['goals'], ['strength']);
    final chip = tester.widget<InputChip>(find.byType(InputChip));
    chip.onDeleted!();
    await tester.pumpAndSettle();
    expect(api.queries.last.containsKey('goals'), false);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search uses new query and details require a full fetch', (
    tester,
  ) async {
    final api = await mount(tester);
    await tester.enterText(find.byType(TextField), 'strength');
    await tester.pump(const Duration(milliseconds: 301));
    await tester.pumpAndSettle();
    expect(api.queries.last['q'], 'strength');
    await tester.tap(find.text('Starting Strength'));
    await tester.pumpAndSettle();
    expect(api.detailRequests, 1);
    expect(find.textContaining('Не удалось открыть план'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('filters fit narrow screens with doubled system text', (
    tester,
  ) async {
    await mount(tester, scale: 2);
    await tester.tap(find.byTooltip('Фильтры'));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(SingleChildScrollView).last,
      const Offset(0, -450),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Применить'), findsOneWidget);
  });
}
