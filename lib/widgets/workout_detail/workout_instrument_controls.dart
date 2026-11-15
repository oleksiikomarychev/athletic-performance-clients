import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';

/// Unified compact instrument control bar combining Active Session timer/actions
/// and Readiness scaling controls in Execution Mode.
class WorkoutExecutionHeaderBar extends StatelessWidget {
  final bool isActiveSession;
  final bool isBusy;
  final bool canStartSession;
  final DateTime? lastFinishedAt;
  final Duration lastElapsed;
  final ValueListenable<Duration> elapsedListenable;
  final String Function(Duration) formatDuration;
  final VoidCallback onStartSession;
  final VoidCallback onCancelSession;
  final VoidCallback onCompleteAllSets;
  final VoidCallback onFinishSession;

  final int readinessScore;
  final double readinessFactor;
  final bool isApplyingReadiness;
  final bool canApplyReadiness;
  final VoidCallback onDecrementReadiness;
  final VoidCallback onIncrementReadiness;
  final VoidCallback onApplyReadiness;
  final Widget? footerSlot;

  const WorkoutExecutionHeaderBar({
    super.key,
    required this.isActiveSession,
    required this.isBusy,
    required this.canStartSession,
    required this.lastFinishedAt,
    required this.lastElapsed,
    required this.elapsedListenable,
    required this.formatDuration,
    required this.onStartSession,
    required this.onCancelSession,
    required this.onCompleteAllSets,
    required this.onFinishSession,
    required this.readinessScore,
    required this.readinessFactor,
    required this.isApplyingReadiness,
    required this.canApplyReadiness,
    required this.onDecrementReadiness,
    required this.onIncrementReadiness,
    required this.onApplyReadiness,
    this.footerSlot,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dimensions = UiDimensions.of(context);
    final instrument = InstrumentTheme.of(context);

    final Color sessionBg = isActiveSession
        ? Color.alphaBlend(
            instrument.successColor.withValues(alpha: 0.10),
            scheme.surfaceContainerLow,
          )
        : scheme.surfaceContainerLow;
    final Color sessionBorder = isActiveSession
        ? instrument.successColor.withValues(alpha: 0.45)
        : scheme.outlineVariant.withValues(alpha: 0.45);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(
        dimensions.pagePadding,
        dimensions.rowGap,
        dimensions.pagePadding,
        dimensions.rowGap,
      ),
      padding: EdgeInsets.all(dimensions.cardPadding),
      decoration: InstrumentTheme.cardDecoration(
        context,
        color: sessionBg,
        borderColor: sessionBorder,
        borderWidth: isActiveSession ? 1.5 : 1.0,
        radius: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSessionRow(context, theme, scheme, instrument),
          SizedBox(height: dimensions.rowGap),
          Divider(
            height: 1,
            thickness: 1,
            color: scheme.outlineVariant.withValues(alpha: 0.35),
          ),
          SizedBox(height: dimensions.rowGap),
          _buildReadinessRow(context, theme, scheme, dimensions),
          if (footerSlot != null) ...[
            SizedBox(height: dimensions.rowGap),
            Divider(
              height: 1,
              thickness: 1,
              color: scheme.outlineVariant.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 6),
            footerSlot!,
          ],
        ],
      ),
    );
  }

  Widget _buildSessionRow(
    BuildContext context,
    ThemeData theme,
    ColorScheme scheme,
    InstrumentTheme instrument,
  ) {
    final statusWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActiveSession
                ? instrument.successColor
                : scheme.onSurfaceVariant.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isActiveSession
                    ? 'ACTIVE SESSION'
                    : (lastFinishedAt != null ? 'LAST SESSION' : 'SESSION READY'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: InstrumentTheme.microLabel(
                  context,
                  color: isActiveSession
                      ? instrument.successColor
                      : scheme.onSurfaceVariant,
                ),
              ),
              if (isActiveSession)
                ValueListenableBuilder<Duration>(
                  valueListenable: elapsedListenable,
                  builder: (_, d, __) => Text(
                    formatDuration(d),
                    style: InstrumentTheme.tabular(
                      theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ) ??
                          const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                )
              else
                Text(
                  lastFinishedAt != null
                      ? formatDuration(lastElapsed)
                      : 'Tap Start to track',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: InstrumentTheme.tabular(
                    theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ) ??
                        const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        ),
      ],
    );

    final Widget actionsWidget = !isActiveSession
        ? FilledButton.icon(
            onPressed: canStartSession && !isBusy ? onStartSession : null,
            style: FilledButton.styleFrom(
              backgroundColor: instrument.successColor,
              foregroundColor: scheme.brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
              minimumSize: const Size(48, 48),
              tapTargetSize: MaterialTapTargetSize.padded,
              visualDensity: VisualDensity.standard,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.play_arrow_rounded, size: 18),
            label: const Text('Start'),
          )
        : Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: isBusy ? null : onCancelSession,
                style: OutlinedButton.styleFrom(
                  foregroundColor: scheme.error,
                  minimumSize: const Size(48, 48),
                  tapTargetSize: MaterialTapTargetSize.padded,
                  visualDensity: VisualDensity.standard,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: scheme.error.withValues(alpha: 0.6)),
                ),
                icon: const Icon(Icons.stop_circle_outlined, size: 16),
                label: const Text('Cancel'),
              ),
              SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  onPressed: isBusy ? null : onCompleteAllSets,
                  icon: const Icon(Icons.playlist_add_check_rounded, size: 22),
                  tooltip: 'Mark all as completed',
                  color: instrument.successColor,
                  style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    tapTargetSize: MaterialTapTargetSize.padded,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: isBusy ? null : onFinishSession,
                style: FilledButton.styleFrom(
                  backgroundColor: instrument.successColor,
                  foregroundColor: scheme.brightness == Brightness.dark
                      ? Colors.black
                      : Colors.white,
                  minimumSize: const Size(48, 48),
                  tapTargetSize: MaterialTapTargetSize.padded,
                  visualDensity: VisualDensity.standard,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.check_circle_outline, size: 16),
                label: const Text('Finish'),
              ),
            ],
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360 && isActiveSession) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              statusWidget,
              const SizedBox(height: 8),
              actionsWidget,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: statusWidget),
            const SizedBox(width: 8),
            actionsWidget,
          ],
        );
      },
    );
  }

  Widget _buildReadinessRow(
    BuildContext context,
    ThemeData theme,
    ColorScheme scheme,
    UiDimensions dimensions,
  ) {
    final labelBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'READINESS',
          style: InstrumentTheme.microLabel(context),
        ),
        const SizedBox(height: 2),
        Text(
          '$readinessScore/10 · ×${readinessFactor.toStringAsFixed(2)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: InstrumentTheme.tabular(
            theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ) ??
                const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );

    final stepperAndApply = Wrap(
      spacing: 4,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: IconButton(
            icon: const Icon(Icons.remove, size: 18),
            color: scheme.primary,
            tooltip: 'Уменьшить',
            style: IconButton.styleFrom(
              minimumSize: const Size(48, 48),
              tapTargetSize: MaterialTapTargetSize.padded,
            ),
            onPressed: onDecrementReadiness,
          ),
        ),
        Container(
          constraints: const BoxConstraints(minWidth: 36),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: InstrumentTheme.cardDecoration(
            context,
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.65),
            radius: 8,
          ),
          child: Text(
            readinessScore.toString(),
            textAlign: TextAlign.center,
            style: InstrumentTheme.tabular(
              theme.textTheme.titleSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ) ??
                  const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        SizedBox(
          width: 48,
          height: 48,
          child: IconButton(
            icon: const Icon(Icons.add, size: 18),
            color: scheme.primary,
            tooltip: 'Увеличить',
            style: IconButton.styleFrom(
              minimumSize: const Size(48, 48),
              tapTargetSize: MaterialTapTargetSize.padded,
            ),
            onPressed: onIncrementReadiness,
          ),
        ),
        FilledButton.tonal(
          onPressed: (isApplyingReadiness || !canApplyReadiness)
              ? null
              : onApplyReadiness,
          style: FilledButton.styleFrom(
            minimumSize: const Size(48, 48),
            tapTargetSize: MaterialTapTargetSize.padded,
            visualDensity: VisualDensity.standard,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: isApplyingReadiness
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Применить'),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              labelBlock,
              const SizedBox(height: 4),
              stepperAndApply,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: labelBlock),
            const SizedBox(width: 8),
            stepperAndApply,
          ],
        );
      },
    );
  }
}

