import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/providers/plan_catalog_provider.dart';
import 'package:workout_app/services/service_locator.dart';
import 'package:workout_app/widgets/instrument_modal.dart';

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

  /// Opens [PlanCatalogFilters] inside a single-contour obsidian sheet.
  static Future<Map<String, Set<String>>?> show(
    BuildContext context, {
    required PlanCatalogState initial,
  }) {
    return showInstrumentBottomSheet<Map<String, Set<String>>>(
      context: context,
      isScrollControlled: true,
      heightFactor: 0.78,
      builder: (_) => PlanCatalogFilters(initial: initial),
    );
  }

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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hairline =
        (isDark ? instrument.hairlineBorder : scheme.outlineVariant)
            .withValues(alpha: isDark ? 0.85 : 0.55);

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'CATALOG FILTERS',
                        style: InstrumentTheme.microLabel(
                          context,
                          color: instrument.workingAura,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Фильтры планов',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  child: IconButton(
                    tooltip: 'Закрыть',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceBetween,
              children: [
                if (_catalog.loading)
                  SizedBox(
                    width: 140,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 4,
                        backgroundColor: hairline,
                        color: instrument.workingAura,
                      ),
                    ),
                  )
                else if (_catalog.error != null)
                  InstrumentActionButton(
                    label: 'Повторить загрузку',
                    variant: InstrumentActionVariant.secondary,
                    accentColor: instrument.peakEffortColor,
                    onPressed: _controller.refresh,
                  )
                else
                  Text(
                    'Найдено: ${_catalog.page.total}',
                    style: InstrumentTheme.tabular(
                      (theme.textTheme.labelLarge ?? const TextStyle())
                          .copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                InstrumentActionButton(
                  label: 'Сбросить',
                  variant: InstrumentActionVariant.secondary,
                  onPressed: () => setState(() {
                    _selected.clear();
                    _controller.setFilters(_selected);
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: hairline),
            const SizedBox(height: 14),
            for (final facet in catalogFacetTitles.entries) ...[
              Text(
                facet.value.toUpperCase(),
                style: InstrumentTheme.microLabel(context),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final value in {
                    ...?_catalog.page.facets[facet.key]?.keys,
                    ...?_selected[facet.key],
                  })
                    InstrumentSelectablePill(
                      label:
                          '${catalogFilterLabel(facet.key, value)} (${_catalog.loading ? '…' : _catalog.page.facets[facet.key]?[value] ?? 0})',
                      selected: _selected[facet.key]?.contains(value) ?? false,
                      onTap: () => setState(() {
                        final values = _selected.putIfAbsent(
                          facet.key,
                          () => <String>{},
                        );
                        final isSelected = values.contains(value);
                        isSelected ? values.remove(value) : values.add(value);
                        _controller.setFilters(_selected);
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Container(height: 1, color: hairline),
              const SizedBox(height: 14),
            ],
            const SizedBox(height: 4),
            InstrumentActionButton(
              label: 'Применить',
              expanded: true,
              variant: InstrumentActionVariant.primary,
              accentColor: instrument.workingAura,
              onPressed: _catalog.loading || _catalog.error != null
                  ? null
                  : () => Navigator.pop(context, _selected),
            ),
          ],
        ),
      ),
    );
  }
}
