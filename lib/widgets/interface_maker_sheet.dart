import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/providers/interface_maker_provider.dart';

/// Descriptor for a floating pill inside [CanvasPillStrip].
@immutable
class CanvasPillItem {
  final Key? key;
  final String label;
  final IconData? icon;
  final bool selected;
  final Color? accentColor;
  final VoidCallback onTap;

  const CanvasPillItem({
    this.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.accentColor,
    required this.onTap,
  });
}

/// Layer 1 horizontal pill strip rendered directly on the ambient canvas
/// with zero enclosing wrapper card box.
class CanvasPillStrip extends StatelessWidget {
  final List<CanvasPillItem> items;
  final EdgeInsetsGeometry padding;
  final double spacing;

  const CanvasPillStrip({
    super.key,
    required this.items,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) SizedBox(width: spacing),
            _CanvasPill(
              item: items[i],
              isDark: isDark,
              scheme: scheme,
              instrument: instrument,
              theme: theme,
            ),
          ],
        ],
      ),
    );
  }
}

class _CanvasPill extends StatelessWidget {
  final CanvasPillItem item;
  final bool isDark;
  final ColorScheme scheme;
  final InstrumentTheme instrument;
  final ThemeData theme;

  const _CanvasPill({
    required this.item,
    required this.isDark,
    required this.scheme,
    required this.instrument,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final accent = item.accentColor ?? instrument.workingAura;
    final fillColor = item.selected
        ? accent.withValues(alpha: isDark ? 0.18 : 0.14)
        : (isDark
              ? InstrumentPalette.obsidianCardLow.withValues(alpha: 0.85)
              : scheme.surfaceContainerLow);
    final borderColor = item.selected
        ? accent.withValues(alpha: 0.72)
        : (isDark
              ? instrument.hairlineBorder
              : scheme.outlineVariant.withValues(alpha: 0.6));
    final fgColor = item.selected ? accent : scheme.onSurface;

    return Semantics(
      button: true,
      selected: item.selected,
      label: item.label,
      child: Material(
        key: item.key,
        color: Colors.transparent,
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(999),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: borderColor, width: 1.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.icon != null) ...[
                      Icon(item.icon, size: 15, color: fgColor),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      item.label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: fgColor,
                        fontWeight: item.selected
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Modal customizer ("⊞ Сетка") for CARROT Interface Maker:
/// discipline presets, 4 telemetry slot assignments, chart/voice switches,
/// and module ordering & visibility.
class InterfaceMakerSheet extends ConsumerWidget {
  const InterfaceMakerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const InterfaceMakerSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(interfaceMakerProvider);
    final controller = ref.read(interfaceMakerProvider.notifier);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? InstrumentPalette.obsidianCardLow : scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: isDark ? instrument.hairlineBorder : scheme.outlineVariant,
          ),
        ),
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.78,
        minChildSize: 0.48,
        maxChildSize: 0.94,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(
                    Icons.grid_view_rounded,
                    size: 20,
                    color: instrument.workingAura,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Сетка и модули экрана',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: controller.resetToDefault,
                    child: const Text('Сбросить'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'ПРЕСЕТЫ ДИСЦИПЛИНЫ',
                style: InstrumentTheme.microLabel(context),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: InterfacePreset.values
                    .map((preset) {
                      final selected = config.preset == preset;
                      return ChoiceChip(
                        label: Text(preset.label),
                        selected: selected,
                        onSelected: (_) => controller.applyPreset(preset),
                      );
                    })
                    .toList(growable: false),
              ),
              const SizedBox(height: 16),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('График-волна в карточках'),
                subtitle: const Text(
                  'Отключите для компактного режима без графиков',
                ),
                value: config.showChart,
                onChanged: controller.setShowChart,
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Характерный CARROT-брифинг'),
                subtitle: const Text(
                  'Саркастичная сводка нагрузки вместо сухой тактической',
                ),
                value: config.snarkyVoice,
                onChanged: controller.setSnarkyVoice,
              ),
              const Divider(height: 24),
              Text(
                '4 СЛОТА ТЕЛЕМЕТРИИ (DATA POINT PICKER)',
                style: InstrumentTheme.microLabel(context),
              ),
              const SizedBox(height: 8),
              for (int i = 0; i < config.slots.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 72,
                          child: Text(
                            'Слот ${i + 1}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<MetricSlot>(
                            value: config.slots[i],
                            isExpanded: true,
                            underline: const SizedBox.shrink(),
                            onChanged: (next) {
                              if (next != null) {
                                controller.setSlot(i, next);
                              }
                            },
                            items: MetricSlot.values
                                .map(
                                  (m) => DropdownMenuItem(
                                    value: m,
                                    child: Text(
                                      m.displayName,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(growable: false),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const Divider(height: 24),
              Text(
                'МОДУЛИ И ПОРЯДОК ЭКРАНА',
                style: InstrumentTheme.microLabel(context),
              ),
              const SizedBox(height: 8),
              for (int idx = 0; idx < config.moduleOrder.length; idx++) ...[
                _ModuleConfigRow(
                  module: config.moduleOrder[idx],
                  visible: config.isModuleVisible(config.moduleOrder[idx]),
                  canMoveUp: idx > 0,
                  canMoveDown: idx < config.moduleOrder.length - 1,
                  onToggle: () =>
                      controller.toggleModuleVisibility(config.moduleOrder[idx]),
                  onMoveUp: () => controller.moveModule(idx, idx - 1),
                  onMoveDown: () => controller.moveModule(idx, idx + 1),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ModuleConfigRow extends StatelessWidget {
  final LayoutModule module;
  final bool visible;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onToggle;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  const _ModuleConfigRow({
    required this.module,
    required this.visible,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onToggle,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Row(
        children: [
          Checkbox(
            value: visible,
            onChanged: (_) => onToggle(),
          ),
          Expanded(
            child: Text(
              module.displayName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            tooltip: 'Выше',
            onPressed: canMoveUp ? onMoveUp : null,
            icon: const Icon(Icons.keyboard_arrow_up),
          ),
          IconButton(
            tooltip: 'Ниже',
            onPressed: canMoveDown ? onMoveDown : null,
            icon: const Icon(Icons.keyboard_arrow_down),
          ),
        ],
      ),
    );
  }
}
