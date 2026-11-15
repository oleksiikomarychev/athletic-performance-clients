import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/config/theme/app_theme.dart';
import 'package:workout_app/models/calendar_plan.dart';
import 'package:workout_app/models/calendar_plan_summary.dart';
import 'package:workout_app/providers/interface_maker_provider.dart';
import 'package:workout_app/widgets/instrument_metric_matrix.dart';
import 'package:workout_app/widgets/plan_analytics_chart.dart';
import 'package:workout_app/widgets/plan_detail/plan_instrument_widgets.dart';

void main() {
  testWidgets('chart labels a day once when several workouts share it', (
    tester,
  ) async {
    const points = [
      PlanAnalyticsPoint(order: 0, label: 'May 23', values: {'volume': 1}),
      PlanAnalyticsPoint(order: 1, label: 'May 23', values: {'volume': 2}),
      PlanAnalyticsPoint(order: 2, label: 'May 26', values: {'volume': 3}),
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 200,
            child: PlanAnalyticsChart(
              points: points,
              metricX: 'volume',
              metricY: 'volume',
              lineSeries: [
                PlanAnalyticsLineSeries(metric: 'volume', color: Colors.blue),
              ],
              bottomLabelModulo: 1,
            ),
          ),
        ),
      ),
    );

    expect(find.text('May 23'), findsOneWidget);
    expect(find.text('May 26'), findsOneWidget);
  });

  testWidgets(
    'PlanAnalyticsChart bleedMode hides left Y-axis, preserves 0.0 discrete dots, and separates Planned vs Actual',
    (tester) async {
      const points = [
        PlanAnalyticsPoint(
          order: 0,
          label: 'D1',
          values: {'intensity': 0.0},
          actualValues: {'intensity': 65.0},
        ),
        PlanAnalyticsPoint(
          order: 1,
          label: 'D2',
          values: {'intensity': 82.5},
          actualValues: {'intensity': 80.0},
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme(),
          home: const MediaQuery(
            data: MediaQueryData(
              size: Size(320, 640),
              textScaler: TextScaler.linear(2.0),
            ),
            child: Scaffold(
              body: SizedBox(
                width: 320,
                height: 180,
                child: PlanAnalyticsChart(
                  points: points,
                  metricX: 'intensity',
                  metricY: 'intensity',
                  bleedMode: true,
                  accentColor: Color(0xFF00D4AA),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('PLANNED'), findsOneWidget);
      expect(find.text('ACTUAL'), findsOneWidget);

      final lineChart = tester.widget<LineChart>(find.byType(LineChart));
      expect(lineChart.data.titlesData.leftTitles.sideTitles.reservedSize, 0);
      expect(lineChart.data.lineBarsData.length, 2);

      final planned = lineChart.data.lineBarsData[0];
      final actual = lineChart.data.lineBarsData[1];
      expect(planned.isCurved, isFalse);
      expect(actual.isCurved, isFalse);
      expect(planned.dotData.show, isTrue);
      expect(actual.dotData.show, isTrue);
      expect(planned.dashArray, isNotNull);
      expect(actual.dashArray, isNull);
      // Verify 0.0 is preserved rather than treated as missing.
      expect(planned.spots.first.y, 0.0);
    },
  );

  testWidgets(
    'Blueprint B PlanPassportCard + PlanVariantsBar enforce Max Border Depth = 1, switch chart metric on slot tap, and fit 320px @ 2.0x',
    (tester) async {
      final plan = CalendarPlan(
        id: 10,
        name: 'Strength Peaking Block',
        schedule: const {},
        durationWeeks: 6,
        isActive: true,
        primaryGoal: 'strength_powerlifting',
        intendedFrequencyPerWeek: 4,
        requiredEquipment: const ['Barbell', 'Rack'],
      );
      const points = [
        PlanAnalyticsPoint(
          order: 0,
          label: 'D1',
          values: {'intensity': 75.0, 'volume': 40.0, 'effort': 7.5, 'sets': 12},
          actualValues: {'intensity': 74.0, 'volume': 38.0, 'effort': 7.5, 'sets': 12},
        ),
        PlanAnalyticsPoint(
          order: 1,
          label: 'D2',
          values: {'intensity': 88.0, 'volume': 55.0, 'effort': 9.0, 'sets': 16},
          actualValues: {'intensity': 86.0, 'volume': 52.0, 'effort': 8.5, 'sets': 15},
        ),
      ];

      MetricSlot activeSlot = MetricSlot.peakIntensity;
      String activeMetric = 'intensity';

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              theme: AppTheme.darkTheme(),
              home: MediaQuery(
                data: const MediaQueryData(
                  size: Size(320, 760),
                  textScaler: TextScaler.linear(2.0),
                ),
                child: Scaffold(
                  body: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PlanVariantsBar(
                          currentPlanId: 10,
                          rootPlanId: 10,
                          variants: [
                            CalendarPlanSummary(
                              id: 10,
                              name: 'Original',
                              durationWeeks: 6,
                              isActive: true,
                              rootPlanId: 10,
                              isOriginal: true,
                            ),
                          ],
                          isLoading: false,
                          errorText: null,
                          onSelectOriginal: () {},
                          onSelectVariant: (_) {},
                          onCreateVariant: () {},
                        ),
                        PlanPassportCard(
                          plan: plan,
                          adoptersLoading: false,
                          adoptersError: null,
                          adoptersCount: 42,
                          updatingPublic: false,
                          onPublicChanged: (_) {},
                          chartSlot: SizedBox(
                            height: 152,
                            child: PlanAnalyticsChart(
                              points: points,
                              metricX: activeMetric,
                              metricY: activeMetric,
                              bleedMode: true,
                            ),
                          ),
                          metricCells: const [
                            InstrumentMetricCellData(
                              slot: MetricSlot.peakIntensity,
                              value: '88%',
                            ),
                            InstrumentMetricCellData(
                              slot: MetricSlot.kpsh,
                              value: '55',
                            ),
                            InstrumentMetricCellData(
                              slot: MetricSlot.avgRpe,
                              value: '8.3',
                            ),
                            InstrumentMetricCellData(
                              slot: MetricSlot.setsCount,
                              value: '16',
                            ),
                          ],
                          selectedSlot: activeSlot,
                          onSelectSlot: (slot) {
                            setState(() {
                              activeSlot = slot;
                              activeMetric = switch (slot) {
                                MetricSlot.kpsh => 'volume',
                                MetricSlot.avgRpe => 'effort',
                                MetricSlot.setsCount => 'sets',
                                _ => 'intensity',
                              };
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Verify Max Border Depth = 1 inside PlanPassportCard: only the card root Container has a rectangular box border.
      final innerContainers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(PlanPassportCard),
          matching: find.byType(Container),
        ),
      );
      final borderedBoxes = innerContainers.where((container) {
        final decoration = container.decoration;
        return decoration is BoxDecoration &&
            decoration.border != null &&
            decoration.shape == BoxShape.rectangle;
      }).toList();
      expect(borderedBoxes.length, 1);

      // Tap KPI matrix slot KPSH and verify activeMetric updates to 'volume'.
      await tester.tap(find.text('КПШ'));
      await tester.pumpAndSettle();
      expect(activeMetric, 'volume');
      final updatedChart = tester.widget<PlanAnalyticsChart>(
        find.byType(PlanAnalyticsChart),
      );
      expect(updatedChart.metricY, 'volume');
    },
  );
}