/// Exercise section header with muscle/equipment meta and live tabular volume badge.
class ExerciseSummaryHeader extends StatelessWidget {
  final String name;
  final String muscleGroup;
  final String equipment;
  final int setCount;
  final double totalVolume;
  final VoidCallback? onDeleteExercise;

  const ExerciseSummaryHeader({
    super.key,
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    required this.setCount,
    required this.totalVolume,
    this.onDeleteExercise,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dimensions = UiDimensions.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 2,
        top: 6,
        bottom: dimensions.rowGap,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.surfaceContainerHigh,
            ),
            child: Icon(
              Icons.fitness_center_rounded,
              color: scheme.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '${muscleGroup.isNotEmpty ? muscleGroup : 'No muscle group'} · ${equipment.isNotEmpty ? equipment : 'No equipment'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$setCount× · ${totalVolume.round()} kg',
              style: InstrumentTheme.tabular(
                InstrumentTheme.microLabel(context, color: scheme.onSurface),
              ),
            ),
          ),
          if (onDeleteExercise != null)
            SizedBox(
              width: 48,
              height: 48,
              child: IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                color: scheme.error,
                tooltip: 'Delete exercise',
                style: IconButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  tapTargetSize: MaterialTapTargetSize.padded,
                ),
                onPressed: onDeleteExercise,
              ),
            ),
        ],
      ),
    );
  }
}

