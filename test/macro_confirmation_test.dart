import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/config/theme/app_theme.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/models/macro.dart';
import 'package:workout_app/providers/macro_context_providers.dart';
import 'package:workout_app/providers/macro_preview_providers.dart';
import 'package:workout_app/providers/macro_providers.dart';
import 'package:workout_app/providers/target_data_providers.dart';
import 'package:workout_app/screens/macros/macro_editor_screen.dart';
import 'package:workout_app/screens/macros/macros_list_screen.dart';
import 'package:workout_app/screens/macros/macros_preview_screen.dart';
import 'package:workout_app/screens/macros/widgets/action_builder.dart';
import 'package:workout_app/services/api_client.dart';
import 'package:workout_app/services/macro_service.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';

class RecordingApi extends Fake implements ApiClient {
  final calls = <Map>[];
  int previews = 0;
  bool fail = false;
  List<Map<String, dynamic>> macros = const [
    {
      'id': 1,
      'calendar_plan_id': 1,
      'name': 'RPE Deload Rule',
      'is_active': true,
      'priority': 10,
      'rule': {
        'trigger': {'metric': 'RPE_Session'},
        'condition': {'op': 'gt', 'value': 1},
        'action': {
          'type': 'Adjust_Load',
          'params': {'mode': 'by_Percent', 'value': -5},
          'target': {'exercise_ids': <int>[]},
        },
        'duration': {'scope': 'Next_N_Workouts', 'count': 1},
      },
    },
  ];

  @override
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    String? context,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    return macros;
  }
  @override
  Future<dynamic> post(
    String endpoint,
    dynamic data, {
    Map<String, dynamic>? queryParams,
    String? context,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (Uri.parse(endpoint).path.endsWith('/run-macros')) {
      previews++;
      return snapshot;
    }
    calls.add(Map.from(data as Map));
    if (fail) throw Exception('Тренировка изменилась');
    if (data['mesocycles_only'] == true) {
      return {
        'apply_result': {'applied': 0},
        'plan_changes': [
          {'applied': true},
        ],
      };
    }
    return {
      'apply_result': {'applied': 1},
      'plan_changes': [],
    };
  }
}

const snapshot = {
  'applied_plan_id': 1,
  'contract_version': 2,
  'preview_id': 'shown-id',
  'set_changes_count': 1,
  'preview': [
    {
      'name': 'Третий повтор',
      'patches': [
        {
          'workout_id': 2,
          'exercise_id': 8,
          'instance_id': 11,
          'set_id': 3,
          'before': {'intensity': 95, 'volume': 2},
          'after': {'intensity': 93, 'volume': 3},
          'alternatives': [
            {
              'requested': {'intensity': 95, 'volume': 3},
              'proposed': {'intensity': 93, 'volume': 3},
            },
          ],
        },
      ],
    },
  ],
};

// Только для изолированного gateway, запущенного контрактным тестом backend.
class LoopbackHttp extends HttpOverrides {}

class GatewayApi extends Fake implements ApiClient {
  final Uri gateway;
  final client = LoopbackHttp().createHttpClient(null);
  final confirmed = Completer<void>();
  GatewayApi(this.gateway) {
    if (gateway.host != '127.0.0.1')
      throw ArgumentError('Expected local contract gateway');
  }

  Future<dynamic> request(String path, [Map? payload]) async {
    final uri = gateway.resolve(path);
    final req = await client.openUrl(payload == null ? 'GET' : 'POST', uri);
    if (payload != null) {
      req.headers.contentType = ContentType.json;
      req.write(jsonEncode(payload));
    }
    final res = await req.close();
    final body = await utf8.decodeStream(res);
    if (res.statusCode != 200) throw StateError(body);
    return jsonDecode(body);
  }

  @override
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    String? context,
    Duration timeout = const Duration(seconds: 10),
  }) => request(Uri.parse(endpoint).path);

  @override
  Future<dynamic> post(
    String endpoint,
    dynamic data, {
    Map<String, dynamic>? queryParams,
    String? context,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      return await request(Uri.parse(endpoint).path, data as Map);
    } finally {
      confirmed.complete();
    }
  }
}

Widget _wrapMacroApp(
  Widget home, {
  double textScale = 1.0,
}) {
  return MaterialApp(
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
  );
}

