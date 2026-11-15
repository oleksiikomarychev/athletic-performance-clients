import 'package:flutter/material.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/providers/interface_maker_provider.dart';
import 'package:workout_app/src/api/nutrition_api.dart';
import 'package:workout_app/src/widgets/snack_utils.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/instrument_metric_matrix.dart';
import 'package:workout_app/widgets/instrument_modal.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';

import 'nutrition_plan_create.dart';

class NutritionPlanDetail extends StatefulWidget {
  final Map<String, dynamic> sessionData;

  const NutritionPlanDetail({super.key, required this.sessionData});

  @override
  State<NutritionPlanDetail> createState() => _NutritionPlanDetailState();
}

class _NutritionPlanDetailState extends State<NutritionPlanDetail> {
  Future<void> _deleteSession() async {
    final instrument = InstrumentTheme.of(context);
    final confirmed = await showInstrumentDialog<bool>(
      context: context,
      eyebrow: 'DESTRUCTIVE ACTION',
      title: 'Delete Session',
      message: 'Are you sure you want to delete this session?',
      accentColor: instrument.peakEffortColor,
      actions: [
        InstrumentActionButton(
          label: 'Cancel',
          variant: InstrumentActionVariant.secondary,
          onPressed: () => Navigator.pop(context, false),
        ),
        InstrumentActionButton(
          label: 'Delete',
          variant: InstrumentActionVariant.destructive,
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );

    if (confirmed == true) {
      try {
        await NutritionApi.deleteSession(widget.sessionData['session_id']);
        if (!mounted) return;
        showAppSnackBar(context, 'Session deleted successfully');
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        showAppSnackBar(context, 'Error: $e', isError: true);
      }
    }
  }

  Future<void> _editSession() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            NutritionPlanCreate(initialPlan: widget.sessionData),
      ),
    );
    if (result != null && mounted) {
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entries = widget.sessionData['entries'] as List<dynamic>? ?? const [];

    return AssistantChatHost(
      contextBuilder: () async => {
        'screen': 'nutrition_plan_detail',
        'entities': {
          'session_id': widget.sessionData['session_id'],
          'user_id': widget.sessionData['user_id'],
          'entries_count': entries.length,
        },
      },
      builder: (context, openChat) {
        final topInset = AmbientScaffoldShell.topContentInset(context);
        final bottomInset = AmbientScaffoldShell.bottomContentInset(context);

        return AmbientScaffoldShell(
          appBar: PrimaryAppBar(
            title: l10n.nutritionSessionTitle(
              widget.sessionData['session_id'].toString(),
            ),
            onTitleTap: openChat,
            showBack: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit session',
                onPressed: _editSession,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                tooltip: 'Delete session',
                onPressed: _deleteSession,
              ),
            ],
          ),
          body: ListView(
            padding: EdgeInsets.fromLTRB(
              16,
              topInset + 8,
              16,
              bottomInset + 24,
            ),
            children: [
              _SessionTelemetryCard(
                sessionData: widget.sessionData,
                entries: entries,
                l10n: l10n,
              ),
              const SizedBox(height: 14),
              _NutritionEntriesModule(entries: entries, l10n: l10n),
            ],
          ),
        );
      },
    );
  }
}

class _SessionTelemetryCard extends StatelessWidget {
  final Map<String, dynamic> sessionData;
  final List<dynamic> entries;
  final AppLocalizations l10n;

