import 'package:flutter/material.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/widgets/instrument_modal.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Widget? action;
  final double? iconSize;
  final Color? iconColor;
  final EdgeInsetsGeometry? padding;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.action,
    this.iconSize = 56.0,
    this.iconColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final instrument = InstrumentTheme.of(context);
    final effectiveColor = iconColor ?? instrument.workingAura;

    return Center(
      child: SingleChildScrollView(
        padding: padding ?? const EdgeInsets.all(24.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(24),
          decoration: InstrumentTheme.instrumentCardDecoration(
            context,
            accentColor: effectiveColor,
            radius: 22,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: effectiveColor.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: iconSize, color: effectiveColor),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              if (action != null) ...[const SizedBox(height: 20), action!],
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? retryButtonText;
  final EdgeInsetsGeometry? padding;

  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.retryButtonText = 'Retry',
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final danger = instrument.peakEffortColor;

    return Center(
      child: SingleChildScrollView(
        padding: padding ?? const EdgeInsets.all(24.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(24),
          decoration: InstrumentTheme.instrumentCardDecoration(
            context,
            accentColor: danger,
            radius: 22,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: danger.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_outline, size: 48, color: danger),
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 20),
                InstrumentActionButton(
                  label: retryButtonText ?? 'Retry',
                  icon: Icons.refresh,
                  variant: InstrumentActionVariant.destructive,
                  accentColor: danger,
                  onPressed: onRetry,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
