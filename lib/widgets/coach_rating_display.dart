import 'package:flutter/material.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';

class CoachRatingDisplay extends StatelessWidget {
  final double? averageRating;
  final int? reviewCount;
  final bool showCount;

  const CoachRatingDisplay({
    super.key,
    this.averageRating,
    this.reviewCount,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    if (averageRating == null || reviewCount == null || reviewCount == 0) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);

    return Wrap(
      spacing: 4,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _buildStarRating(context, averageRating!, instrument, scheme),
        Text(
          averageRating!.toStringAsFixed(1),
          style: InstrumentTheme.tabular(
            (theme.textTheme.labelLarge ?? const TextStyle()).copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
        ),
        if (showCount)
          Text(
            '($reviewCount)',
            style: InstrumentTheme.tabular(
              (theme.textTheme.labelSmall ?? const TextStyle()).copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStarRating(
    BuildContext context,
    double rating,
    InstrumentTheme instrument,
    ColorScheme scheme,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating - 0.5) {
          return Icon(
            Icons.star_rounded,
            color: instrument.stormAura,
            size: 16,
          );
        } else if (index < rating) {
          return Icon(
            Icons.star_half_rounded,
            color: instrument.stormAura,
            size: 16,
          );
        } else {
          return Icon(
            Icons.star_border_rounded,
            color: scheme.outlineVariant,
            size: 16,
          );
        }
      }),
    );
  }
}
