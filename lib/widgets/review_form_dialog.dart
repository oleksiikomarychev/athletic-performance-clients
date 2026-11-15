import 'package:flutter/material.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/widgets/instrument_modal.dart';

class ReviewFormDialog extends StatefulWidget {
  final int linkId;
  final String coachName;
  final Future<void> Function(int linkId, int rating, String? comment) onSubmit;

  const ReviewFormDialog({
    super.key,
    required this.linkId,
    required this.coachName,
    required this.onSubmit,
  });

  @override
  State<ReviewFormDialog> createState() => _ReviewFormDialogState();
}

class _ReviewFormDialogState extends State<ReviewFormDialog> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final instrument = InstrumentTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    return InstrumentDialog(
      eyebrow: 'COACH REVIEW',
      title: 'Review ${widget.coachName}',
      accentColor: instrument.stormAura,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RATING', style: InstrumentTheme.microLabel(context)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 2,
            runSpacing: 2,
            children: List.generate(5, (index) {
              final selected = index < _rating;
              return ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                child: IconButton(
                  tooltip: 'Rate ${index + 1} stars',
                  icon: Icon(
                    selected ? Icons.star_rounded : Icons.star_border_rounded,
                    color: selected
                        ? instrument.stormAura
                        : scheme.outlineVariant,
                    size: 28,
                  ),
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          setState(() {
                            _rating = index + 1;
                          });
                        },
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Text('COMMENT (OPTIONAL)', style: InstrumentTheme.microLabel(context)),
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            enabled: !_isSubmitting,
            maxLines: 3,
            maxLength: 5000,
            decoration: InstrumentTheme.inputDecoration(
              context,
              hintText: 'Share your experience...',
              radius: 12,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
      actions: [
        InstrumentActionButton(
          label: 'Cancel',
          variant: InstrumentActionVariant.secondary,
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
        ),
        InstrumentActionButton(
          label: 'Submit',
          variant: InstrumentActionVariant.primary,
          accentColor: instrument.stormAura,
          loading: _isSubmitting,
          onPressed: _rating == 0 || _isSubmitting ? null : _handleSubmit,
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.onSubmit(
        widget.linkId,
        _rating,
        _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