void main() {
  const gateway = String.fromEnvironment('MACRO_GATEWAY');
  if (gateway.isNotEmpty) {
    LiveTestWidgetsFlutterBinding();
    testWidgets('живой gateway', (tester) async {
      const wid = int.fromEnvironment('MACRO_WORKOUT');
      final api = GatewayApi(Uri.parse(gateway));
      addTearDown(() => api.client.close(force: true));
      const id = int.fromEnvironment('MACRO_PLAN');
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            macroPreviewServiceProvider.overrideWithValue(
              MacroService(apiClient: api),
            ),
            previewContextProvider(id).overrideWith(
              (ref) async =>
                  const PreviewContextData(workoutNames: {}, exerciseNames: {}),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () =>
                      showSessionMacroSuggestion(context, api, wid, id),
                  child: const Text('Завершённая тренировка'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Завершённая тренировка'));
      final open = find.text('Посмотреть изменения');
      final deadline = DateTime.now().add(const Duration(seconds: 10));
      while (open.evaluate().isEmpty && DateTime.now().isBefore(deadline)) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.tap(open);
      await tester.pumpAndSettle();
      final button = find.text('Подтвердить изменения подходов');
      await tester.scrollUntilVisible(button, 200);
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await api.confirmed.future.timeout(const Duration(seconds: 10));
      await tester.pumpAndSettle();
      expect(find.text('Изменено экземпляров упражнений: 2'), findsOneWidget);
    });
  }
  testWidgets('редактор передаёт проценты со знаком и валидирует границу', (
    tester,
  ) async {
    Map? action;
    final form = GlobalKey<FormState>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          exerciseDefinitionsProvider.overrideWith((ref) async => []),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: Form(
                key: form,
                child: ActionBuilder(
                  initial: const {
                    'type': 'Adjust_Load',
                    'params': {'mode': 'by_Percent', 'value': 1},
                    'target': {
                      'exercise_ids': [8],
                    },
                  },
                  onChanged: (value) => action = value,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final field = find.byType(TextFormField).first;
    await tester.enterText(field, '-2,5');
    expect(action?['params']['value'], -2.5);
    expect(form.currentState!.validate(), isTrue);
    await tester.enterText(field, '-120');
    expect(form.currentState!.validate(), isFalse);
  });

  testWidgets('пустой результат не предлагает подтверждение', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          macroPreviewServiceProvider.overrideWithValue(
            MacroService(apiClient: RecordingApi()),
          ),
          previewContextProvider(1).overrideWith(
            (ref) async =>
                const PreviewContextData(workoutNames: {}, exerciseNames: {}),
          ),
        ],
        child: _wrapMacroApp(
          const MacrosPreviewScreen(
            appliedPlanId: 1,
            initialPreview: {
              'applied_plan_id': 1,
              'contract_version': 2,
              'set_changes_count': 0,
              'preview': [],
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Изменений подходов нет.'), findsOneWidget);
    expect(find.text('Подтвердить изменения подходов'), findsNothing);
  });

  testWidgets('смешанное предложение сохраняет отдельные подтверждения', (
    tester,
  ) async {
    final api = RecordingApi();
    final mixed = {
      ...snapshot,
      'preview': [
        ...(snapshot['preview'] as List),
        {
          'name': 'Вставка',
          'plan_changes': [
            {
              'params': {'template_id': 1},
            },
          ],
        },
      ],
    };
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          macroPreviewServiceProvider.overrideWithValue(
            MacroService(apiClient: api),
          ),
          previewContextProvider(1).overrideWith(
            (ref) async =>
                const PreviewContextData(workoutNames: {}, exerciseNames: {}),
          ),
        ],
        child: _wrapMacroApp(
          MacrosPreviewScreen(appliedPlanId: 1, initialPreview: mixed),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final sets = find.text('Подтвердить изменения подходов');
    await tester.ensureVisible(sets);
    await tester.tap(sets);
    await tester.pumpAndSettle();
    final meso = find.text('Применить правила вставки мезоциклов отдельно');
    await tester.ensureVisible(meso);
    await tester.tap(meso);
    await tester.pumpAndSettle();
    expect(api.calls, [
      {'preview_id': 'shown-id'},
      {'mesocycles_only': true},
    ]);
    expect(find.text('Мезоцикл добавлен'), findsOneWidget);
  });

  for (final fail in [false, true]) {
    testWidgets(
      'показанный вариант и результат подтверждения, конфликт=$fail',
      (tester) async {
        final api = RecordingApi()..fail = fail;
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              macroPreviewServiceProvider.overrideWithValue(
                MacroService(apiClient: api),
              ),
              previewContextProvider(1).overrideWith(
                (ref) async => const PreviewContextData(
                  workoutNames: {},
                  exerciseNames: {},
                ),
              ),
            ],
            child: _wrapMacroApp(
              MacrosPreviewScreen(
                appliedPlanId: 1,
                initialPreview: fail ? snapshot : null,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.textContaining('Запрошено: 3 повт., 95%'), findsOneWidget);
        expect(
          find.textContaining('Ближайший вариант: 3 повт., 93%'),
          findsOneWidget,
        );
        expect(api.calls, isEmpty);
        expect(api.previews, fail ? 0 : 1);
        await tester.tap(find.text('Подтвердить изменения подходов'));
        await tester.pumpAndSettle();
        expect(api.calls, [
          {'preview_id': 'shown-id'},
        ]);
        expect(
          find.textContaining(
            fail
                ? 'Тренировка изменилась'
                : 'Изменено экземпляров упражнений: 1',
          ),
          findsOneWidget,
        );
      },
    );
  }

  testWidgets('старый сервер не поддерживает подтверждение результата', (
    tester,
  ) async {
    final api = RecordingApi();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          macroPreviewServiceProvider.overrideWithValue(
            MacroService(apiClient: api),
          ),
          previewContextProvider(1).overrideWith(
            (ref) async =>
                const PreviewContextData(workoutNames: {}, exerciseNames: {}),
          ),
        ],
        child: _wrapMacroApp(
          const MacrosPreviewScreen(
            appliedPlanId: 1,
            initialPreview: {'applied_plan_id': 1, 'preview': []},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('требуется новая версия'), findsOneWidget);
    expect(find.text('Подтвердить изменения подходов'), findsNothing);
    expect(api.calls, isEmpty);
  });

  group('Wave 3 Macros Instrument UI @ 320px 2.0x textScale', () {
    testWidgets('MacrosListScreen renders without overflow or legacy widgets', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final api = RecordingApi();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            macroServiceProvider.overrideWithValue(
              MacroService(apiClient: api),
            ),
          ],
          child: _wrapMacroApp(
            const MacrosListScreen(calendarPlanId: 1),
            textScale: 2.0,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AssistantChatHost), findsOneWidget);
      expect(find.byType(AmbientScaffoldShell), findsOneWidget);
      expect(find.byType(Card), findsNothing);
      expect(find.byType(ListTile), findsNothing);
      expect(find.byType(Divider), findsNothing);
      expect(find.text('RPE Deload Rule'), findsOneWidget);
      final err = tester.takeException();
      if (err is FlutterError) {
        debugPrint(err.toStringDeep());
      }
      expect(err, isNull);
    });

    testWidgets('MacroEditorScreen renders without overflow or FilterChip', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final api = RecordingApi();
      final macro = PlanMacro(
        id: 1,
        calendarPlanId: 1,
        name: 'RPE Deload Rule',
        isActive: true,
        priority: 10,
        rule: MacroRule(
          trigger: const {'metric': 'RPE_Session'},
          condition: const {'op': 'gt', 'value': 1},
          action: const {
            'type': 'Adjust_Load',
            'params': {'mode': 'by_Percent', 'value': -5},
            'target': {'exercise_ids': <int>[]},
          },
          duration: const {'scope': 'Next_N_Workouts', 'count': 1},
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            macroServiceProvider.overrideWithValue(
              MacroService(apiClient: api),
            ),
            exerciseDefinitionsProvider.overrideWith((ref) async => []),
          ],
          child: _wrapMacroApp(
            MacroEditorScreen(initial: macro, calendarPlanId: 1),
            textScale: 2.0,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AssistantChatHost), findsOneWidget);
      expect(find.byType(AmbientScaffoldShell), findsOneWidget);
      expect(find.byType(FilterChip), findsNothing);
      expect(find.byType(Chip), findsNothing);
      expect(find.byType(Card), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('MacrosPreviewScreen renders without overflow at 320px 2.0x', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final api = RecordingApi();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            macroPreviewServiceProvider.overrideWithValue(
              MacroService(apiClient: api),
            ),
            previewContextProvider(1).overrideWith(
              (ref) async =>
                  const PreviewContextData(workoutNames: {}, exerciseNames: {}),
            ),
          ],
          child: _wrapMacroApp(
            const MacrosPreviewScreen(appliedPlanId: 1, initialPreview: snapshot),
            textScale: 2.0,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AssistantChatHost), findsOneWidget);
      expect(find.byType(AmbientScaffoldShell), findsOneWidget);
      expect(find.byType(Card), findsNothing);
      expect(find.byType(Divider), findsNothing);
      final err = tester.takeException();
      if (err is FlutterError) {
        debugPrint(err.toStringDeep());
      }
      expect(err, isNull);
    });
  });
}
