import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:workout_app/config/constants/theme_constants.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';

class BottomNavBarItem {
  final IconData icon;
  final String label;
  final String? activeLabel;

  const BottomNavBarItem({
    required this.icon,
    required this.label,
    this.activeLabel,
  });
}

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavBarItem> items;
  final Color? backgroundColor;
  final double elevation;
  final double height;
  final double iconSize;
  final double selectedFontSize;
  final double unselectedFontSize;
  final Duration animationDuration;
  final Curve animationCurve;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.elevation = 8.0,
    this.height = kBottomNavigationBarHeight,
    this.iconSize = 24.0,
    this.selectedFontSize = 12.0,
    this.unselectedFontSize = 12.0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
  }) : assert(items.length >= 2, 'BottomNavBar must have at least 2 items');

  @override
  Widget build(BuildContext context) {
    final dimensions = UiDimensions.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final instrument = InstrumentTheme.of(context);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final scaledLabelHeight =
        MediaQuery.textScalerOf(context).scale(
          selectedFontSize > unselectedFontSize
              ? selectedFontSize
              : unselectedFontSize,
        ) *
        1.1;
    final barHeight = height > iconSize + 4 + scaledLabelHeight * 2 + 20
        ? height
        : iconSize + 4 + scaledLabelHeight * 2 + 20;
    final outerHorizontalPadding = dimensions.navigationInset;
    final islandOffset = dimensions.navigationInset;

    final dockFill = backgroundColor ??
        (isDark
            ? instrument.dockBackground.withValues(alpha: 0.80)
            : const Color(0xFF0E3A6B).withValues(alpha: 0.84));
    final dockBorder = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.28);

    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: SizedBox(
        height: barHeight + bottomPadding + islandOffset,
        child: SafeArea(
          top: false,
          bottom: true,
          child: Padding(
            padding: EdgeInsets.only(
              left: outerHorizontalPadding,
              right: outerHorizontalPadding,
              bottom: islandOffset,
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark || backgroundColor != null ? dockFill : null,
                      gradient: isDark || backgroundColor != null
                          ? null
                          : LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: AppGradients.blue.colors
                                  .map((c) => c.withValues(alpha: 0.86))
                                  .toList(growable: false),
                            ),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: dockBorder, width: 1.0),
                    ),
                    child: SizedBox(
                      height: barHeight - 6,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          items.length,
                          (index) => Expanded(
                            child: _buildNavItem(
                              context: context,
                              item: items[index],
                              isSelected: index == currentIndex,
                              onTap: () => onTap(index),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required BottomNavBarItem item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final instrument = InstrumentTheme.of(context);
    final label = isSelected ? (item.activeLabel ?? item.label) : item.label;
    final isDark = theme.brightness == Brightness.dark;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);

    final activeAccent = isDark ? instrument.workingAura : Colors.white;
    final Color iconColor = isDark
        ? (isSelected ? activeAccent : const Color(0xFF94A3B8))
        : (isSelected ? Colors.white : Colors.white.withValues(alpha: 0.78));
    final Color textColor = iconColor;
    final Color pillFill = isSelected
        ? activeAccent.withValues(alpha: isDark ? 0.16 : 0.22)
        : Colors.transparent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: reducedMotion ? Duration.zero : animationDuration,
          curve: animationCurve,
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: pillFill,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: iconSize, color: iconColor),
              const SizedBox(height: 3.0),
              AnimatedDefaultTextStyle(
                duration: reducedMotion ? Duration.zero : animationDuration,
                curve: animationCurve,
                style: textTheme.labelSmall!.copyWith(
                  fontSize: isSelected ? selectedFontSize : unselectedFontSize,
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  height: 1.1,
                ),
                child: Text(
                  label,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
