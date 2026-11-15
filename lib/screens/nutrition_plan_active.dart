import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/providers/interface_maker_provider.dart';
import 'package:workout_app/providers/plan_providers.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/empty_state.dart';
import 'package:workout_app/widgets/error_message.dart';
import 'package:workout_app/widgets/instrument_metric_matrix.dart';
import 'package:workout_app/widgets/loading_indicator.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';

class NutritionPlanActive extends ConsumerWidget {
  const NutritionPlanActive({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePlanAsync = ref.watch(activeAppliedPlanProvider);
    final activePlanSnapshot = activePlanAsync.asData?.value;

    return AssistantChatHost(
      contextBuilder: () async => {
        'screen': 'nutrition_plan_active',
        'plan_name': activePlanSnapshot?.calendarPlan.name,
        'has_nutrition_plan':
            activePlanSnapshot?.calendarPlan.nutritionPlan?.isNotEmpty ?? false,
      },
      builder: (context, openChat) {
        final topInset = AmbientScaffoldShell.topContentInset(context);
        final bottomInset = AmbientScaffoldShell.bottomContentInset(context);

        return AmbientScaffoldShell(
          appBar: PrimaryAppBar(
            title: 'Active Nutrition Plan',
            onTitleTap: openChat,
            showBack: true,
          ),
          body: activePlanAsync.when(
            loading: () => Padding(
              padding: EdgeInsets.only(top: topInset, bottom: bottomInset),
              child: const LoadingIndicator(),
            ),
            error: (error, _) => Padding(
              padding: EdgeInsets.only(top: topInset, bottom: bottomInset),
              child: ErrorMessage(
                message: 'Error: $error',
                onRetry: () => ref.invalidate(activeAppliedPlanProvider),
              ),
            ),
            data: (activePlan) {
              if (activePlan == null) {
                return Padding(
                  padding: EdgeInsets.only(top: topInset, bottom: bottomInset),
                  child: const EmptyState(
                    icon: Icons.calendar_today_outlined,
                    title: 'No active calendar plan',
                    description:
                        'Apply a calendar plan to view its nutrition targets.',
                  ),
                );
              }

              final nutritionPlan = activePlan.calendarPlan.nutritionPlan;
              if (nutritionPlan == null || nutritionPlan.isEmpty) {
                return Padding(
                  padding: EdgeInsets.only(top: topInset, bottom: bottomInset),
                  child: const EmptyState(
                    icon: Icons.restaurant_menu_rounded,
                    title: 'No nutrition plan configured',
                    description:
                        'The active calendar plan does not define nutrition guidelines.',
                  ),
                );
              }

              final summaryCells = _extractMacroCells(context, nutritionPlan);
              final sections = nutritionPlan.entries
                  .where((e) => !_isMacroSummaryKey(e.key))
                  .toList(growable: false);

              return ListView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  topInset + 8,
                  16,
                  bottomInset + 24,
                ),
                children: [
                  _ActivePlanSummaryCard(
                    planName: activePlan.calendarPlan.name,
                    macroCells: summaryCells,
                  ),
                  if (sections.isNotEmpty) const SizedBox(height: 14),
                  for (int i = 0; i < sections.length; i++) ...[
                    _NutritionSectionCard(
                      sectionKey: sections[i].key,
                      value: sections[i].value,
                    ),
                    if (i < sections.length - 1) const SizedBox(height: 12),
                  ],
                ],
              );
            },
          ),
        );
      },
    );
  }

  static bool _isMacroSummaryKey(String rawKey) {
    final k = rawKey.toLowerCase();
    return k == 'kcal' ||
        k == 'calories' ||
        k == 'protein' ||
        k == 'protein_g' ||
        k == 'fat' ||
        k == 'fats' ||
        k == 'fat_g' ||
        k == 'carbs' ||
        k == 'carbohydrates' ||
        k == 'carbs_g';
  }

  static List<InstrumentMetricCellData> _extractMacroCells(
    BuildContext context,
    Map<String, dynamic> source,
  ) {
    String? pickValue(List<String> keys) {
      for (final entry in source.entries) {
        if (keys.contains(entry.key.toLowerCase()) && entry.value != null) {
          return entry.value.toString();
        }
      }
      return null;
    }

    final kcal = pickValue(const ['kcal', 'calories']);
    final protein = pickValue(const ['protein', 'protein_g']);
    final fat = pickValue(const ['fat', 'fats', 'fat_g']);
    final carbs = pickValue(const ['carbs', 'carbohydrates', 'carbs_g']);

    if (kcal == null && protein == null && fat == null && carbs == null) {
      return const [];
    }

    final instrument = InstrumentTheme.of(context);
    return [
      InstrumentMetricCellData(
        slot: MetricSlot.tonnage,
        label: 'KCAL',
        value: kcal ?? '—',
        valueColor: instrument.stormAura,
      ),
      InstrumentMetricCellData(
        slot: MetricSlot.peakIntensity,
        label: 'PROTEIN',
        value: protein != null ? '${protein}g' : '—',
        valueColor: instrument.deloadAura,
      ),
      InstrumentMetricCellData(
        slot: MetricSlot.avgRpe,
        label: 'FAT',
        value: fat != null ? '${fat}g' : '—',
        valueColor: instrument.moderateEffortColor,
      ),
      InstrumentMetricCellData(
        slot: MetricSlot.setsCount,
        label: 'CARB',
        value: carbs != null ? '${carbs}g' : '—',
        valueColor: instrument.workingAura,
      ),
    ];
  }
}

class _ActivePlanSummaryCard extends StatelessWidget {
  final String planName;
  final List<InstrumentMetricCellData> macroCells;

  const _ActivePlanSummaryCard({
    required this.planName,
    required this.macroCells,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final instrument = InstrumentTheme.of(context);

    return Container(
      decoration: InstrumentTheme.instrumentCardDecoration(
        context,
        accentColor: instrument.deloadAura,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACTIVE NUTRITION TARGET',
                  style: InstrumentTheme.microLabel(
                    context,
                    color: instrument.deloadAura,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  planName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (macroCells.isNotEmpty) ...[
            Container(height: 1, color: instrument.hairlineBorder),
            InstrumentMetricMatrix(
              cells: macroCells,
              accentColor: instrument.deloadAura,
            ),
          ],
        ],
      ),
    );
  }
}

class _NutritionSectionCard extends StatelessWidget {
  final String sectionKey;
  final dynamic value;

  const _NutritionSectionCard({
    required this.sectionKey,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);

    return Container(
      decoration: InstrumentTheme.instrumentCardDecoration(context),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NUTRITION MODULE',
                  style: InstrumentTheme.microLabel(context),
                ),
                const SizedBox(height: 4),
                Text(
                  sectionKey,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: instrument.hairlineBorder),
          if (value is Map)
            _buildMapEntries(context, Map<String, dynamic>.from(value as Map))
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                value?.toString() ?? 'N/A',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapEntries(BuildContext context, Map<String, dynamic> map) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final entries = map.entries.toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < entries.length; i++) ...[
          if (i > 0) Container(height: 1, color: instrument.hairlineBorder),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 4,
              children: [
                Text(
                  entries[i].key,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  entries[i].value?.toString() ?? 'N/A',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
