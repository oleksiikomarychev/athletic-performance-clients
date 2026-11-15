import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_app/config/constants/theme_constants.dart';
import 'package:workout_app/config/theme/app_theme.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/models/exercise_instance.dart';
import 'package:workout_app/models/exercise_set_dto.dart';
import 'package:workout_app/models/workout.dart';
import 'package:workout_app/providers/ambient_environment_provider.dart';
import 'package:workout_app/providers/interface_maker_provider.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/custom_bottom_nav_bar.dart';
import 'package:workout_app/widgets/floating_header_bar.dart';
import 'package:workout_app/widgets/instrument_metric_matrix.dart';
import 'package:workout_app/widgets/interface_maker_sheet.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Wave 1 Obsidian Theme & Ambient Environment', () {
    test('AppTheme.darkTheme uses explicit obsidian-graphite tokens', () {
      final dark = AppTheme.darkTheme(density: UiDensity.compact);
      final scheme = dark.colorScheme;
      final instrument = dark.extension<InstrumentTheme>()!;

      expect(dark.scaffoldBackgroundColor, const Color(0xFF0A0E14));
      expect(scheme.surface, const Color(0xFF0A0E14));
      expect(scheme.surfaceContainerLow, const Color(0xFF111722));
      expect(scheme.surfaceContainerHigh, const Color(0xFF172030));
      expect(scheme.outlineVariant, const Color(0xFF263449));

      expect(instrument.deloadAura, const Color(0xFF2DD4BF));
      expect(instrument.workingAura, const Color(0xFF38BDF8));
      expect(instrument.stormAura, const Color(0xFFF59E0B));
      expect(instrument.executionAccent, const Color(0xFF10B981));
    });

    test('TrainingEnvironmentData classifies deload, workingVolume, cnsStorm, and liveExecution', () {
      final deload = TrainingEnvironmentData.fromSets(const [
        ExerciseSetDto(reps: 8, weight: 80, rpe: 6.0, intensity: 60),
      ]);
      expect(deload.state, TrainingEnvironmentState.deload);

      final working = TrainingEnvironmentData.fromSets(const [
        ExerciseSetDto(reps: 8, weight: 120, rpe: 8.0, intensity: 76),
      ]);
      expect(working.state, TrainingEnvironmentState.workingVolume);

      final stormWorkout = Workout(
        id: 1,
        name: 'Heavy Squat',
        exerciseInstances: const [
          ExerciseInstance(
            exerciseListId: 10,
            sets: [
              ExerciseSetDto(reps: 8, weight: 160, rpe: 10.0, intensity: 90),
            ],
          ),
        ],
      );
      final storm = TrainingEnvironmentData.fromWorkout(stormWorkout);
      expect(storm.state, TrainingEnvironmentState.cnsStorm);
      expect(storm.tacticalBriefing, contains('160 кг × 8'));
      expect(storm.tacticalBriefing, contains('RPE 10'));

      final live = TrainingEnvironmentData.fromWorkout(
        stormWorkout,
        isLiveExecution: true,
      );
      expect(live.state, TrainingEnvironmentState.liveExecution);
    });

    testWidgets('AmbientScaffoldShell suppresses aura in liveExecution and animations under disableAnimations', (tester) async {
      final storm = TrainingEnvironmentData.evaluate(peakRpe: 9.5);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme(),
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: AmbientScaffoldShell(
              environment: storm,
              body: const Center(child: Text('Storm')),
            ),
          ),
        ),
      );
      expect(find.byType(AnimatedContainer), findsNothing);
      expect(tester.takeException(), isNull);

      final live = TrainingEnvironmentData.evaluate(
        peakRpe: 9.5,
        isLiveExecution: true,
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme(),
          home: AmbientScaffoldShell(
            environment: live,
            body: const Center(child: Text('Live')),
          ),
        ),
      );
      // Radial aura AnimatedContainer is omitted during liveExecution.
      expect(find.byType(AnimatedContainer), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('AmbientScaffoldShell drifts cached RepaintBoundary aura lobes smoothly when active', (tester) async {
      final storm = TrainingEnvironmentData.evaluate(peakRpe: 9.5);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme(),
          home: AmbientScaffoldShell(
            environment: storm,
            body: const Center(child: Text('Storm')),
          ),
        ),
      );

      final auraFinder = find.byKey(const ValueKey<String>('drifting_ambient_aura'));
      final transformsBefore = tester
          .widgetList<Transform>(
            find.descendant(of: auraFinder, matching: find.byType(Transform)),
          )
          .toList();
      expect(transformsBefore.length, 2);
      expect(
        find.descendant(
          of: auraFinder,
          matching: find.byType(RepaintBoundary),
        ),
        findsNWidgets(2),
      );

      final initialTx = transformsBefore.first.transform.getTranslation().x;
      await tester.pump(const Duration(seconds: 4));

      final transformsAfter = tester
          .widgetList<Transform>(
            find.descendant(of: auraFinder, matching: find.byType(Transform)),
          )
          .toList();
      final movedTx = transformsAfter.first.transform.getTranslation().x;
      expect(movedTx, isNot(equals(initialTx)));
      expect(tester.takeException(), isNull);
    });

    testWidgets('GlobalAmbientStage shares a single drifting aura across plain Scaffolds and pushed AmbientScaffoldShell routes', (tester) async {
      final storm = TrainingEnvironmentData.evaluate(peakRpe: 9.5);
      final live = TrainingEnvironmentData.evaluate(
        peakRpe: 9.5,
        isLiveExecution: true,
      );
      final auraFinder = find.byKey(const ValueKey<String>('drifting_ambient_aura'));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme(),
          builder: (context, child) => GlobalAmbientStage(child: child!),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      Theme.of(context).scaffoldBackgroundColor ==
                              Colors.transparent
                          ? 'transparent-canvas'
                          : 'opaque-canvas',
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => AmbientScaffoldShell(
                              environment: storm,
                              body: Builder(
                                builder: (stormCtx) => ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(stormCtx).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => AmbientScaffoldShell(
                                          environment: live,
                                          body: const Text('Live Execution'),
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Go Live'),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      child: const Text('Push Storm'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('transparent-canvas'), findsOneWidget);
      // Root aura contributes 2 RepaintBoundary layers.
      expect(
        find.descendant(
          of: auraFinder,
          matching: find.byType(RepaintBoundary),
        ),
        findsNWidgets(2),
      );

      final beforePushTx = tester
          .widgetList<Transform>(
            find.descendant(of: auraFinder, matching: find.byType(Transform)),
          )
          .first
          .transform
          .getTranslation()
          .x;

      await tester.tap(find.text('Push Storm'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Still only 1 aura / 2 RepaintBoundary layers (not duplicated per screen) and
      // the shared orbit continued advancing rather than resetting to 0.
      expect(auraFinder, findsOneWidget);
      expect(
        find.descendant(
          of: auraFinder,
          matching: find.byType(RepaintBoundary),
        ),
        findsNWidgets(2),
      );
      final afterPushTx = tester
          .widgetList<Transform>(
            find.descendant(of: auraFinder, matching: find.byType(Transform)),
          )
          .first
          .transform
          .getTranslation()
          .x;
      expect(afterPushTx, isNot(equals(beforePushTx)));

      // Entering liveExecution suppresses the shared aura; popping restores it.
      await tester.tap(find.text('Go Live'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(auraFinder, findsNothing);

      Navigator.of(tester.element(find.text('Live Execution'))).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(auraFinder, findsOneWidget);
      expect(
        find.descendant(
          of: auraFinder,
          matching: find.byType(RepaintBoundary),
        ),
        findsNWidgets(2),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('Wave 1 Unified Instrument Chrome', () {
    testWidgets('PrimaryAppBar, FloatingHeaderBar, and CustomBottomNavBar eliminate darkChrome bricks', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme(density: UiDensity.compact),
          home: Scaffold(
            extendBody: true,
            extendBodyBehindAppBar: true,
            appBar: PrimaryAppBar.detail(
              title: 'Plan Detail',
              actions: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.check)),
              ],
            ),
            body: const Center(child: Text('Canvas')),
            bottomNavigationBar: CustomBottomNavBar(
              currentIndex: 0,
              onTap: (_) {},
              items: const [
                BottomNavBarItem(icon: Icons.fitness_center, label: 'Workouts'),
                BottomNavBarItem(icon: Icons.schedule, label: 'Plans'),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      final containers = tester.widgetList<Container>(find.byType(Container));
      for (final c in containers) {
        final deco = c.decoration;
        if (deco is BoxDecoration) {
          expect(deco.color, isNot(AppColors.darkChrome));
        }
        expect(c.color, isNot(AppColors.darkChrome));
      }

      // Detached glass orbs wrap back button and trailing action with >=48x48 tap targets.
      expect(find.byType(DetachedGlassOrb), findsNWidgets(2));
      for (final orb in find.byType(DetachedGlassOrb).evaluate()) {
        final size = orb.size!;
        expect(size.width, greaterThanOrEqualTo(48));
        expect(size.height, greaterThanOrEqualTo(48));
      }

      // FloatingHeaderBar also uses detached orbs and center capsule.
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme(density: UiDensity.compact),
          home: Scaffold(
            body: FloatingHeaderBar(
              title: 'Workouts',
              onTitleTap: () {},
              onProfileTap: () {},
            ),
          ),
        ),
      );
      expect(find.byType(DetachedGlassOrb), findsOneWidget);
      expect(find.byType(FloatingTitleCapsule), findsOneWidget);
    });
  });

  group('Wave 1 Interface Maker & InstrumentMetricMatrix', () {
    test('InterfaceMakerController switches presets, persists Custom slots, and reorders modules', () async {
      final controller = InterfaceMakerController();
      expect(controller.state.preset, InterfacePreset.powerlifter);
      expect(controller.state.showChart, isTrue);

      await controller.applyPreset(InterfacePreset.volume);
      expect(controller.state.preset, InterfacePreset.volume);
      expect(controller.state.slots, const [
        MetricSlot.tonnage,
        MetricSlot.setsCount,
        MetricSlot.density,
        MetricSlot.avgRpe,
      ]);

      await controller.applyPreset(InterfacePreset.minimalist);
      expect(controller.state.preset, InterfacePreset.minimalist);
      expect(controller.state.showChart, isFalse);

      await controller.setSlot(1, MetricSlot.e1rm);
      expect(controller.state.preset, InterfacePreset.custom);
      expect(controller.state.slots[1], MetricSlot.e1rm);

      await controller.moveModule(3, 1);
      expect(controller.state.moduleOrder[1], LayoutModule.scheduleOrLibrary);

      // Re-create controller from persisted SharedPreferences.
      final reloaded = InterfaceMakerController();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(reloaded.state.preset, InterfacePreset.custom);
      expect(reloaded.state.slots[1], MetricSlot.e1rm);
      expect(reloaded.state.moduleOrder[1], LayoutModule.scheduleOrLibrary);
    });

    testWidgets('InstrumentMetricMatrix has zero inner borders, supports selection, and falls back to 2x2 at 320px/2.0 textScale', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      MetricSlot selected = MetricSlot.peakIntensity;

      Widget buildMatrix(double textScale) => MaterialApp(
        theme: AppTheme.darkTheme(density: UiDensity.compact),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: child!,
        ),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return InstrumentMetricMatrix(
                selectedSlot: selected,
                onSelectSlot: (slot) => setState(() => selected = slot),
                cells: const [
                  InstrumentMetricCellData(slot: MetricSlot.peakIntensity, value: '87.5%'),
                  InstrumentMetricCellData(slot: MetricSlot.e1rm, value: '182.5 kg'),
                  InstrumentMetricCellData(slot: MetricSlot.peakRpe, value: 'RPE 9.5'),
                  InstrumentMetricCellData(slot: MetricSlot.kpsh, value: '24'),
                ],
              );
            },
          ),
        ),
      );

      await tester.pumpWidget(buildMatrix(1.0));
      expect(tester.takeException(), isNull);

      // Verify zero bordered boxes inside InstrumentMetricMatrix.
      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(InstrumentMetricMatrix),
          matching: find.byType(Container),
        ),
      );
      for (final c in containers) {
        final deco = c.decoration;
        if (deco is BoxDecoration) {
          expect(deco.border, isNull);
        }
      }

      await tester.tap(find.text('182.5 kg'));
      await tester.pump();
      expect(selected, MetricSlot.e1rm);

      // Enlarged textScale triggers 2x2 layout with zero overflow.
      await tester.pumpWidget(buildMatrix(2.0));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('InterfaceMakerSheet and CanvasPillStrip render cleanly at 320px and 2.0 textScale', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.darkTheme(density: UiDensity.compact),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(2.0),
              ),
              child: child!,
            ),
            home: Scaffold(
              body: Column(
                children: [
                  CanvasPillStrip(
                    items: [
                      CanvasPillItem(
                        label: 'Сила 5/3/1',
                        selected: true,
                        onTap: () {},
                      ),
                      CanvasPillItem(
                        label: 'Объём',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const Expanded(child: InterfaceMakerSheet()),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
