import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_app/config/api_config.dart';
import 'package:workout_app/models/calendar_plan.dart';
import 'package:workout_app/services/api_client.dart';
import 'package:workout_app/services/service_locator.dart';

class PlanCatalogPage {
  final List<CalendarPlan> items;
  final int total;
  final Map<String, Map<String, int>> facets;

  const PlanCatalogPage({
    this.items = const [],
    this.total = 0,
    this.facets = const {},
  });

  factory PlanCatalogPage.fromJson(Map<String, dynamic> json) =>
      PlanCatalogPage(
        items: (json['items'] as List)
            .map((p) => CalendarPlan.fromJson(Map<String, dynamic>.from(p)))
            .toList(),
        total: json['total'] as int,
        facets: (json['facets'] as Map<String, dynamic>).map(
          (key, values) => MapEntry(key, {
            for (final value in values as List)
              value['value'].toString(): value['count'] as int,
          }),
        ),
      );
}

class PlanCatalogState {
  final String query;
  final Map<String, Set<String>> filters;
  final PlanCatalogPage page;
  final bool loading;
  final bool loadingMore;
  final Object? error;

  const PlanCatalogState({
    this.query = '',
    this.filters = const {},
    this.page = const PlanCatalogPage(),
    this.loading = false,
    this.loadingMore = false,
    this.error,
  });

  int get filterCount =>
      filters.values.fold(0, (sum, values) => sum + values.length);
  bool get hasMore => page.items.length < page.total;
}

class PlanCatalogController extends StateNotifier<PlanCatalogState> {
  final ApiClient api;
  Timer? _debounce;
  int _generation = 0;
  bool _disposed = false;

  PlanCatalogController(
    this.api, {
    String query = '',
    Map<String, Set<String>> filters = const {},
  }) : super(PlanCatalogState(query: query, filters: filters)) {
    refresh();
  }

  PlanCatalogState get snapshot => state;

  void setQuery(String query) {
    _debounce?.cancel();
    final generation = ++_generation;
    state = PlanCatalogState(
      query: query,
      filters: state.filters,
      page: state.page,
      loading: true,
    );
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => _fetch(generation),
    );
  }

  Future<void> setFilters(Map<String, Set<String>> filters) {
    state = PlanCatalogState(
      query: state.query,
      page: state.page,
      filters: {
        for (final entry in filters.entries)
          if (entry.value.isNotEmpty) entry.key: Set.unmodifiable(entry.value),
      },
    );
    return refresh();
  }

  Future<void> refresh() {
    _debounce?.cancel();
    final generation = ++_generation;
    state = PlanCatalogState(
      query: state.query,
      filters: state.filters,
      page: state.page,
      loading: true,
    );
    return _fetch(generation);
  }

  Future<void> loadMore() async {
    if (state.loading || state.loadingMore || !state.hasMore) return;
    state = PlanCatalogState(
      query: state.query,
      filters: state.filters,
      page: state.page,
      loadingMore: true,
    );
    await _fetch(_generation, append: true);
  }

  Future<void> _fetch(int generation, {bool append = false}) async {
    final previous = state;
    try {
      final json = await api.get(
        ApiConfig.buildEndpoint('/plans/calendar-plans/catalog'),
        queryParams: {
          if (previous.query.trim().isNotEmpty) 'q': previous.query.trim(),
          for (final entry in previous.filters.entries)
            entry.key: entry.value.toList()..sort(),
          'offset': append ? previous.page.items.length : 0,
          'limit': 30,
        },
        context: 'plan_catalog',
      );
      if (_disposed || generation != _generation) return;
      final page = PlanCatalogPage.fromJson(Map<String, dynamic>.from(json));
      state = PlanCatalogState(
        query: previous.query,
        filters: previous.filters,
        page: PlanCatalogPage(
          items: append ? [...previous.page.items, ...page.items] : page.items,
          total: page.total,
          facets: page.facets,
        ),
      );
    } catch (error) {
      if (_disposed || generation != _generation) return;
      state = PlanCatalogState(
        query: previous.query,
        filters: previous.filters,
        page: append ? previous.page : const PlanCatalogPage(),
        error: error,
      );
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    super.dispose();
  }
}

final planCatalogProvider =
    StateNotifierProvider.autoDispose<PlanCatalogController, PlanCatalogState>(
      (ref) => PlanCatalogController(ref.watch(apiClientProvider)),
    );