/// Column micro-labels aligned with [SetCapsuleRow].
class SetTableColumnHeaders extends StatelessWidget {
  const SetTableColumnHeaders({super.key});

  @override
  Widget build(BuildContext context) {
    final dimensions = UiDimensions.of(context);
    final labelStyle = InstrumentTheme.microLabel(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: dimensions.rowGap * 2,
        vertical: dimensions.rowGap,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              'DONE',
              style: labelStyle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 22,
            child: Text(
              'SET',
              style: labelStyle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: dimensions.rowGap),
          Expanded(
            flex: 4,
            child: Text(
              'KG',
              textAlign: TextAlign.center,
              style: labelStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: dimensions.rowGap),
          Expanded(
            flex: 3,
            child: Text(
              'REPS',
              textAlign: TextAlign.center,
              style: labelStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: dimensions.rowGap),
          Expanded(
            flex: 3,
            child: Text(
              'RPE',
              textAlign: TextAlign.center,
              style: labelStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

/// Capsule-style set row with separated input cells, tabular numerals,
/// RPE semantic color spectrum, and visual provenance for auto-derived values.
class SetCapsuleRow extends StatelessWidget {
  final int setIndex;
  final bool isCompleted;
  final bool canToggle;
  final bool isBusy;
  final TextEditingController weightController;
  final TextEditingController repsController;
  final TextEditingController rpeController;
  final double? currentRpeValue;
  final String? autoDerivedField; // 'weight' | 'reps' | 'rpe' | null
  final VoidCallback? onToggleCompletion;
  final VoidCallback onDelete;
  final ValueChanged<String> onWeightChanged;
  final ValueChanged<String> onRepsChanged;
  final ValueChanged<String> onRpeChanged;
  final VoidCallback onWeightSubmitted;
  final VoidCallback onRepsSubmitted;
  final VoidCallback onRpeSubmitted;

  const SetCapsuleRow({
    super.key,
    required this.setIndex,
    required this.isCompleted,
    required this.canToggle,
    required this.isBusy,
    required this.weightController,
    required this.repsController,
    required this.rpeController,
    required this.currentRpeValue,
    required this.autoDerivedField,
    required this.onToggleCompletion,
    required this.onDelete,
    required this.onWeightChanged,
    required this.onRepsChanged,
    required this.onRpeChanged,
    required this.onWeightSubmitted,
    required this.onRepsSubmitted,
    required this.onRpeSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dimensions = UiDimensions.of(context);
    final instrument = InstrumentTheme.of(context);

    final Color rowBg = isCompleted
        ? Color.alphaBlend(
            instrument.successColor.withValues(alpha: 0.12),
            scheme.surfaceContainerLow,
          )
        : scheme.surfaceContainerLowest.withValues(alpha: 0.45);
    final Color rowBorder = isCompleted
        ? instrument.successColor.withValues(alpha: 0.45)
        : scheme.outlineVariant.withValues(alpha: 0.3);

    final Color rpeColor = instrument.colorForRpe(currentRpeValue, scheme);
    final bool hasRpe = currentRpeValue != null && currentRpeValue! > 0;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: dimensions.rowGap,
        vertical: 4,
      ),
      decoration: InstrumentTheme.cardDecoration(
        context,
        color: rowBg,
        borderColor: rowBorder,
        radius: 12,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: canToggle ? onToggleCompletion : null,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: dimensions.rowGap,
              vertical: dimensions.rowGap,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Checkbox(
                    value: isCompleted,
                    activeColor: instrument.successColor,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    onChanged: canToggle ? (_) => onToggleCompletion?.call() : null,
                  ),
                ),
                SizedBox(
                  width: 22,
                  child: Text(
                    '${setIndex + 1}',
                    textAlign: TextAlign.center,
                    style: InstrumentTheme.tabular(
                      theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isCompleted
                                ? instrument.successColor
                                : scheme.onSurfaceVariant,
                          ) ??
                          const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                SizedBox(width: dimensions.rowGap),
                Expanded(
                  flex: 4,
                  child: _CapsuleCellInput(
                    controller: weightController,
                    hint: 'kg',
                    enabled: !isCompleted,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: false,
                    ),
                    isAutoDerived: autoDerivedField == 'weight',
                    onChanged: onWeightChanged,
                    onSubmitted: onWeightSubmitted,
                  ),
                ),
                SizedBox(width: dimensions.rowGap),
                Expanded(
                  flex: 3,
                  child: _CapsuleCellInput(
                    controller: repsController,
                    hint: 'reps',
                    enabled: !isCompleted,
                    keyboardType: TextInputType.number,
                    isAutoDerived: autoDerivedField == 'reps',
                    onChanged: onRepsChanged,
                    onSubmitted: onRepsSubmitted,
                  ),
                ),
                SizedBox(width: dimensions.rowGap),
                Expanded(
                  flex: 3,
                  child: _CapsuleCellInput(
                    controller: rpeController,
                    hint: 'RPE',
                    enabled: !isCompleted,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: false,
                    ),
                    isAutoDerived: autoDerivedField == 'rpe',
                    accentColor: hasRpe ? rpeColor : null,
                    onChanged: onRpeChanged,
                    onSubmitted: onRpeSubmitted,
                  ),
                ),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    color: scheme.onSurfaceVariant,
                    onPressed: isBusy ? null : onDelete,
                    padding: EdgeInsets.zero,
                    tooltip: 'Delete set',
                    style: IconButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      tapTargetSize: MaterialTapTargetSize.padded,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CapsuleCellInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool enabled;
  final TextInputType keyboardType;
  final bool isAutoDerived;
  final Color? accentColor;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;

  const _CapsuleCellInput({
    required this.controller,
    required this.hint,
    required this.enabled,
    required this.keyboardType,
    required this.isAutoDerived,
    this.accentColor,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dimensions = UiDimensions.of(context);
    final instrument = InstrumentTheme.of(context);

    final Color effectiveAccent = isAutoDerived
        ? instrument.derivedColor
        : (accentColor ?? scheme.outlineVariant);

    final Color fillColor = accentColor != null
        ? Color.alphaBlend(
            accentColor!.withValues(alpha: 0.12),
            scheme.surfaceContainerHighest.withValues(alpha: 0.45),
          )
        : scheme.surfaceContainerHighest.withValues(alpha: 0.55);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          textAlign: TextAlign.center,
          style: InstrumentTheme.tabular(
            theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: accentColor ?? scheme.onSurface,
                ) ??
                const TextStyle(fontWeight: FontWeight.w700),
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: fillColor,
            contentPadding: EdgeInsets.symmetric(
              vertical: dimensions.rowGap + 2,
              horizontal: 4,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: effectiveAccent.withValues(
                  alpha: isAutoDerived || accentColor != null ? 0.75 : 0.35,
                ),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: effectiveAccent.withValues(
                  alpha: isAutoDerived || accentColor != null ? 0.75 : 0.35,
                ),
                width: isAutoDerived ? 1.25 : 1.0,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: effectiveAccent.withValues(alpha: 0.25),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: scheme.primary, width: 1.5),
            ),
            hintText: hint,
            hintStyle: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
          onChanged: onChanged,
          onSubmitted: (_) => onSubmitted(),
        ),
        if (isAutoDerived)
          Positioned(
            top: -6,
            right: 4,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: instrument.derivedColor.withValues(alpha: 0.65),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  'AUTO',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: instrument.derivedColor,
                    height: 1.1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
