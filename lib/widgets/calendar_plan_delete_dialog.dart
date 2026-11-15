import 'package:flutter/material.dart';
import 'package:workout_app/config/api_config.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/models/calendar_plan.dart';
import 'package:workout_app/services/api_client.dart';
import 'package:workout_app/services/base_api_service.dart';
import 'package:workout_app/widgets/instrument_modal.dart';

/// Returns true only after the server has deleted the captured plan.
Future<bool> confirmAndDeleteCalendarPlan(
  BuildContext context, {
  required CalendarPlan plan,
  required ApiClient apiClient,
}) async {
  Future<bool> confirm({List<Map<String, dynamic>>? variants}) async {
    if (!context.mounted) return false;
    final cascade = variants != null;
    final instrument = InstrumentTheme.of(context);
    final danger = instrument.peakEffortColor;
    final scheme = Theme.of(context).colorScheme;

    return await showInstrumentDialog<bool>(
          context: context,
          eyebrow: cascade ? 'CASCADE DELETE' : 'DELETE PLAN',
          title: cascade ? 'Удалить план с вариантами?' : 'Удалить план?',
          accentColor: danger,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '«${plan.name}»',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                cascade
                    ? 'Будут безвозвратно удалены план, все его варианты и связанные применения плана.'
                    : 'План и связанные применения плана будут удалены. Это действие нельзя отменить.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              if (variants != null && variants.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(height: 1, color: instrument.hairlineBorder),
                const SizedBox(height: 8),
                for (final variant in variants)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.subdirectory_arrow_right_rounded,
                          size: 16,
                          color: danger,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${variant['name'] ?? 'Без названия'}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
          actionsBuilder: (dialogContext) => [
            InstrumentActionButton(
              label: 'Отмена',
              variant: InstrumentActionVariant.secondary,
              onPressed: () => Navigator.pop(dialogContext, false),
            ),
            InstrumentActionButton(
              label: cascade ? 'Удалить всё' : 'Удалить',
              variant: InstrumentActionVariant.destructive,
              accentColor: danger,
              onPressed: () => Navigator.pop(dialogContext, true),
            ),
          ],
        ) ??
        false;
  }

  if (!await confirm() || !context.mounted) return false;
  final endpoint = ApiConfig.deleteCalendarPlanEndpoint(plan.id.toString());
  try {
    await apiClient.delete(endpoint, context: 'calendar_plan_detail_delete');
  } on ApiException catch (error) {
    if (error.statusCode != 400 ||
        !error.message.contains(
          'Cannot delete the original plan while variants exist',
        )) {
      rethrow;
    }
    if (!context.mounted) return false;
    List<Map<String, dynamic>> variants = [];
    try {
      final response = await apiClient.get(
        ApiConfig.listPlanVariantsEndpoint(plan.id.toString()),
        context: 'calendar_plan_delete_variants',
      );
      if (response is List) {
        variants = response
            .whereType<Map<String, dynamic>>()
            .where((variant) => variant['id'] != plan.id)
            .toList();
      }
    } catch (_) {
      // Keep the explicit cascade warning even when variant names cannot load.
    }
    if (!context.mounted ||
        !await confirm(variants: variants) ||
        !context.mounted)
      return false;
    await apiClient.delete(
      endpoint,
      queryParams: {'cascade': 'true'},
      context: 'calendar_plan_detail_delete_cascade',
    );
  }

  // A cache failure must not turn a successful deletion into a retryable error.
  try {
    await apiClient.invalidateCacheGroups([
      'plans:list',
      'plans:detail',
      'plans:variants',
      'plans:active',
      'plans:active_workouts',
      'workouts:list',
      'workouts:history_all',
    ]);
  } catch (_) {}
  return true;
}
