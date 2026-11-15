import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/config/theme/app_theme.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/models/calendar_plan.dart';
import 'package:workout_app/providers/plan_catalog_provider.dart';
import 'package:workout_app/providers/target_data_providers.dart';
import 'package:workout_app/services/api_client.dart';
import 'package:workout_app/services/base_api_service.dart';
import 'package:workout_app/services/service_locator.dart';
import 'package:workout_app/widgets/calendar_plan_apply_confirmation.dart';
import 'package:workout_app/widgets/calendar_plan_delete_dialog.dart';
import 'package:workout_app/widgets/chat_tools/mass_edit_tool_widget.dart';
import 'package:workout_app/widgets/chat_tools/schedule_shift_tool_widget.dart';
import 'package:workout_app/widgets/empty_state.dart';
import 'package:workout_app/widgets/error_message.dart';
import 'package:workout_app/widgets/instrument_modal.dart';
import 'package:workout_app/widgets/plan_catalog_filters.dart';
import 'package:workout_app/widgets/review_form_dialog.dart';

class _NoopApiClient extends ApiClient {
  @override
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    String? context,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    return {
      'items': <dynamic>[],
      'total': 1,
      'facets': {
        'duration_weeks': [
          {'value': 8, 'count': 1},
        ],
        'goals': [
          {'value': 'strength', 'count': 1},
        ],
        'frequencies': [
          {'value': 4, 'count': 1},
        ],
        'levels': [
          {'value': 'intermediate', 'count': 1},
        ],
      },
    };
  }
}

void main() {
  Widget wrapApp(
    Widget child, {
    double textScale = 1.0,
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        apiClientProvider.overrideWithValue(_NoopApiClient()),
        exerciseDefinitionNameMapProvider.overrideWithValue(const {
          1: 'Squat',
        }),
        ...overrides,
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, inner) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: inner!,
        ),
        home: Scaffold(body: child),
      ),
    );
  }

  testWidgets(
    'PlanCatalogFilters renders obsidian pills instead of FilterChip with >=48dp touch targets',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      const state = PlanCatalogState();
      await tester.pumpWidget(wrapApp(const PlanCatalogFilters(initial: state)));
      await tester.pumpAndSettle();

      expect(find.byType(FilterChip), findsNothing);
      expect(find.byType(InstrumentSelectablePill), findsAtLeastNWidgets(4));

      final pillSize = tester.getSize(
        find.byType(InstrumentSelectablePill).first,
      );
      expect(pillSize.height, greaterThanOrEqualTo(48));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'confirmations and ReviewFormDialog use InstrumentDialog without AlertDialog at 320px @ 2.0x',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        wrapApp(
          textScale: 2.0,
          Builder(
            builder: (context) => Column(
              children: [
                TextButton(
                  onPressed: () => applyPlanWithConfirmation<void>(
                    context,
                    submit: (replace) async {
                      if (!replace) {
                        throw ApiException('Conflict', statusCode: 409);
                      }
                    },
                  ),
                  child: const Text('Apply'),
                ),
                TextButton(
                  onPressed: () => confirmAndDeleteCalendarPlan(
                    context,
                    plan: CalendarPlan(
                      id: 1,
                      name: 'Test Plan',
                      schedule: const {},
                      durationWeeks: 8,
                    ),
                    apiClient: _NoopApiClient(),
                  ),
                  child: const Text('Delete'),
                ),
                TextButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => ReviewFormDialog(
                      linkId: 9,
                      coachName: 'Coach Alex',
                      onSubmit: (_, __, ___) async {},
                    ),
                  ),
                  child: const Text('Review'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(InstrumentDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(InstrumentDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Review'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(InstrumentDialog), findsOneWidget);
      final starSize = tester.getSize(
        find.byIcon(Icons.star_border_rounded).first,
      );
      expect(starSize.width, greaterThanOrEqualTo(24));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'MassEditToolWidget & ScheduleShiftToolWidget render single-contour ToolResultCard without Material Card at 320px @ 2.0x',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 840));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        wrapApp(
          textScale: 2.0,
          SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: const [
                MassEditToolWidget(
                  payload: {
                    'mode': 'preview',
                    'summary': {'workouts_matched': 4, 'sets_matched': 16},
                    'mass_edit_command': {
                      'filter': {
                        'only_future': true,
                        'exercise_definition_ids': [1],
                      },
                      'actions': {'increase_weight_by': 2.5},
                    },
                  },
                ),
                SizedBox(height: 12),
                ScheduleShiftToolWidget(
                  payload: {
                    'mode': 'preview',
                    'days': 3,
                    'summary': {'workouts_shifted': 5},
                    'schedule_shift_command': {'days': 3},
                  },
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsNothing);
      expect(find.byType(Chip), findsNothing);
      expect(find.byType(ToolResultCard), findsNWidgets(2));
      expect(find.byType(InstrumentStatusPill), findsAtLeastNWidgets(4));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'ErrorMessage and EmptyState render semantic instrument accents and >=48dp retry button',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        wrapApp(
          Column(
            children: [
              ErrorMessage(message: 'Network down', onRetry: () {}),
              const SizedBox(height: 12),
              const EmptyState(
                icon: Icons.fitness_center,
                title: 'Empty',
                description: 'Nothing here',
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final errorIcon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
      expect(errorIcon.color, InstrumentTheme.dark.peakEffortColor);
      final retryBtnSize = tester.getSize(
        find.byType(InstrumentActionButton).first,
      );
      expect(retryBtnSize.height, greaterThanOrEqualTo(48));
      expect(tester.takeException(), isNull);
    },
  );
}
