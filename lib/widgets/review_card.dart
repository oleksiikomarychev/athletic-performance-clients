import 'package:flutter/material.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/models/coach_review.dart';

class ReviewCard extends StatelessWidget {
  final CoachReview review;

  const ReviewCard({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final dims = UiDimensions.of(context);
    final hairline =
        (theme.brightness == Brightness.dark
                ? instrument.hairlineBorder
                : scheme.outlineVariant)
            .withValues(alpha: 0.65);

    final hasBody =
        (review.reviewerName != null &&
            review.reviewerName!.trim().isNotEmpty) ||
        (review.comment != null && review.comment!.trim().isNotEmpty);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        decoration: InstrumentTheme.instrumentCardDecoration(
          context,
          radius: 20,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.all(dims.cardPadding),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildStarRating(context, review.rating, instrument),
                      const SizedBox(width: 8),
                      Text(
                        review.rating.toString(),
                        style: InstrumentTheme.tabular(
                          (theme.textTheme.titleMedium ?? const TextStyle())
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _formatDate(review.createdAt),
                    style: InstrumentTheme.tabular(
                      (theme.textTheme.bodySmall ?? const TextStyle())
                          .copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
            if (hasBody) ...[
              Container(height: 1, color: hairline),
              Padding(
                padding: EdgeInsets.all(dims.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (review.reviewerName != null &&
                        review.reviewerName!.trim().isNotEmpty) ...[
                      Text(
                        'BY ${review.reviewerName!.toUpperCase()}',
                        style: InstrumentTheme.microLabel(context),
                      ),
                      if (review.comment != null &&
                          review.comment!.isNotEmpty)
                        const SizedBox(height: 6),
                    ],
                    if (review.comment != null && review.comment!.isNotEmpty)
                      Text(
                        review.comment!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface,
                          height: 1.35,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(
    BuildContext context,
    int rating,
    InstrumentTheme instrument,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating) {
          return Icon(
            Icons.star_rounded,
            color: instrument.stormAura,
            size: 18,
          );
        }
        return Icon(
          Icons.star_border_rounded,
          color: scheme.outlineVariant,
          size: 18,
        );
      }),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
