import 'package:flutter/material.dart';
import 'package:workout_app/models/calendar_plan.dart';
import 'package:workout_app/screens/user_profile_screen.dart';
import 'package:workout_app/config/theme/responsive.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';
import 'package:workout_app/widgets/responsive_container.dart';
import 'package:workout_app/widgets/loading_indicator.dart';
import 'package:workout_app/widgets/error_message.dart';
import 'package:workout_app/widgets/empty_state.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_app/providers/plan_catalog_provider.dart';
import 'package:workout_app/services/service_locator.dart';
import 'package:workout_app/config/api_config.dart';
import 'package:workout_app/widgets/plan_catalog_filters.dart';
import 'package:workout_app/widgets/calendar_plan_card.dart';
import 'calendar_plan_create.dart';
import 'calendar_plan_detail.dart';

class CalendarPlansScreen extends ConsumerStatefulWidget {
  const CalendarPlansScreen({super.key});

  @override
  ConsumerState<CalendarPlansScreen> createState() =>
      _CalendarPlansScreenState();
}

class _CalendarPlansScreenState extends ConsumerState<CalendarPlansScreen> {
  final _search = TextEditingController();
  int? _openingPlanId;

  Future<Map<String, dynamic>?> _buildChatContext() async {
    final plans = (ref.read(planCatalogProvider).page.items)
        .map(
          (p) => <String, dynamic>{
            'id': p.id,
            'name': p.name,
            'duration_weeks': p.durationWeeks,
            'is_active': p.isActive,
            'primary_goal': p.primaryGoal,
            'intended_experience_level': p.intendedExperienceLevel,
            'intended_frequency_per_week': p.intendedFrequencyPerWeek,
            'session_duration_target_min': p.sessionDurationTargetMin,
            'required_equipment': p.requiredEquipment,
            'notes': p.notes,
          },
        )
        .toList(growable: false);

    return <String, dynamic>{
      'v': 1,
      'app': 'WorkoutApp',
      'screen': 'calendar_plans',
      'search_query': ref.read(planCatalogProvider).query,
      'filters': {
        for (final e in ref.read(planCatalogProvider).filters.entries)
          e.key: e.value.toList(),
      },
      'total_results': ref.read(planCatalogProvider).page.total,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'entities': <String, dynamic>{'calendar_plans': plans},
    };
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openPlan(CalendarPlan summary) async {
    if (_openingPlanId != null) return;
    setState(() => _openingPlanId = summary.id);
    try {
      // Catalog items deliberately omit the workout hierarchy. Load full data
      // before opening details so Apply never receives a partial plan.
      final data = await ref
          .read(apiClientProvider)
          .get(
            ApiConfig.getCalendarPlanEndpoint(summary.id.toString()),
            context: 'catalog_open_plan',
          );
      if (!mounted) return;
      final plan = CalendarPlan.fromJson(Map<String, dynamic>.from(data));
      await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => CalendarPlanDetail(plan: plan)),
      );
      if (mounted) await ref.read(planCatalogProvider.notifier).refresh();
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось открыть план: $error')),
        );
    } finally {
      if (mounted) setState(() => _openingPlanId = null);
    }
  }

  Future<void> _showFilters() async {
    FocusScope.of(context).unfocus();
    final filters = await showModalBottomSheet<Map<String, Set<String>>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.75,
        child: PlanCatalogFilters(initial: ref.read(planCatalogProvider)),
      ),
    );
    if (mounted && filters != null)
      await ref.read(planCatalogProvider.notifier).setFilters(filters);
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(planCatalogProvider);
    final controller = ref.read(planCatalogProvider.notifier);
    final dimensions = UiDimensions.of(context);

    return AssistantChatHost(
      contextBuilder: _buildChatContext,
      builder: (context, openChat) {
        return Scaffold(
          appBar: PrimaryAppBar(
            title: 'Training Plans',
            onTitleTap: openChat,
            actions: [
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UserProfileScreen()),
                ),
              ),
            ],
          ),
          body: ResponsiveContainer(
            maxWidth: Breakpoints.maxContentWidthWide,
            child: Column(
              children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: dimensions.pagePadding,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _search,
                        onChanged: controller.setQuery,
                        onSubmitted: (_) => controller.refresh(),
                        decoration: InputDecoration(
                          hintText: 'Поиск планов',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: catalog.query.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Очистить поиск',
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    _search.clear();
                                    controller.setQuery('');
                                  },
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Badge(
                      isLabelVisible: catalog.filterCount > 0,
                      label: Text('${catalog.filterCount}'),
                      child: IconButton(
                        tooltip: 'Фильтры',
                        onPressed: _showFilters,
                        icon: const Icon(Icons.tune),
                      ),
                    ),
                  ],
                ),
              ),
              if (catalog.filterCount > 0)
                SizedBox(
                  height: 44 * MediaQuery.textScalerOf(context).scale(1),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: dimensions.pagePadding,
                    ),
                    children: [
                      for (final facet in catalog.filters.entries)
                        for (final value in facet.value)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: InputChip(
                              label: Text(catalogFilterLabel(facet.key, value)),
                              onDeleted: () {
                                final next = {
                                  for (final e in catalog.filters.entries)
                                    e.key: {...e.value},
                                };
                                next[facet.key]!.remove(value);
                                controller.setFilters(next);
                              },
                            ),
                          ),
                      TextButton(
                        onPressed: () => controller.setFilters({}),
                        child: const Text('Сбросить'),
                      ),
                    ],
                  ),
                ),
              if (!catalog.loading && catalog.error == null)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: dimensions.pagePadding,
                    vertical: 4,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Найдено: ${catalog.page.total}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: catalog.loading
                      ? const LoadingIndicator()
                      : catalog.error != null && catalog.page.items.isEmpty
                      ? ErrorMessage(
                          message:
                              'Не удалось загрузить планы: ${catalog.error}',
                          onRetry: controller.refresh,
                        )
                      : Responsive.isWide(context) &&
                            catalog.page.items.isNotEmpty
                      ? _buildWideCatalogList(
                          context,
                          catalog,
                          controller,
                          dimensions,
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: EdgeInsets.fromLTRB(
                            dimensions.pagePadding,
                            dimensions.rowGap,
                            dimensions.pagePadding,
                            96 + MediaQuery.paddingOf(context).bottom,
                          ),
                          itemCount: catalog.page.items.isEmpty
                              ? 1
                              : catalog.page.items.length +
                                    (catalog.hasMore ? 1 : 0),
                          separatorBuilder: (_, _) =>
                              SizedBox(height: dimensions.rowGap),
                          itemBuilder: (context, index) {
                            if (catalog.page.items.isEmpty)
                              return const EmptyState(
                                icon: Icons.search_off,
                                title: 'Планы не найдены',
                                description: 'Измените запрос или фильтры',
                              );
                            if (index == catalog.page.items.length)
                              return catalog.loadingMore
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : TextButton(
                                      onPressed: controller.loadMore,
                                      child: Text(
                                        catalog.error == null
                                            ? 'Показать ещё'
                                            : 'Не удалось загрузить. Повторить',
                                      ),
                                    );
                            final plan = catalog.page.items[index];
                            return Column(
                              children: [
                                CalendarPlanCard(
                                  key: ValueKey(plan.id),
                                  plan: plan,
                                  onTap: () => _openPlan(plan),
                                ),
                                if (_openingPlanId == plan.id)
                                  const LinearProgressIndicator(),
                              ],
                            );
                          },
                        ),
                ),
              ),
            ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => const CalendarPlanCreate(),
                ),
              );
              if (!mounted) return;
              if (result == true) {
                controller.refresh();
              }
            },
            child: const Icon(Icons.add),
            tooltip: 'Create new calendar plan',
          ),
        );
      },
    );
  }

  Widget _buildWideCatalogList(
    BuildContext context,
    dynamic catalog,
    dynamic controller,
    UiDimensions dimensions,
  ) {
    final columns = Responsive.gridColumns(
      context,
      compact: 1,
      medium: 2,
      expanded: 3,
    );
    final items = catalog.page.items;
    final rowCount = (items.length / columns).ceil();
    final totalRows = rowCount + (catalog.hasMore ? 1 : 0);

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        dimensions.pagePadding,
        dimensions.rowGap,
        dimensions.pagePadding,
        96 + MediaQuery.paddingOf(context).bottom,
      ),
      itemCount: totalRows,
      separatorBuilder: (_, _) => SizedBox(height: dimensions.rowGap),
      itemBuilder: (context, rowIndex) {
        if (rowIndex == rowCount) {
          return catalog.loadingMore
              ? const Center(child: CircularProgressIndicator())
              : TextButton(
                  onPressed: controller.loadMore,
                  child: Text(
                    catalog.error == null
                        ? 'Показать ещё'
                        : 'Не удалось загрузить. Повторить',
                  ),
                );
        }
        final start = rowIndex * columns;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var c = 0; c < columns; c++) ...[
              if (c > 0) SizedBox(width: dimensions.rowGap),
              Expanded(
                child: start + c < items.length
                    ? Column(
                        children: [
                          CalendarPlanCard(
                            key: ValueKey(items[start + c].id),
                            plan: items[start + c],
                            onTap: () => _openPlan(items[start + c]),
                          ),
                          if (_openingPlanId == items[start + c].id)
                            const LinearProgressIndicator(),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ],
        );
      },
    );
  }
}
