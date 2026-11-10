import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/widgets/plan_analytics_chart.dart';

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
}