  const _SessionTelemetryCard({
    required this.sessionData,
    required this.entries,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);

    final macroCells = _buildMacroSummaryCells(context);
    final dateRaw = sessionData['date']?.toString();
    final dateText = (dateRaw != null && dateRaw.isNotEmpty)
        ? dateRaw.split('T').first
        : 'N/A';

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
                  'SESSION TELEMETRY',
                  style: InstrumentTheme.microLabel(
                    context,
                    color: instrument.deloadAura,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.nutritionSessionTitle(
                    sessionData['session_id'].toString(),
                  ),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          if (macroCells != null) ...[
            Container(height: 1, color: instrument.hairlineBorder),
            InstrumentMetricMatrix(
              cells: macroCells,
              accentColor: instrument.deloadAura,
            ),
          ],
          Container(height: 1, color: instrument.hairlineBorder),
          _TelemetryLineRow(
            label: l10n.userIdLabel(sessionData['user_id'].toString()),
            value: '${entries.length} ${l10n.nutritionEntriesLabel.toLowerCase()}',
          ),
          Container(height: 1, color: instrument.hairlineBorder),
          _TelemetryLineRow(label: l10n.dateLabel, value: dateText),
          Container(height: 1, color: instrument.hairlineBorder),
          _TelemetryLineRow(
            label: l10n.workoutIdLabel,
            value: sessionData['workout_id']?.toString() ?? 'N/A',
          ),
          Container(height: 1, color: instrument.hairlineBorder),
          _TelemetryLineRow(
            label: l10n.appliedPlanWorkoutIdLabel,
            value: sessionData['applied_plan_workout_id']?.toString() ?? 'N/A',
            mutedValue: scheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  List<InstrumentMetricCellData>? _buildMacroSummaryCells(
    BuildContext context,
  ) {
    double? kcal = _sumNumericField(['kcal', 'calories']);
    double? protein = _sumNumericField(['protein', 'protein_g']);
    double? fat = _sumNumericField(['fat', 'fats', 'fat_g']);
    double? carbs = _sumNumericField(['carbs', 'carbohydrates', 'carbs_g']);

    if (kcal == null && protein == null && fat == null && carbs == null) {
      return null;
    }

    final instrument = InstrumentTheme.of(context);
    String fmt(double? v, String unit) {
      if (v == null) return '—';
      final s = v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);
      return unit.isEmpty ? s : '$s$unit';
    }

    return [
      InstrumentMetricCellData(
        slot: MetricSlot.tonnage,
        label: 'KCAL',
        value: fmt(kcal, ''),
        valueColor: instrument.stormAura,
      ),
      InstrumentMetricCellData(
        slot: MetricSlot.peakIntensity,
        label: 'PROTEIN',
        value: fmt(protein, 'g'),
        valueColor: instrument.deloadAura,
      ),
      InstrumentMetricCellData(
        slot: MetricSlot.avgRpe,
        label: 'FAT',
        value: fmt(fat, 'g'),
        valueColor: instrument.moderateEffortColor,
      ),
      InstrumentMetricCellData(
        slot: MetricSlot.setsCount,
        label: 'CARB',
        value: fmt(carbs, 'g'),
        valueColor: instrument.workingAura,
      ),
    ];
  }

  double? _sumNumericField(List<String> keys) {
    double? total;
    for (final raw in entries) {
      if (raw is! Map) continue;
      for (final key in keys) {
        final v = raw[key];
        final parsed = v is num ? v.toDouble() : double.tryParse('$v');
        if (parsed != null) {
          total = (total ?? 0) + parsed;
          break;
        }
      }
    }
    if (total != null) return total;
    for (final key in keys) {
      final v = sessionData[key];
      final parsed = v is num ? v.toDouble() : double.tryParse('$v');
      if (parsed != null) return parsed;
    }
    return null;
  }
}

class _TelemetryLineRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? mutedValue;

  const _TelemetryLineRow({
    required this.label,
    required this.value,
    this.mutedValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 4,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: mutedValue ?? scheme.onSurface,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionEntriesModule extends StatelessWidget {
  final List<dynamic> entries;
  final AppLocalizations l10n;

  const _NutritionEntriesModule({required this.entries, required this.l10n});

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
                  'INTAKE LOG · ${entries.length}',
                  style: InstrumentTheme.microLabel(context).copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.nutritionEntriesLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: instrument.hairlineBorder),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                l10n.nutritionNoEntries,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            )
          else
            for (int i = 0; i < entries.length; i++) ...[
              if (i > 0) Container(height: 1, color: instrument.hairlineBorder),
              _NutritionEntryRow(
                entryMap: Map<String, dynamic>.from(entries[i] as Map),
                l10n: l10n,
              ),
            ],
        ],
      ),
    );
  }
}

class _NutritionEntryRow extends StatelessWidget {
  final Map<String, dynamic> entryMap;
  final AppLocalizations l10n;

  const _NutritionEntryRow({required this.entryMap, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final typeText = entryMap['type']?.toString() ?? 'Unknown';
    final dosageText =
        '${entryMap['dosage'] ?? 0} ${entryMap['unit'] ?? ''}'.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entryMap['name']?.toString() ?? 'Unknown',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              Text(
                '${l10n.typeLabel}: $typeText',
                style: InstrumentTheme.microLabel(
                  context,
                  color: instrument.workingAura,
                ),
              ),
              Text(
                '${l10n.dosageLabel}: $dosageText',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
