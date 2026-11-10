import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_app/services/service_locator.dart';
import 'package:workout_app/providers/plan_catalog_provider.dart';

const catalogFacetTitles = {
  'duration_weeks': 'Длительность',
  'goals': 'Цель',
  'frequencies': 'Тренировок в неделю',
  'levels': 'Уровень',
};

String catalogFilterLabel(String key, String value) => switch (key) {
  'duration_weeks' => '$value нед.',
  'frequencies' => '$value / нед.',
  // Display formatting only; requests and selections retain exact stored codes.
  _ => value.replaceAll('_', ' '),
};

class PlanCatalogFilters extends ConsumerStatefulWidget {
  final PlanCatalogState initial;
  const PlanCatalogFilters({super.key, required this.initial});

  @override
  ConsumerState<PlanCatalogFilters> createState() => _PlanCatalogFiltersState();
}

class _PlanCatalogFiltersState extends ConsumerState<PlanCatalogFilters> {
  late Map<String, Set<String>> _selected;
  late PlanCatalogController _controller;
  late PlanCatalogState _catalog;
  late VoidCallback _unlisten;

  @override
  void initState() {
    super.initState();
    _selected = {
      for (final e in widget.initial.filters.entries) e.key: {...e.value},
    };
    _controller = PlanCatalogController(
      ref.read(apiClientProvider),
      query: widget.initial.query,
      filters: _selected,
    );
    _catalog = _controller.snapshot;
    _unlisten = _controller.addListener((state) {
      if (mounted) setState(() => _catalog = state);
    });
  }

  @override
  void dispose() {
    _unlisten();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Фильтры планов',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Закрыть',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _catalog.loading
                        ? const LinearProgressIndicator()
                        : _catalog.error != null
                        ? TextButton(
                            onPressed: _controller.refresh,
                            child: const Text('Повторить загрузку'),
                          )
                        : Text('Найдено: ${_catalog.page.total}'),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      _selected.clear();
                      _controller.setFilters(_selected);
                    }),
                    child: const Text('Сбросить'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final facet in catalogFacetTitles.entries) ...[
                    Text(
                      facet.value,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        for (final value in {
                          ...?_catalog.page.facets[facet.key]?.keys,
                          ...?_selected[facet.key],
                        })
                          FilterChip(
                            label: Text(
                              '${catalogFilterLabel(facet.key, value)} (${_catalog.loading ? '…' : _catalog.page.facets[facet.key]?[value] ?? 0})',
                            ),
                            selected:
                                _selected[facet.key]?.contains(value) ?? false,
                            onSelected: (selected) => setState(() {
                              final values = _selected.putIfAbsent(
                                facet.key,
                                () => <String>{},
                              );
                              selected
                                  ? values.add(value)
                                  : values.remove(value);
                              _controller.setFilters(_selected);
                            }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _catalog.loading || _catalog.error != null
                      ? null
                      : () => Navigator.pop(context, _selected),
                  child: const Text('Применить'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
