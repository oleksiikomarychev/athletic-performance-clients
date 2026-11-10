import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/config/api_config.dart';
import 'package:workout_app/providers/plan_catalog_provider.dart';
import 'package:workout_app/services/api_client.dart';

class CatalogApi extends ApiClient {
  final requests = <Map<String, dynamic>>[];
  final pending = <Completer<dynamic>>[];
  @override
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    String? context,
    Duration timeout = const Duration(seconds: ApiConfig.receiveTimeout),
  }) {
    requests.add(queryParams!);
    final response = Completer<dynamic>();
    pending.add(response);
    return response.future;
  }
}

Map<String, dynamic> page(int id, {int total = 1}) => {
  'items': [
    {'id': id, 'name': 'Plan $id', 'duration_weeks': 4},
  ],
  'total': total,
  'offset': 0,
  'limit': 30,
  'facets': {
    'levels': [
      {'value': 'novice_to_intermediate', 'count': total},
    ],
  },
};

void main() {
  testWidgets(
    'typing debounces and discards old requests before next request starts',
    (tester) async {
      final api = CatalogApi();
      final controller = PlanCatalogController(api);
      controller.setQuery('str');
      api.pending[0].complete(page(1));
      await tester.pump(const Duration(milliseconds: 200));
      expect(controller.snapshot.loading, true);
      expect(controller.snapshot.page.items, isEmpty);
      controller.setQuery('strength');
      await tester.pump(const Duration(milliseconds: 299));
      expect(api.requests.length, 1);
      await tester.pump(const Duration(milliseconds: 1));
      expect(api.requests.last['q'], 'strength');
      api.pending[1].complete(page(2));
      await tester.pump();
      expect(controller.snapshot.page.items.single.id, 2);
      controller.dispose();
    },
  );

  testWidgets('new filters beat older responses and retain exact codes', (
    tester,
  ) async {
    final api = CatalogApi();
    final controller = PlanCatalogController(api);
    final selected = {
      'levels': {'novice_to_intermediate', 'beginner-intermediate'},
    };
    controller.setFilters(selected);
    selected['levels']!.clear();
    expect(api.requests.last['levels'], [
      'beginner-intermediate',
      'novice_to_intermediate',
    ]);
    api.pending[1].complete(page(2));
    await tester.pump();
    api.pending[0].complete(page(1));
    await tester.pump();
    expect(controller.snapshot.page.items.single.id, 2);
    expect(controller.snapshot.filters['levels']!.length, 2);
    controller.dispose();
  });

  testWidgets(
    'pagination failure preserves items and retries the same offset',
    (tester) async {
      final api = CatalogApi();
      final controller = PlanCatalogController(api);
      api.pending[0].complete(page(1, total: 2));
      await tester.pump();
      controller.loadMore();
      controller.loadMore();
      expect(api.requests.length, 2);
      expect(api.requests.last['offset'], 1);
      api.pending[1].completeError(Exception('offline'));
      await tester.pump();
      expect(controller.snapshot.page.items.single.id, 1);
      controller.loadMore();
      expect(api.requests.last['offset'], 1);
      api.pending[2].complete(page(2, total: 2));
      await tester.pump();
      expect(controller.snapshot.page.items.map((p) => p.id), [1, 2]);
      expect(controller.snapshot.hasMore, false);
      controller.dispose();
    },
  );

  testWidgets('disposed controller ignores pending responses and debounce', (
    tester,
  ) async {
    final api = CatalogApi();
    final controller = PlanCatalogController(api);
    controller.setQuery('next');
    controller.dispose();
    api.pending[0].completeError(Exception('offline'));
    await tester.pump(const Duration(seconds: 1));
    expect(api.requests.length, 1);
    expect(tester.takeException(), isNull);
  });
}
